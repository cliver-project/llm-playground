FROM python:3.13-slim AS builder

COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

WORKDIR /app
COPY pyproject.toml uv.lock README.md ./
COPY llmlib/ llmlib/

RUN uv export --no-dev --locked --no-hashes --no-emit-project -o requirements.txt
RUN uv build --wheel

FROM python:3.13-slim

COPY --from=builder /app/requirements.txt /tmp/
COPY --from=builder /app/dist/*.whl /tmp/

RUN pip install --no-cache-dir -r /tmp/requirements.txt /tmp/*.whl && \
    rm -f /tmp/requirements.txt /tmp/*.whl

RUN useradd -u 1000 -m -d /home/playground -s /bin/bash playground
USER 1000

WORKDIR /home/playground/work
COPY --chown=1000:1000 notebooks/ notebooks/
RUN mkdir -p models vectordb

ENV SENTENCE_TRANSFORMERS_HOME=/home/playground/work/models

VOLUME ["/home/playground/work/models", "/home/playground/work/vectordb"]

EXPOSE 8888

CMD ["jupyter", "lab", \
     "--ip=0.0.0.0", "--port=8888", "--no-browser", \
     "--ServerApp.token=''", \
     "--ServerApp.disable_check_xsrf=True", \
     "--notebook-dir=/home/playground/work"]
