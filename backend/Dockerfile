# ChatDev (DevAll) backend: FastAPI workflow server from the pinned upstream release.
# Upstream publishes no image, so we build the release tag and check its commit.
ARG CHATDEV_REF=v2.2.0
ARG CHATDEV_COMMIT=3c72d860d2553f05129b7dff0fd4efdde5b01d2f

FROM alpine/git:v2.54.1@sha256:29cff25811f790b9f72fc266bf8009a5a911714c0e03c31c47339c50909d9aef AS src
ARG CHATDEV_REF
ARG CHATDEV_COMMIT
RUN git clone --quiet --depth 1 --branch "$CHATDEV_REF" https://github.com/OpenBMB/ChatDev /src \
 && test "$(git -C /src rev-parse HEAD)" = "$CHATDEV_COMMIT" \
 && rm -r /src/.git /src/assets /src/frontend /src/docs

FROM python:3.12.16-slim-bookworm@sha256:935c3c5b12357a7e10caa9c1e6ca5692344d97cf229832ef584be2cec9fc03df AS builder
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends pkg-config build-essential libcairo2-dev \
 && rm -r /var/lib/apt/lists/*
RUN pip install --no-cache-dir uv==0.13.9
ENV UV_PROJECT_ENVIRONMENT=/opt/venv UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy
WORKDIR /app
COPY --from=src /src/pyproject.toml /src/uv.lock ./
RUN uv sync --no-cache --frozen --no-install-project --no-dev

FROM python:3.12.16-slim-bookworm@sha256:935c3c5b12357a7e10caa9c1e6ca5692344d97cf229832ef584be2cec9fc03df
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends libcairo2 curl \
 && rm -r /var/lib/apt/lists/* \
 && useradd -m -u 1000 appuser
COPY --from=builder /opt/venv /opt/venv
COPY --from=builder /usr/local/bin/uv /usr/local/bin/uvx /usr/local/bin/
WORKDIR /app
COPY --from=src /src/ /app/
# Keep the shipped workflows and built-in tools as defaults; the start script
# links the live copies to the volume.
RUN mkdir -p /opt/chatdev-defaults \
 && mv /app/yaml_instance /opt/chatdev-defaults/yaml_instance \
 && mv /app/functions/function_calling /opt/chatdev-defaults/function_calling \
 && chown -R appuser:appuser /app
COPY start.sh /usr/local/bin/chatdev-start
RUN chmod 0755 /usr/local/bin/chatdev-start
ENV PATH="/opt/venv/bin:${PATH}" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=6400 \
    CHATDEV_DATA_DIR=/data \
    OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1 NUMEXPR_MAX_THREADS=1 \
    MPLBACKEND=Agg
EXPOSE 6400
CMD ["/usr/local/bin/chatdev-start"]
