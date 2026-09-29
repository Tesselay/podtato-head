#!/bin/bash

SCRIPT_DIR=$(dirname -- "$(readlink -e -- "$0")")

declare -r CALL="$1"
declare -r CLUSTER_NAME="$2"
declare -r CLUSTER_NAMESPACE="$3"
declare -r MANIFEST_PATH="$4"
declare -r SERVER_ADDRESS="$5"
declare -r SERVER_PORT="$6"

function create-cluster {
    declare -r _CLUSTER_NAME="$1"

    if ! kubectl cluster-info --cluster "kind-$_CLUSTER_NAME" &> /dev/null; then
        kind create cluster --name "$_CLUSTER_NAME"
    fi

    kubectl cluster-info --cluster "kind-$_CLUSTER_NAME"
}

function apply-manifest {
    declare -r _CLUSTER_NAME="$1"
    declare -r _CLUSTER_NAMESPACE="$2"
    declare -r _MANIFEST_PATH="$3"

    if ! kubectl get pods --cluster "kind-$_CLUSTER_NAME" --namespace "$_CLUSTER_NAMESPACE" | grep "Running" &> /dev/null; then
        kubectl apply --cluster "kind-$_CLUSTER_NAME" -f "$_MANIFEST_PATH"
    fi
}

function forward-cluster {
    # kind requires port forwarding the load balancer on a single-machine-cluster
    declare -r _CLUSTER_NAME="$1"
    declare -r _CLUSTER_NAMESPACE="$2"
    declare -r _SRV_ADDR="$3"
    declare -r _SRV_PORT="$4"
    declare -r _MAX_WAIT=60
    declare _WAIT=0

    while [[ $(kubectl get pods --cluster "kind-$_CLUSTER_NAME" --namespace "$_CLUSTER_NAMESPACE" --field-selector="status.phase=Running" | grep -c "Running") != 6 ]] && (( $_WAIT < $_MAX_WAIT )); do
        sleep 1
        _WAIT=$((_WAIT + 1))
    done

    if (( $_WAIT >= $_MAX_WAIT )); then
        echo "Pods not up after $_MAX_WAIT seconds, something is wrong."
        return 1
    fi


    kubectl port-forward --cluster "kind-$_CLUSTER_NAME" --namespace "$_CLUSTER_NAMESPACE" --address "$_SRV_ADDR" svc/podtato-head-entry "${_SRV_PORT}:9000" &
}

function verify-cluster-state {
    declare -r _CLUSTER_NAME="$1"
    declare -r _CLUSTER_NAMESPACE="$2"
    declare -r _SRV_ADDRESS="$3"
    declare -r _SRV_PORT="$4"
    declare _STATE=0

    if [[ $(kubectl get pods --cluster "kind-$_CLUSTER_NAME" --namespace "$_CLUSTER_NAMESPACE" --field-selector="status.phase=Running" | grep -c "Running") == 6 ]]; then
        :
    else
        _STATE=1
    fi

    curl http://${_SRV_ADDRESS}:${_SRV_PORT}

    return $_STATE
}

function stop-forward {
    if pgrep "kubectl"; then
        pkill "kubectl"
    fi
}

function remove-cluster {
    declare -r _CLUSTER_NAME="$1"
    declare -r _MANIFEST_PATH="$2"

    kubectl delete --cluster "kind-$_CLUSTER_NAME" -f "$_MANIFEST_PATH"
    kind delete cluster --name "$_CLUSTER_NAME"
}


case $CALL in
    "CREATE")
        create-cluster "$CLUSTER_NAME"
        ;;
    "APPLY")
        apply-manifest "$CLUSTER_NAME" "$CLUSTER_NAMESPACE" "$MANIFEST_PATH"
        ;;
    "FORWARD")
        forward-cluster "$CLUSTER_NAME" "$CLUSTER_NAMESPACE" "$SERVER_ADDRESS" "$SERVER_PORT"
        ;;
    "TEST")
        verify-cluster-state "$CLUSTER_NAME" "$CLUSTER_NAMESPACE" "$SERVER_ADDRESS" "$SERVER_PORT"
        ;;
    "KILL")
        stop-forward
        ;;
    "REMOVE")
        remove-cluster "$CLUSTER_NAME" "$MANIFEST_PATH"
        ;;
    *)
        echo "Flag '$CALL' is not supported."
esac
