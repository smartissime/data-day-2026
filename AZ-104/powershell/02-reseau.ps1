# Atelier 2 (ticket T2) : VNet, sous-reseaux, ASG, NSG, Bastion
$ErrorActionPreference = "Stop"
. "$PSScriptRoot/00-prologue.ps1"

# ---- 1. VNet et sous-reseaux ----
$delegAci = New-AzDelegation -Name "aci" -ServiceName "Microsoft.ContainerInstance/containerGroups"
$snetWeb  = New-AzVirtualNetworkSubnetConfig -Name "snet-web"  -AddressPrefix "10.10.1.0/24"
$snetApp  = New-AzVirtualNetworkSubnetConfig -Name "snet-app"  -AddressPrefix "10.10.2.0/24" -Delegation $delegAci
$snetData = New-AzVirtualNetworkSubnetConfig -Name "snet-data" -AddressPrefix "10.10.3.0/24"
$snetBas  = New-AzVirtualNetworkSubnetConfig -Name "AzureBastionSubnet" -AddressPrefix "10.10.250.0/26"

$vnet = New-AzVirtualNetwork -Name $VnetName -ResourceGroupName $RgNet -Location $Loc `
          -AddressPrefix "10.10.0.0/16" -Subnet $snetWeb, $snetApp, $snetData, $snetBas -Tag $Tags -Force

# ---- 2. ASG ----
$asgWeb = New-AzApplicationSecurityGroup -Name "asg-web" -ResourceGroupName $RgNet -Location $Loc -Force
$asgApp = New-AzApplicationSecurityGroup -Name "asg-app" -ResourceGroupName $RgNet -Location $Loc -Force

# ---- 3. NSG ----
$rDeny = New-AzNetworkSecurityRuleConfig -Name "Deny-All-Inbound" -Priority 4000 -Direction Inbound -Access Deny `
    -Protocol * -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange *

# nsg-web
$rWebLb   = New-AzNetworkSecurityRuleConfig -Name "Allow-HTTP-From-LB" -Priority 100 -Direction Inbound -Access Allow -Protocol Tcp `
    -SourceAddressPrefix "AzureLoadBalancer" -SourcePortRange * -DestinationApplicationSecurityGroup $asgWeb -DestinationPortRange 80
$rWebInet = New-AzNetworkSecurityRuleConfig -Name "Allow-HTTP-Internet" -Priority 110 -Direction Inbound -Access Allow -Protocol Tcp `
    -SourceAddressPrefix "Internet" -SourcePortRange * -DestinationApplicationSecurityGroup $asgWeb -DestinationPortRange 80, 443
$rWebSsh  = New-AzNetworkSecurityRuleConfig -Name "Allow-SSH-From-Bastion" -Priority 120 -Direction Inbound -Access Allow -Protocol Tcp `
    -SourceAddressPrefix "10.10.250.0/26" -SourcePortRange * -DestinationApplicationSecurityGroup $asgWeb -DestinationPortRange 22
$nsgWeb = New-AzNetworkSecurityGroup -Name "nsg-web" -ResourceGroupName $RgNet -Location $Loc -SecurityRules $rWebLb, $rWebInet, $rWebSsh, $rDeny -Tag $Tags -Force

# nsg-app
$rAppFromWeb = New-AzNetworkSecurityRuleConfig -Name "Allow-API-From-Web" -Priority 100 -Direction Inbound -Access Allow -Protocol Tcp `
    -SourceApplicationSecurityGroup $asgWeb -SourcePortRange * -DestinationApplicationSecurityGroup $asgApp -DestinationPortRange 8080
$nsgApp = New-AzNetworkSecurityGroup -Name "nsg-app" -ResourceGroupName $RgNet -Location $Loc -SecurityRules $rAppFromWeb, $rDeny -Tag $Tags -Force

# nsg-data
$rDataFromApp = New-AzNetworkSecurityRuleConfig -Name "Allow-HTTPS-From-App" -Priority 100 -Direction Inbound -Access Allow -Protocol Tcp `
    -SourceApplicationSecurityGroup $asgApp -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 443
$nsgData = New-AzNetworkSecurityGroup -Name "nsg-data" -ResourceGroupName $RgNet -Location $Loc -SecurityRules $rDataFromApp, $rDeny -Tag $Tags -Force

# Association : modifier l'objet VNet puis Set-AzVirtualNetwork (sinon rien n'est applique)
$vnet = Get-AzVirtualNetwork -Name $VnetName -ResourceGroupName $RgNet
Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name "snet-web"  -AddressPrefix "10.10.1.0/24" -NetworkSecurityGroup $nsgWeb | Out-Null
Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name "snet-app"  -AddressPrefix "10.10.2.0/24" -NetworkSecurityGroup $nsgApp -Delegation $delegAci | Out-Null
Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name "snet-data" -AddressPrefix "10.10.3.0/24" -NetworkSecurityGroup $nsgData | Out-Null
$vnet | Set-AzVirtualNetwork | Out-Null

(Get-AzVirtualNetwork -Name $VnetName -ResourceGroupName $RgNet).Subnets |
    Select-Object Name, AddressPrefix, @{n="NSG";e={ ($_.NetworkSecurityGroup.Id -split "/")[-1] }} | Format-Table

# ---- 4. Bastion (long : tache de fond) ----
New-AzPublicIpAddress -Name "pip-bastion" -ResourceGroupName $RgNet -Location $Loc -Sku Standard -AllocationMethod Static -Tag $Tags -Force | Out-Null
New-AzBastion -Name "bas-trackit" -ResourceGroupName $RgNet -VirtualNetworkName $VnetName -VirtualNetworkRgName $RgNet `
    -PublicIpAddressRgName $RgNet -PublicIpAddressName "pip-bastion" -Sku Basic -AsJob | Out-Null
Write-Host "Bastion en cours de creation (8 a 10 min). Suivi : Get-Job | Format-Table Name, State"
