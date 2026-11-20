# Build + package a Hostinger deploy zip (kbar-fun_<timestamp>.zip in deploy-prod/)
# Usage: npm run deploy
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot)

npm.cmd run build
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$stage = 'deploy-prod\stage'
Remove-Item 'deploy-prod' -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force "$stage\server\data" | Out-Null

$exclude = @('node_modules','.git','.angular','deploy-prod','server\data\rsvps.local','server\data\settings.local','server\uploads','.env','nul','server.log','server3100.log')
$files = Get-ChildItem -Recurse -Force -File | Where-Object {
  $p = $_.FullName.Substring((Get-Location).Path.Length + 1)
  -not ($exclude | Where-Object { $p -eq $_ -or $p.StartsWith($_ + '\') -or $p -like "$_*" })
}
foreach ($f in $files) {
  $rel = $f.FullName.Substring((Get-Location).Path.Length + 1)
  $dest = Join-Path $stage $rel
  New-Item -ItemType Directory -Force (Split-Path $dest) | Out-Null
  Copy-Item $f.FullName $dest -Force
}

$ts = Get-Date -Format 'yyyyMMdd_HHmmss'
$zip = "deploy-prod\kbar-fun_$ts.zip"
Compress-Archive -Path "$stage\*" -DestinationPath $zip -Force
Remove-Item $stage -Recurse -Force
Write-Host "`nREADY: $zip ($('{0:N1}' -f ((Get-Item $zip).Length/1MB)) MB) - upload on Hostinger Deployments page"
