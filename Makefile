.PHONY: help
help: ## this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
.DEFAULT_GOAL := help

GO_VERSION ?= %GO_VERSION%
APP_NAME ?= %APP_NAME%

GOTAG ?= $(GO_VERSION)-alpine
HOST_OS ?= $(shell uname -s | tr '[:upper:]' '[:lower:]')
HOST_ARCH ?= $(shell uname -m | sed -e 's/x86_64/amd64/' -e 's/aarch64/arm64/' -e 's/arm64/arm64/')
HOST_PLATFORM ?= $(HOST_OS)/$(HOST_ARCH)
GO_MOD_CACHE ?= $(APP_NAME)-go-mod-cache
GO_BUILD_CACHE ?= $(APP_NAME)-go-build-cache

.PHONY: clean
clean: ## remove built binaries
	@rm -f $(APP_NAME) $(APP_NAME)_dev

.PHONY: go
go: ## run go
	@docker run --rm -it \
		--workdir /code \
		--entrypoint go \
		-v $(shell pwd):/code \
		-v $(GO_MOD_CACHE):/go/pkg/mod \
		-v $(GO_BUILD_CACHE):/root/.cache/go-build \
		docker.io/golang:$(GOTAG) \
		$(args)

.PHONY: fmt
fmt: ## run go fmt
	@docker run --rm -it \
		--workdir /code \
		--entrypoint go \
		-v $(shell pwd):/code \
		-v $(GO_MOD_CACHE):/go/pkg/mod \
		-v $(GO_BUILD_CACHE):/root/.cache/go-build \
		docker.io/golang:$(GOTAG) \
		fmt

.PHONY: build
build: ## build a stripped linux/amd64 binary
	@docker buildx build . \
		--target final \
		--output type=local,dest=. \
		--build-arg GOTAG=$(GOTAG) \
		--build-arg APP_NAME=$(APP_NAME) \
		--platform linux/amd64 \
		$(args)

.PHONY: build_dev
build_dev: ## build a native binary in dev mode
	@docker buildx build . \
		--target final_dev \
		--output type=local,dest=. \
		--build-arg GOTAG=$(GOTAG) \
		--build-arg APP_NAME=$(APP_NAME) \
		--platform $(HOST_PLATFORM) \
		$(args)

.PHONY: run
run: build_dev ## run application in dev mode locally
	@./$(APP_NAME)_dev $(args)

