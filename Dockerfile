FROM ubuntu:24.04 AS ree-wrapper

ARG DEBIAN_FRONTEND=noninteractive
ARG REE_REPO=https://github.com/gensyn-ai/ree.git
ARG REE_REF=560343c9771c3c9b4eac093b10756c4a9cf5747f

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

FROM gensynai/ree:v0.1.0@sha256:687b74da49bd8cf887c6c7802a7ff5ac5dca1e80a6c25bf799259bba0efe685e

USER root
WORKDIR /opt/ree-cloud

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates python3 python3-pip \
 && python3 -m pip install --no-cache-dir --break-system-packages --upgrade pip \
 && python3 -m pip install --no-cache-dir --break-system-packages "jupyterlab>=4,<5" "notebook>=7" \
 && python3 -c "import jupyterlab; print('jupyterlab', jupyterlab.__version__, 'OK')" \
 && rm -rf /var/lib/apt/lists/*

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

ENV PATH="/runtime/bin:${PATH}" \
    REE_CLOUD_MODE=1 \
    REE_HOST_CACHE=/workspace/.cache \
    REE_RUN_AS_USER=reecloud
