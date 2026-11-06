param([string]$Selection = '')
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path $PSScriptRoot -Parent
$pythonPath = Join-Path $PSScriptRoot '.venv\Scripts\python.exe'
if (!(Test-Path -LiteralPath $pythonPath)) { throw 'Run uv sync --project e2e_test first.' }
foreach ($name in @('ARTEMIS_BASE_URL', 'ARTEMIS_TEST_ACCOUNT_EMAIL', 'ARTEMIS_DEVICE')) {
    if (![Environment]::GetEnvironmentVariable($name)) { throw "Missing $name" }
}
$batchPath = Join-Path $repoRoot ('evidence\artemis\local-runs\' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType Directory -Path $batchPath | Out-Null
$previousRun = $env:ARTEMIS_RUN
Push-Location $repoRoot
try {
    foreach ($iteration in 1..3) {
        $env:ARTEMIS_RUN = "$iteration"
        $pytestArgs = @('-m', 'pytest', 'e2e_test', '-v', '--tb=short', "--junitxml=$batchPath\run-$iteration.xml")
        if ($Selection) { $pytestArgs += @('-k', $Selection) }
        & $pythonPath @pytestArgs
        if ($LASTEXITCODE -gt 1) { throw 'Pytest could not execute the suite. Check setup before continuing.' }
    }
    & $pythonPath (Join-Path $PSScriptRoot 'summarize_results.py') $batchPath
} finally {
    $env:ARTEMIS_RUN = $previousRun
    Pop-Location
}
