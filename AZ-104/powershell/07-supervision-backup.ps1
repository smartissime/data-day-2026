# Atelier 7 (ticket T7) : Log Analytics, AMA + DCR, diagnostics, alertes, Azure Backup, Network Watcher
$ErrorActionPreference = "Stop"
. "$PSScriptRoot/00-prologue.ps1"
Set-Location $PSScriptRoot

# ---- 1. Log Analytics ----
$law = Get-AzOperationalInsightsWorkspace -ResourceGroupName $RgShared -Name $LawName -ErrorAction SilentlyContinue
if (-not $law) { $law = New-AzOperationalInsightsWorkspace -ResourceGroupName $RgShared -Name $LawName -Location $Loc -Sku PerGB2018 -RetentionInDays 90 -Tag $Tags }

# ---- 2. DCR + Azure Monitor Agent sur les VM web ----
(Get-Content ./dcr-linux.json) -replace "__LAW_ID__", $law.ResourceId -replace "__LOCATION__", $Loc | Set-Content /tmp/dcr-linux.json
$dcr = New-AzDataCollectionRule -ResourceGroupName $RgShared -RuleName "dcr-linux-trackit" -Location $Loc -RuleFile /tmp/dcr-linux.json
foreach ($vmName in "vm-web-01","vm-web-02") {
    $vm = Get-AzVM -ResourceGroupName $RgProd -Name $vmName
    Set-AzVMExtension -ResourceGroupName $RgProd -VMName $vmName -Name "AzureMonitorLinuxAgent" -Publisher "Microsoft.Azure.Monitor" `
        -ExtensionType "AzureMonitorLinuxAgent" -TypeHandlerVersion "1.0" -EnableAutomaticUpgrade $true | Out-Null
    New-AzDataCollectionRuleAssociation -TargetResourceId $vm.Id -AssociationName "dcra-$vmName" -RuleId $dcr.Id | Out-Null
}

# ---- 3. Parametres de diagnostic ----
$lb = Get-AzLoadBalancer -ResourceGroupName $RgProd -Name "lb-trackit-web"
$kv = Get-AzKeyVault -VaultName $KvName
$st = Get-AzStorageAccount -ResourceGroupName $RgProd -Name $StName
$logAll   = New-AzDiagnosticSettingLogSettingsObject    -Enabled $true -CategoryGroup "allLogs"
$logAudit = New-AzDiagnosticSettingLogSettingsObject    -Enabled $true -CategoryGroup "audit"
$metAll   = New-AzDiagnosticSettingMetricSettingsObject -Enabled $true -Category "AllMetrics"
$metTx    = New-AzDiagnosticSettingMetricSettingsObject -Enabled $true -Category "Transaction"
New-AzDiagnosticSetting -Name "diag-lb"      -ResourceId $lb.Id          -WorkspaceId $law.ResourceId -Log $logAll   -Metric $metAll | Out-Null
New-AzDiagnosticSetting -Name "diag-kv"      -ResourceId $kv.ResourceId  -WorkspaceId $law.ResourceId -Log $logAudit | Out-Null
New-AzDiagnosticSetting -Name "diag-st-blob" -ResourceId "$($st.Id)/blobServices/default" -WorkspaceId $law.ResourceId -Log $logAll -Metric $metTx | Out-Null

# ---- 4. Groupe d'actions et alertes ----
$emailDsi = New-AzActionGroupEmailReceiverObject -Name "dsi" -EmailAddress $AlertEmail
$ag = New-AzActionGroup -ResourceGroupName $RgShared -Name "ag-dsi" -ShortName "dsi" -Location "Global" -EmailReceiver $emailDsi

$vmIds = (Get-AzVM -ResourceGroupName $RgProd | Where-Object Name -like "vm-web-*").Id
$condCpu = New-AzMetricAlertRuleV2Criteria -MetricName "Percentage CPU" -MetricNamespace "Microsoft.Compute/virtualMachines" -TimeAggregation Average -Operator GreaterThan -Threshold 80
Add-AzMetricAlertRuleV2 -Name "alert-cpu-web" -ResourceGroupName $RgProd -Severity 2 `
    -TargetResourceScope $vmIds -TargetResourceType "Microsoft.Compute/virtualMachines" -TargetResourceRegion $Loc `
    -WindowSize (New-TimeSpan -Minutes 5) -Frequency (New-TimeSpan -Minutes 1) -Condition $condCpu -ActionGroupId $ag.Id `
    -Description "CPU web superieure a 80 % pendant 5 min" | Out-Null

$c1 = New-AzActivityLogAlertAlertRuleAnyOfOrLeafConditionObject -Field "category"      -Equal "Administrative"
$c2 = New-AzActivityLogAlertAlertRuleAnyOfOrLeafConditionObject -Field "operationName" -Equal "Microsoft.Compute/virtualMachines/deallocate/action"
$agRef = New-AzActivityLogAlertActionGroupObject -Id $ag.Id
New-AzActivityLogAlert -Name "alert-vm-deallocate" -ResourceGroupName $RgProd -Location "Global" -Scope "/subscriptions/$SubId" -Condition @($c1, $c2) -Action $agRef | Out-Null

$condLb = New-AzMetricAlertRuleV2Criteria -MetricName "DipAvailability" -MetricNamespace "Microsoft.Network/loadBalancers" -TimeAggregation Average -Operator LessThan -Threshold 50
Add-AzMetricAlertRuleV2 -Name "alert-lb-health" -ResourceGroupName $RgProd -Severity 1 -TargetResourceId $lb.Id `
    -WindowSize (New-TimeSpan -Minutes 5) -Frequency (New-TimeSpan -Minutes 1) -Condition $condLb -ActionGroupId $ag.Id | Out-Null
Get-AzMetricAlertRuleV2 -ResourceGroupName $RgProd | Format-Table Name, Severity, Enabled

# ---- 5. Azure Backup ----
$vault = Get-AzRecoveryServicesVault -ResourceGroupName $RgShared -Name $RsvName -ErrorAction SilentlyContinue
if (-not $vault) {
    $vault = New-AzRecoveryServicesVault -ResourceGroupName $RgShared -Name $RsvName -Location $Loc -Tag $Tags
    Set-AzRecoveryServicesBackupProperty -Vault $vault -BackupStorageRedundancy LocallyRedundant
}
Set-AzRecoveryServicesVaultContext -Vault $vault
$policy = Get-AzRecoveryServicesBackupProtectionPolicy -Name "DefaultPolicy"
Enable-AzRecoveryServicesBackupProtection -Policy $policy -Name "vm-web-01" -ResourceGroupName $RgProd | Out-Null
$container = Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM -FriendlyName "vm-web-01"
$item      = Get-AzRecoveryServicesBackupItem -Container $container -WorkloadType AzureVM
Backup-AzRecoveryServicesBackupItem -Item $item -ExpiryDateTimeUTC (Get-Date).AddDays(3).ToUniversalTime() | Out-Null
Get-AzRecoveryServicesBackupJob | Format-Table WorkloadName, Operation, Status, StartTime

# ---- 6. Network Watcher ----
$nw   = Get-AzNetworkWatcher -Location $Loc
$vm1  = Get-AzVM -ResourceGroupName $RgProd -Name "vm-web-01"
$nic1 = Get-AzNetworkInterface -ResourceId $vm1.NetworkProfile.NetworkInterfaces[0].Id
Write-Host "IP flow verify : SSH depuis Internet vers vm-web-01 (attendu : Deny par Deny-All-Inbound)"
Test-AzNetworkWatcherIPFlow -NetworkWatcher $nw -TargetVirtualMachineId $vm1.Id -Direction Inbound -Protocol TCP `
    -LocalIPAddress $nic1.IpConfigurations[0].PrivateIpAddress -LocalPort 22 -RemoteIPAddress 203.0.113.10 -RemotePort 50000 | Format-List Access, RuleName
$ApiIp = (Get-AzContainerGroup -ResourceGroupName $RgProd -Name "aci-trackit-api").IPAddressIP
$vm2 = Get-AzVM -ResourceGroupName $RgProd -Name "vm-web-02"
Write-Host "Connection troubleshoot : vm-web-02 vers l'API ${ApiIp}:8080 (attendu : Reachable)"
Test-AzNetworkWatcherConnectivity -NetworkWatcher $nw -SourceId $vm2.Id -DestinationAddress $ApiIp -DestinationPort 8080 | Format-List ConnectionStatus, AvgLatencyInMs

Write-Host ""
Write-Host "Pour declencher les alertes : Stop-AzVM -ResourceGroupName $RgProd -Name vm-web-02 -Force"
