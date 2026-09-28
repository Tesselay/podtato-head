# ----- Configuration ------------------------------------------------------------------
.DEFAULT_GOAL := run-local


# ----- Phony Targets ------------------------------------------------------------------
.PHONY: microservices build-microservices-images push-microservices-images test-microservices \
		server build-server-images push-server-images test-server \
		bootstrap install-requirements \
	 	run-local stop-local remove-local \
		test podtato-head-verify

bootstrap: install_requirements
microservices: build-microservices-images push-microservices-images test-microservices
server: build-server-images push-server-images test-server
test: podtato-head-verify


# ----- Bootstrap ----------------------------------------------------------------------
install-requirements:
	scripts/requirements.sh /usr/local/bin


# ----- Local --------------------------------------------------------------------------
run-local:
	$(MAKE) -C delivery/kind create
	$(MAKE) -C delivery/kind run-local

stop-local:
	$(MAKE) -C delivery/kind stop-local

remove-local:
	$(MAKE) -C delivery/kind stop-local remove


# ----- Microservices ------------------------------------------------------------------
podtato-head-verify:
	$(MAKE) -C podtato-head-microservices vet
	$(MAKE) -C podtato-head-microservices fmt
	$(MAKE) -C podtato-head-microservices test

build-microservices-images:
	podtato-head-microservices/build/build_images.sh "" "" "" \
		scratch ''
	podtato-head-microservices/build/build_images.sh "" "" "" \
		gcr.io/distroless/static:latest distroless
	podtato-head-microservices/build/build_images.sh "" "" "" \
		registry.access.redhat.com/ubi9/ubi-micro:latest ubi
	podtato-head-microservices/build/build_images.sh "" "" "" \
		distroless.dev/alpine-base:latest chainguard

push-microservices-images:
	podtato-head-microservices/build/build_images.sh "" "" "" \
		scratch '' true
	podtato-head-microservices/build/build_images.sh "" "" "" \
		gcr.io/distroless/static:latest distroless true
	podtato-head-microservices/build/build_images.sh "" "" "" \
		registry.access.redhat.com/ubi9/ubi-micro:latest ubi true
	podtato-head-microservices/build/build_images.sh "" "" "" \
		distroless.dev/alpine-base:latest chainguard true

test-microservices: push-microservices-images
# special build and tag for test images
	IMAGE_VERSION=test podtato-head-microservices/build/build_images.sh "" "" "" \
		scratch '' true
	IMAGE_VERSION=test scripts/test_with_kind.sh


# ----- Server -------------------------------------------------------------------------
build-server-images:
	podtato-head-server/build/build_image.sh '' '' '' \
		scratch '' false
	podtato-head-server/build/build_image.sh '' '' '' \
		gcr.io/distroless/static:latest distroless false
	podtato-head-server/build/build_image.sh '' '' '' \
		registry.access.redhat.com/ubi9/ubi-micro:latest ubi false
	podtato-head-server/build/build_image.sh '' '' '' \
		distroless.dev/alpine-base:latest chainguard false

push-server-images:
	podtato-head-server/build/build_image.sh '' '' '' \
		scratch '' true
	podtato-head-server/build/build_image.sh '' '' '' \
		gcr.io/distroless/static:latest distroless true
	podtato-head-server/build/build_image.sh '' '' '' \
		registry.access.redhat.com/ubi9/ubi-micro:latest ubi true
	podtato-head-server/build/build_image.sh '' '' '' \
		distroless.dev/alpine-base:latest chainguard true

test-server: push-server-images
	podtato-head-server/build/test_image.sh
	podtato-head-server/build/test_image.sh '' '' '' distroless
	podtato-head-server/build/test_image.sh '' '' '' ubi
	podtato-head-server/build/test_image.sh '' '' '' chainguard
