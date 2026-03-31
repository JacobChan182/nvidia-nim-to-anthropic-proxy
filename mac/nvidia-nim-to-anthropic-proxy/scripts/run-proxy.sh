#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./scripts/run-proxy.sh [--config <path>] [--port <port>]

Notes:
  - Creates/uses ./.venv
  - Loads ./.env if present (KEY=VALUE lines)
EOF
}

CONFIG_PATH=""
PORT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --config) CONFIG_PATH="${2:-}"; shift 2 ;;
    --port) PORT="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 2 ;;
  esac
done

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${PROJECT_ROOT}"

if [[ -z "${CONFIG_PATH}" ]]; then
  CONFIG_PATH="${PROJECT_ROOT}/config.yaml"
elif [[ "${CONFIG_PATH}" != /* ]]; then
  CONFIG_PATH="${PROJECT_ROOT}/${CONFIG_PATH}"
fi

if [[ ! -f "${CONFIG_PATH}" ]]; then
  echo "Config not found: ${CONFIG_PATH}" >&2
  exit 1
fi

# Load .env into this process (optional)
ENV_PATH="${PROJECT_ROOT}/.env"
if [[ -f "${ENV_PATH}" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "${ENV_PATH}"
  set +a
fi

PYTHON_BIN="${PYTHON_BIN:-python3}"
VENV_DIR="${PROJECT_ROOT}/.venv"
VENV_PY="${VENV_DIR}/bin/python"

if [[ ! -x "${VENV_PY}" ]]; then
  "${PYTHON_BIN}" -m venv "${VENV_DIR}"
fi

"${VENV_PY}" -m pip install --upgrade pip >/dev/null
"${VENV_PY}" -m pip install -r "${PROJECT_ROOT}/requirements.txt" >/dev/null

export PYTHONIOENCODING="${PYTHONIOENCODING:-utf-8}"

echo "Starting LiteLLM proxy with config: ${CONFIG_PATH}"
ARGS=(--config "${CONFIG_PATH}")
if [[ -n "${PORT}" ]]; then
  ARGS+=(--port "${PORT}")
fi

exec "${VENV_PY}" "${PROJECT_ROOT}/scripts/run_litellm.py" "${ARGS[@]}"

