# Atelier 3 (ticket T3) : compte de stockage, blobs, cycle de vie, SAS, Azure Files, point de terminaison prive
param([switch]$SkipPrivateEndpoint)
$ErrorActionPreference = "Stop"
. "$PSScriptRoot/00-prologue.ps1"
Set-Location $PSScriptRoot

# ---- 1. Compte de stockage + protection des donnees ----
$st = New-AzStorageAccount -ResourceGroupName $RgProd -Name $StName -Location $Loc -SkuName Standard_LRS -Kind StorageV2 `
        -AccessTier Hot -MinimumTlsVersion TLS1_2 -AllowBlobPublicAccess $false -AllowSharedKeyAccess $true -Tag $Tags
Enable-AzStorageBlobDeleteRetentionPolicy      -ResourceGroupName $RgProd -StorageAccountName $StName -RetentionDays 14 | Out-Null
Enable-AzStorageContainerDeleteRetentionPolicy -ResourceGroupName $RgProd -StorageAccountName $StName -RetentionDays 14 | Out-Null
Update-AzStorageBlobServiceProperty            -ResourceGroupName $RgProd -StorageAccountName $StName -IsVersioningEnabled $true | Out-Null

# ---- 2. Role de plan de donnees, conteneur, chargement, niveau Cool ----
$me = (Get-AzADUser -SignedIn).Id
if (-not (Get-AzRoleAssignment -ObjectId $me -RoleDefinitionName "Storage Blob Data Contributor" -Scope $st.Id -ErrorAction SilentlyContinue)) {
    New-AzRoleAssignment -ObjectId $me -RoleDefinitionName "Storage Blob Data Contributor" -Scope $st.Id | Out-Null
    Write-Host "Propagation du role (30 s)..."; Start-Sleep -Seconds 30
}
$ctx = New-AzStorageContext -StorageAccountName $StName -UseConnectedAccount
if (-not (Get-AzStorageContainer -Name "bons-livraison" -Context $ctx -ErrorAction SilentlyContinue)) {
    New-AzStorageContainer -Name "bons-livraison" -Context $ctx -Permission Off | Out-Null
}
"Bon de livraison n 1001 - Lyon" | Out-File -FilePath ./BL-1001.pdf
Set-AzStorageBlobContent -File ./BL-1001.pdf -Container "bons-livraison" -Blob "2026/09/BL-1001.pdf" -Context $ctx -Force | Out-Null
$blob = Get-AzStorageBlob -Container "bons-livraison" -Blob "2026/09/BL-1001.pdf" -Context $ctx
$blob.BlobClient.SetAccessTier("Cool") | Out-Null
Get-AzStorageBlob -Container "bons-livraison" -Context $ctx | Format-Table Name, Length, AccessTier, LastModified

# ---- 3. Cycle de vie ----
$action = Add-AzStorageAccountManagementPolicyAction -BaseBlobAction TierToCool    -DaysAfterModificationGreaterThan 30
$action = Add-AzStorageAccountManagementPolicyAction -BaseBlobAction TierToArchive -DaysAfterModificationGreaterThan 90   -InputObject $action
$action = Add-AzStorageAccountManagementPolicyAction -BaseBlobAction Delete        -DaysAfterModificationGreaterThan 3650 -InputObject $action
$filter = New-AzStorageAccountManagementPolicyFilter -PrefixMatch "bons-livraison/" -BlobType blockBlob
$rule   = New-AzStorageAccountManagementPolicyRule -Name "archive-bons-livraison" -Action $action -Filter $filter
Set-AzStorageAccountManagementPolicy -ResourceGroupName $RgProd -StorageAccountName $StName -Rule $rule | Out-Null

# ---- 4. SAS de delegation utilisateur (1 h) ----
$sasUri = New-AzStorageBlobSASToken -Container "bons-livraison" -Blob "2026/09/BL-1001.pdf" -Permission r -Protocol HttpsOnly `
            -StartTime (Get-Date).AddMinutes(-5) -ExpiryTime (Get-Date).AddHours(1) -Context $ctx -FullUri
Write-Host "URL SAS (1 h) : $sasUri"

# ---- 5. Azure Files ----
if (-not (Get-AzRmStorageShare -ResourceGroupName $RgProd -StorageAccountName $StName -Name "agences" -ErrorAction SilentlyContinue)) {
    New-AzRmStorageShare -ResourceGroupName $RgProd -StorageAccountName $StName -Name "agences" -QuotaGiB 100 -EnabledProtocol SMB | Out-Null
}
Get-AzRmStorageShare -ResourceGroupName $RgProd -StorageAccountName $StName | Format-Table Name, QuotaGiB, EnabledProtocols

# ---- 6. Point de terminaison prive + DNS prive + pare-feu (bonus) ----
if (-not $SkipPrivateEndpoint) {
    $vnet     = Get-AzVirtualNetwork -Name $VnetName -ResourceGroupName $RgNet
    $snetData = Get-AzVirtualNetworkSubnetConfig -Name "snet-data" -VirtualNetwork $vnet
    $plsConn  = New-AzPrivateLinkServiceConnection -Name "pe-st-blob-conn" -PrivateLinkServiceId $st.Id -GroupId "blob"
    New-AzPrivateEndpoint -Name "pe-st-blob" -ResourceGroupName $RgNet -Location $Loc -Subnet $snetData -PrivateLinkServiceConnection $plsConn -Force | Out-Null
    $zone = New-AzPrivateDnsZone -ResourceGroupName $RgNet -Name "privatelink.blob.core.windows.net"
    New-AzPrivateDnsVirtualNetworkLink -ResourceGroupName $RgNet -ZoneName $zone.Name -Name "link-trackit" -VirtualNetworkId $vnet.Id -EnableRegistration:$false | Out-Null
    $zoneConfig = New-AzPrivateDnsZoneConfig -Name "blob" -PrivateDnsZoneId $zone.ResourceId
    New-AzPrivateDnsZoneGroup -ResourceGroupName $RgNet -PrivateEndpointName "pe-st-blob" -Name "zg-blob" -PrivateDnsZoneConfig $zoneConfig -Force | Out-Null
    $myIp = (Invoke-RestMethod -Uri "https://ifconfig.me/ip").Trim()
    Update-AzStorageAccountNetworkRuleSet -ResourceGroupName $RgProd -Name $StName -DefaultAction Deny -Bypass AzureServices | Out-Null
    Add-AzStorageAccountNetworkRule       -ResourceGroupName $RgProd -Name $StName -IPAddressOrRange $myIp | Out-Null
    Write-Host "Pare-feu actif : acces prive via 10.10.3.x, plus votre IP $myIp"
}
