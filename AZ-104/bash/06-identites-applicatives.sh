#!/bin/bash
# Atelier 6 (ticket T6) : app registration, principal de service du pipeline, Key Vault, identite manageee
set -euo pipefail
source "$(dirname "$0")/00-prologue.sh"

REDIRECT="http://trackit-$SUFFIX.$LOC.cloudapp.azure.com/signin-oidc"
GRAPH_APP="00000003-0000-0000-c000-000000000000"
USER_READ="e1fe6dd8-ba31-4d61-89e7-88639da4683d"

# ---- 1. App registration TrackIt-Web ----
APP_ID=$(az ad app list --display-name TrackIt-Web --query "[0].appId" -o tsv)
if [ -z "$APP_ID" ]; then
  APP_ID=$(az ad app create --display-name TrackIt-Web --sign-in-audience AzureADMyOrg \
     --web-redirect-uris "$REDIRECT" --enable-id-token-issuance true --query appId -o tsv)
fi
az ad app update --id "$APP_ID" --identifier-uris "api://$APP_ID"
az ad sp create --id "$APP_ID" -o none 2>/dev/null || true
SP_ID=$(az ad sp show --id "$APP_ID" --query id -o tsv)

az ad app permission add --id "$APP_ID" --api "$GRAPH_APP" --api-permissions "$USER_READ=Scope" -o none 2>/dev/null || true
az ad app permission admin-consent --id "$APP_ID"
az ad sp update --id "$APP_ID" --set appRoleAssignmentRequired=true

# Affecter le groupe des lecteurs a l'application (role par defaut)
READERS_ID=$(az ad group show -g grp-trackit-readers --query id -o tsv)
az rest --method post --url "https://graph.microsoft.com/v1.0/groups/$READERS_ID/appRoleAssignments" \
  --body "{\"principalId\":\"$READERS_ID\",\"resourceId\":\"$SP_ID\",\"appRoleId\":\"00000000-0000-0000-0000-000000000000\"}" -o none 2>/dev/null || true

# Secret client (visible une seule fois)
CLIENT_SECRET=$(az ad app credential reset --id "$APP_ID" --display-name bootcamp --years 1 --query password -o tsv)
echo "AppId TrackIt-Web : $APP_ID"
echo "URL de test (chef.lyon doit passer, dev.novadev doit etre refuse AADSTS50105) :"
echo "https://login.microsoftonline.com/$TENANT/oauth2/v2.0/authorize?client_id=$APP_ID&response_type=id_token&redirect_uri=$REDIRECT&scope=openid&nonce=123&response_mode=fragment"

# ---- 2. Principal de service du pipeline ----
ACR_ID=$(az acr show -n "$ACR" --query id -o tsv)
echo "Creation de sp-trackit-deploy (conserver la sortie JSON pour le pipeline) :"
az ad sp create-for-rbac -n sp-trackit-deploy --role Contributor --scopes "/subscriptions/$SUB/resourceGroups/$RG_PROD"
SP_DEPLOY_ID=$(az ad sp list --display-name sp-trackit-deploy --query "[0].id" -o tsv)
az role assignment create --assignee-object-id "$SP_DEPLOY_ID" --assignee-principal-type ServicePrincipal \
  --role AcrPush --scope "$ACR_ID" -o none

# ---- 3. Key Vault ----
az keyvault create -g "$RG_SHARED" -n "$KV" -l "$LOC" --enable-rbac-authorization true \
  --enable-purge-protection true --retention-days 90 --tags $TAGS -o none
KV_ID=$(az keyvault show -n "$KV" --query id -o tsv)
ME=$(az ad signed-in-user show --query id -o tsv)
az role assignment create --assignee-object-id "$ME" --assignee-principal-type User \
  --role "Key Vault Secrets Officer" --scope "$KV_ID" -o none
echo "Propagation du role (30 s)..."; sleep 30

if [ -z "${ADMIN_PASSWORD:-}" ]; then read -r -s -p "Mot de passe administrateur des VM (a stocker dans Key Vault) : " ADMIN_PASSWORD; echo; fi
az keyvault secret set --vault-name "$KV" -n vm-admin-password         --value "$ADMIN_PASSWORD" -o none
az keyvault secret set --vault-name "$KV" -n trackit-web-client-secret --value "$CLIENT_SECRET" -o none
az keyvault secret list --vault-name "$KV" --query "[].{Nom:name,Actif:attributes.enabled}" -o table

# ---- 4. Identite manageee de l'API : lecture des secrets et des blobs sans cle ----
ID_PRIN=$(az identity show -g "$RG_SHARED" -n id-trackit-api --query principalId -o tsv)
ST_ID=$(az storage account show -g "$RG_PROD" -n "$ST" --query id -o tsv)
az role assignment create --assignee-object-id "$ID_PRIN" --assignee-principal-type ServicePrincipal --role "Key Vault Secrets User"   --scope "$KV_ID" -o none
az role assignment create --assignee-object-id "$ID_PRIN" --assignee-principal-type ServicePrincipal --role "Storage Blob Data Reader" --scope "$ST_ID" -o none

# ---- 5. Fichier de parametres Bicep pointant vers Key Vault ----
sed -e "s/<subscription-id>/$SUB/" -e "s/ryo042/$SUFFIX/g" main.bicepparam > /tmp/main.$SUFFIX.bicepparam
echo "Previsualisation d'un redeploiement dont le mot de passe vient de Key Vault :"
az deployment group what-if -g "$RG_PROD" --parameters /tmp/main.$SUFFIX.bicepparam
