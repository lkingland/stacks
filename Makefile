# Default to printing target help rather than an explicit target
.DEFAULT_GOAL := help

VTAG := $(shell git tag --points-at HEAD)
VERS := $(shell [ -z $(VTAG) ] && echo 'tip' || echo $(VTAG) )

# Include git mutation
COMMIT ?= true

all: vendor generate release## Run a complete versioning of the repo index.

vendor:  ## Updates the vendored build script create_codewind_index.py
	curl -o ./lib/create_codewind_index.py https://raw.githubusercontent.com/appsody/stacks/master/ci/create_codewind_index.py
	chmod +x ./lib/create_codewind_index.py

generate: ## Generate a repository inded file from the default .yaml (requires Python3)
	cp ~/.appsody/stacks/dev.local/boson-index.yaml .
	./lib/create_codewind_index.py -n "Boson" -f ./boson-index.yaml

release: ## Publish the stack index files as a release. (requires hub and the current commit tagged)
	hub release create -a boson-index.yaml -a boson-index.json -m '$(VERS)' $(VERS)

# Auto documenting help
# see http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'