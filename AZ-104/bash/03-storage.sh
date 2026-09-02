#!/bin/bash
# Atelier 3 (ticket T3) : compte de stockage, blobs, cycle de vie, SAS, Azure Files, point de terminaison prive
set -euo pipefail
source "$(dirname "$0")/00-prologue.sh"
cd "$(dirname "$0")"

# ---- 1. Compte de stockage + protection des donnees ----
az storage account create -g "$RG_PROD" -n "$ST" -l "$LOC" --sku Standard_LRS --kind StorageV2 \
  --access-tier Hot --min-tls-version TLS1_2 --allow-blob-public-access false \
  --allow-shared-key-access true --tags $TAGS -o none
az storage account blob-service-properties update --account-name "$ST" -g "$RG_PROD" \
  --enable-delete-retention true --delete-retention-days 14 \
  --enable-container-delete-retention true --container-delete-retention-days 14 --enable-versioning true -o none
ST_ID=$(az storage account show -g "$RG_PROD" -n "$ST" --query id -o tsv)

# ---- 2. Role de plan de donnees pour soi-meme, conteneur, chargement, niveau Cool ----
ME=$(az ad signed-in-user show --query id -o tsv)
az role assignment create --assignee-object-id "$ME" --assignee-principal-type User \
  --role "Storage Blob Data Contributor" --scope "$ST_ID" -o none
echo "Propagation du role (30 s)..."; sleep 30

az storage container create --account-name "$ST" -n bons-livraison --auth-mode login -o none
echo "Bon de livraison n 1001 - Lyon" > BL-1001.pdf
az storage blob upload --account-name "$ST" -c bons-livraison -f BL-1001.pdf -n 2026/09/BL-1001.pdf --auth-mode login --overwrite -o none
az storage blob set-tier --account-name "$ST" -c bons-livraison -n 2026/09/BL-1001.pdf --tier Cool --auth-mode login
az storage blob list --account-name "$ST" -c bons-livraison --auth-mode login \
  --query "[].{Nom:name,Taille:properties.contentLength,Niveau:properties.blobTier}" -o table

# ---- 3. Cycle de vie ----
az storage account management-policy create --account-name "$ST" -g "$RG_PROD" --policy @lifecycle.json -o none

# ---- 4. SAS de delegation utilisateur, valable 1 h ----
END=$(date -u -d "+1 hour" '+%Y-%m-%dT%H:%MZ')
echo "URL SAS (1 h) :"
az storage blob generate-sas --account-name "$ST" -c bons-livraison -n 2026/09/BL-1001.pdf \
  --permissions r --expiry "$END" --https-only --auth-mode login --as-user --full-uri -o tsv

# ---- 5. Azure Files ----
az storage share-rm create --storage-account "$ST" -g "$RG_PROD" -n agences --quota 100 --enabled-protocols SMB -o none
az storage share-rm list --storage-account "$ST" -g "$RG_PROD" -o table

# ---- 6. Point de terminaison prive + DNS prive + pare-feu (bonus) ----
if [ "${WITH_PRIVATE_ENDPOINT:-yes}" = "yes" ]; then
  az network private-endpoint create -g "$RG_NET" -n pe-st-blob --vnet-name "$VNET" --subnet snet-data \
    --private-connection-resource-id "$ST_ID" --group-id blob --connection-name pe-st-blob-conn -l "$LOC" -o none
  az network private-dns zone create -g "$RG_NET" -n privatelink.blob.core.windows.net -o none
  az network private-dns link vnet create -g "$RG_NET" -n link-trackit -z privatelink.blob.core.windows.net \
    -v "$VNET" -e false -o none
  az network private-endpoint dns-zone-group create -g "$RG_NET" --endpoint-name pe-st-blob -n zg-blob \
    --private-dns-zone privatelink.blob.core.windows.net --zone-name blob -o none
  MYIP=$(curl -s ifconfig.me)
  az storage account update -g "$RG_PROD" -n "$ST" --default-action Deny --bypass AzureServices -o none
  az storage account network-rule add -g "$RG_PROD" -n "$ST" --ip-address "$MYIP" -o none
  echo "Pare-feu actif : acces prive via 10.10.3.x, plus votre IP $MYIP"
fi
