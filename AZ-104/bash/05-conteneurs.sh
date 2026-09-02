#!/bin/bash
# Atelier 5 (ticket T5) : ACR, construction de l'image, ACI dans le VNet avec identite manageee
set -euo pipefail
source "$(dirname "$0")/00-prologue.sh"
cd "$(dirname "$0")"

# ---- 1. Registre ----
az acr create -g "$RG_SHARED" -n "$ACR" --sku Standard -l "$LOC" --admin-enabled false --tags $TAGS -o none
ACR_ID=$(az acr show -n "$ACR" --query id -o tsv)
ACR_SERVER=$(az acr show -n "$ACR" --query loginServer -o tsv)

# ---- 2. Construction a distance (ACR Tasks) ----
az acr build -r "$ACR" -t trackit-api:1.0 ./api
az acr repository show-tags -n "$ACR" --repository trackit-api -o table

# ---- 3. Identite manageee + AcrPull ----
az identity create -g "$RG_SHARED" -n id-trackit-api -l "$LOC" --tags $TAGS -o none
ID_RES=$(az identity show -g "$RG_SHARED" -n id-trackit-api --query id -o tsv)
ID_PRIN=$(az identity show -g "$RG_SHARED" -n id-trackit-api --query principalId -o tsv)
echo "Propagation de l'identite (30 s)..."; sleep 30
az role assignment create --assignee-object-id "$ID_PRIN" --assignee-principal-type ServicePrincipal \
  --role AcrPull --scope "$ACR_ID" -o none

# ---- 4. ACI dans snet-app ----
SUBNET_APP=$(az network vnet subnet show -g "$RG_NET" --vnet-name "$VNET" -n snet-app --query id -o tsv)
az container create -g "$RG_PROD" -n aci-trackit-api -l "$LOC" \
  --image "$ACR_SERVER/trackit-api:${API_VERSION:-1.0}" --acr-identity "$ID_RES" --assign-identity "$ID_RES" \
  --cpu 1 --memory 1.5 --ports 8080 --os-type Linux \
  --subnet "$SUBNET_APP" --restart-policy Always \
  --environment-variables API_VERSION="${API_VERSION:-1.0}" --tags $TAGS -o none
API_IP=$(az container show -g "$RG_PROD" -n aci-trackit-api --query ipAddress.ip -o tsv)
echo "API TrackIt : http://$API_IP:8080  (privee, joignable depuis asg-web uniquement)"
az container logs -g "$RG_PROD" -n aci-trackit-api || true

# ---- 5. Brancher le front nginx sur l'API via Run Command (sans session interactive) ----
for vm in vm-web-01 vm-web-02; do
  az vm run-command invoke -g "$RG_PROD" -n "$vm" --command-id RunShellScript \
    --scripts @nginx-proxy.sh --parameters "$API_IP" --query "value[0].message" -o tsv | tail -n 3
done
LB_FQDN=$(az network public-ip show -g "$RG_PROD" -n pip-trackit-lb --query dnsSettings.fqdn -o tsv)
echo "Test de bout en bout :"
curl -s "http://$LB_FQDN/api/palettes/PAL-7781"; echo
