param([switch]$BillingConfirmed)
$ErrorActionPreference = 'Stop'
if (-not $BillingConfirmed) {
  throw 'Confirm billing and create the Storage bucket in Firebase Console first. Then run with -BillingConfirmed.'
}
Set-Location (Split-Path $PSScriptRoot -Parent)
# Explicit project; never relies on the active CLI alias.
npx --yes firebase-tools@15.34.2 deploy --project eventhub-group4 --only 'firestore:rules,firestore:indexes,storage,functions:eventhub'
if ($LASTEXITCODE -ne 0) { throw 'Deploy failed. Do not mark cloud complete; review CLI output.' }
Write-Host 'Deploy completed. Run the cloud test checklist and collect console evidence.'
