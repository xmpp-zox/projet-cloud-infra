[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
Set-Location -Path $PSScriptRoot

if (-not $env:TF_VAR_db_password) { $env:TF_VAR_db_password = "placeholder-not-used-during-destroy-1234" }

Write-Host "==> terraform destroy" -ForegroundColor Yellow
terraform destroy -auto-approve
Write-Host "==> All AWS resources removed." -ForegroundColor Green
