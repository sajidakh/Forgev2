Set-StrictMode -Version Latest

function Get-RepoRoot {
  return (Resolve-Path (Join-Path $PSScriptRoot ".."))
}

function Push-RepoRoot {
  param([string]$who = "script")
  $root = Get-RepoRoot
  Push-Location $root
  Write-Host "[cd] $who -> $root" -ForegroundColor DarkGray
}

function Pop-RepoRoot {
  Pop-Location
}

function Assert-LastExitCode {
  param([string]$step = "step")
  if ($LASTEXITCODE -ne 0) {
    throw "Non-zero exit in $step (exit=$LASTEXITCODE)"
  }
}
