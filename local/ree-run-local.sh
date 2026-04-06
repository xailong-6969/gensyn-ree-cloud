#!/usr/bin/env bash
set -euo pipefail

REE_WORKDIR="${REE_WORKDIR:-/opt/ree-cloud}"
REE_HOST_CACHE="${REE_HOST_CACHE:-/workspace/.cache}"
REE_RECEIPTS_DIR="${REE_RECEIPTS_DIR:-/workspace/receipts}"

mkdir -p "${REE_HOST_CACHE}/gensyn" "${REE_RECEIPTS_DIR}"

cd "${REE_WORKDIR}"

set +e
python3 ree.py "$@"
status=$?
set -e

latest_receipt="$(find "${REE_HOST_CACHE}/gensyn" -name 'receipt_*.json' -print 2>/dev/null | sort | tail -1 || true)"
if [[ -n "${latest_receipt}" ]]; then
  receipt_basename="$(basename "${latest_receipt}")"
  cp -f "${latest_receipt}" "${REE_RECEIPTS_DIR}/${receipt_basename}"
  cp -f "${latest_receipt}" "${REE_RECEIPTS_DIR}/latest-receipt.json"
  printf 'Receipt: %s\n' "${latest_receipt}"
  printf 'Receipt copy: %s/%s\n' "${REE_RECEIPTS_DIR}" "${receipt_basename}"
  printf 'Latest receipt: %s/latest-receipt.json\n' "${REE_RECEIPTS_DIR}"
fi

exit "${status}"
