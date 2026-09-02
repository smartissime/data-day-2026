#!/bin/bash
# Atelier 7 (ticket T7) : Log Analytics, AMA + DCR, diagnostics, alertes, Azure Backup, Network Watcher
set -euo pipefail
source "$(dirname "$0")/00-prologue.sh"
cd "$(dirname "$0")"

# ---- 1. Log Analytics ----
az monitor log-analytics workspace create -g "$RG_SHARED" -n "$LAW" -l "$LOC" --retention-time 90 --tags $TAGS -o none
LAW_ID=$(az monitor log-analytics workspace show -g "$RG_SHARED" -n "$LAW" --query id -o tsv)

# ---- 2. DCR + Azure Monitor Agent sur les VM web ----
sed -e "s#__LAW_ID__#$LAW_ID#" -e "s#__LOCATION__#$LOC#" dcr-linux.json > /tmp/dcr-linux.json
az monitor data-collection rule create -g "$RG_SHARED" -n dcr-linux-trackit -l "$LOC" --rule-file /tmp/dcr-linux.json -o none
DCR_ID=$(az monitor data-collection rule show -g "$RG_SHARED" -n dcr-linux-trackit --query id -o tsv)
for vm in vm-web-01 vm-web-02; do
  VM_ID=$(az vm show -g "$RG_PROD" -n "$vm" --query id -o tsv)
  az vm extension set -g "$RG_PROD" --vm-name "$vm" -n AzureMonitorLinuxAgent --publisher Microsoft.Azure.Monitor --enable-auto-upgrade true -o none
  az monitor data-collection rule association create -n "dcra-$vm" --rule-id "$DCR_ID" --resource "$VM_ID" -o none
done

# ---- 3. Parametres de diagnostic ----
LB_ID=$(az network lb show -g "$RG_PROD" -n lb-trackit-web --query id -o tsv)
KV_ID=$(az keyvault show -n "$KV" --query id -o tsv)
ST_ID=$(az storage account show -g "$RG_PROD" -n "$ST" --query id -o tsv)
az monitor diagnostic-settings create -n diag-lb --resource "$LB_ID" --workspace "$LAW_ID" \
  --metrics '[{"category":"AllMetrics","enabled":true}]' --logs '[{"categoryGroup":"allLogs","enabled":true}]' -o none
az monitor diagnostic-settings create -n diag-kv --resource "$KV_ID" --workspace "$LAW_ID" \
  --logs '[{"categoryGroup":"audit","enabled":true}]' -o none
az monitor diagnostic-settings create -n diag-st-blob --resource "$ST_ID/blobServices/default" --workspace "$LAW_ID" \
  --metrics '[{"category":"Transaction","enabled":true}]' --logs '[{"categoryGroup":"allLogs","enabled":true}]' -o none

# ---- 4. Groupe d'actions et alertes ----
az monitor action-group create -g "$RG_SHARED" -n ag-dsi --short-name dsi --action email dsi "$ALERT_EMAIL" -o none
AG_ID=$(az monitor action-group show -g "$RG_SHARED" -n ag-dsi --query id -o tsv)
VM1=$(az vm show -g "$RG_PROD" -n vm-web-01 --query id -o tsv)
VM2=$(az vm show -g "$RG_PROD" -n vm-web-02 --query id -o tsv)

az monitor metrics alert create -g "$RG_PROD" -n alert-cpu-web --scopes "$VM1" "$VM2" \
  --condition "avg Percentage CPU > 80" --window-size 5m --evaluation-frequency 1m --severity 2 \
  --action "$AG_ID" --description "CPU web superieure a 80 % pendant 5 min" -o none
az monitor activity-log alert create -g "$RG_PROD" -n alert-vm-deallocate --scope "/subscriptions/$SUB" \
  --condition category=Administrative and operationName=Microsoft.Compute/virtualMachines/deallocate/action \
  --action-group "$AG_ID" -o none
az monitor metrics alert create -g "$RG_PROD" -n alert-lb-health --scopes "$LB_ID" \
  --condition "avg DipAvailability < 50" --window-size 5m --evaluation-frequency 1m --severity 1 --action "$AG_ID" -o none
az monitor metrics alert list -g "$RG_PROD" --query "[].{Alerte:name,Gravite:severity,Active:enabled}" -o table

# ---- 5. Azure Backup ----
az backup vault create -g "$RG_SHARED" -n "$RSV" -l "$LOC" --tags $TAGS -o none
az backup vault backup-properties set -g "$RG_SHARED" -n "$RSV" --backup-storage-redundancy LocallyRedundant -o none
az backup protection enable-for-vm -g "$RG_SHARED" -v "$RSV" --vm "$VM1" --policy-name DefaultPolicy -o none
RETAIN=$(date -u -d "+3 days" '+%d-%m-%Y')
az backup protection backup-now -g "$RG_SHARED" -v "$RSV" -c vm-web-01 -i vm-web-01 --retain-until "$RETAIN" -o none
az backup job list -g "$RG_SHARED" -v "$RSV" -o table

# ---- 6. Network Watcher ----
echo "IP flow verify : SSH depuis Internet vers vm-web-01 (attendu : Deny par Deny-All-Inbound)"
IP1=$(az vm list-ip-addresses -g "$RG_PROD" -n vm-web-01 --query "[0].virtualMachine.network.privateIpAddresses[0]" -o tsv)
az network watcher test-ip-flow --vm vm-web-01 -g "$RG_PROD" --direction Inbound --protocol TCP \
  --local "$IP1:22" --remote "203.0.113.10:50000" -o table
API_IP=$(az container show -g "$RG_PROD" -n aci-trackit-api --query ipAddress.ip -o tsv)
echo "Connection troubleshoot : vm-web-02 vers l'API $API_IP:8080 (attendu : Reachable)"
az network watcher test-connectivity -g "$RG_PROD" --source-resource vm-web-02 --dest-address "$API_IP" --dest-port 8080 \
  --query "{Statut:connectionStatus,LatenceMs:avgLatencyInMs}" -o table

echo
echo "Pour declencher les alertes : az vm deallocate -g $RG_PROD -n vm-web-02"
