# =============================================================================
# Bootcamp AZ-104 : TrackIt chez Boreal Logistique
# 00 - Prologue : variables communes, connexion Graph, groupes de ressources
# Usage : . ./00-prologue.ps1    (dot sourcing, a relancer apres chaque pause)
# Auteur : Rodrigue YENGO, ARCHIA365
# =============================================================================

# ---- A PERSONNALISER ----
if (-not $Suffix)     { $Suffix     = "ryo042" }          # vos initiales + 3 chiffres
if (-not $Loc)        { $Loc        = "francecentral" }   # repli : westeurope
if (-not $AlertEmail) { $AlertEmail = "abo@archia365.fr" }

# ---- Conventions ----
$RgProd   = "rg-trackit-prod"
$RgNet    = "rg-trackit-network"
$RgShared = "rg-trackit-shared"
$Tags     = @{ env = "prod"; app = "trackit"; owner = $Suffix; costcenter = "DSI" }

$VnetName = "vnet-trackit-prod"
$StName   = "sttrackitprod$Suffix"
$AcrName  = "acrtrackit$Suffix"
$KvName   = "kv-trackit-$Suffix"
$LawName  = "log-trackit-prod"
$RsvName  = "rsv-trackit"

$ctxAz    = Get-AzContext
if (-not $ctxAz) { Connect-AzAccount | Out-Null; $ctxAz = Get-AzContext }
$SubId    = $ctxAz.Subscription.Id
$TenantId = $ctxAz.Tenant.Id
Write-Host "Souscription : $($ctxAz.Subscription.Name) ($SubId)"
Write-Host "Suffixe      : $Suffix   Region : $Loc"

# ---- Microsoft Graph (Entra ID) ----
if (-not (Get-Module -ListAvailable Microsoft.Graph.Users)) {
    Install-Module Microsoft.Graph -Scope CurrentUser -Force
}
if (-not (Get-MgContext)) {
    Connect-MgGraph -Scopes "User.ReadWrite.All","Group.ReadWrite.All","Application.ReadWrite.All",
        "AppRoleAssignment.ReadWrite.All","DelegatedPermissionGrant.ReadWrite.All","Domain.Read.All","User.Invite.All" -NoWelcome
}

# ---- Groupes de ressources (idempotent) ----
foreach ($rg in $RgNet, $RgProd, $RgShared) {
    if (-not (Get-AzResourceGroup -Name $rg -ErrorAction SilentlyContinue)) {
        New-AzResourceGroup -Name $rg -Location $Loc -Tag $Tags | Out-Null
    }
}
Get-AzResourceGroup | Where-Object ResourceGroupName -like "rg-trackit*" | Format-Table ResourceGroupName, Location
