#!/bin/bash
# Atelier 1 (ticket T1) : Entra ID, RBAC, Azure Policy, verrous
set -euo pipefail
source "$(dirname "$0")/00-prologue.sh"

DOMAIN=$(az rest --method get --url "https://graph.microsoft.com/v1.0/domains" --query "value[?isDefault].id" -o tsv)
echo "Domaine Entra : $DOMAIN"

# ---- 1. Utilisateurs et groupes ----
for u in chef.lyon chef.nantes chef.lille dev.novadev; do
  if ! az ad user show --id "$u@$DOMAIN" -o none 2>/dev/null; then
    az ad user create --display-name "$u" --user-principal-name "$u@$DOMAIN" \
      --password "Bootcamp-AZ104-$RANDOM!" --force-change-password-next-sign-in true -o none
    echo "Utilisateur cree : $u@$DOMAIN"
  fi
done

for g in grp-trackit-admins grp-trackit-readers grp-novadev; do
  if [ -z "$(az ad group list --display-name "$g" --query "[0].id" -o tsv)" ]; then
    az ad group create --display-name "$g" --mail-nickname "$g" -o none
    echo "Groupe cree : $g"
  fi
done

READERS_ID=$(az ad group show -g grp-trackit-readers --query id -o tsv)
NOVADEV_ID=$(az ad group show -g grp-novadev --query id -o tsv)
ADMINS_ID=$(az ad group show -g grp-trackit-admins --query id -o tsv)

for u in chef.lyon chef.nantes chef.lille; do
  az ad group member add -g grp-trackit-readers --member-id "$(az ad user show --id "$u@$DOMAIN" --query id -o tsv)" 2>/dev/null || true
done
az ad group member add -g grp-novadev --member-id "$(az ad user show --id "dev.novadev@$DOMAIN" --query id -o tsv)" 2>/dev/null || true
az ad group member add -g grp-trackit-admins --member-id "$(az ad signed-in-user show --query id -o tsv)" 2>/dev/null || true

# Invitation B2B (demonstration, l'acceptation n'est pas necessaire)
az rest --method post --url "https://graph.microsoft.com/v1.0/invitations" \
  --body '{"invitedUserEmailAddress":"externe@novadev.fr","inviteRedirectUrl":"https://portal.azure.com","sendInvitationMessage":false}' -o none || true

# ---- 2. RBAC ----
az role assignment create --assignee-object-id "$ADMINS_ID"  --assignee-principal-type Group --role "Owner"                  --scope "/subscriptions/$SUB" -o none
az role assignment create --assignee-object-id "$READERS_ID" --assignee-principal-type Group --role "Reader"                 --scope "/subscriptions/$SUB" -o none
az role assignment create --assignee-object-id "$READERS_ID" --assignee-principal-type Group --role "Cost Management Reader" --scope "/subscriptions/$SUB" -o none
az role assignment create --assignee-object-id "$NOVADEV_ID" --assignee-principal-type Group --role "Contributor"            --scope "/subscriptions/$SUB/resourceGroups/$RG_PROD" -o none

echo "--- Attributions sur $RG_PROD (avec heritage) ---"
az role assignment list -g "$RG_PROD" --include-inherited --query "[].{Principal:principalName,Role:roleDefinitionName,Scope:scope}" -o table

# ---- 3. Azure Policy ----
az policy assignment create --name "req-tag-costcenter" --display-name "Tag costcenter obligatoire" \
  --policy "1e30110a-5ceb-460c-a204-c1c3969c6d62" --scope "/subscriptions/$SUB" \
  --params '{"tagName":{"value":"costcenter"},"tagValue":{"value":"DSI"}}' -o none
az policy assignment create --name "allowed-locations" --display-name "Regions autorisees" \
  --policy "e56962a6-4747-49cd-b67b-bf8b01975c4c" --scope "/subscriptions/$SUB" \
  --params '{"listOfAllowedLocations":{"value":["francecentral","westeurope"]}}' -o none
az policy assignment list --query "[].{Nom:name,Affichage:displayName}" -o table

# ---- 4. Verrou ----
az lock create --name lock-no-delete-net --lock-type CanNotDelete --resource-group "$RG_NET" \
  --notes "Reseau de production TrackIt" -o none
az lock list -g "$RG_NET" -o table

echo
echo "TEST : la commande suivante doit etre refusee par Policy (RequestDisallowedByPolicy) :"
echo "  az group create -n rg-test -l $LOC"
