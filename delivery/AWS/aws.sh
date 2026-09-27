#!/bin/bash

declare -r UUID_REGEX="^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"

function verify-aws-key {
    declare -r _KEY="$1"
    declare -r _AWS_CLI_PATH="$2"
    declare _KEY_REGEX_STATUS=false
    declare _KEY_ATTR_ENABLED=false

    if [[ $_KEY =~ $UUID_REGEX ]]; then
        _KEY_REGEX_STATUS=true

        _KEY_ATTR_ENABLED=$(docker run --rm -it -v \
            ./${_AWS_CLI_PATH}:/root/.aws public.ecr.aws/aws-cli/aws-cli kms describe-key \
            --key-id "$_KEY" --query KeyMetadata.Enabled --no-cli-pager \
            | sed $'s/[^[:print:]\t]//g'
        )
    fi

    if $_KEY_REGEX_STATUS $_KEY_ATTR_ENABLED; then
        return 0
    else
        return 1
    fi
}
