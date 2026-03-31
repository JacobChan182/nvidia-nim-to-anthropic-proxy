@echo off
setlocal

REM Single proxy exposing all 5 model aliases on one port.
REM Use model names: product-architect, backend, ios, android, qa

set "PROXY_PORT=4010"
REM Resolve proxy directory relative to this .bat file location.
REM %~dp0 expands to the drive+path of this script (trailing slash included).
set "PROXY_DIR=%~dp0nvidia-nim-to-anthropic-proxy"
set "ENV_FILE=%PROXY_DIR%\.env"

REM Optional defaults (only applied if not already set by .env or your shell)
if not defined ANTHROPIC_BASE_URL set "ANTHROPIC_BASE_URL=http://127.0.0.1:%PROXY_PORT%"
if not defined ANTHROPIC_API_KEY set "ANTHROPIC_API_KEY=sk-llm-proxy-local"
if not defined ANTHROPIC_AUTH_TOKEN set "ANTHROPIC_AUTH_TOKEN=%ANTHROPIC_API_KEY%"

cd /d "%PROXY_DIR%"

REM Load .env into *this* process so the proxy sees env vars.
REM Supports simple KEY=VALUE lines (ignores blank lines and # comments).
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$envFile = '%ENV_FILE%';" ^
  "if (Test-Path $envFile) {" ^
  "  Get-Content $envFile | ForEach-Object { $_.Trim() } | Where-Object { $_ -and -not $_.StartsWith('#') } | ForEach-Object {" ^
  "    $parts = $_ -split '=', 2;" ^
  "    if ($parts.Length -eq 2) { [System.Environment]::SetEnvironmentVariable($parts[0], $parts[1], 'Process') }" ^
  "  }" ^
  "}" ^
  "& powershell -NoProfile -ExecutionPolicy Bypass -File 'scripts\run-proxy.ps1' -ConfigPath 'config.all.yaml' -Port %PROXY_PORT%"

