"""Start LiteLLM proxy; avoids Windows console_scripts that pin a stale Python path."""
from litellm.proxy.proxy_cli import run_server

if __name__ == "__main__":
    run_server.main(standalone_mode=True)
