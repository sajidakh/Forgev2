Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot "_global.ps1")
Push-RepoRoot "start-dev"

try {
  $apiPath      = Join-Path (Get-RepoRoot) "backend\python"
  $uiPath       = Join-Path (Get-RepoRoot) "ui"
  $electronPath = Join-Path (Get-RepoRoot) "electron"

  Write-Host "`n[start] Booting Forge dev stack..." -ForegroundColor Cyan

  # API
  $uvicorn = Join-Path $apiPath ".venv\Scripts\uvicorn.exe"
  if (-not (Test-Path $uvicorn)) {
    Write-Warning "Uvicorn not found at $uvicorn. Did you create the venv and install requirements?"
  } else {
    Start-Process -WindowStyle Minimized -FilePath "pwsh" -ArgumentList @(
      "-NoProfile","-ExecutionPolicy","Bypass","-Command",
      "Set-Location '$apiPath'; & '$uvicorn' app:app --host 127.0.0.1 --port 8000 --reload"
    )
  }

  Start-Sleep -Seconds 2

  # UI
  Start-Process -WindowStyle Minimized -FilePath "pwsh" -ArgumentList @(
    "-NoProfile","-ExecutionPolicy","Bypass","-Command",
    "Set-Location '$uiPath'; npm run dev"
  )

  Start-Sleep -Seconds 3

  # Electron
  Start-Process -WindowStyle Normal -FilePath "pwsh" -ArgumentList @(
    "-NoProfile","-ExecutionPolicy","Bypass","-Command",
    "Set-Location '$electronPath'; npm start"
  )

  Write-Host "[start] API http://127.0.0.1:8000 | UI http://127.0.0.1:5173 | Electron wrapping UI" -ForegroundColor Green
}
finally {
  Pop-RepoRoot
}
