#!/bin/bash
# Shellscript for env var definition since bash is kinder with shell variables

declare -r AWS_CLI_PATH="$1"
declare -r AWS_ENV_PATH="$2"
declare GENERATE_KEY="${3:-false}"

declare -r UUID_REGEX="^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"

if [[ -e ${AWS_ENV_PATH} ]]; then
    declare -r ENV_KEYID=$(awk 'BEGIN{ FS = "="} /^AWS_KEYID_COSIGN/{ print $2 }' ${AWS_ENV_PATH})
    if [[ $ENV_KEYID =~ $UUID_REGEX ]]; then
        declare -r KEY_ENABLED=$(docker run --rm -it -v ./${AWS_CLI_PATH}:/root/.aws public.ecr.aws/aws-cli/aws-cli kms describe-key \
            --key-id $ENV_KEYID --query KeyMetadata.Enabled --no-cli-pager \
            | sed $'s/[^[:print:]\t]//g'
        )
        if $KEY_ENABLED; then
            echo "Key is good"
        else
            GENERATE_KEY=true
        fi
    else
        GENERATE_KEY=true
    fi
else
    GENERATE_KEY=true
fi

if $GENERATE_KEY; then
    declare -r AWS_KEYID_COSIGN="$(docker run --rm -it -v ./${AWS_CLI_PATH}:/root/.aws public.ecr.aws/aws-cli/aws-cli kms create-key \
        --key-spec RSA_4096 \
        --key-usage SIGN_VERIFY \
        --description "Cosign Signature Key Pair" \
        --query KeyMetadata.KeyId --output text --no-cli-pager \
        | sed $'s/[^[:print:]\t]//g'
    )"
    if [[ -e ${AWS_ENV_PATH} ]]; then
        _KEYID="$AWS_KEYID_COSIGN" perl -pi -e 's/^AWS_KEYID_COSIGN=.*/AWS_KEYID_COSIGN=$ENV{_KEYID}/' ${AWS_ENV_PATH}
    else
        echo "AWS_KEYID_COSIGN=$AWS_KEYID_COSIGN" > ${AWS_ENV_PATH}
    fi
fi
