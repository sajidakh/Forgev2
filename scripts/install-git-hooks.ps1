Set-StrictMode -Version Latest
$hooksDir = Join-Path (Resolve-Path (Join-Path $PSScriptRoot '..')) '.git\hooks'
if (-not (Test-Path $hooksDir)) { throw ".git\hooks not found; is this a git repo?" }

$bat = @"
@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\..\scripts\run-tests.ps1"
if errorlevel 1 (
  echo.
  echo [FAIL] Tests failed. Commit aborted.
  exit /b 1
)
"@

$path = Join-Path $hooksDir 'pre-commit.bat'
$bat | Set-Content -Encoding ASCII $path
Write-Host "Installed pre-commit hook at $path" -ForegroundColor Green
