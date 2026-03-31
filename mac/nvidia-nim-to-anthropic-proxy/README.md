# NVIDIA NIM → Anthropic Proxy (macOS)

This folder mirrors the functional parts of `windows/` for macOS.

It runs a **LiteLLM Proxy** that exposes **Anthropic-compatible** endpoints (like `/v1/messages`) while routing to **NVIDIA NIM** backends.

## Prereqs

- macOS with `python3` available (3.9+ recommended)
- NVIDIA NIM API keys for the models you configure

## Setup

```bash
cd /path/to/Proxies/mac/nvidia-nim-to-anthropic-proxy
cp .env.example .env
# edit .env and set the NVIDIA_NIM_API_KEY_* values
```

## Run (all 5 model aliases)

From the `mac/` folder:

```bash
./run-kimi-all.command
```

Proxy default:

- Base URL: `http://127.0.0.1:4010`
- Auth: `Authorization: Bearer $LITELLM_MASTER_KEY`

Models exposed:

- `product-architect`
- `backend`
- `ios`
- `android`
- `qa`

## Configure Claude Code (in the same terminal session)

```bash
export ANTHROPIC_BASE_URL="http://127.0.0.1:4010"
export ANTHROPIC_API_KEY="sk-llm-proxy-local"
export ANTHROPIC_MODEL="product-architect"  # optional
claude -p "hello"
```

