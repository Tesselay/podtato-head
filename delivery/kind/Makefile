# ----- Configuration ------------------------------------------------------------------
CLUSTER_NAME      := local
CLUSTER_NAMESPACE := podtato-kubectl
MANIFEST_PATH     := ../kubectl/manifest.yaml
SERVER_ADDRESS    := 127.0.0.1
SERVER_PORT       := 9000


# ----- Phony Targets ------------------------------------------------------------------
.PHONY: create-cluster apply-manifest forward-load-balancer stop-forward verify-cluster-state \
	    create run-local test-local stop-local

create: create-cluster apply-manifest
run-local: forward-load-balancer
test-local: verify-cluster-state
stop-local: stop-forward


# ----- Recipes ------------------------------------------------------------------------
create-cluster:
	./kind.sh "CREATE" $(CLUSTER_NAME)

apply-manifest:
	./kind.sh "APPLY" $(CLUSTER_NAME) $(CLUSTER_NAMESPACE) $(MANIFEST_PATH)

forward-load-balancer:
	./kind.sh "FORWARD" $(CLUSTER_NAME) $(CLUSTER_NAMESPACE) "" $(SERVER_ADDRESS) $(SERVER_PORT)

verify-cluster-state:
	./kind.sh "TEST" $(CLUSTER_NAME) $(CLUSTER_NAMESPACE) "" $(SERVER_ADDRESS) $(SERVER_PORT)

stop-forward:
	./kind.sh "KILL"

remove:
	./kind.sh "REMOVE" $(CLUSTER_NAME) "" $(MANIFEST_PATH)
