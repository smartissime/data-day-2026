# Atelier 1 (ticket T1) : Entra ID, RBAC, Azure Policy, verrous
$ErrorActionPreference = "Stop"
. "$PSScriptRoot/00-prologue.ps1"

$Domain = (Get-MgDomain | Where-Object IsDefault).Id
Write-Host "Domaine Entra : $Domain"

# ---- 1. Utilisateurs et groupes ----
foreach ($u in "chef.lyon","chef.nantes","chef.lille","dev.novadev") {
    if (-not (Get-MgUser -Filter "userPrincipalName eq '$u@$Domain'")) {
        $profile = @{ Password = "Bootcamp-AZ104-$(Get-Random -Maximum 9999)!"; ForceChangePasswordNextSignIn = $true }
        New-MgUser -DisplayName $u -UserPrincipalName "$u@$Domain" -MailNickname $u `
                   -AccountEnabled -PasswordProfile $profile -UsageLocation "FR" | Out-Null
        Write-Host "Utilisateur cree : $u@$Domain"
    }
}

function Get-OrCreateGroup([string]$Name) {
    $g = Get-MgGroup -Filter "displayName eq '$Name'"
    if (-not $g) { $g = New-MgGroup -DisplayName $Name -MailNickname $Name -SecurityEnabled -MailEnabled:$false; Write-Host "Groupe cree : $Name" }
    return $g
}
$grpAdmins  = Get-OrCreateGroup "grp-trackit-admins"
$grpReaders = Get-OrCreateGroup "grp-trackit-readers"
$grpNovadev = Get-OrCreateGroup "grp-novadev"

function Add-MemberSafe($GroupId, $UserId) {
    try { New-MgGroupMember -GroupId $GroupId -DirectoryObjectId $UserId -ErrorAction Stop } catch { }
}
foreach ($u in "chef.lyon","chef.nantes","chef.lille") {
    Add-MemberSafe $grpReaders.Id (Get-MgUser -UserId "$u@$Domain").Id
}
Add-MemberSafe $grpNovadev.Id (Get-MgUser -UserId "dev.novadev@$Domain").Id
Add-MemberSafe $grpAdmins.Id  (Get-MgUser -UserId (Get-MgContext).Account).Id

# Invitation B2B (demonstration)
try { New-MgInvitation -InvitedUserEmailAddress "externe@novadev.fr" -InviteRedirectUrl "https://portal.azure.com" -SendInvitationMessage:$false | Out-Null } catch { }

# ---- 2. RBAC ----
$scopeSub = "/subscriptions/$SubId"
function Grant-Role($ObjectId, $Role, $Scope) {
    if (-not (Get-AzRoleAssignment -ObjectId $ObjectId -RoleDefinitionName $Role -Scope $Scope -ErrorAction SilentlyContinue)) {
        New-AzRoleAssignment -ObjectId $ObjectId -RoleDefinitionName $Role -Scope $Scope | Out-Null
    }
}
Grant-Role $grpAdmins.Id  "Owner"                  $scopeSub
Grant-Role $grpReaders.Id "Reader"                 $scopeSub
Grant-Role $grpReaders.Id "Cost Management Reader" $scopeSub
Grant-Role $grpNovadev.Id "Contributor"            "$scopeSub/resourceGroups/$RgProd"

Write-Host "--- Attributions sur $RgProd (avec heritage) ---"
Get-AzRoleAssignment -ResourceGroupName $RgProd | Format-Table DisplayName, RoleDefinitionName, Scope

# ---- 3. Azure Policy ----
$defTag = Get-AzPolicyDefinition -Name "1e30110a-5ceb-460c-a204-c1c3969c6d62"   # Require a tag and its value on resources
$defLoc = Get-AzPolicyDefinition -Name "e56962a6-4747-49cd-b67b-bf8b01975c4c"   # Allowed locations
if (-not (Get-AzPolicyAssignment -Name "req-tag-costcenter" -Scope $scopeSub -ErrorAction SilentlyContinue)) {
    New-AzPolicyAssignment -Name "req-tag-costcenter" -DisplayName "Tag costcenter obligatoire" -PolicyDefinition $defTag -Scope $scopeSub `
        -PolicyParameterObject @{ tagName = "costcenter"; tagValue = "DSI" } | Out-Null
}
if (-not (Get-AzPolicyAssignment -Name "allowed-locations" -Scope $scopeSub -ErrorAction SilentlyContinue)) {
    New-AzPolicyAssignment -Name "allowed-locations" -DisplayName "Regions autorisees" -PolicyDefinition $defLoc -Scope $scopeSub `
        -PolicyParameterObject @{ listOfAllowedLocations = @("francecentral","westeurope") } | Out-Null
}
Get-AzPolicyAssignment -Scope $scopeSub | Where-Object Name -in "req-tag-costcenter","allowed-locations" | Format-Table Name, @{n="Affichage";e={$_.Properties.DisplayName}}

# ---- 4. Verrou ----
if (-not (Get-AzResourceLock -LockName "lock-no-delete-net" -ResourceGroupName $RgNet -ErrorAction SilentlyContinue)) {
    New-AzResourceLock -LockName "lock-no-delete-net" -LockLevel CanNotDelete -ResourceGroupName $RgNet -LockNotes "Reseau de production TrackIt" -Force | Out-Null
}
Get-AzResourceLock -ResourceGroupName $RgNet | Format-Table Name, @{n="Niveau";e={$_.Properties.level}}

Write-Host ""
Write-Host "TEST : la commande suivante doit etre refusee par Policy (RequestDisallowedByPolicy) :"
Write-Host "  New-AzResourceGroup -Name rg-test -Location $Loc"
