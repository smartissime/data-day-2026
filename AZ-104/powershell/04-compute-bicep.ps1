# Atelier 4 (ticket T4) : deploiement Bicep de 2 VM web en zones + Load Balancer Standard
param([int]$WebVmCount = 2, [securestring]$AdminPassword)
$ErrorActionPreference = "Stop"
. "$PSScriptRoot/00-prologue.ps1"
Set-Location $PSScriptRoot

if (-not $AdminPassword) { $AdminPassword = Read-Host -Prompt "Mot de passe administrateur des VM" -AsSecureString }

# ---- 1. Transpilation (pedagogique) et previsualisation ----
bicep build ./trackit-web.bicep --outfile /tmp/trackit-web.json
Write-Host "Template ARM genere : /tmp/trackit-web.json"

$deployParams = @{
    ResourceGroupName = $RgProd
    Name              = "deploy-web-01"
    TemplateFile      = "./trackit-web.bicep"
    suffix            = $Suffix
    adminPassword     = $AdminPassword
    webVmCount        = $WebVmCount
}
New-AzResourceGroupDeployment @deployParams -WhatIf

# ---- 2. Deploiement ----
$dep = New-AzResourceGroupDeployment @deployParams -Verbose
$LbFqdn = $dep.Outputs.lbFqdn.Value
Write-Host "Site web : http://$LbFqdn"

# ---- 3. Verifications ----
Get-AzVM -ResourceGroupName $RgProd -Status | Format-Table Name, PowerState, @{n="Zone";e={$_.Zones -join ","}}
Get-AzNetworkInterface -ResourceGroupName $RgProd |
    Select-Object Name, @{n="ASG";e={ ($_.IpConfigurations[0].ApplicationSecurityGroups.Id -split "/")[-1] }},
                        @{n="IP";e={ $_.IpConfigurations[0].PrivateIpAddress }} | Format-Table

Write-Host "Attente de nginx (60 s)..."; Start-Sleep -Seconds 60
1..4 | ForEach-Object { ((Invoke-WebRequest -Uri "http://$LbFqdn" -UseBasicParsing).Content | Select-String -Pattern "vm-web-0\d").Matches.Value }

# ---- 4. Test de bascule ----
Write-Host "Desallocation de vm-web-01 : le site doit continuer de repondre..."
Stop-AzVM -ResourceGroupName $RgProd -Name "vm-web-01" -Force | Out-Null
Start-Sleep -Seconds 20
1..3 | ForEach-Object { ((Invoke-WebRequest -Uri "http://$LbFqdn" -UseBasicParsing).Content | Select-String -Pattern "vm-web-0\d").Matches.Value }
Start-AzVM -ResourceGroupName $RgProd -Name "vm-web-01" -NoWait | Out-Null
Write-Host "vm-web-01 redemarre en arriere-plan."
