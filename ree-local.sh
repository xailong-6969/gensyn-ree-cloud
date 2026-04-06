#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
TOOLS_DIR="${SCRIPT_DIR}/local"

IMAGE="${REE_LOCAL_IMAGE:-xailong6969/gensyn-ree-cloud:latest}"
CACHE_DIR="${REE_LOCAL_CACHE_DIR:-${SCRIPT_DIR}/.ree-local/cache}"
RECEIPTS_DIR="${REE_LOCAL_RECEIPTS_DIR:-${SCRIPT_DIR}/receipts}"

mkdir -p "${CACHE_DIR}" "${RECEIPTS_DIR}"

GPU_ARGS=()
if command -v nvidia-smi >/dev/null 2>&1; then
  GPU_ARGS=(--gpus all)
fi

docker pull "${IMAGE}"

exec docker run --rm -it \
  "${GPU_ARGS[@]}" \
  -e REE_DIRECT_MODE=1 \
  -e REE_CLOUD_MODE=1 \
  -e REE_HOST_CACHE=/workspace/.cache \
  -e REE_RECEIPTS_DIR=/workspace/receipts \
  -v "${CACHE_DIR}:/workspace/.cache" \
  -v "${RECEIPTS_DIR}:/workspace/receipts" \
  -v "${TOOLS_DIR}:/opt/ree-local-tools:ro" \
  --workdir /opt/ree-cloud \
  --entrypoint /bin/bash \
  "${IMAGE}" \
  --rcfile /opt/ree-local-tools/ree-local-bashrc -i
