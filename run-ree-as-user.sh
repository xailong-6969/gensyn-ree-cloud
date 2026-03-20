#!/usr/bin/env bash
set -euo pipefail

REE_WORKDIR="${REE_WORKDIR:-/opt/ree-cloud}"
REE_HOST_CACHE="${REE_HOST_CACHE:-/workspace/.cache}"
HF_HOME="${HF_HOME:-${REE_HOST_CACHE}/huggingface}"
TARGET_USER="${REE_RUN_AS_USER:-reecloud}"

mkdir -p /workspace/receipts
mkdir -p "${REE_HOST_CACHE}/gensyn"
mkdir -p "${HF_HOME}"

export REE_CLOUD_MODE=1
export REE_HOST_CACHE
export HF_HOME
export TERM="${TERM:-xterm-256color}"

run_cmd="cd '${REE_WORKDIR}' && export REE_CLOUD_MODE=1 REE_HOST_CACHE='${REE_HOST_CACHE}' HF_HOME='${HF_HOME}' TERM='${TERM}' && exec python3 ree.py"

if [[ "$(id -u)" -eq 0 ]] && id -u "${TARGET_USER}" >/dev/null 2>&1; then
  chown -R "${TARGET_USER}:${TARGET_USER}" "${REE_WORKDIR}" /workspace/receipts "${REE_HOST_CACHE}" 2>/dev/null || true
  exec su -s /bin/bash -c "${run_cmd}" "${TARGET_USER}"
fi

exec bash -lc "${run_cmd}"