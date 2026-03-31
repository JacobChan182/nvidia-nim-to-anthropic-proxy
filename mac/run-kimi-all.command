#!/usr/bin/env bash
set -euo pipefail

# Single proxy exposing all 5 model aliases on one port.
# Model names: product-architect, backend, ios, android, qa

PROXY_PORT="${PROXY_PORT:-4010}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROXY_DIR="${SCRIPT_DIR}/nvidia-nim-to-anthropic-proxy"
ENV_FILE="${PROXY_DIR}/.env"

# Optional defaults (only applied if not already set by .env or your shell)
export ANTHROPIC_BASE_URL="${ANTHROPIC_BASE_URL:-http://127.0.0.1:${PROXY_PORT}}"
export ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-sk-llm-proxy-local}"
export ANTHROPIC_AUTH_TOKEN="${ANTHROPIC_AUTH_TOKEN:-$ANTHROPIC_API_KEY}"

cd "${PROXY_DIR}"

# Load .env into this process so the proxy sees env vars
if [[ -f "${ENV_FILE}" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
  set +a
fi

exec bash "./scripts/run-proxy.sh" --config "./config.all.yaml" --port "${PROXY_PORT}"

