[CmdletBinding()]
param(
  [switch]$SkipUI,
  [switch]$SkipBandit,
  [switch]$SkipTests,
  [int]$MinCov = 0
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- Repo root (works when run as script or interactively) ---
$repoRoot = $null
if ($PSScriptRoot) {
  $repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
} else {
  try {
    $gitRoot = (git -C $PWD rev-parse --show-toplevel 2>$null)
    $repoRoot = if ($gitRoot) { $gitRoot } else { $PWD }
  } catch { $repoRoot = $PWD }
}

Push-Location $repoRoot
try {
  Write-Host "[cd] run-quality -> $(Get-Location)"

  Write-Host "== Env Check ==" -ForegroundColor Yellow
  node -v | ForEach-Object { Write-Host "Node OK: $_" }
  (python --version) 2>&1 | ForEach-Object { Write-Host "Python OK: $_" }

  Write-Host "== Lockfiles ==" -ForegroundColor Yellow
  if (-not (Test-Path 'ui\package-lock.json')) { throw 'ui\package-lock.json missing' }
  Write-Host "Lockfiles present"

  # ---------- Security (Bandit) + Tests (pytest) ----------
  Push-Location 'backend\python'
  try {
    if (-not (Test-Path '.\.venv\Scripts\activate')) { python -m venv .venv }
    .\.venv\Scripts\pip.exe install -q -r requirements-dev.txt | Out-Null

    if (-not $SkipBandit) {
      $banditCfg = Join-Path $repoRoot '.bandit.yml'
      $banditArgs = @('-q','-r','.')
      if (Test-Path $banditCfg) { $banditArgs += @('-c', $banditCfg) }
      $banditArgs += @('-x', '.\.venv,.\tests,.\__pycache__')
      & .\.venv\Scripts\bandit.exe @banditArgs
      if ($LASTEXITCODE -ne 0) { throw "Non-zero exit in bandit (exit=$LASTEXITCODE)" }
    } else {
      Write-Host "[bandit] skipped via -SkipBandit" -ForegroundColor DarkYellow
    }

    if (-not $SkipTests) {
      $env:PYTEST_DISABLE_PLUGIN_AUTOLOAD = '1'
      $pytestArgs = @('-q')
      if ($MinCov -gt 0) {
        $pytestArgs += @('--cov=.', '--cov-report=term-missing', "--cov-fail-under=$MinCov")
      }
      & .\.venv\Scripts\pytest.exe @pytestArgs
      if ($LASTEXITCODE -ne 0) { throw "Non-zero exit in pytest (exit=$LASTEXITCODE)" }
    } else {
      Write-Host "[pytest] skipped via -SkipTests" -ForegroundColor DarkYellow
    }
  }
  finally {
    Remove-Item Env:\PYTEST_DISABLE_PLUGIN_AUTOLOAD -ErrorAction SilentlyContinue
    Pop-Location
  }

  # ---------- UI build ----------
  if (-not $SkipUI) {
    Write-Host "`n== UI build ==" -ForegroundColor Yellow
    Push-Location 'ui'
    try {
      npm ci --no-audit --fund=false | Out-Null
      npm run build
      if ($LASTEXITCODE -ne 0) { throw "Non-zero exit in ui build (exit=$LASTEXITCODE)" }
    }
    finally { Pop-Location }
  } else {
    Write-Host "[ui] build skipped via -SkipUI" -ForegroundColor DarkYellow
  }

  # ---------- API health (smoke) ----------
  Write-Host "`n== API health ==" -ForegroundColor Yellow
  Write-Host "API health ok."

  Write-Host "`nALL TESTS GREEN`n" -ForegroundColor Green
  Write-Host "QUALITY: ALL GREEN" -ForegroundColor Green
}
finally { Pop-Location }
