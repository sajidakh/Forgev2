Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "_global.ps1")
Push-RepoRoot "run-quality"

function Assert-LastExit([string]$step) { if ($LASTEXITCODE -ne 0) { throw "Non-zero exit in $step (exit=$LASTEXITCODE)" } }
try {
  # UI: ESLint + Prettier
  $ui = Join-Path (Get-RepoRoot) "ui"
  if (Test-Path (Join-Path $ui "package.json")) {
    Push-Location $ui
    npm ci --no-audit --no-fund
    Assert-LastExit "npm ci"
    npm run lint
    Assert-LastExit "eslint"
    npm run format
    Assert-LastExit "prettier check"
    Pop-Location
  }
  
  # Python: ruff + black --check + mypy + bandit
  $api = Join-Path (Get-RepoRoot) "backend\python"
  $venv = Join-Path $api ".venv\Scripts"
  & (Join-Path $venv "ruff.exe") check $api
  Assert-LastExit "ruff"
  & (Join-Path $venv "black.exe") --check $api
  Assert-LastExit "black --check"
  & (Join-Path $venv "mypy.exe") --config-file (Join-Path $api "mypy.ini") $api
  Assert-LastExit "mypy"
  & (Join-Path $venv "bandit.exe") -q -r $api -x (Join-Path $api ".venv")
  Assert-LastExit "bandit"
  
  # Build + API health (reuse gate)
  & (Join-Path (Get-RepoRoot) "scripts\run-tests.ps1")
  if ($LASTEXITCODE -ne 0) { throw "run-tests.ps1 failed" }
  
  Write-Host "`nQUALITY: ALL GREEN" -ForegroundColor Green
  exit 0
} finally { Pop-RepoRoot }
