. $(Join-Path \ '_global.ps1')

Write-Host "
=== API SMOKE ===" -ForegroundColor Cyan
try {
  \ = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/health' -Method GET -TimeoutSec 5
  Write-Host ("API: {0} ({1})" -f \.status, \.service) -ForegroundColor Green
} catch {
  Write-Host "API UNREACHABLE" -ForegroundColor Red
  exit 1
}

Write-Host "
=== UI TIP ===" -ForegroundColor Cyan
Write-Host "Click 'Ping API' in the Electron window and expect 'API: ok (forge-api)'" -ForegroundColor Yellow
