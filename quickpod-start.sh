#!/usr/bin/env bash
set -euo pipefail

PYTHON="$(command -v python3)"

/opt/ree-cloud/jupyter-on-start.sh

# ── Ensure jupyterlab is available at runtime ──────────────────────
# QuickPod may overlay its own Python environment, so the jupyterlab
# installed at Docker-build time might not be visible.
ensure_jupyterlab() {
  if ! "${PYTHON}" -c "import jupyterlab" 2>/dev/null; then
    printf '[ree-cloud] jupyterlab not found – attempting install …\n'
    "${PYTHON}" -m pip install --no-cache-dir --break-system-packages jupyterlab 2>&1 \
      || "${PYTHON}" -m pip install --no-cache-dir jupyterlab 2>&1 \
      || "${PYTHON}" -m pip install --no-cache-dir --user jupyterlab 2>&1 \
      || printf '[ree-cloud] WARNING: all pip install attempts failed\n'
  fi
}
ensure_jupyterlab

JUPYTER_PORT="${JUPYTER_PORT:-8080}"
JUPYTER_TOKEN="${JUPYTER_TOKEN:-$("${PYTHON}" -c 'import secrets; print(secrets.token_urlsafe(24))')}"
JUPYTER_URL="http://${PUBLIC_IPADDR:-127.0.0.1}:${QUICKPOD_PORT_8080:-$JUPYTER_PORT}/lab?token=${JUPYTER_TOKEN}"
RUN_AS_USER="${REE_RUN_AS_USER:-reecloud}"

cat > /workspace/JUPYTER-INFO.txt <<EOF
QuickPod JupyterLab is starting.

Port:
  ${JUPYTER_PORT}

Access URL:
  ${JUPYTER_URL}

Token:
  ${JUPYTER_TOKEN}

Inside JupyterLab, open a terminal and run:
  python3 ree.py

Optional least-privilege launch:
  /opt/ree-cloud/run-ree-as-user.sh
EOF

printf 'QuickPod JupyterLab URL: %s\n' "${JUPYTER_URL}"
printf 'QuickPod JupyterLab token: %s\n' "${JUPYTER_TOKEN}"

# ── Final validation: fall back to direct ree.py if Jupyter is gone ─
if ! "${PYTHON}" -c "import jupyterlab" 2>/dev/null; then
  printf '\n[ree-cloud] ╔══════════════════════════════════════════════════╗\n'
  printf '[ree-cloud] ║  JupyterLab unavailable after all install tries. ║\n'
  printf '[ree-cloud] ║  Falling back to running ree.py directly.        ║\n'
  printf '[ree-cloud] ╚══════════════════════════════════════════════════╝\n\n'
  cd /opt/ree-cloud
  exec "${PYTHON}" ree.py
fi
# ── Auto-create terminal + delayed banner ─────────────────────────
auto_create_terminal_and_banner() {
  # Wait for Jupyter to be ready
  for i in $(seq 1 30); do
    if curl -s -o /dev/null -w '%{http_code}' \
         "http://localhost:${JUPYTER_PORT}/api/status?token=${JUPYTER_TOKEN}" 2>/dev/null \
       | grep -q '200'; then
      break
    fi
    sleep 1
  done

  # Create a terminal session so /terminals/1 exists
  curl -s -X POST "http://localhost:${JUPYTER_PORT}/api/terminals?token=${JUPYTER_TOKEN}" \
    -H 'Content-Type: application/json' > /dev/null 2>&1 || true

  TERMINAL_URL="http://${PUBLIC_IPADDR:-127.0.0.1}:${QUICKPOD_PORT_8080:-$JUPYTER_PORT}/terminals/1?token=${JUPYTER_TOKEN}"

  printf '\n'
  printf '╔════════════════════════════════════════════════════════════╗\n'
  printf '║            QuickPod Jupyter Terminal Ready!              ║\n'
  printf '╠════════════════════════════════════════════════════════════╣\n'
  printf '║                                                          ║\n'
  printf '║  Terminal: %-45s║\n' "${TERMINAL_URL}"
  printf '║  Token:    %-45s║\n' "${JUPYTER_TOKEN}"
  printf '║                                                          ║\n'
  printf '║  In the terminal, run:                                   ║\n'
  printf '║    python3 ree.py                                        ║\n'
  printf '║                                                          ║\n'
  printf '╚════════════════════════════════════════════════════════════╝\n'
  printf '\n'
}

JUPYTER_CMD=(
  "${PYTHON}" -m jupyterlab
  --ServerApp.ip=0.0.0.0
  --ServerApp.port="${JUPYTER_PORT}"
  --ServerApp.root_dir=/opt/ree-cloud
  --ServerApp.token="${JUPYTER_TOKEN}"
  --ServerApp.allow_remote_access=True
  --no-browser
)

if [[ "$(id -u)" -eq 0 ]] && id -u "${RUN_AS_USER}" >/dev/null 2>&1; then
  # Ensure jupyterlab is also visible to the non-root user's Python path
  su -s /bin/bash "${RUN_AS_USER}" -c "${PYTHON} -c 'import jupyterlab' 2>/dev/null || ${PYTHON} -m pip install --no-cache-dir --break-system-packages jupyterlab notebook 2>&1 || ${PYTHON} -m pip install --no-cache-dir --user jupyterlab notebook 2>&1 || true"
  printf -v JUPYTER_CMD_STR '%q ' "${JUPYTER_CMD[@]}"
  auto_create_terminal_and_banner &
  exec su -s /bin/bash "${RUN_AS_USER}" -c "export HOME=/home/${RUN_AS_USER}; exec ${JUPYTER_CMD_STR}"
fi

auto_create_terminal_and_banner &
exec "${JUPYTER_CMD[@]}"

