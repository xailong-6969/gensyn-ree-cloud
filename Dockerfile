FROM ubuntu:24.04 AS ree-wrapper

ARG DEBIAN_FRONTEND=noninteractive
ARG REE_REPO=https://github.com/gensyn-ai/ree.git
ARG REE_REF=8fb1fdbdbd09a0c09f6a2da6053b93ddbeb2d53e

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates git patch \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
RUN git clone "${REE_REPO}" ree \
 && cd /tmp/ree \
 && git checkout "${REE_REF}"

COPY diffs/ree-cloud-adapter.diff /tmp/ree-cloud-adapter.diff
RUN cd /tmp/ree \
 && patch -p1 < /tmp/ree-cloud-adapter.diff \
 && chmod +x ree.py ree.sh

FROM gensynai/ree:v0.4.0@sha256:e45039f1509dcf11c8cc3c65457c924f38a68b1f2b8a9357942c2c57c0d89b1d

USER root
WORKDIR /opt/ree-cloud

RUN /usr/bin/python3.11 -m venv /opt/jupyter-venv \
 && /opt/jupyter-venv/bin/python -m pip install --no-cache-dir --upgrade pip \
 && /opt/jupyter-venv/bin/python -m pip install --no-cache-dir "jupyterlab>=4,<5" "notebook>=7" \
 && /opt/jupyter-venv/bin/python -c "import jupyterlab; print('jupyterlab', jupyterlab.__version__, 'OK')"

COPY --from=ree-wrapper /tmp/ree/ /opt/ree-cloud/
COPY jupyter-on-start.sh /opt/ree-cloud/jupyter-on-start.sh
COPY quickpod-start.sh /opt/ree-cloud/quickpod-start.sh
COPY vast-on-start.sh /opt/ree-cloud/vast-on-start.sh
COPY run-ree-as-user.sh /opt/ree-cloud/run-ree-as-user.sh
RUN if ! id -u reecloud >/dev/null 2>&1; then useradd -m -s /bin/bash reecloud; fi \
 && mkdir -p /workspace \
 && chown -R reecloud:reecloud /opt/ree-cloud /workspace \
 && chmod +x /opt/ree-cloud/jupyter-on-start.sh /opt/ree-cloud/quickpod-start.sh /opt/ree-cloud/vast-on-start.sh /opt/ree-cloud/run-ree-as-user.sh \
 && printf '#!/bin/sh\nexport PATH="/runtime/bin:${PATH}"\n' > /etc/profile.d/runtime-bin.sh \
 && chmod +x /etc/profile.d/runtime-bin.sh

ENV PATH="/opt/jupyter-venv/bin:/runtime/bin:${PATH}" \
    REE_CLOUD_MODE=1 \
    REE_HOST_CACHE=/workspace/.cache \
    REE_RUN_AS_USER=reecloud
