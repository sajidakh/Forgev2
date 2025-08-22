Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
Write-Host "== Lockfiles ==" -ForegroundColor Cyan
if (-not (Test-Path "ui\package-lock.json")) { throw "ui\package-lock.json missing" }
if (-not (Test-Path "backend\python\requirements.txt")) { throw "backend\python\requirements.txt missing" }
$req = Get-Content "backend\python\requirements.txt"
if ($req -match ">=|<=|~=|\*") { Write-Warning "requirements.txt has non-pinned specifiers; prefer exact == pins" }
Write-Host "Lockfiles present" -ForegroundColor Green
