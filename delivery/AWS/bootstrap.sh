#!/bin/bash
# Shellscript for env var definition since bash is kinder with shell variables

SCRIPT_DIR=$(dirname -- "$(readlink -e -- "$0")")
source "$SCRIPT_DIR/../../scripts/env-files.sh"
source "$SCRIPT_DIR/aws.sh"

touch "$SCRIPT_DIR/aws.env"
source "$SCRIPT_DIR/aws.env"

declare -r AWS_CLI_PATH="$1"
declare -r AWS_ENV_PATH="$2"

if ! verify-aws-key "$AWS_KEYID_COSIGN" "$AWS_CLI_PATH"; then
    declare -r _AWS_KEYID_COSIGN="$(docker run --rm -it -v ./${AWS_CLI_PATH}:/root/.aws public.ecr.aws/aws-cli/aws-cli kms create-key \
        --key-spec RSA_4096 \
        --key-usage SIGN_VERIFY \
        --description "Cosign Signature Key Pair" \
        --query KeyMetadata.KeyId --output text --no-cli-pager \
        | sed $'s/[^[:print:]\t]//g'
    )"
    add-or-update-env-var "AWS_KEYID_COSIGN" "$_AWS_KEYID_COSIGN" "${AWS_ENV_PATH}"
    add-or-update-env-var "COSIGN_KEY_PATH" "awskms:///$_AWS_KEYID_COSIGN" "${AWS_ENV_PATH}"
fi
