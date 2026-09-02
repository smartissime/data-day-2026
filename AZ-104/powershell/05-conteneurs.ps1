# Atelier 5 (ticket T5) : ACR, construction de l'image, ACI dans le VNet avec identite manageee
param([string]$ApiVersion = "1.0")
$ErrorActionPreference = "Stop"
. "$PSScriptRoot/00-prologue.ps1"
Set-Location $PSScriptRoot

# ---- 1. Registre ----
$acr = Get-AzContainerRegistry -ResourceGroupName $RgShared -Name $AcrName -ErrorAction SilentlyContinue
if (-not $acr) { $acr = New-AzContainerRegistry -ResourceGroupName $RgShared -Name $AcrName -Location $Loc -Sku Standard -EnableAdminUser:$false -Tag $Tags }

# ---- 2. Construction de l'image ----
# Le module Az n'a pas d'equivalent a ACR Tasks : on appelle Azure CLI (present dans Cloud Shell).
# Alternative avec Docker local : Connect-AzContainerRegistry -Name $AcrName ; docker build/push.
az acr build --registry $AcrName --image "trackit-api:$ApiVersion" ./api
Get-AzContainerRegistryTag -RegistryName $AcrName -RepositoryName "trackit-api" | Select-Object -ExpandProperty Tags | Format-Table Name, LastUpdateTime

# ---- 3. Identite manageee + AcrPull ----
$id = Get-AzUserAssignedIdentity -ResourceGroupName $RgShared -Name "id-trackit-api" -ErrorAction SilentlyContinue
if (-not $id) {
    $id = New-AzUserAssignedIdentity -ResourceGroupName $RgShared -Name "id-trackit-api" -Location $Loc -Tag $Tags
    Write-Host "Propagation de l'identite (30 s)..."; Start-Sleep -Seconds 30
    New-AzRoleAssignment -ObjectId $id.PrincipalId -RoleDefinitionName "AcrPull" -Scope $acr.Id | Out-Null
}

# ---- 4. ACI dans snet-app ----
$vnet    = Get-AzVirtualNetwork -Name $VnetName -ResourceGroupName $RgNet
$snetApp = Get-AzVirtualNetworkSubnetConfig -Name "snet-app" -VirtualNetwork $vnet
$port = New-AzContainerInstancePortObject -Port 8080 -Protocol TCP
$env  = New-AzContainerInstanceEnvironmentVariableObject -Name "API_VERSION" -Value $ApiVersion
$cont = New-AzContainerInstanceObject -Name "api-trackit" -Image "$($acr.LoginServer)/trackit-api:$ApiVersion" `
          -RequestCpu 1 -RequestMemoryInGb 1.5 -Port $port -EnvironmentVariable $env
$cred = New-AzContainerGroupImageRegistryCredentialObject -Server $acr.LoginServer -Identity $id.Id

$aci = New-AzContainerGroup -ResourceGroupName $RgProd -Name "aci-trackit-api" -Location $Loc `
         -Container $cont -OsType Linux -RestartPolicy Always `
         -SubnetId @{ id = $snetApp.Id; name = "snet-app" } `
         -IdentityType UserAssigned -IdentityUserAssignedIdentity @{ $id.Id = @{} } `
         -ImageRegistryCredential $cred -Tag $Tags
$ApiIp = $aci.IPAddressIP
Write-Host "API TrackIt : http://${ApiIp}:8080  (privee, joignable depuis asg-web uniquement)"
try { Get-AzContainerInstanceLog -ResourceGroupName $RgProd -ContainerGroupName "aci-trackit-api" -ContainerName "api-trackit" } catch { }

# ---- 5. Brancher le front nginx sur l'API via Run Command ----
foreach ($vmName in "vm-web-01","vm-web-02") {
    $r = Invoke-AzVMRunCommand -ResourceGroupName $RgProd -VMName $vmName -CommandId "RunShellScript" -ScriptPath ./nginx-proxy.sh -Parameter @{ arg1 = $ApiIp }
    Write-Host "$vmName : $($r.Value[0].Message.Trim() -split "`n" | Select-Object -Last 1)"
}
$LbFqdn = (Get-AzPublicIpAddress -ResourceGroupName $RgProd -Name "pip-trackit-lb").DnsSettings.Fqdn
Write-Host "Test de bout en bout :"
(Invoke-WebRequest -Uri "http://$LbFqdn/api/palettes/PAL-7781" -UseBasicParsing).Content
