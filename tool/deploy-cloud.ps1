$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
# Explicit project; never relies on the active CLI alias.
npx --yes firebase-tools@15.34.2 deploy --project eventhub-group4 --only 'firestore:rules,firestore:indexes'
if ($LASTEXITCODE -ne 0) { throw 'Deploy failed. Do not mark cloud complete; review CLI output.' }
Write-Host 'Firestore Rules and indexes deployed. Run the native cloud test checklist.'
