#!/bin/bash
# Atelier 4 (ticket T4) : deploiement Bicep de 2 VM web en zones + Load Balancer Standard
set -euo pipefail
source "$(dirname "$0")/00-prologue.sh"
cd "$(dirname "$0")"

if [ -z "${ADMIN_PASSWORD:-}" ]; then
  read -r -s -p "Mot de passe administrateur des VM : " ADMIN_PASSWORD; echo
fi

# ---- 1. Transpilation (pedagogique) et previsualisation ----
az bicep build --file trackit-web.bicep --outfile /tmp/trackit-web.json
echo "Template ARM genere : /tmp/trackit-web.json ($(wc -l < /tmp/trackit-web.json) lignes)"
az deployment group what-if -g "$RG_PROD" --template-file trackit-web.bicep \
  --parameters suffix="$SUFFIX" adminPassword="$ADMIN_PASSWORD" webVmCount="${WEB_VM_COUNT:-2}"

# ---- 2. Deploiement ----
az deployment group create -g "$RG_PROD" -n deploy-web-01 --template-file trackit-web.bicep \
  --parameters suffix="$SUFFIX" adminPassword="$ADMIN_PASSWORD" webVmCount="${WEB_VM_COUNT:-2}" -o none
LB_FQDN=$(az deployment group show -g "$RG_PROD" -n deploy-web-01 --query properties.outputs.lbFqdn.value -o tsv)
echo "Site web : http://$LB_FQDN"

# ---- 3. Verifications ----
az vm list -g "$RG_PROD" -d --query "[].{VM:name,Zone:zones[0],Etat:powerState,IP:privateIps}" -o table
az network nic list -g "$RG_PROD" \
  --query "[].{NIC:name,ASG:ipConfigurations[0].applicationSecurityGroups[0].id,Pool:ipConfigurations[0].loadBalancerBackendAddressPools[0].id}" -o table

echo "Attente de nginx (60 s)..."; sleep 60
for i in 1 2 3 4; do curl -s "http://$LB_FQDN" | grep -o "vm-web-0[0-9]" || true; done

# ---- 4. Test de bascule ----
echo "Desallocation de vm-web-01 : le site doit continuer de repondre..."
az vm deallocate -g "$RG_PROD" -n vm-web-01 -o none
sleep 20
for i in 1 2 3; do curl -s "http://$LB_FQDN" | grep -o "vm-web-0[0-9]" || true; done
az vm start -g "$RG_PROD" -n vm-web-01 --no-wait
echo "vm-web-01 redemarre en arriere-plan."
