# Nettoyage complet, dans l'ordre impose par le coffre et le verrou
param([switch]$DeleteEntraTestObjects)
$ErrorActionPreference = "Continue"
. "$PSScriptRoot/00-prologue.ps1"

Write-Host "1. Arret de la protection Backup et suppression des donnees"
$vault = Get-AzRecoveryServicesVault -ResourceGroupName $RgShared -Name $RsvName -ErrorAction SilentlyContinue
if ($vault) {
    Set-AzRecoveryServicesVaultContext -Vault $vault
    $item = Get-AzRecoveryServicesBackupItem -BackupManagementType AzureVM -WorkloadType AzureVM -Name "vm-web-01" -ErrorAction SilentlyContinue
    if ($item) { Disable-AzRecoveryServicesBackupProtection -Item $item -RemoveRecoveryPoints -Force | Out-Null }
}

Write-Host "2. Suppression du verrou"
Remove-AzResourceLock -LockName "lock-no-delete-net" -ResourceGroupName $RgNet -Force -ErrorAction SilentlyContinue | Out-Null

Write-Host "3. Suppression des groupes de ressources (arriere-plan)"
foreach ($rg in $RgProd, $RgNet, $RgShared) { Remove-AzResourceGroup -Name $rg -Force -AsJob -ErrorAction SilentlyContinue | Out-Null }

Write-Host "4. Entra ID et Policy"
$app = Get-MgApplication -Filter "displayName eq 'TrackIt-Web'"
if ($app) { Remove-MgApplication -ApplicationId $app.Id }
$spDeploy = Get-AzADServicePrincipal -DisplayName "sp-trackit-deploy"
if ($spDeploy) { Remove-AzADApplication -ApplicationId $spDeploy.AppId }
Remove-AzPolicyAssignment -Name "req-tag-costcenter" -Scope "/subscriptions/$SubId" -ErrorAction SilentlyContinue
Remove-AzPolicyAssignment -Name "allowed-locations"  -Scope "/subscriptions/$SubId" -ErrorAction SilentlyContinue

if ($DeleteEntraTestObjects) {
    $Domain = (Get-MgDomain | Where-Object IsDefault).Id
    foreach ($u in "chef.lyon","chef.nantes","chef.lille","dev.novadev") { Remove-MgUser -UserId "$u@$Domain" -ErrorAction SilentlyContinue }
    foreach ($g in "grp-trackit-admins","grp-trackit-readers","grp-novadev") {
        $grp = Get-MgGroup -Filter "displayName eq '$g'"; if ($grp) { Remove-MgGroup -GroupId $grp.Id }
    }
}

Get-Job | Wait-Job | Format-Table Name, State
Write-Host "Termine. Le Key Vault $KvName reste en suppression reversible 90 jours (protection contre la purge) : c'est normal."
