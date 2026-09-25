#!/bin/bash
# Shellscript for env var definition since bash is kinder with shell variables

AWS_CLI_PATH="$1"
AWS_ENV_PATH="$2"

AWS_KEYID_COSIGN="$(docker run --rm -it -v ./${AWS_CLI_PATH}:/root/.aws public.ecr.aws/aws-cli/aws-cli kms create-key \
	    --key-spec RSA_4096 \
	    --key-usage SIGN_VERIFY \
	    --description "Cosign Signature Key Pair" \
	    --query KeyMetadata.KeyId --output text --no-cli-pager \
	)" \

if [[ -e ${AWS_ENV_PATH} ]]; then
    KEYID="$AWS_KEYID_COSIGN" perl -pi -e 's/^AWS_KEYID_COSIGN=.*/AWS_KEYID_COSIGN=$ENV{KEYID}/' ${AWS_ENV_PATH}
else
    echo "AWS_KEYID_COSIGN=$AWS_KEYID_COSIGN" > ${AWS_ENV_PATH}
fi
