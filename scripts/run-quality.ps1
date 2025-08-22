Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "_global.ps1")
Push-RepoRoot "run-quality"
function Assert-LastExit([string]$step){ if ($LASTEXITCODE -ne 0) { throw "Non-zero exit in $step (exit=$LASTEXITCODE)" } }
try {
  & (Join-Path (Get-RepoRoot) "scripts\check-env.ps1")
  & (Join-Path (Get-RepoRoot) "scripts\check-locks.ps1")
  
  # UI: deps + lint + prettier
  $ui = Join-Path (Get-RepoRoot) "ui"
  if (Test-Path (Join-Path $ui "package.json")) {
    Push-Location $ui
    if (Test-Path "package-lock.json") { npm ci --no-audit --no-fund } else { npm install --no-audit --no-fund }
    Assert-LastExit "npm install/ci"
    npm run lint; Assert-LastExit "eslint"
    npm run format; Assert-LastExit "prettier check"
    Pop-Location
  }
  
  # Python: ensure deps + ruff/black/mypy/bandit + pytest
  $api = Join-Path (Get-RepoRoot) "backend\python"
  $venv = Join-Path $api ".venv\Scripts"
  & (Join-Path $venv "pip.exe") install -r (Join-Path $api "requirements.txt") | Out-Null
  & (Join-Path $venv "pip.exe") install -r (Join-Path $api "requirements-dev.txt") | Out-Null
  & (Join-Path $venv "ruff.exe") check $api; Assert-LastExit "ruff"
  & (Join-Path $venv "black.exe") --check $api; Assert-LastExit "black --check"
  & (Join-Path $venv "mypy.exe") --config-file (Join-Path $api "mypy.ini") $api; Assert-LastExit "mypy"
    Push-Location $api
  & (Join-Path $venv "bandit.exe") -q -r . -x ".venv,tests,__pycache__"
  Pop-Location
  if (Test-Path (Join-Path $api "tests")) {
    & (Join-Path $venv "pytest.exe") -q (Join-Path $api "tests"); Assert-LastExit "pytest"
  }
  
  # Build + API health
  & (Join-Path (Get-RepoRoot) "scripts\run-tests.ps1")
  if ($LASTEXITCODE -ne 0) { throw "run-tests.ps1 failed" }
  Write-Host "`nQUALITY: ALL GREEN" -ForegroundColor Green
  exit 0
} finally { Pop-RepoRoot }



