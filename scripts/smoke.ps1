Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot "_global.ps1")
Push-RepoRoot "smoke"

try {
  Write-Host "`n=== API SMOKE ===" -ForegroundColor Cyan
  try {
    $resp = Invoke-RestMethod -Uri "http://127.0.0.1:8000/health" -Method GET -TimeoutSec 5
    Write-Host ("API: {0} ({1})" -f $resp.status, $resp.service) -ForegroundColor Green
  } catch {
    Write-Host "API UNREACHABLE: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
  }
}
finally {
  Pop-RepoRoot
}
