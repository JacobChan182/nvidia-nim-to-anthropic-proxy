# Claude Code → NVIDIA Kimi (moonshotai/kimi-k2.5) via LiteLLM Proxy

This repo is a minimal bridge so **Claude Code** (which speaks Anthropic's `/v1/messages` format) can call **NVIDIA's NIM endpoint** for `moonshotai/kimi-k2.5`.

It uses **LiteLLM Proxy** as the protocol translator/gateway.

## Files

- `config.yaml` routes `kimi-k2.5-nvidia` → `nvidia_nim/moonshotai/kimi-k2.5`
- `.env.example` contains the required `NVIDIA_NIM_API_KEY`
- `.gitignore` ignores secrets and venv

## Prerequisites

- Python 3.9+ and `pip`
- An NVIDIA API key for the `moonshotai/kimi-k2.5` model in the NVIDIA API catalog (from `https://build.nvidia.com/moonshotai/kimi-k2.5`)
- Port `4000` available locally

## Setup (PowerShell)

1. Create and activate a virtual environment

```powershell
cd "c:\Users\PROJECT_ROOT"
python -m venv .venv
.\.venv\Scripts\Activate.ps1
```

2. Install dependencies

```powershell
pip install -r requirements.txt
```

3. Configure env vars

```powershell
copy .env.example .env
# Edit .env and set NVIDIA_NIM_API_KEY=...
```

## Run the proxy

In the same terminal (with the venv activated):

```powershell
$env:PYTHONIOENCODING="utf-8"
litellm --config "c:\Users\PROJECT_ROOT\config.yaml"
```

The proxy listens on `http://127.0.0.1:4000` by default.

## Smoke test with Python

```powershell
python -c "import json,urllib.request; url='http://127.0.0.1:4000/v1/messages'; body={'model':'kimi-k2.5-nvidia','max_tokens':64,'messages':[{'role':'user','content':'Say hello in one sentence.'}]}; headers={'Content-Type':'application/json','Authorization':'Bearer sk-llm-proxy-local','anthropic-version':'2023-06-01','anthropic-beta':'token-counting-2024-11-01'}; data=json.dumps(body).encode('utf-8'); req=urllib.request.Request(url,data=data,headers=headers,method='POST'); print(urllib.request.urlopen(req).read().decode('utf-8'))"
```

## Configure Claude Code

In PowerShell:

```powershell
$env:ANTHROPIC_BASE_URL="http://127.0.0.1:4000"
$env:ANTHROPIC_AUTH_TOKEN="sk-llm-proxy-local"
```

Then start Claude Code with the model alias:

```powershell
claude --model kimi-k2.5-nvidia
```

## Notes / limitations

- “Free” access is dependent on NVIDIA’s catalog/trial terms and rate limits; this bridge is only the wiring layer.
- Claude Code tool use is best-effort with non-Anthropic models behind a proxy; if tool-calling fails, try simpler prompts or switch to the Ollama flow.
- LiteLLM itself is third-party software. If you are security-sensitive, audit your dependency versions and review LiteLLM security guidance.

