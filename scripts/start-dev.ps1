Set-StrictMode -Version Latest

# Dot-source global (optional)
$globalPath = Join-Path $PSScriptRoot '_global.ps1'
if (Test-Path $globalPath) { . $globalPath }

# Resolve paths relative to repo
$repoRoot     = Resolve-Path (Join-Path $PSScriptRoot '..')
$apiPath      = Join-Path $repoRoot 'backend\python'
$uiPath       = Join-Path $repoRoot 'ui'
$electronPath = Join-Path $repoRoot 'electron'

Write-Host "`n[start] Booting Forge dev stack..." -ForegroundColor Cyan

# Start API (uvicorn in venv)
$uvicorn = Join-Path $apiPath '.venv\Scripts\uvicorn.exe'
if (-not (Test-Path $uvicorn)) {
  Write-Warning "Uvicorn not found at $uvicorn. Did you create the venv and install requirements?"
} else {
  Start-Process -WindowStyle Minimized -FilePath 'pwsh' -ArgumentList @(
    '-NoProfile','-ExecutionPolicy','Bypass','-Command',
    "Set-Location '$apiPath'; & '$uvicorn' app:app --host 127.0.0.1 --port 8000 --reload"
  )
}

Start-Sleep -Seconds 2

# Start UI (Vite)
Start-Process -WindowStyle Minimized -FilePath 'pwsh' -ArgumentList @(
  '-NoProfile','-ExecutionPolicy','Bypass','-Command',
  "Set-Location '$uiPath'; npm run dev"
)

Start-Sleep -Seconds 3

# Start Electron
Start-Process -WindowStyle Normal -FilePath 'pwsh' -ArgumentList @(
  '-NoProfile','-ExecutionPolicy','Bypass','-Command',
  "Set-Location '$electronPath'; npm start"
)

Write-Host "[start] API http://127.0.0.1:8000 | UI http://127.0.0.1:5173 | Electron wrapping UI" -ForegroundColor Green
