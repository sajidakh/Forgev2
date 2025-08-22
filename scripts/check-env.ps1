Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
function Fail($m){ Write-Host $m -ForegroundColor Red; exit 1 }
Write-Host "== Env Check ==" -ForegroundColor Cyan
$nodeV = (& node -v) 2>$null
if (-not $nodeV) { Fail "Node not found on PATH" }
$nodeMajor = ($nodeV.TrimStart("v").Split(".")[0]) -as [int]
if ($nodeMajor -ne 18) { Fail "Node major must be 18.x; got $nodeV" }
Write-Host "Node OK: $nodeV" -ForegroundColor Green
$py = "backend\python\.venv\Scripts\python.exe"
if (-not (Test-Path $py)) { Fail "Python venv not found at $py" }
$pyV = & $py -V
if ($pyV -notmatch "3\.11\.\d+") { Fail "Python must be 3.11.x; got $pyV" }
Write-Host "Python OK: $pyV" -ForegroundColor Green
