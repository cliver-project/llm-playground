# LLM Playground

A playground for experimenting with LLM providers, powered by [CLIver](https://pypi.org/project/cliver/)'s AgentCore.

## Prerequisites

- Python 3.10+
- [uv](https://docs.astral.sh/uv/)
- A CLIver config at `~/.cliver/config.yaml` with at least one provider configured.
  A sample is provided — copy and edit it:
  ```bash
  mkdir -p ~/.cliver
  cp config.yaml.sample ~/.cliver/config.yaml
  ```
  Then set the API keys as environment variables (e.g. in your `.env` file):
  ```
  DEEPSEEK_API_KEY=sk-...
  OPENAI_API_KEY=sk-...
  ```

## Setup

```bash
make install
```

This installs all dependencies and registers a **"LLMs Playground"** Jupyter kernel.

## Usage

### In a notebook

```python
from llms_playground import get_agent

agent = get_agent(default_model="deepseek/deepseek-chat")
result = agent.chat("Hello!")
print(result)
```

### Run JupyterLab in browser

```bash
make notebook
```

Opens JupyterLab at http://localhost:8888. Select the **"LLMs Playground"** kernel when creating or opening a notebook.

### Run with Docker

```bash
make docker-run
```

Builds and runs a Docker container with JupyterLab at http://localhost:8888. Your `notebooks/` directory, `.env` file, and CLIver config are mounted automatically.

### VS Code

1. Install the **Jupyter** extension (`ms-toolsai.jupyter`) from the Extensions panel (`Cmd+Shift+X`)
2. Run `make install`
3. Reload the VS Code window (`Cmd+Shift+P` → "Developer: Reload Window")
4. Open a notebook and click the kernel picker (top right)
5. Choose **"Select Another Kernel..."** → **"Jupyter Kernel..."** → **"LLMs Playground"**

If the kernel doesn't appear, choose **"Python Environments..."** → select the `.venv` interpreter instead.

## Clean

```bash
make clean
```
