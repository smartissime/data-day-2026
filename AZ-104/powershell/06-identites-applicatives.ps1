# Atelier 6 (ticket T6) : app registration, principal de service du pipeline, Key Vault, identite manageee
param([securestring]$AdminPassword)
$ErrorActionPreference = "Stop"
. "$PSScriptRoot/00-prologue.ps1"
Set-Location $PSScriptRoot

$redirect   = "http://trackit-$Suffix.$Loc.cloudapp.azure.com/signin-oidc"
$graphAppId = "00000003-0000-0000-c000-000000000000"
$userReadId = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"

# ---- 1. App registration TrackIt-Web ----
$app = Get-MgApplication -Filter "displayName eq 'TrackIt-Web'"
if (-not $app) {
    $app = New-MgApplication -DisplayName "TrackIt-Web" -SignInAudience "AzureADMyOrg" `
        -Web @{ RedirectUris = @($redirect); ImplicitGrantSettings = @{ EnableIdTokenIssuance = $true } } `
        -RequiredResourceAccess @(@{ ResourceAppId = $graphAppId; ResourceAccess = @(@{ Id = $userReadId; Type = "Scope" }) })
}
$scopeId = [guid]::NewGuid().Guid
Update-MgApplication -ApplicationId $app.Id -IdentifierUris @("api://$($app.AppId)") -Api @{
    Oauth2PermissionScopes = @(@{
        Id = $scopeId; Value = "Palettes.Read"; Type = "User"; IsEnabled = $true
        AdminConsentDisplayName = "Lire les palettes"; AdminConsentDescription = "Permet de lire le suivi des palettes"
        UserConsentDisplayName  = "Lire les palettes"; UserConsentDescription  = "Permet de lire le suivi des palettes"
    })
}
$secret = Add-MgApplicationPassword -ApplicationId $app.Id -PasswordCredential @{ DisplayName = "bootcamp"; EndDateTime = (Get-Date).AddMonths(6) }
$ClientSecret = $secret.SecretText

$sp = Get-MgServicePrincipal -Filter "appId eq '$($app.AppId)'"
if (-not $sp) { $sp = New-MgServicePrincipal -AppId $app.AppId }
$graphSp = Get-MgServicePrincipal -Filter "appId eq '$graphAppId'"
if (-not (Get-MgOauth2PermissionGrant -Filter "clientId eq '$($sp.Id)'")) {
    New-MgOauth2PermissionGrant -ClientId $sp.Id -ConsentType "AllPrincipals" -ResourceId $graphSp.Id -Scope "User.Read" | Out-Null
}
Update-MgServicePrincipal -ServicePrincipalId $sp.Id -AppRoleAssignmentRequired:$true
$grpReaders = Get-MgGroup -Filter "displayName eq 'grp-trackit-readers'"
try {
    New-MgGroupAppRoleAssignment -GroupId $grpReaders.Id -PrincipalId $grpReaders.Id -ResourceId $sp.Id -AppRoleId "00000000-0000-0000-0000-000000000000" | Out-Null
} catch { }

Write-Host "AppId TrackIt-Web : $($app.AppId)"
Write-Host "URL de test (chef.lyon doit passer, dev.novadev doit etre refuse AADSTS50105) :"
Write-Host "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/authorize?client_id=$($app.AppId)&response_type=id_token&redirect_uri=$([uri]::EscapeDataString($redirect))&scope=openid&nonce=123&response_mode=fragment"

# ---- 2. Principal de service du pipeline ----
$acr = Get-AzContainerRegistry -ResourceGroupName $RgShared -Name $AcrName
$spDeploy = Get-AzADServicePrincipal -DisplayName "sp-trackit-deploy"
if (-not $spDeploy) {
    $spDeploy = New-AzADServicePrincipal -DisplayName "sp-trackit-deploy" -Role "Contributor" -Scope "/subscriptions/$SubId/resourceGroups/$RgProd"
    Write-Host "sp-trackit-deploy : AppId = $($spDeploy.AppId)"
    Write-Host "Secret (a transmettre une seule fois au pipeline) : $($spDeploy.PasswordCredentials.SecretText)"
}
if (-not (Get-AzRoleAssignment -ObjectId $spDeploy.Id -RoleDefinitionName "AcrPush" -Scope $acr.Id -ErrorAction SilentlyContinue)) {
    New-AzRoleAssignment -ObjectId $spDeploy.Id -RoleDefinitionName "AcrPush" -Scope $acr.Id | Out-Null
}

# ---- 3. Key Vault ----
$kv = Get-AzKeyVault -VaultName $KvName -ErrorAction SilentlyContinue
if (-not $kv) {
    $kv = New-AzKeyVault -ResourceGroupName $RgShared -Name $KvName -Location $Loc -EnableRbacAuthorization -EnablePurgeProtection -SoftDeleteRetentionInDays 90 -Tag $Tags
}
$me = (Get-AzADUser -SignedIn).Id
if (-not (Get-AzRoleAssignment -ObjectId $me -RoleDefinitionName "Key Vault Secrets Officer" -Scope $kv.ResourceId -ErrorAction SilentlyContinue)) {
    New-AzRoleAssignment -ObjectId $me -RoleDefinitionName "Key Vault Secrets Officer" -Scope $kv.ResourceId | Out-Null
    Write-Host "Propagation du role (30 s)..."; Start-Sleep -Seconds 30
}
if (-not $AdminPassword) { $AdminPassword = Read-Host -Prompt "Mot de passe administrateur des VM (a stocker dans Key Vault)" -AsSecureString }
Set-AzKeyVaultSecret -VaultName $KvName -Name "vm-admin-password"         -SecretValue $AdminPassword | Out-Null
Set-AzKeyVaultSecret -VaultName $KvName -Name "trackit-web-client-secret" -SecretValue (ConvertTo-SecureString $ClientSecret -AsPlainText -Force) | Out-Null
Get-AzKeyVaultSecret -VaultName $KvName | Format-Table Name, Enabled, Updated

# ---- 4. Identite manageee de l'API : lecture des secrets et des blobs sans cle ----
$id = Get-AzUserAssignedIdentity -ResourceGroupName $RgShared -Name "id-trackit-api"
$st = Get-AzStorageAccount -ResourceGroupName $RgProd -Name $StName
foreach ($pair in @(@("Key Vault Secrets User", $kv.ResourceId), @("Storage Blob Data Reader", $st.Id))) {
    if (-not (Get-AzRoleAssignment -ObjectId $id.PrincipalId -RoleDefinitionName $pair[0] -Scope $pair[1] -ErrorAction SilentlyContinue)) {
        New-AzRoleAssignment -ObjectId $id.PrincipalId -RoleDefinitionName $pair[0] -Scope $pair[1] | Out-Null
    }
}

# ---- 5. Fichier de parametres Bicep pointant vers Key Vault ----
(Get-Content ./main.bicepparam) -replace "<subscription-id>", $SubId -replace "ryo042", $Suffix | Set-Content "/tmp/main.$Suffix.bicepparam"
Write-Host "Previsualisation d'un redeploiement dont le mot de passe vient de Key Vault :"
New-AzResourceGroupDeployment -ResourceGroupName $RgProd -Name "deploy-web-02" -TemplateParameterFile "/tmp/main.$Suffix.bicepparam" -WhatIf
