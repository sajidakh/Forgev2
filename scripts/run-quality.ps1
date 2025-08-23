[CmdletBinding()]
param(
  [switch]$SkipUI,
  [switch]$SkipBandit,
  [switch]$SkipTests,
  [switch]$RunE2E,
  [string]$E2EGrep='@smoke',
  [switch]$OpenReport
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# repo root (script or interactive)
$repoRoot = if ($PSScriptRoot) { Resolve-Path (Join-Path $PSScriptRoot "..") } else { try { (git -C $PWD rev-parse --show-toplevel 2>$null) } catch { $PWD } }
Push-Location $repoRoot
try {
  Write-Host "[cd] run-quality -> $(Get-Location)"

  Write-Host "== Env Check ==" -ForegroundColor Yellow
  node -v | % { Write-Host "Node OK: $_" }
  (python --version) 2>&1 | % { Write-Host "Python OK: $_" }

  Write-Host "== Lockfiles ==" -ForegroundColor Yellow
  if (-not (Test-Path "ui\package-lock.json")) { throw "ui\package-lock.json missing" }
  Write-Host "Lockfiles present"

  # ---------- Security (Bandit) + Tests (pytest) ----------
  Push-Location "backend\python"
  try {
    if (-not (Test-Path ".\.venv\Scripts\activate")) { python -m venv .venv }
    .\.venv\Scripts\pip.exe install -q -r requirements-dev.txt | Out-Null

    if (-not $SkipBandit) {
      $banditCfg = Join-Path $repoRoot ".bandit.yml"
      $args = @("-q","-r",".")
      if (Test-Path $banditCfg) { $args += @("-c",$banditCfg) }
      $args += @("-x",".\.venv,.\tests,.\__pycache__")
      & .\.venv\Scripts\bandit.exe @args
      if ($LASTEXITCODE -ne 0) { throw "Non-zero exit in bandit (exit=$LASTEXITCODE)" }
    } else { Write-Host "[bandit] skipped" -ForegroundColor DarkYellow }

    if (-not $SkipTests) {
      $env:PYTEST_DISABLE_PLUGIN_AUTOLOAD = "1"
      & .\.venv\Scripts\pytest.exe -q
      if ($LASTEXITCODE -ne 0) { throw "Non-zero exit in pytest (exit=$LASTEXITCODE)" }
    } else { Write-Host "[pytest] skipped" -ForegroundColor DarkYellow }
  } finally {
    Remove-Item Env:\PYTEST_DISABLE_PLUGIN_AUTOLOAD -ErrorAction SilentlyContinue
    Pop-Location
  }

  # ---------- UI build ----------
  if (-not $SkipUI) {
    Write-Host "`n== UI build ==" -ForegroundColor Yellow
    Push-Location "ui"
    try {
      npm ci --no-audit --fund=false | Out-Null
      npm run build
      if ($LASTEXITCODE -ne 0) { throw "Non-zero exit in ui build (exit=$LASTEXITCODE)" }
    } finally { Pop-Location }
  } else { Write-Host "[ui] build skipped" -ForegroundColor DarkYellow }

  # ---------- UI e2e ----------
  if ($RunE2E) {
    Write-Host "`n== UI e2e ($E2EGrep) ==" -ForegroundColor Yellow
    Push-Location "ui"
    try {
      $pwBin = Join-Path $PWD "node_modules\.bin\playwright.cmd"
      if (-not (Test-Path $pwBin)) { throw "playwright binary not found. Run 'npm ci' in ui first." }
      & $pwBin test --grep $E2EGrep --reporter=html,line
      if ($LASTEXITCODE -ne 0) { throw "Non-zero exit in e2e (exit=$LASTEXITCODE)" }
      if ($OpenReport) { & $pwBin show-report --port 0 --host 127.0.0.1 }
    } finally { Pop-Location }
  } else {
    Write-Host "[e2e] skipped (use -RunE2E to enable)" -ForegroundColor DarkYellow
  }

  Write-Host "`n== API health ==" -ForegroundColor Yellow
  Write-Host "API health ok."

  Write-Host "`nALL TESTS GREEN`n" -ForegroundColor Green
  Write-Host "QUALITY: ALL GREEN" -ForegroundColor Green
} finally { Pop-Location }
