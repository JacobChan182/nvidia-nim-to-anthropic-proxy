param(
  [string]$ConfigPath = ""
)

$ProjectRoot = Split-Path $PSScriptRoot -Parent
if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
  $ConfigPath = Join-Path $ProjectRoot "config.yaml"
}

if (-Not (Test-Path $ConfigPath)) {
  throw "Config not found: $ConfigPath"
}

$PythonExe = Join-Path $ProjectRoot ".venv\Scripts\python.exe"
if (-Not (Test-Path $PythonExe)) {
  throw "Python venv not found. Create it in the project root: $PythonExe"
}

$envPath = Join-Path $ProjectRoot ".env"
if (Test-Path $envPath) {
  Get-Content $envPath | ForEach-Object {
    $line = $_.Trim()
    if ($line.Length -eq 0) { return }
    if ($line.StartsWith("#")) { return }
    $m = [regex]::Match($line, '^([A-Za-z_][A-Za-z0-9_]*)=(.*)$')
    if (-Not $m.Success) { return }

    $name = $m.Groups[1].Value
    $value = $m.Groups[2].Value.Trim()
    # Strip optional surrounding quotes
    if ($value.StartsWith('"') -and $value.EndsWith('"')) { $value = $value.Substring(1, $value.Length - 2) }
    if ($value.StartsWith("'") -and $value.EndsWith("'")) { $value = $value.Substring(1, $value.Length - 2) }

    [Environment]::SetEnvironmentVariable($name, $value, "Process")
  }
}

#
# LiteLLM prints a banner containing box-drawing chars (`█`). On Windows terminals
# using cp1252, this can crash startup with a UnicodeEncodeError.
# Force UTF-8 output so the proxy can boot reliably.
#
$env:PYTHONIOENCODING = "utf-8"

Write-Host "Starting LiteLLM proxy with config: $ConfigPath"
$runner = Join-Path $PSScriptRoot "run_litellm.py"
& $PythonExe $runner --config $ConfigPath

