#!/usr/bin/env bash
set -euo pipefail

PYTHON="$(command -v python3)"

REE_WORKDIR="${REE_WORKDIR:-/opt/ree-cloud}"
REE_HOST_CACHE="${REE_HOST_CACHE:-/workspace/.cache}"
HF_HOME="${HF_HOME:-${REE_HOST_CACHE}/huggingface}"

mkdir -p /workspace/receipts
mkdir -p "${REE_HOST_CACHE}/gensyn"
mkdir -p "${HF_HOME}"

# ── Ensure reecloud user can write to workspace ───────────────────
RUN_USER="${REE_RUN_AS_USER:-reecloud}"
if [[ "$(id -u)" -eq 0 ]] && id -u "${RUN_USER}" >/dev/null 2>&1; then
  chown -R "${RUN_USER}:${RUN_USER}" /workspace 2>/dev/null || true
fi

export REE_CLOUD_MODE=1
export REE_HOST_CACHE
export HF_HOME
export TERM="${TERM:-xterm-256color}"

# ── Ensure /runtime/bin is on PATH (gensyn-sdk lives there) ───────
if [[ -d /runtime/bin ]] && [[ ":${PATH}:" != *":/runtime/bin:"* ]]; then
  export PATH="/runtime/bin:${PATH}"
fi

# ── Pre-install jupyterlab if missing ─────────────────────────────
# This shared entry-point is called by both vast-on-start.sh and
# quickpod-start.sh. Installing here ensures coverage regardless
# of which path is used.
if ! "${PYTHON}" -c "import jupyterlab" 2>/dev/null; then
  printf '[ree-cloud] jupyterlab not found – installing from shared entry-point …\n'
  "${PYTHON}" -m pip install --no-cache-dir --break-system-packages jupyterlab 2>&1 \
    || "${PYTHON}" -m pip install --no-cache-dir jupyterlab 2>&1 \
    || "${PYTHON}" -m pip install --no-cache-dir --user jupyterlab 2>&1 \
    || printf '[ree-cloud] WARNING: jupyterlab install failed (will retry in caller)\n'
fi

cat > /workspace/REE-GUIDE.txt <<EOF
Gensyn REE is ready.

Recommended flow inside the Jupyter terminal:
  python3 ree.py

If your terminal does not open in ${REE_WORKDIR}, run:
  cd ${REE_WORKDIR}
  python3 ree.py

Optional least-privilege launch:
  ${REE_WORKDIR}/run-ree-as-user.sh

Cache root:
  ${REE_HOST_CACHE}
EOF

printf 'REE environment prepared. Run `python3 ree.py` in the Jupyter terminal.\n'
printf 'For a non-root REE process, use `%s/run-ree-as-user.sh`.\n' "${REE_WORKDIR}"