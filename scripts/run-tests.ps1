Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repo = Resolve-Path (Join-Path $PSScriptRoot '..')

# === UI: build (compile-time green) ===
$ui = Join-Path $repo 'ui'
if (Test-Path (Join-Path $ui 'package.json')) {
  Write-Host "`n== UI build ==" -ForegroundColor Cyan
  Push-Location $ui
  if (Test-Path (Join-Path $ui 'package-lock.json')) {
    npm ci --no-audit --no-fund
  } else {
    npm install --no-audit --no-fund
  }
  npm run build
  Pop-Location
} else {
  Write-Host "UI not present; skipping build."
}

# === API: ephemeral health check ===
$api = Join-Path $repo 'backend\python'
$uvicorn = Join-Path $api '.venv\Scripts\uvicorn.exe'
if (-not (Test-Path $uvicorn)) {
  throw "Uvicorn not found at $uvicorn. Create venv and install requirements first."
}

Write-Host "`n== API health ==" -ForegroundColor Cyan
$proc = Start-Process -FilePath $uvicorn -ArgumentList @('app:app','--host','127.0.0.1','--port','8000') -WorkingDirectory $api -PassThru -WindowStyle Hidden
try {
  $deadline = (Get-Date).AddSeconds(15)
  $ok = $false
  while ((Get-Date) -lt $deadline) {
    try {
      Start-Sleep -Milliseconds 300
      $resp = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/health' -TimeoutSec 2
      if ($resp.status -eq 'ok') { $ok = $true; break }
    } catch { }
  }
  if (-not $ok) { throw "API health did not return ok within timeout." }
  Write-Host "API health ok." -ForegroundColor Green
} finally {
  if ($proc -and -not $proc.HasExited) { $proc.Kill() | Out-Null }
}

Write-Host "`nALL TESTS GREEN" -ForegroundColor Green
exit 0
