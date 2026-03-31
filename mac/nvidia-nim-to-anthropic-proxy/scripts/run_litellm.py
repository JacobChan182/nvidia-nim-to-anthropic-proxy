"""Start LiteLLM proxy; avoids shell entrypoint path issues."""
from litellm.proxy.proxy_cli import run_server

if __name__ == "__main__":
    run_server.main(standalone_mode=True)

