Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "_global.ps1")
Push-RepoRoot "run-quality"
function Assert-LastExit([string]$step){ if ($LASTEXITCODE -ne 0) { throw "Non-zero exit in $step (exit=$LASTEXITCODE)" } }
try {
$env:PYTEST_DISABLE_PLUGIN_AUTOLOAD = '1'
 -q
  }
  
  # Build + API health
  & (Join-Path (Get-RepoRoot) "scripts\run-tests.ps1")
  if ($LASTEXITCODE -ne 0) { throw "run-tests.ps1 failed" }
  Write-Host "`nQUALITY: ALL GREEN" -ForegroundColor Green
  exit 0
} finally { Pop-RepoRoot }





