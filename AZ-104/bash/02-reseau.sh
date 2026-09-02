#!/bin/bash
# Atelier 2 (ticket T2) : VNet, sous-reseaux, ASG, NSG, Bastion
set -euo pipefail
source "$(dirname "$0")/00-prologue.sh"

# ---- 1. VNet et sous-reseaux ----
az network vnet create -g "$RG_NET" -n "$VNET" --address-prefix 10.10.0.0/16 -l "$LOC" --tags $TAGS -o none
az network vnet subnet create -g "$RG_NET" --vnet-name "$VNET" -n snet-web  --address-prefix 10.10.1.0/24 -o none
az network vnet subnet create -g "$RG_NET" --vnet-name "$VNET" -n snet-app  --address-prefix 10.10.2.0/24 \
   --delegations Microsoft.ContainerInstance/containerGroups -o none
az network vnet subnet create -g "$RG_NET" --vnet-name "$VNET" -n snet-data --address-prefix 10.10.3.0/24 -o none
az network vnet subnet create -g "$RG_NET" --vnet-name "$VNET" -n AzureBastionSubnet --address-prefix 10.10.250.0/26 -o none

# ---- 2. ASG ----
az network asg create -g "$RG_NET" -n asg-web -l "$LOC" -o none
az network asg create -g "$RG_NET" -n asg-app -l "$LOC" -o none

# ---- 3. NSG ----
deny_all() {  # $1 = nom du NSG
  az network nsg rule create -g "$RG_NET" --nsg-name "$1" -n Deny-All-Inbound --priority 4000 \
    --source-address-prefixes '*' --destination-address-prefixes '*' \
    --destination-port-ranges '*' --access Deny --protocol '*' -o none
}

# nsg-web
az network nsg create -g "$RG_NET" -n nsg-web -l "$LOC" --tags $TAGS -o none
az network nsg rule create -g "$RG_NET" --nsg-name nsg-web -n Allow-HTTP-From-LB --priority 100 \
  --source-address-prefixes AzureLoadBalancer --destination-asgs asg-web \
  --destination-port-ranges 80 --access Allow --protocol Tcp -o none
az network nsg rule create -g "$RG_NET" --nsg-name nsg-web -n Allow-HTTP-Internet --priority 110 \
  --source-address-prefixes Internet --destination-asgs asg-web \
  --destination-port-ranges 80 443 --access Allow --protocol Tcp -o none
az network nsg rule create -g "$RG_NET" --nsg-name nsg-web -n Allow-SSH-From-Bastion --priority 120 \
  --source-address-prefixes 10.10.250.0/26 --destination-asgs asg-web \
  --destination-port-ranges 22 --access Allow --protocol Tcp -o none
deny_all nsg-web
az network vnet subnet update -g "$RG_NET" --vnet-name "$VNET" -n snet-web --network-security-group nsg-web -o none

# nsg-app
az network nsg create -g "$RG_NET" -n nsg-app -l "$LOC" --tags $TAGS -o none
az network nsg rule create -g "$RG_NET" --nsg-name nsg-app -n Allow-API-From-Web --priority 100 \
  --source-asgs asg-web --destination-asgs asg-app --destination-port-ranges 8080 --access Allow --protocol Tcp -o none
deny_all nsg-app
az network vnet subnet update -g "$RG_NET" --vnet-name "$VNET" -n snet-app --network-security-group nsg-app -o none

# nsg-data
az network nsg create -g "$RG_NET" -n nsg-data -l "$LOC" --tags $TAGS -o none
az network nsg rule create -g "$RG_NET" --nsg-name nsg-data -n Allow-HTTPS-From-App --priority 100 \
  --source-asgs asg-app --destination-address-prefixes '*' --destination-port-ranges 443 --access Allow --protocol Tcp -o none
deny_all nsg-data
az network vnet subnet update -g "$RG_NET" --vnet-name "$VNET" -n snet-data --network-security-group nsg-data -o none

az network vnet subnet list -g "$RG_NET" --vnet-name "$VNET" \
  --query "[].{Subnet:name,Prefix:addressPrefix,NSG:networkSecurityGroup.id}" -o table

# ---- 4. Bastion (long : lance en arriere-plan) ----
az network public-ip create -g "$RG_NET" -n pip-bastion --sku Standard --allocation-method Static -l "$LOC" --tags $TAGS -o none
az network bastion create -g "$RG_NET" -n bas-trackit --vnet-name "$VNET" \
  --public-ip-address pip-bastion -l "$LOC" --sku Basic --no-wait
echo "Bastion en cours de creation (8 a 10 min). Suivi : az network bastion show -g $RG_NET -n bas-trackit --query provisioningState"
