Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot "_global.ps1")
Push-RepoRoot "install-git-hooks"
try {
  $hooksDir = Join-Path (Get-RepoRoot) ".git\hooks"
  if (-not (Test-Path $hooksDir)) { throw ".git\hooks not found; is this a git repo?" }
  $bat = @('@echo off',
    'powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\..\scripts\run-quality.ps1"',
    'if errorlevel 1 (',
    '  echo.',
    '  echo [FAIL] Quality gate failed. Commit aborted.',
    '  exit /b 1',
    ')') -join "`r`n"
  $path = Join-Path $hooksDir "pre-commit.bat"
  Set-Content -Path $path -Value $bat -Encoding ASCII
  Write-Host "Installed pre-commit hook (run-quality) at $path" -ForegroundColor Green
} finally { Pop-RepoRoot }
