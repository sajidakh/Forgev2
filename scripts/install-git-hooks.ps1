Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot "_global.ps1")
Push-RepoRoot "install-git-hooks"
try {
  $hooks = Join-Path (Get-RepoRoot) ".git\hooks"
  if (-not (Test-Path $hooks)) { throw ".git\hooks not found" }
  $bat = @('@echo off',
    'setlocal',
    'pwsh -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\..\scripts\run-quality.ps1"',
    'set ec=%ERRORLEVEL%',
    'if not "%ec%"=="0" (',
    '  echo [FAIL] Quality gate failed. Commit aborted.',
    '  exit /b %ec%',
    ')',
    'endlocal') -join "`r`n"
  Set-Content -Path (Join-Path $hooks "pre-commit.bat") -Value $bat -Encoding ASCII
  Write-Host "Pre-commit hook installed." -ForegroundColor Green
} finally { Pop-RepoRoot }
