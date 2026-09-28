# ----- Configuration ------------------------------------------------------------------
AWS_CLI_PATH     := CLI/.aws
ENV_PATH         := ../../.env

BOOTSTRAP_SCRIPT := bootstrap.sh

# Allow absence on cold start as Make rereads this file after generating a target.
-include $(ENV_PATH)


# ----- Phony Targets ------------------------------------------------------------------
.PHONY: all $(ENV_PATH)

all: $(ENV_PATH)


# ----- Bootstrap ----------------------------------------------------------------------
$(ENV_PATH):
	./$(BOOTSTRAP_SCRIPT) $(AWS_CLI_PATH) $(ENV_PATH)
