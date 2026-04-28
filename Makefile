IMAGE_NAME ?= llm-playground
PORT ?= 8888

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Setup

.PHONY: sync
sync: ## Clean-sync the virtualenv with all dependencies (including optional)
	uv lock --upgrade
	uv sync --all-extras --reinstall

.PHONY: install
install: sync ## Sync dependencies and register Jupyter kernel
	uv run python -m ipykernel install --user --name llms-playground --display-name "LLMs Playground"

.PHONY: clean
clean: ## Clean build artifacts, caches, and virtual environment
	rm -rf .venv dist build *.egg-info
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name .ipynb_checkpoints -exec rm -rf {} + 2>/dev/null || true

##@ Run

.PHONY: notebook
notebook: install ## Start JupyterLab in the browser
	uv run jupyter lab --port=$(PORT) --no-browser --notebook-dir=.

##@ Docker

.PHONY: docker-build
docker-build: ## Build the Docker image
	docker build -t $(IMAGE_NAME) .

.PHONY: docker-run
docker-run: docker-build ## Build and run JupyterLab in Docker
	@docker stop $(IMAGE_NAME) 2>/dev/null || true
	docker run --rm -p $(PORT):8888 \
		--name $(IMAGE_NAME) \
		-v $(CURDIR)/notebooks:/home/playground/work/notebooks:rw \
		-v $(CURDIR)/models:/home/playground/work/models:rw \
		-v $(CURDIR)/vectordb:/home/playground/work/vectordb:rw \
		-v $(CURDIR)/.env:/home/playground/work/.env:ro \
		-v $(HOME)/.cliver:/home/playground/.cliver:ro \
		$(IMAGE_NAME)
