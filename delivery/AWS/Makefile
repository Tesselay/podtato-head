# ----- Configuration ------------------------------------------------------------------
AWS_CLI_PATH     := CLI/.aws
AWS_ENV_PATH     := aws.env

BOOTSTRAP_SCRIPT := bootstrap.sh

# Allow absence on cold start as Make rereads this file after generating a target.
-include $(AWS_ENV_PATH)


# ----- Phony Targets ------------------------------------------------------------------
.PHONY: all bootstrap

all: bootstrap

bootstrap: $(AWS_ENV_PATH)


# ----- Bootstrap ----------------------------------------------------------------------
$(AWS_ENV_PATH): $(BOOTSTRAP_SCRIPT)
	./$(BOOTSTRAP_SCRIPT) $(AWS_CLI_PATH) $(AWS_ENV_PATH)
