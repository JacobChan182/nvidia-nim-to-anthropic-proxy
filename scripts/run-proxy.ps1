param(
  [string]$ConfigPath = "c:\Users\Jacob\Desktop\Projects\claude\config.yaml"
)

if (-Not (Test-Path $ConfigPath)) {
  throw "Config not found: $ConfigPath"
}

$envPath = "c:\Users\Jacob\Desktop\Projects\claude\.env"
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
litellm --config $ConfigPath

