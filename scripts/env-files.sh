#!/bin/bash

function add-or-update-env-var {
    declare -r _ENV_KEY="$1"
    declare -r _ENV_VAL="$2"
    declare -r _ENV_FILE="$3"

    if [[ ! -e ${_ENV_FILE} ]]; then
        touch ${_ENV_FILE}
    fi

    if grep -q "^${_ENV_KEY}=" "${_ENV_FILE}"; then
        _KEY=$_ENV_KEY _VAL=$_ENV_VAL -pi -e 's/^\Q$ENV{_KEY}\E=.*/$ENV{_KEY}=$ENV{_VAL}/' "$_ENV_FILE"
    else
        echo "${_ENV_KEY}=${_ENV_VAL}" >> "${_ENV_FILE}"
    fi

}
