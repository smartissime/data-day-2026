#!/bin/bash
# Nettoyage complet, dans l'ordre impose par le coffre et le verrou
set -uo pipefail
source "$(dirname "$0")/00-prologue.sh"

echo "1. Arret de la protection Backup et suppression des donnees"
az backup protection disable -g "$RG_SHARED" -v "$RSV" -c vm-web-01 -i vm-web-01 --delete-backup-data true --yes -o none 2>/dev/null

echo "2. Suppression du verrou"
az lock delete --name lock-no-delete-net --resource-group "$RG_NET" 2>/dev/null

echo "3. Suppression des groupes de ressources (arriere-plan)"
for rg in "$RG_PROD" "$RG_NET" "$RG_SHARED"; do az group delete -n "$rg" --yes --no-wait 2>/dev/null; done

echo "4. Entra ID et Policy"
APP_ID=$(az ad app list --display-name TrackIt-Web --query "[0].appId" -o tsv)
[ -n "$APP_ID" ] && az ad app delete --id "$APP_ID"
SP_DEPLOY_APP=$(az ad sp list --display-name sp-trackit-deploy --query "[0].appId" -o tsv)
[ -n "$SP_DEPLOY_APP" ] && az ad app delete --id "$SP_DEPLOY_APP"
az policy assignment delete --name req-tag-costcenter 2>/dev/null
az policy assignment delete --name allowed-locations 2>/dev/null

if [ "${DELETE_ENTRA_TEST_OBJECTS:-no}" = "yes" ]; then
  DOMAIN=$(az rest --method get --url "https://graph.microsoft.com/v1.0/domains" --query "value[?isDefault].id" -o tsv)
  for u in chef.lyon chef.nantes chef.lille dev.novadev; do az ad user delete --id "$u@$DOMAIN" 2>/dev/null; done
  for g in grp-trackit-admins grp-trackit-readers grp-novadev; do az ad group delete -g "$g" 2>/dev/null; done
fi

echo "Termine. Le Key Vault $KV reste en suppression reversible 90 jours (protection contre la purge) : c'est normal."
echo "Suivi : az group list --query \"[?starts_with(name,'rg-trackit')].name\" -o tsv"
