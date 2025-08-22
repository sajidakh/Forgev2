. $(Join-Path \ '_global.ps1')

Write-Host "
[start] Booting Forge dev stack..." -ForegroundColor Cyan
# 1) API
Start-Process -WindowStyle Minimized -FilePath powershell -ArgumentList @(
  '-NoProfile','-ExecutionPolicy','Bypass','-Command',
  'Set-Location ""backend/python""; .\.venv\Scripts\uvicorn.exe app:app --host 127.0.0.1 --port 8000 --reload'
)

# Wait briefly for API
Start-Sleep -Seconds 2

# 2) UI (Vite)
Start-Process -WindowStyle Minimized -FilePath powershell -ArgumentList @(
  '-NoProfile','-ExecutionPolicy','Bypass','-Command',
  'Set-Location ""ui""; npm run dev'
)

# 3) Electron (wait a tad for Vite to come up)
Start-Sleep -Seconds 3
Start-Process -WindowStyle Normal -FilePath powershell -ArgumentList @(
  '-NoProfile','-ExecutionPolicy','Bypass','-Command',
  'Set-Location ""electron""; npm start'
)

Write-Host "[start] API on http://127.0.0.1:8000 | UI on http://127.0.0.1:5173 | Electron wrapping UI" -ForegroundColor Green
