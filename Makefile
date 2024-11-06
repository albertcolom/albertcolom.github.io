.PHONY: help build serve

help: ## Show help
	@echo "\n\033[1mAvailable commands:\033[0m\n"
	@@awk 'BEGIN {FS = ":.*##";} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

build: ## Build a jekyll site
	@docker run --rm -v .:/srv/jekyll -it jekyll/jekyll jekyll build

serve: ## Serve a local website
	@docker run --rm -v .:/srv/jekyll -p 4000:4000 -it jekyll/jekyll jekyll serve
