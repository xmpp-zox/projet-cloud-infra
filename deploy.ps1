<#
.SYNOPSIS
  One-command deploy of the Projet Cloud stack on AWS.
.DESCRIPTION
  Validates prerequisites, prompts for the RDS password if not set,
  then runs terraform init/apply and prints the URLs.
.EXAMPLE
  ./deploy.ps1
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-Location -Path $PSScriptRoot

Write-Host "==> Checking prerequisites..." -ForegroundColor Cyan
foreach ($cmd in 'terraform','aws') {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        throw "$cmd is not installed or not on PATH. See README.md (Prerequisites)."
    }
}

Write-Host "==> Verifying AWS credentials..." -ForegroundColor Cyan
$caller = aws sts get-caller-identity --output json 2>$null | ConvertFrom-Json
if (-not $caller) { throw "AWS credentials are missing or expired. Run 'aws configure' or refresh your AWS Academy session." }
Write-Host ("    Account: {0}  Arn: {1}" -f $caller.Account, $caller.Arn) -ForegroundColor DarkGray

if (-not $env:TF_VAR_db_password) {
    $sec = Read-Host "Enter a strong RDS master password (min 8 chars)" -AsSecureString
    $env:TF_VAR_db_password = [System.Net.NetworkCredential]::new('', $sec).Password
    if ($env:TF_VAR_db_password.Length -lt 8) { throw "Password must be at least 8 characters." }
}

if (-not (Test-Path .\terraform.tfvars)) {
    Write-Host "==> Creating terraform.tfvars from example..." -ForegroundColor Cyan
    Copy-Item .\terraform.tfvars.example .\terraform.tfvars
    Write-Host "    Edit terraform.tfvars if you need to change region/repos/SSH, then re-run." -ForegroundColor Yellow
}

Write-Host "==> terraform init" -ForegroundColor Cyan
terraform init -upgrade

Write-Host "==> terraform apply" -ForegroundColor Cyan
terraform apply -auto-approve

Write-Host ""
Write-Host "==> Stack is up. Outputs:" -ForegroundColor Green
terraform output

$fe = terraform output -raw frontend_url 2>$null
if ($fe) {
    Write-Host ""
    Write-Host "Frontend builds Angular on first boot (~3-4 min). Then open:" -ForegroundColor Green
    Write-Host "    $fe" -ForegroundColor White
}
