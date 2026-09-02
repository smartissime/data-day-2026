#!/bin/bash
# =============================================================================
# Bootcamp AZ-104 : TrackIt chez Boreal Logistique
# 00 - Prologue : variables communes et groupes de ressources
# Usage : source ./00-prologue.sh   (a relancer apres chaque pause)
# Auteur : Rodrigue YENGO, ARCHIA365
# =============================================================================

# ---- A PERSONNALISER ----
export SUFFIX="${SUFFIX:-ryo042}"          # vos initiales + 3 chiffres
export LOC="${LOC:-francecentral}"         # repli : westeurope
export ALERT_EMAIL="${ALERT_EMAIL:-abo@archia365.fr}"

# ---- Conventions ----
export RG_PROD="rg-trackit-prod"
export RG_NET="rg-trackit-network"
export RG_SHARED="rg-trackit-shared"
export TAGS="env=prod app=trackit owner=$SUFFIX costcenter=DSI"

export VNET="vnet-trackit-prod"
export ST="sttrackitprod$SUFFIX"
export ACR="acrtrackit$SUFFIX"
export KV="kv-trackit-$SUFFIX"
export LAW="log-trackit-prod"
export RSV="rsv-trackit"

export SUB=$(az account show --query id -o tsv)
export TENANT=$(az account show --query tenantId -o tsv)

echo "Souscription : $(az account show --query name -o tsv) ($SUB)"
echo "Suffixe      : $SUFFIX   Region : $LOC"

# Groupes de ressources (idempotent)
for rg in "$RG_NET" "$RG_PROD" "$RG_SHARED"; do
  az group create -n "$rg" -l "$LOC" --tags $TAGS -o none
done
az group list --query "[?starts_with(name,'rg-trackit')].{Nom:name,Region:location}" -o table
