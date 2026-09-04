# Bootcamp AZ-104 : scénario fil rouge « TrackIt chez Boréal Logistique »

| | |
|---|---|
| **Auteur** | Rodrigue YENGO |
| **Entreprise** | ARCHIA365 |
| **Adresse** | Bureau 326, 59 rue de Ponthieu, 75008 Paris |
| **LinkedIn** | https://www.linkedin.com/company/130004016 et https://www.linkedin.com/company/26302862 |
| **YouTube** | ArchiFridays : https://www.youtube.com/@ArchiFridays |
| **Version** | 1.1, septembre 2026 |

> **Durée :** 7 h de formation effective (2 pauses de 15 min incluses, déjeuner hors créneau)
> **Format :** démo formateur, puis reproduction par les participants (1 souscription par participant)
> **Public :** administrateurs et techniciens infrastructure préparant l'examen AZ-104 (Microsoft Azure Administrator)
> **Outils :** portail Azure, Azure Cloud Shell (Bash, Azure CLI, Bicep), VS Code avec l'extension Bicep (optionnel), Docker Desktop (optionnel, ACR sait construire les images à distance)

---

## Sommaire

1. Mise en situation
2. Déroulé minuté
3. Kick-off
4. Atelier 1 : identités et gouvernance
5. Atelier 2 : réseau virtuel, NSG, ASG, Bastion
6. Atelier 3 : Azure Storage
7. Atelier 4 : templates Bicep, machines virtuelles et Load Balancer
8. Atelier 5 : conteneurs avec ACR et ACI
9. Atelier 6 : App registration, principal de service, identité managée
10. Atelier 7 : supervision, alertes, sauvegarde
11. Clôture
12. Couverture de l'examen AZ-104
13. Kit formateur
14. Glossaire express

---

## 1. Mise en situation

### 1.1 Le client

**Boréal Logistique** est une PME lyonnaise de transport frigorifique (180 salariés, 3 agences : Lyon, Nantes, Lille). Son application métier **TrackIt** permet aux clients de suivre leurs palettes en temps réel et aux agences de déposer les bons de livraison scannés.

Aujourd'hui TrackIt tourne sur deux serveurs physiques vieillissants dans un local technique à Lyon. La DSI (2 personnes) vient de signer un contrat Azure et vous mandate. **Vous êtes l'administrateur Azure fraîchement recruté** : votre mission est de migrer TrackIt dans le cloud **avant la fin de la journée**, en respectant un cahier des charges précis.

### 1.2 Le cahier des charges (les « tickets » de la journée)

| # | Exigence du client | Traduction Azure |
|---|---|---|
| T1 | Séparer les accès : la DSI administre tout, les chefs d'agence ne font que consulter, le prestataire de développement ne touche qu'à ses ressources | Entra ID (utilisateurs, groupes), RBAC, Azure Policy, verrous |
| T2 | Le réseau doit être cloisonné : le front web n'accède pas directement aux données, l'administration ne se fait plus « en RDP ouvert sur Internet » | VNet, sous-réseaux, **NSG**, **ASG**, Bastion |
| T3 | Les bons de livraison scannés (PDF) doivent être stockés à moindre coût, archivés après 90 jours, accessibles temporairement aux clients | **Azure Storage** (Blob, SAS, cycle de vie, Azure Files, point de terminaison privé) |
| T4 | Le front web doit résister à la panne d'un serveur et être déployé de façon reproductible | **Templates Bicep et ARM**, VM en zones de disponibilité, **Azure Load Balancer** |
| T5 | L'API TrackIt a déjà été conteneurisée par le prestataire ; il faut l'héberger sans gérer de VM | **ACR et ACI** (Azure Container Registry, Azure Container Instances) |
| T6 | Les clients se connectent avec un compte d'entreprise, et le pipeline du prestataire doit déployer sans mot de passe en clair | **App registration** Entra ID, principal de service, identité managée, Key Vault |
| T7 | La DSI veut être alertée avant que ça casse, et pouvoir restaurer une VM | Azure Monitor, Log Analytics, alertes, Azure Backup, Network Watcher |

Chaque atelier de la journée **ferme un ticket**. À la fin du bootcamp, l'architecture complète est déployée et fonctionnelle dans la souscription de chaque participant.

### 1.3 Architecture cible

```
                         Internet
                            |
            +---------------+----------------+
            |  Azure Load Balancer (Standard) |  IP publique : pip-trackit-lb
            +---------------+----------------+
                            |
 +--------------------------+---------------------------------------------+
 | vnet-trackit-prod  10.10.0.0/16                                        |
 |                                                                        |
 |  snet-web 10.10.1.0/24        snet-app 10.10.2.0/24    snet-data       |
 |  +----------+ +----------+    +------------------+     10.10.3.0/24    |
 |  | vm-web-01| | vm-web-02|    | ACI : api-trackit|     +------------+  |
 |  | zone 1   | | zone 2   |--->| (image ACR)      |---->| Private EP |  |
 |  +----------+ +----------+    +------------------+     | vers Blob  |  |
 |   ASG : asg-web                ASG : asg-app           +------------+  |
 |   NSG : nsg-web                NSG : nsg-app            NSG : nsg-data |
 |                                                                        |
 |  AzureBastionSubnet 10.10.250.0/26  : Bastion bas-trackit              |
 +------------------------------------------------------------------------+

 Hors VNet :  sttrackitprod<suffix> (Blob + Files)   acrtrackit<suffix>   kv-trackit-<suffix>
              log-trackit-prod (Log Analytics)        rsv-trackit (Recovery Services)
 Identité  :  Entra ID : groupes, app registration TrackIt-Web, principal de service sp-trackit-deploy
```

### 1.4 Conventions de nommage et tags (à respecter toute la journée)

- **Région :** `francecentral` (repli `westeurope` si le quota est insuffisant)
- **Groupes de ressources :** `rg-trackit-prod` (application), `rg-trackit-network` (réseau), `rg-trackit-shared` (services transverses)
- **Tags obligatoires :** `env=prod`, `app=trackit`, `owner=<votre trigramme>`, `costcenter=DSI`
- **Suffixe unique :** `<suffix>` = vos initiales + 3 chiffres (exemple `ryo042`) pour les noms globalement uniques (compte de stockage, ACR, Key Vault)

> **Rappel de concept : la hiérarchie des ressources Azure.** Tenant Entra ID (identités), puis groupes d'administration (management groups), puis souscriptions (facturation, quotas, limite de sécurité), puis groupes de ressources (cycle de vie commun), puis ressources. Le RBAC, les policies et les verrous se posent à chacun de ces niveaux et **s'héritent vers le bas**. Le préfixe `rg-`, `vnet-`, `nsg-`, `st` que nous utilisons suit le Cloud Adoption Framework (CAF) de Microsoft : un nom doit dire le type, l'application, l'environnement et éventuellement la région.

> **Bonne pratique : un groupe de ressources = un cycle de vie.** On regroupe ce qui se crée et se supprime ensemble. Le réseau (durable) est séparé de l'application (redéployable) et des services partagés (registre, coffre, workspace). C'est aussi ce qui rend le nettoyage de fin de journée propre.

---

## 2. Déroulé minuté

| Heure | Durée | Séquence | Ticket | Domaine AZ-104 |
|---|---|---|---|---|
| 09:00 | 30 min | Kick-off, présentation du scénario, préparation de l'environnement | aucun | aucun |
| 09:30 | 60 min | **Atelier 1** : identités et gouvernance | T1 | Gérer les identités et la gouvernance (20 à 25 %) |
| 10:30 | 15 min | Pause | | |
| 10:45 | 60 min | **Atelier 2** : réseau virtuel, NSG, ASG, Bastion | T2 | Configurer et gérer les réseaux virtuels (15 à 20 %) |
| 11:45 | 45 min | **Atelier 3** : Azure Storage | T3 | Implémenter et gérer le stockage (15 à 20 %) |
| 12:30 | | Déjeuner (hors créneau) | | |
| 13:30 | 60 min | **Atelier 4** : Bicep, VM et Load Balancer | T4 | Déployer et gérer les ressources de calcul (20 à 25 %) |
| 14:30 | 45 min | **Atelier 5** : conteneurs, ACR et ACI | T5 | Déployer et gérer les ressources de calcul |
| 15:15 | 15 min | Pause | | |
| 15:30 | 45 min | **Atelier 6** : App registration, principal de service, identité managée | T6 | Identités et gouvernance |
| 16:15 | 35 min | **Atelier 7** : supervision, alertes, sauvegarde | T7 | Surveiller et maintenir les ressources (10 à 15 %) |
| 16:50 | 10 min | Clôture, nettoyage, révision des pièges d'examen | aucun | aucun |
| **17:00** | | **Fin, 7 h au total** | | |

Chaque atelier suit le même rythme : **5 min de contexte (le ticket et le rappel des concepts)**, **démo formateur (environ 40 %)**, **reproduction par les participants (environ 50 %)**, **checkpoint, bonnes pratiques et pièges d'examen (environ 10 %)**.

---

## 3. Kick-off (09:00 à 09:30)

**Objectifs :** tout le monde dispose d'une souscription opérationnelle, Cloud Shell est ouvert, les variables communes sont chargées.

### Rappel des concepts

- **Les trois façons d'administrer Azure :** le portail (découverte, visualisation), Azure CLI et PowerShell (répétable, scriptable), les templates ARM ou Bicep (déclaratif, idempotent). L'examen attend que vous sachiez lire les trois. Dans ce bootcamp, la démo utilise surtout Azure CLI et Bicep ; le portail sert à vérifier.
- **Azure Cloud Shell** : un shell hébergé, déjà authentifié, avec Azure CLI, PowerShell, Bicep, kubectl, git et un stockage persistant (partage Azure Files monté dans `~/clouddrive`). Il tourne dans une région, pas dans votre VNet : c'est pour cela que certains tests réseau se feront depuis une VM via Bastion.
- **Azure Resource Manager (ARM)** est le plan de contrôle unique : portail, CLI, PowerShell et SDK parlent tous à ARM, qui applique RBAC, Policy et verrous avant d'accepter une opération.

### Déroulé

1. Présentation de Boréal Logistique et du cahier des charges (10 min).
2. Lecture de l'architecture cible ; chaque participant note son `<suffix>`.
3. Ouverture de Cloud Shell (Bash) et exécution du prologue :

```bash
# --- Prologue commun : à coller dans Cloud Shell ---
export SUFFIX="ryo042"                 # à personnaliser
export LOC="francecentral"
export RG_PROD="rg-trackit-prod"
export RG_NET="rg-trackit-network"
export RG_SHARED="rg-trackit-shared"
export TAGS="env=prod app=trackit owner=$SUFFIX costcenter=DSI"

az account show --output table
az group create -n $RG_NET    -l $LOC --tags $TAGS
az group create -n $RG_PROD   -l $LOC --tags $TAGS
az group create -n $RG_SHARED -l $LOC --tags $TAGS
```

4. Vérification des quotas (au moins 4 vCPU de la famille Dsv5 dans la région) : `az vm list-usage -l $LOC -o table | grep -i "Dsv5"`.

### Bonnes pratiques

- Sauvegarder le prologue dans `~/clouddrive/prologue.sh` : les variables d'environnement ne survivent pas à la fermeture de Cloud Shell, il suffira de faire `source ~/clouddrive/prologue.sh` après chaque pause.
- Toujours poser les tags à la création : Azure Policy refusera de toute façon les ressources non taguées à partir de l'atelier 1.
- Annoncer dès maintenant que le nettoyage final se fait par suppression des 3 groupes de ressources. C'est une leçon AZ-104 en soi : le groupe de ressources est le périmètre de cycle de vie.

---

## 4. Atelier 1 : identités et gouvernance (09:30 à 10:30), ticket T1

### Le ticket

> « La DSI administre tout. Les chefs d'agence (Lyon, Nantes, Lille) doivent pouvoir *voir* les ressources et les coûts, rien de plus. Le prestataire NovaDev ne doit toucher qu'au groupe de ressources de l'application. Et personne ne doit pouvoir créer une ressource sans tag `costcenter`. »

### Rappel des concepts

**Microsoft Entra ID** (anciennement Azure AD) est l'annuaire d'identités. Il contient les utilisateurs (membres ou invités), les groupes (sécurité ou Microsoft 365, à appartenance affectée ou dynamique), les appareils et les applications. Un tenant Entra ID est associé à une ou plusieurs souscriptions Azure ; une souscription n'a qu'un seul tenant de confiance.

**Deux systèmes de rôles cohabitent, et c'est la source de confusion numéro un de l'examen :**

| | Rôles Entra ID | Rôles Azure (RBAC) |
|---|---|---|
| Portée | L'annuaire : utilisateurs, groupes, applications, licences | Les ressources Azure : souscriptions, groupes de ressources, ressources |
| Exemples | Global Administrator, User Administrator, Application Administrator | Owner, Contributor, Reader, User Access Administrator, Storage Blob Data Contributor |
| Où se gère | Entra ID > Rôles et administrateurs | Ressource > Access control (IAM) |
| Lien entre les deux | Un Global Administrator peut s'accorder le rôle User Access Administrator sur toutes les souscriptions (« Elevate access »), mais ne l'a pas par défaut | |

**Une attribution RBAC = un principal de sécurité (utilisateur, groupe, principal de service, identité managée) + une définition de rôle + une étendue.** Les rôles s'additionnent (on obtient l'union des permissions) et une attribution *Deny* n'existe que via les affectations de refus créées par Azure Blueprints ou les verrous. Les quatre rôles fondamentaux : **Owner** (tout, y compris déléguer les accès), **Contributor** (tout sauf déléguer les accès), **Reader** (lecture seule), **User Access Administrator** (gérer uniquement les accès). Les rôles de **plan de données** (Storage Blob Data Reader, Key Vault Secrets User) sont distincts des rôles de **plan de contrôle** : être Owner d'un compte de stockage ne donne pas le droit de lire les blobs avec un jeton Entra.

**Azure Policy** évalue les ressources par rapport à des règles métier. Une **définition** décrit la condition et l'effet (Audit, Deny, Append, Modify, DeployIfNotExists, AuditIfNotExists, Disabled). Une **initiative** regroupe plusieurs définitions. Une **assignation** applique la définition ou l'initiative à une étendue, avec des exclusions possibles. Policy complète le RBAC : le RBAC dit *qui* peut faire *quoi*, Policy dit *comment* les ressources doivent être configurées, quel que soit l'auteur.

**Les verrous de ressource** (`CanNotDelete`, `ReadOnly`) s'appliquent à tout le monde, Owner compris, et s'héritent. Ils protègent contre l'erreur humaine, pas contre un administrateur malveillant (qui peut retirer le verrou).

### Démo formateur (25 min)

**1. Utilisateurs et groupes Entra ID**

| Objet | Nom | Membres |
|---|---|---|
| Groupe de sécurité | `grp-trackit-admins` | vous |
| Groupe de sécurité | `grp-trackit-readers` | `chef.lyon`, `chef.nantes`, `chef.lille` |
| Groupe de sécurité | `grp-novadev` | `dev.novadev` |
| Utilisateur invité | `externe@novadev.fr` | (B2B : montrer l'invitation, ne pas attendre l'acceptation) |

```bash
DOMAIN=$(az rest --method get --url "https://graph.microsoft.com/v1.0/domains" --query "value[?isDefault].id" -o tsv)
for u in chef.lyon chef.nantes chef.lille dev.novadev; do
  az ad user create --display-name "$u" --user-principal-name "$u@$DOMAIN" \
    --password "Bootcamp-AZ104-$RANDOM!" --force-change-password-next-sign-in true
done
az ad group create --display-name grp-trackit-admins  --mail-nickname grp-trackit-admins
az ad group create --display-name grp-trackit-readers --mail-nickname grp-trackit-readers
az ad group create --display-name grp-novadev         --mail-nickname grp-novadev
for u in chef.lyon chef.nantes chef.lille; do
  az ad group member add -g grp-trackit-readers --member-id $(az ad user show --id "$u@$DOMAIN" --query id -o tsv)
done
az ad group member add -g grp-novadev --member-id $(az ad user show --id "dev.novadev@$DOMAIN" --query id -o tsv)
```

**2. RBAC : le bon rôle, à la bonne étendue**

| Groupe | Rôle | Étendue |
|---|---|---|
| `grp-trackit-admins` | Owner | Souscription |
| `grp-trackit-readers` | Reader et Cost Management Reader | Souscription |
| `grp-novadev` | Contributor | `rg-trackit-prod` uniquement |

```bash
SUB=$(az account show --query id -o tsv)
az role assignment create --assignee-object-id $(az ad group show -g grp-trackit-readers --query id -o tsv) \
  --assignee-principal-type Group --role "Reader" --scope /subscriptions/$SUB
az role assignment create --assignee-object-id $(az ad group show -g grp-trackit-readers --query id -o tsv) \
  --assignee-principal-type Group --role "Cost Management Reader" --scope /subscriptions/$SUB
az role assignment create --assignee-object-id $(az ad group show -g grp-novadev --query id -o tsv) \
  --assignee-principal-type Group --role "Contributor" \
  --scope /subscriptions/$SUB/resourceGroups/$RG_PROD
```

Montrer dans le portail **Access control (IAM) > Check access** avec `dev.novadev` : Contributor sur `rg-trackit-prod`, rien sur `rg-trackit-network`. Insister sur l'**héritage** (souscription, puis RG, puis ressource) et sur la différence entre **rôle Entra ID** (Global Administrator) et **rôle Azure RBAC** (Owner).

**3. Azure Policy : tags obligatoires et régions autorisées**

- Assigner la définition intégrée *Require a tag and its value on resources* avec `costcenter = DSI` sur la souscription (effet **Deny**).
- Assigner *Allowed locations* avec `francecentral` et `westeurope`.
- Créer une **initiative** « Gouvernance Boréal » regroupant les deux (montrer le concept, assignation facultative).

```bash
az policy assignment create --name "req-tag-costcenter" --display-name "Tag costcenter obligatoire" \
  --policy "1e30110a-5ceb-460c-a204-c1c3969c6d62" --scope /subscriptions/$SUB \
  --params '{"tagName":{"value":"costcenter"},"tagValue":{"value":"DSI"}}'
az policy assignment create --name "allowed-locations" --display-name "Regions autorisees" \
  --policy "e56962a6-4747-49cd-b67b-bf8b01975c4c" --scope /subscriptions/$SUB \
  --params '{"listOfAllowedLocations":{"value":["francecentral","westeurope"]}}'
```

**4. Verrou de ressource**

```bash
az lock create --name lock-no-delete-net --lock-type CanNotDelete --resource-group $RG_NET
```

### Reproduction par les participants (25 min)

Reproduire les 4 étapes. **Test à réaliser :** tenter de créer un groupe de ressources `rg-test` sans tag, puis une ressource dans `northeurope`. Les deux doivent être refusés par Policy (compter jusqu'à 5 min de propagation ; sinon montrer le refus côté formateur).

### Bonnes pratiques

- **Attribuer les rôles à des groupes, jamais à des utilisateurs.** Un départ ou une arrivée se gère par l'appartenance au groupe, pas par une chasse aux attributions.
- **Moindre privilège et étendue la plus étroite possible.** Contributor sur un groupe de ressources plutôt qu'Owner sur la souscription. Réserver Owner à un petit groupe et envisager **PIM** (Privileged Identity Management, Entra ID P2) pour des élévations temporaires.
- **Préférer les rôles intégrés.** Un rôle personnalisé (`Actions`, `NotActions`, `DataActions`, `NotDataActions`, `AssignableScopes`) ne se crée que quand aucun rôle intégré ne convient, et se documente.
- **Commencer Policy en mode Audit**, observer la conformité, puis passer en Deny. Sur un existant, un Deny immédiat bloque les redéploiements légitimes.
- **Un verrou `CanNotDelete` sur le réseau, les coffres et les journaux** ; éviter `ReadOnly` sur les comptes de stockage et les Key Vault (il bloque la lecture des clés et casse des applications).
- **Activer MFA pour tous les administrateurs** (paramètres de sécurité par défaut, ou Conditional Access si Entra ID P1) et documenter des comptes de secours (« break glass »).

### Checkpoint et pièges d'examen (10 min)

- [ ] 3 groupes et 4 utilisateurs existent dans Entra ID, les membres sont affectés
- [ ] `dev.novadev` est Contributor sur `rg-trackit-prod` **seulement**
- [ ] La création d'une ressource sans tag `costcenter` ou hors régions autorisées est refusée
- [ ] `rg-trackit-network` est protégé contre la suppression

**Pièges classiques :** Owner n'est pas Contributor (Owner peut gérer le RBAC) ; un verrou `ReadOnly` bloque aussi certaines opérations qui ressemblent à de la lecture (lister les clés d'un compte de stockage est un POST) ; Azure Policy évalue les **nouvelles** ressources immédiatement mais les ressources existantes seulement au cycle de conformité (environ 24 h, ou déclenchement manuel) ; un utilisateur invité B2B a besoin d'une attribution RBAC comme n'importe quel utilisateur ; **Cost Management Reader** ne donne pas accès aux ressources ; l'effet **Append** ajoute un tag à la création alors que **Modify** peut aussi corriger l'existant via une tâche de correction ; les groupes dynamiques nécessitent Entra ID P1 ; la **réinitialisation de mot de passe en libre-service (SSPR)** se configure par groupe et impose l'inscription de méthodes d'authentification.

---

## 5. Atelier 2 : réseau virtuel, NSG, ASG, Bastion (10:45 à 11:45), ticket T2

### Le ticket

> « Les deux serveurs web ne doivent recevoir que du HTTP/HTTPS venant du Load Balancer. L'API ne doit être appelable que depuis les serveurs web. La donnée n'est accessible que depuis l'API. Et l'administration se fait via Bastion, plus jamais de port 22 ou 3389 exposé. »

### Rappel des concepts

**Un réseau virtuel (VNet)** est un espace d'adressage privé (RFC 1918 recommandé) dans une région, découpé en **sous-réseaux**. Azure réserve **5 adresses** par sous-réseau (la première et la dernière, plus 3 pour la passerelle et le DNS) : un `/24` offre donc 251 adresses utilisables, un `/29` seulement 3. Les VNet ne communiquent pas entre eux par défaut ; on les relie par **peering** (même région ou global, non transitif), par **VPN Gateway** (site à site, point à site) ou par **ExpressRoute**.

**Le routage** est automatique : Azure crée des routes système (intra-VNet, vers Internet, vers les peerings). Les **routes définies par l'utilisateur (UDR)** dans une table de routage associée à un sous-réseau les remplacent, par exemple pour forcer le trafic vers une appliance virtuelle réseau (NVA) ou un Azure Firewall. Règle de priorité : UDR, puis routes BGP, puis routes système.

**Un groupe de sécurité réseau (NSG)** est un pare-feu à état, de niveau 3 et 4, composé de règles entrantes et sortantes. Chaque règle a une priorité (100 à 4096, la plus basse gagne), une source, une destination, un protocole, des ports et une action. Trois règles entrantes par défaut, non supprimables mais surchargeables : `AllowVnetInBound` (65000), `AllowAzureLoadBalancerInBound` (65001), `DenyAllInBound` (65500). Un NSG s'associe à un **sous-réseau**, à une **carte réseau (NIC)**, ou aux deux : en entrée, le NSG du sous-réseau est évalué d'abord, puis celui de la NIC ; en sortie, c'est l'inverse. Le trafic doit être autorisé par les deux. Les **balises de service** (`Internet`, `VirtualNetwork`, `AzureLoadBalancer`, `Storage`, `Sql`, etc.) évitent de maintenir des plages d'adresses IP.

**Un groupe de sécurité d'application (ASG)** est une étiquette logique posée sur des NIC. On écrit ensuite les règles NSG entre ASG (« le rôle web parle au rôle app sur 8080 ») au lieu d'écrire des adresses IP. Une NIC peut appartenir à plusieurs ASG ; tous les membres d'un ASG doivent être dans le même VNet.

**Azure Bastion** est un service PaaS qui fournit du RDP et du SSH via le portail, en HTTPS, sans exposer d'IP publique sur les VM. Il exige un sous-réseau nommé exactement `AzureBastionSubnet` en `/26` minimum et une IP publique Standard. Le SKU Basic suffit pour la démo ; Standard ajoute le client natif, le tunnel et l'échelle.

**La résolution DNS** dans un VNet utilise par défaut le résolveur Azure (168.63.129.16). Les **zones DNS privées** (`privatelink.*`) liées au VNet permettent aux points de terminaison privés d'être résolus sur leur adresse privée.

### Démo formateur (25 min)

**1. VNet et sous-réseaux**

```bash
az network vnet create -g $RG_NET -n vnet-trackit-prod --address-prefix 10.10.0.0/16 -l $LOC --tags $TAGS
az network vnet subnet create -g $RG_NET --vnet-name vnet-trackit-prod -n snet-web  --address-prefix 10.10.1.0/24
az network vnet subnet create -g $RG_NET --vnet-name vnet-trackit-prod -n snet-app  --address-prefix 10.10.2.0/24 \
   --delegations Microsoft.ContainerInstance/containerGroups
az network vnet subnet create -g $RG_NET --vnet-name vnet-trackit-prod -n snet-data --address-prefix 10.10.3.0/24
az network vnet subnet create -g $RG_NET --vnet-name vnet-trackit-prod -n AzureBastionSubnet --address-prefix 10.10.250.0/26
```

Expliquer les 5 adresses réservées, le nom imposé `AzureBastionSubnet` et le `/26` minimum, et la **délégation** de `snet-app` à ACI (obligatoire pour l'atelier 5 : un sous-réseau délégué ne peut plus héberger d'autres types de ressources).

**2. Application Security Groups : nommer les rôles, pas les adresses**

```bash
az network asg create -g $RG_NET -n asg-web -l $LOC
az network asg create -g $RG_NET -n asg-app -l $LOC
```

**3. Network Security Groups : règles par ASG**

`nsg-web` (associé à `snet-web`) :

| Priorité | Nom | Source | Destination | Port | Action |
|---|---|---|---|---|---|
| 100 | Allow-HTTP-From-LB | `AzureLoadBalancer` | `asg-web` | 80 | Allow |
| 110 | Allow-HTTP-Internet | `Internet` | `asg-web` | 80, 443 | Allow |
| 120 | Allow-SSH-From-Bastion | 10.10.250.0/26 | `asg-web` | 22 | Allow |
| 4000 | Deny-All-Inbound | Any | Any | * | Deny |

`nsg-app` (associé à `snet-app`) :

| Priorité | Nom | Source | Destination | Port | Action |
|---|---|---|---|---|---|
| 100 | Allow-API-From-Web | `asg-web` | `asg-app` | 8080 | Allow |
| 4000 | Deny-All-Inbound | Any | Any | * | Deny |

`nsg-data` (associé à `snet-data`) : autorise 443 depuis `asg-app` uniquement, puis Deny-All.

```bash
az network nsg create -g $RG_NET -n nsg-web -l $LOC
az network nsg rule create -g $RG_NET --nsg-name nsg-web -n Allow-HTTP-From-LB --priority 100 \
  --source-address-prefixes AzureLoadBalancer --destination-asgs asg-web \
  --destination-port-ranges 80 --access Allow --protocol Tcp
az network nsg rule create -g $RG_NET --nsg-name nsg-web -n Allow-HTTP-Internet --priority 110 \
  --source-address-prefixes Internet --destination-asgs asg-web \
  --destination-port-ranges 80 443 --access Allow --protocol Tcp
az network nsg rule create -g $RG_NET --nsg-name nsg-web -n Allow-SSH-From-Bastion --priority 120 \
  --source-address-prefixes 10.10.250.0/26 --destination-asgs asg-web \
  --destination-port-ranges 22 --access Allow --protocol Tcp
az network nsg rule create -g $RG_NET --nsg-name nsg-web -n Deny-All-Inbound --priority 4000 \
  --source-address-prefixes '*' --destination-address-prefixes '*' \
  --destination-port-ranges '*' --access Deny --protocol '*'
az network vnet subnet update -g $RG_NET --vnet-name vnet-trackit-prod -n snet-web --network-security-group nsg-web

az network nsg create -g $RG_NET -n nsg-app -l $LOC
az network nsg rule create -g $RG_NET --nsg-name nsg-app -n Allow-API-From-Web --priority 100 \
  --source-asgs asg-web --destination-asgs asg-app --destination-port-ranges 8080 --access Allow --protocol Tcp
az network nsg rule create -g $RG_NET --nsg-name nsg-app -n Deny-All-Inbound --priority 4000 \
  --source-address-prefixes '*' --destination-address-prefixes '*' \
  --destination-port-ranges '*' --access Deny --protocol '*'
az network vnet subnet update -g $RG_NET --vnet-name vnet-trackit-prod -n snet-app --network-security-group nsg-app
```

Pourquoi une règle `Deny-All` explicite alors qu'il en existe une par défaut ? Pour **neutraliser `AllowVnetInBound`** (65000) qui laisserait passer tout le trafic intra-VNet, y compris de `snet-web` vers `snet-data`. C'est LA question piège des NSG.

**4. Bastion** (déploiement long, 8 à 10 min : lancer en `--no-wait` puis continuer)

```bash
az network public-ip create -g $RG_NET -n pip-bastion --sku Standard -l $LOC
az network bastion create -g $RG_NET -n bas-trackit --vnet-name vnet-trackit-prod \
  --public-ip-address pip-bastion -l $LOC --sku Basic --no-wait
```

**5. Aperçu peering et DNS** (5 min, démo portail uniquement) : créer `vnet-trackit-mgmt` 10.20.0.0/16 et un peering bidirectionnel ; expliquer la non-transitivité (un hub avec pare-feu et des UDR pour router entre spokes) et annoncer la zone DNS privée `privatelink.blob.core.windows.net` de l'atelier 3.

### Reproduction par les participants (30 min)

Reproduire VNet, ASG, NSG. Bastion en `--no-wait`. Les VM arriveront à l'atelier 4 : les ASG seront alors rattachés aux NIC par le template.

### Bonnes pratiques

- **Planifier l'adressage avant de créer quoi que ce soit** : un espace d'adressage qui chevauche le réseau sur site interdira le VPN plus tard, et redimensionner un sous-réseau peuplé est pénible.
- **Un NSG par sous-réseau, des règles écrites entre ASG et balises de service.** Éviter les NSG sur les NIC sauf besoin ponctuel : deux niveaux d'évaluation rendent le diagnostic difficile.
- **Toujours terminer par un Deny explicite** et laisser de l'espace entre les priorités (100, 110, 120) pour insérer des règles.
- **Zéro port d'administration exposé sur Internet.** Bastion, ou à défaut JIT (Defender for Cloud), ou VPN. Un NSG « Allow 22 depuis Internet » est la première chose qu'un scanner trouve.
- **Activer les journaux de flux NSG** (Network Watcher) et Traffic Analytics dès la mise en production : on ne peut pas dépanner ce qu'on ne voit pas.
- **Topologie hub and spoke** dès que l'on dépasse deux ou trois VNet : services partagés (pare-feu, passerelles, DNS) dans le hub, applications dans les spokes.

### Checkpoint et pièges d'examen (5 min)

- [ ] 4 sous-réseaux, `snet-app` délégué à ACI
- [ ] `nsg-web` associé à `snet-web`, `nsg-app` à `snet-app`
- [ ] 2 ASG créés (encore vides)
- [ ] Bastion en cours de provisionnement

**Pièges :** les NSG s'appliquent au sous-réseau et/ou à la NIC, les deux sont évalués ; un ASG ne peut contenir que des NIC du même VNet ; les balises de service `AzureLoadBalancer` (sondes de santé), `Internet`, `VirtualNetwork` (inclut les peerings et les réseaux joints par passerelle) ; priorité basse = évaluée en premier ; Bastion impose `AzureBastionSubnet` en `/26` minimum et une IP publique Standard ; le peering n'est pas transitif ; les UDR priment sur les routes système ; le peering global ne permet pas d'utiliser la passerelle distante ; un VNet ne peut pas changer de région, il faut le recréer ; **Azure DNS** public héberge des zones, les **zones privées** résolvent dans les VNet liés (avec auto-inscription possible).

---

## 6. Atelier 3 : Azure Storage (11:45 à 12:30), ticket T3

### Le ticket

> « Les bons de livraison scannés (environ 40 Go par an) doivent être en stockage économique, passés en archive après 90 jours. Un client doit pouvoir télécharger un PDF via un lien valable 1 h. Les agences ont besoin d'un partage de fichiers monté sur leurs postes. L'API ne doit atteindre le stockage que par le réseau privé. »

### Rappel des concepts

**Un compte de stockage** expose jusqu'à quatre services sous un même nom globalement unique : **Blob** (objets, via conteneurs), **Files** (partages SMB ou NFS), **Queue** (messages) et **Table** (NoSQL clé-valeur). Le type de compte recommandé est **StorageV2 (usage général v2)** ; Premium existe pour les blobs de blocs, les fichiers et les blobs de pages à haute performance.

**La redondance** définit combien de copies sont écrites et où :

| Option | Copies | Protège contre | Lecture secondaire |
|---|---|---|---|
| LRS | 3 dans un datacenter | Panne disque ou rack | non |
| ZRS | 3 réparties sur 3 zones | Perte d'un datacenter | non |
| GRS | 3 + 3 dans la région jumelée | Perte de région | non (sauf basculement) |
| RA-GRS | idem GRS | Perte de région | oui |
| GZRS, RA-GZRS | ZRS + 3 dans la région jumelée | Zone et région | selon RA |

**Les niveaux d'accès Blob** arbitrent coût de stockage contre coût d'accès : **Hot** (accès fréquent), **Cool** (30 jours minimum), **Cold** (90 jours minimum), **Archive** (180 jours minimum, hors ligne : lecture après réhydratation de quelques heures). Le niveau se définit par défaut au compte et peut être surchargé par blob. La **gestion du cycle de vie** automatise les transitions et suppressions selon l'âge ou la dernière date d'accès.

**Sécuriser l'accès** peut se faire par : les **clés de compte** (pouvoir total, à éviter), les **signatures d'accès partagé (SAS)** de compte, de service ou de délégation utilisateur (limitées dans le temps, les permissions, l'IP et le protocole), une **stored access policy** (rend une SAS de service révocable), et surtout **Entra ID avec les rôles de données** (Storage Blob Data Owner, Contributor, Reader ; Storage File Data SMB Share Contributor). Côté réseau : le **pare-feu du compte** (réseaux virtuels, plages IP, exceptions pour les services Azure), les **points de terminaison de service** (le trafic reste sur le backbone mais l'adresse du compte reste publique) et les **points de terminaison privés** (une IP privée du VNet pour le compte, résolue par une zone DNS privée).

**Azure Files** fournit des partages SMB (port 445) ou NFS montables depuis Windows, Linux, macOS, avec authentification par clé ou par identité (Entra ID Kerberos, AD DS). **Azure File Sync** permet de garder un serveur de fichiers sur site comme cache d'un partage Azure. **AzCopy** est l'outil en ligne de commande de transfert massif ; **Storage Explorer** l'outil graphique ; **Azure Data Box** l'option physique pour les dizaines de téraoctets.

**Protection des données** : suppression réversible (soft delete) des blobs et des conteneurs, gestion des versions, instantanés, stratégies d'immuabilité (WORM), réplication d'objets entre comptes, et Azure Backup pour Azure Files.

### Démo formateur (20 min)

**1. Compte de stockage**

```bash
ST="sttrackitprod$SUFFIX"
az storage account create -g $RG_PROD -n $ST -l $LOC --sku Standard_LRS --kind StorageV2 \
  --access-tier Hot --min-tls-version TLS1_2 --allow-blob-public-access false \
  --allow-shared-key-access true --tags $TAGS
az storage account blob-service-properties update --account-name $ST -g $RG_PROD \
  --enable-delete-retention true --delete-retention-days 14 \
  --enable-container-delete-retention true --container-delete-retention-days 14 --enable-versioning true
az storage container create --account-name $ST -n bons-livraison --auth-mode login
```

Décision d'architecture à expliquer : pourquoi **LRS** suffit ici (données reproductibles depuis les scanners, budget PME) et quand passer en **ZRS, GRS ou RA-GZRS**. Comparer les niveaux Hot, Cool, Cold, Archive et le coût de réhydratation.

**2. Chargement et niveaux d'accès**

```bash
az role assignment create --assignee $(az ad signed-in-user show --query id -o tsv) \
  --role "Storage Blob Data Contributor" --scope $(az storage account show -g $RG_PROD -n $ST --query id -o tsv)
echo "Bon de livraison n 1001 - Lyon" > BL-1001.pdf
az storage blob upload --account-name $ST -c bons-livraison -f BL-1001.pdf -n 2026/09/BL-1001.pdf --auth-mode login
az storage blob set-tier --account-name $ST -c bons-livraison -n 2026/09/BL-1001.pdf --tier Cool --auth-mode login
```

Si `--auth-mode login` échoue avant l'attribution du rôle : montrer que **Storage Blob Data Contributor** (plan de données) est requis même pour un Owner (plan de contrôle). Excellente illustration RBAC.

**3. Politique de cycle de vie**

```json
{
  "rules": [{
    "name": "archive-bons-livraison",
    "enabled": true,
    "type": "Lifecycle",
    "definition": {
      "filters": { "blobTypes": ["blockBlob"], "prefixMatch": ["bons-livraison/"] },
      "actions": { "baseBlob": {
        "tierToCool":    { "daysAfterModificationGreaterThan": 30 },
        "tierToArchive": { "daysAfterModificationGreaterThan": 90 },
        "delete":        { "daysAfterModificationGreaterThan": 3650 }
      } }
    }
  }]
}
```

```bash
az storage account management-policy create --account-name $ST -g $RG_PROD --policy @lifecycle.json
```

**4. SAS limitée dans le temps**

```bash
END=$(date -u -d "+1 hour" '+%Y-%m-%dT%H:%MZ')
az storage blob generate-sas --account-name $ST -c bons-livraison -n 2026/09/BL-1001.pdf \
  --permissions r --expiry $END --https-only --auth-mode login --as-user --full-uri
```

Comparer **SAS de compte, de service et de délégation utilisateur** (celle-ci est signée par Entra ID, sans clé de compte : c'est celle que nous venons de générer avec `--as-user`), et la **stored access policy** (révocable). Montrer la révocation d'une SAS de compte par rotation de clé.

**5. Azure Files pour les agences**

```bash
az storage share-rm create --storage-account $ST -n agences --quota 100 --enabled-protocols SMB
az storage share-rm show --storage-account $ST -n agences
# Portail : partage agences > Connect : script de montage Windows (net use) ou Linux (mount -t cifs)
```

**6. Point de terminaison privé et pare-feu** (10 min, peut être fait par le formateur seul si le temps manque)

```bash
az network private-endpoint create -g $RG_NET -n pe-st-blob --vnet-name vnet-trackit-prod --subnet snet-data \
  --private-connection-resource-id $(az storage account show -g $RG_PROD -n $ST --query id -o tsv) \
  --group-id blob --connection-name pe-st-blob-conn -l $LOC
az network private-dns zone create -g $RG_NET -n privatelink.blob.core.windows.net
az network private-dns link vnet create -g $RG_NET -n link-trackit -z privatelink.blob.core.windows.net \
  -v vnet-trackit-prod -e false
az network private-endpoint dns-zone-group create -g $RG_NET --endpoint-name pe-st-blob -n zg-blob \
  --private-dns-zone privatelink.blob.core.windows.net --zone-name blob
# Pare-feu : refuser tout sauf le réseau privé, en gardant l'accès depuis l'IP publique du participant
az storage account update -g $RG_PROD -n $ST --default-action Deny --bypass AzureServices
az storage account network-rule add -g $RG_PROD -n $ST --ip-address $(curl -s ifconfig.me)
```

### Reproduction par les participants (20 min)

Étapes 1 à 5 obligatoires, étape 6 en bonus.

### Bonnes pratiques

- **Désactiver l'accès public anonyme aux blobs** au niveau du compte et imposer TLS 1.2 : ce sont deux réglages que Defender for Cloud remonte immédiatement.
- **Privilégier Entra ID et les rôles de données** ; interdire à terme l'accès par clé partagée (`--allow-shared-key-access false`) une fois que toutes les applications utilisent une identité. Si des SAS restent nécessaires, préférer la délégation utilisateur, une durée courte, HTTPS seul et une plage IP.
- **Activer soft delete, versioning et instantanés** avant la première donnée de production ; un `az storage blob delete` sans filet est irréversible.
- **Laisser le cycle de vie faire le travail de FinOps** : le niveau Archive coûte environ dix fois moins cher que Hot, mais chaque transition précoce facture une pénalité de durée minimale.
- **Un point de terminaison privé par service** (blob, file, etc.) et une zone DNS privée par type ; vérifier la résolution depuis le VNet avant de fermer le pare-feu.
- **Choisir la redondance selon le RPO/RTO réel**, pas par réflexe : GRS n'est pas une sauvegarde (une suppression est répliquée), c'est de la continuité d'activité.

### Checkpoint et pièges d'examen (5 min)

- [ ] Blob `2026/09/BL-1001.pdf` en niveau Cool, politique de cycle de vie active
- [ ] Une URL SAS fonctionne depuis une fenêtre de navigation privée et expire à H+1
- [ ] Partage `agences` créé
- [ ] (bonus) `nslookup sttrackitprod<suffix>.blob.core.windows.net` depuis une VM du VNet renvoie 10.10.3.x

**Pièges :** Archive n'est pas lisible sans réhydratation (heures, priorité Standard ou High) ; changer LRS en GRS se fait en ligne, mais passer vers ou depuis ZRS demande une conversion ou une migration ; **AzCopy** contre Storage Explorer contre `az storage` ; Azure Files SMB utilise le port 445, souvent bloqué par les FAI, d'où **Azure File Sync** ou VPN ; soft delete des blobs et soft delete des conteneurs sont deux réglages distincts ; réplication d'objets n'est pas la géo-réplication ; une SAS est une signature, pas une authentification, la révoquer signifie régénérer la clé ou supprimer la stored access policy ; **Storage Blob Data Reader** n'est pas **Reader** ; un point de terminaison de service reste une adresse publique filtrée, un point de terminaison privé est une adresse privée ; le nom du compte est en minuscules et chiffres, 3 à 24 caractères, unique au monde.

---

## 7. Atelier 4 : templates Bicep, VM web et Load Balancer (13:30 à 14:30), ticket T4

### Le ticket

> « Le front web doit être déployé de manière identique et rejouable. Il doit continuer de répondre si un serveur ou un datacenter tombe. Même IP publique pour les clients quoi qu'il arrive. »

### Rappel des concepts

**Infrastructure as Code avec ARM et Bicep.** Un template ARM est un document JSON déclaratif (paramètres, variables, ressources, sorties) soumis à Azure Resource Manager. **Bicep** est un langage de plus haut niveau qui se transpile en JSON ARM : syntaxe plus courte, typage, références symboliques entre ressources, modules, boucles, mot-clé `existing` pour référencer une ressource déjà créée. Le déploiement est **idempotent** : rejouer le même template produit le même état. Deux **modes de déploiement** : **Incremental** (par défaut, n'efface rien) et **Complete** (supprime du groupe de ressources tout ce qui n'est pas dans le template). L'étendue peut être un groupe de ressources, une souscription, un groupe d'administration ou le tenant. `what-if` prévisualise les changements. Les **specs de template** et les **modules** publiés dans un registre permettent de partager des briques validées. Le portail sait **exporter** un template depuis une ressource existante (utile pour apprendre, rarement propre à réutiliser tel quel).

**Machines virtuelles.** Une VM Azure se compose d'une taille (famille : B pour le burst, D pour l'usage général, E pour la mémoire, F pour le calcul, N pour le GPU), d'une image (Marketplace, galerie partagée ou image personnalisée), d'un disque système managé (Standard HDD, Standard SSD, Premium SSD, Ultra), d'un disque temporaire (perdu à la désallocation) et d'au moins une NIC. **Arrêter depuis l'OS** ne libère pas la facturation ; **désallouer** (`Stopped (deallocated)`) oui. Redimensionner nécessite un redémarrage. Les **extensions** (Custom Script, DSC, Azure Monitor Agent, Key Vault) exécutent des actions post-déploiement.

**Disponibilité.** Un **groupe à haute disponibilité (availability set)** répartit les VM sur des domaines de panne (racks, jusqu'à 3) et des domaines de mise à jour (jusqu'à 20) dans un même datacenter : SLA 99,95 %. Les **zones de disponibilité** répartissent les VM sur des datacenters distincts de la région : SLA 99,99 %. Les **groupes de machines virtuelles identiques (VMSS)** ajoutent la mise à l'échelle automatique et le mode d'orchestration flexible. Une VM seule sur disque Premium a un SLA de 99,9 %.

**Azure Load Balancer** est un équilibreur de **couche 4** (TCP, UDP), interne ou public. Composants : configuration IP frontale, pool principal (NIC ou adresses IP), **sonde d'intégrité** (TCP, HTTP, HTTPS : une instance qui échoue est retirée du pool), règles d'équilibrage (distribution par hachage 5-tuple, avec affinité de session possible), règles NAT entrantes (accès à une instance précise), règles de sortie (SNAT). Le SKU **Standard** est le seul à supporter les zones, le SLA de 99,99 %, les règles de sortie et les pools de grande taille ; il est **sécurisé par défaut** (un NSG doit autoriser explicitement le trafic). Le SKU Basic est en fin de vie.

**Situer les autres équilibreurs :** **Application Gateway** (couche 7 : routage par URL, terminaison TLS, WAF, régional), **Azure Front Door** (couche 7, global, CDN, WAF), **Traffic Manager** (routage DNS global : priorité, performance, pondéré, géographique).

### Démo formateur (25 min)

**1. Le template Bicep** `trackit-web.bicep` (présenter section par section : paramètres, ressources existantes, Load Balancer, boucles, extension, sorties)

```bicep
targetScope = 'resourceGroup'

@description('Suffixe unique du participant')
param suffix string
param location string = resourceGroup().location
param adminUsername string = 'azadmin'
@secure()
param adminPassword string
param vmSize string = 'Standard_D2s_v5'
param webVmCount int = 2
param tags object = { env: 'prod', app: 'trackit', costcenter: 'DSI' }

// ---- Ressources existantes (créées à l'atelier 2 dans rg-trackit-network) ----
resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' existing = {
  name: 'vnet-trackit-prod'
  scope: resourceGroup('rg-trackit-network')
}
resource asgWeb 'Microsoft.Network/applicationSecurityGroups@2023-11-01' existing = {
  name: 'asg-web'
  scope: resourceGroup('rg-trackit-network')
}
var subnetWebId = '${vnet.id}/subnets/snet-web'

// ---- Load Balancer public Standard ----
resource pipLb 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: 'pip-trackit-lb'
  location: location
  tags: tags
  sku: { name: 'Standard' }
  zones: [ '1', '2', '3' ]
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: { domainNameLabel: 'trackit-${suffix}' }
  }
}

resource lb 'Microsoft.Network/loadBalancers@2023-11-01' = {
  name: 'lb-trackit-web'
  location: location
  tags: tags
  sku: { name: 'Standard' }
  properties: {
    frontendIPConfigurations: [ { name: 'fe-public', properties: { publicIPAddress: { id: pipLb.id } } } ]
    backendAddressPools: [ { name: 'be-web' } ]
    probes: [ { name: 'probe-http', properties: { protocol: 'Http', port: 80, requestPath: '/', intervalInSeconds: 5, numberOfProbes: 2 } } ]
    loadBalancingRules: [ {
      name: 'rule-http'
      properties: {
        frontendIPConfiguration: { id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', 'lb-trackit-web', 'fe-public') }
        backendAddressPool:      { id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', 'lb-trackit-web', 'be-web') }
        probe:                   { id: resourceId('Microsoft.Network/loadBalancers/probes', 'lb-trackit-web', 'probe-http') }
        protocol: 'Tcp', frontendPort: 80, backendPort: 80, idleTimeoutInMinutes: 4, disableOutboundSnat: true
      }
    } ]
    outboundRules: [ {
      name: 'outbound-web'
      properties: {
        frontendIPConfigurations: [ { id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', 'lb-trackit-web', 'fe-public') } ]
        backendAddressPool: { id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', 'lb-trackit-web', 'be-web') }
        protocol: 'All', allocatedOutboundPorts: 1024, idleTimeoutInMinutes: 4
      }
    } ]
  }
}

// ---- VM web : une par zone, membres de l'ASG et du pool principal ----
resource nic 'Microsoft.Network/networkInterfaces@2023-11-01' = [for i in range(0, webVmCount): {
  name: 'nic-web-0${i + 1}'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [ {
      name: 'ipconfig1'
      properties: {
        subnet: { id: subnetWebId }
        privateIPAllocationMethod: 'Dynamic'
        applicationSecurityGroups: [ { id: asgWeb.id } ]
        loadBalancerBackendAddressPools: [ { id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', 'lb-trackit-web', 'be-web') } ]
      }
    } ]
  }
  dependsOn: [ lb ]
}]

resource vm 'Microsoft.Compute/virtualMachines@2024-03-01' = [for i in range(0, webVmCount): {
  name: 'vm-web-0${i + 1}'
  location: location
  tags: tags
  zones: [ string(i + 1) ]
  properties: {
    hardwareProfile: { vmSize: vmSize }
    osProfile: { computerName: 'vm-web-0${i + 1}', adminUsername: adminUsername, adminPassword: adminPassword }
    storageProfile: {
      imageReference: { publisher: 'Canonical', offer: '0001-com-ubuntu-server-jammy', sku: '22_04-lts-gen2', version: 'latest' }
      osDisk: { createOption: 'FromImage', managedDisk: { storageAccountType: 'Premium_LRS' } }
    }
    networkProfile: { networkInterfaces: [ { id: nic[i].id } ] }
  }
}]

// ---- Extension Custom Script : installe nginx et affiche le nom du serveur ----
resource cse 'Microsoft.Compute/virtualMachines/extensions@2024-03-01' = [for i in range(0, webVmCount): {
  parent: vm[i]
  name: 'install-nginx'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    settings: {
      commandToExecute: 'apt-get update && apt-get install -y nginx && echo "<h1>TrackIt - Boreal Logistique</h1><p>Servi par $(hostname)</p>" > /var/www/html/index.html'
    }
  }
}]

output lbFqdn string = pipLb.properties.dnsSettings.fqdn
output vmNames array = [for i in range(0, webVmCount): vm[i].name]
```

**2. Validation et déploiement**

```bash
az bicep build --file trackit-web.bicep                      # génère le JSON ARM : montrer le lien Bicep vers ARM
az deployment group what-if -g $RG_PROD --template-file trackit-web.bicep \
   --parameters suffix=$SUFFIX adminPassword='Bootcamp-AZ104-Passw0rd!'
az deployment group create -g $RG_PROD -n deploy-web-01 --template-file trackit-web.bicep \
   --parameters suffix=$SUFFIX adminPassword='Bootcamp-AZ104-Passw0rd!'
az deployment group show -g $RG_PROD -n deploy-web-01 --query properties.outputs.lbFqdn.value -o tsv
```

**3. Test du Load Balancer** : ouvrir `http://trackit-<suffix>.francecentral.cloudapp.azure.com` et rafraîchir plusieurs fois : alternance `vm-web-01` et `vm-web-02`. Puis **désallouer `vm-web-01`** (`az vm deallocate -g $RG_PROD -n vm-web-01`) : la sonde retire l'instance du pool en une dizaine de secondes, le site répond toujours. Redémarrer ensuite la VM.

**4. Ce que le template a fait pour vous** (à montrer dans le portail) : les NIC sont membres de `asg-web`, donc les règles NSG de l'atelier 2 s'appliquent ; les VM sont réparties en **zones 1 et 2** ; le mode de déploiement était **Incremental** (rejouer le déploiement ne casse rien). Ouvrir l'historique des déploiements du groupe de ressources, puis *Export template* sur une VM pour montrer le JSON généré.

### Reproduction par les participants (30 min)

Déployer le template (fourni dans le dépôt du bootcamp). Pendant le déploiement (environ 5 min), exercice de lecture : « Que se passe-t-il si je passe `webVmCount=3` ? » (réponse : une troisième VM en zone 3, dans le pool). Tester la bascule.

### Bonnes pratiques

- **Tout passer par le template, rien à la main dans le portail** après le premier déploiement, sinon la dérive de configuration rend le template inutilisable. Le template vit dans Git, il est revu comme du code.
- **Toujours lancer `what-if` avant `create`**, et ne jamais utiliser le mode Complete sans l'avoir prévisualisé.
- **Marquer `@secure()` les secrets** et ne jamais les mettre en dur dans un fichier de paramètres : lecture depuis Key Vault (atelier 6) ou variables de pipeline.
- **Découper en modules** (réseau, calcul, supervision) et **épingler les versions d'API** : un changement de version d'API peut modifier les valeurs par défaut.
- **Zones de disponibilité plutôt qu'availability set** pour tout nouveau déploiement dans une région qui les supporte ; VMSS dès que la charge varie.
- **Sonde HTTP sur une page de santé applicative** plutôt qu'une sonde TCP : un service qui répond au TCP mais renvoie des erreurs 500 doit sortir du pool.
- **Disques : Premium SSD pour la production**, chiffrement au repos par défaut (SSE), Azure Disk Encryption ou chiffrement sur l'hôte si exigé, et sauvegarde (atelier 7).

### Checkpoint et pièges d'examen (5 min)

- [ ] Le FQDN du LB répond et alterne entre les 2 VM
- [ ] `vm-web-01` désallouée : le site répond toujours
- [ ] Les 2 NIC sont dans `asg-web`
- [ ] L'historique de déploiement montre `deploy-web-01` réussi

**Pièges :** LB Basic n'a pas de SLA, pas de zones, pas de règles de sortie ; LB Standard exige une IP publique Standard et un **NSG qui autorise le trafic** (tout est refusé par défaut) ; LB = couche 4, Application Gateway = couche 7 (WAF, routage URL), Traffic Manager = DNS, Front Door = couche 7 globale ; availability set (domaines de panne et de mise à jour, 99,95 %) contre zones (99,99 %) contre VMSS ; le mode **Complete** supprime ce qui n'est pas dans le template ; `@secure()` masque le paramètre dans l'historique ; redimensionner une VM = redémarrage ; le disque temporaire est perdu à la désallocation ; une VM ne peut pas être déplacée d'une zone à une autre sans recréation ; **`dependsOn` implicite** en Bicep dès qu'une ressource référence une autre par symbole ; les **spot VM** peuvent être évincées et ne conviennent pas au front web ; une IP publique Standard est **statique et zone-redondante** par défaut, une Basic est dynamique.

---

## 8. Atelier 5 : conteneurs avec ACR et ACI (14:30 à 15:15), ticket T5

### Le ticket

> « NovaDev a livré l'API TrackIt sous forme d'image Docker. Elle doit tourner dans notre réseau privé (sous-réseau `snet-app`), être appelable par les serveurs web sur le port 8080, sans que la DSI ait à gérer de serveur. »

### Rappel des concepts

**Conteneur, image, registre.** Un conteneur est un processus isolé qui partage le noyau de l'hôte, démarré à partir d'une **image** immuable (couches décrites par un Dockerfile). Les images sont stockées dans un **registre** (Docker Hub, ou un registre privé). Avantages par rapport à la VM : démarrage en secondes, densité, portabilité, reproductibilité ; en contrepartie, pas d'isolation noyau et une durée de vie courte (l'état va ailleurs : volume, base, stockage).

**Azure Container Registry (ACR)** est le registre privé managé. Trois SKU : **Basic** (apprentissage), **Standard** (production courante), **Premium** (géo-réplication, point de terminaison privé, zones, quotas plus élevés). **ACR Tasks** (`az acr build`) construit l'image dans Azure : pas besoin de Docker sur le poste. `az acr import` copie une image depuis un autre registre. L'authentification se fait par Entra ID (rôles **AcrPull**, **AcrPush**, **AcrDelete**), par principal de service, par identité managée, ou par le compte administrateur (à laisser désactivé). ACR peut aussi scanner les images (Defender for Containers) et purger les anciens tags.

**Azure Container Instances (ACI)** exécute des conteneurs à la demande, facturés à la seconde, sans cluster à gérer. Unité de déploiement : le **groupe de conteneurs** (un ou plusieurs conteneurs sur le même hôte, partageant IP, ports, cycle de vie et volumes, comme un pod). Options : IP publique avec étiquette DNS, ou **déploiement dans un VNet** (sous-réseau délégué, IP privée uniquement), volumes **Azure Files**, secrets, variables d'environnement, politique de redémarrage (Always, OnFailure, Never), identité managée, GPU. Cas d'usage : tâches ponctuelles, traitements par lots, API légères, montée en charge « virtual node » pour AKS.

**Situer les autres options de calcul conteneur et PaaS :**

| Service | Vous gérez | Idéal pour |
|---|---|---|
| VM avec Docker | OS, moteur, mises à jour | Contrôle total, existant |
| ACI | Rien, une image | Tâches, API simples, tests |
| App Service (Web App for Containers) | L'application | Sites et API web, emplacements de déploiement, mise à l'échelle |
| Azure Container Apps | L'application, la mise à l'échelle par événements | Microservices, scale to zero |
| AKS | Les nœuds (VMSS), les manifestes | Orchestration Kubernetes complète |

**App Service**, très présent à l'examen : un **plan App Service** définit la région, le SKU (Free, Shared, Basic, Standard, Premium, Isolated) et donc la facturation et les fonctionnalités (mise à l'échelle automatique dès Standard, emplacements de déploiement, sauvegardes, domaines personnalisés et certificats, intégration VNet). Plusieurs applications peuvent partager un plan. Les **emplacements de déploiement (slots)** permettent un basculement sans interruption ; certains paramètres suivent l'emplacement, d'autres l'application.

### Démo formateur (20 min)

**1. Le registre**

```bash
ACR="acrtrackit$SUFFIX"
az acr create -g $RG_SHARED -n $ACR --sku Standard -l $LOC --admin-enabled false --tags $TAGS
```

**2. L'API (livrée par NovaDev)**, dossier `api/` :

```dockerfile
# api/Dockerfile
FROM python:3.12-slim
WORKDIR /app
RUN pip install --no-cache-dir flask==3.0.3
COPY app.py .
EXPOSE 8080
CMD ["python", "app.py"]
```

```python
# api/app.py
import os, socket
from flask import Flask, jsonify
app = Flask(__name__)

@app.get("/api/palettes/<pid>")
def palette(pid):
    return jsonify(palette=pid, statut="En transit - Lyon vers Nantes",
                   temperature_c=-18.2, instance=socket.gethostname(),
                   version=os.getenv("API_VERSION", "1.0"))

@app.get("/health")
def health():
    return "OK", 200

app.run(host="0.0.0.0", port=8080)
```

**3. Construction à distance dans ACR (ACR Tasks), sans Docker local**

```bash
az acr build -r $ACR -t trackit-api:1.0 ./api
az acr repository show-tags -n $ACR --repository trackit-api -o table
```

Montrer aussi `az acr login` puis `docker build` et `docker push` pour ceux qui ont Docker Desktop. Expliquer les SKU Basic, Standard et Premium.

**4. Déploiement en ACI dans le VNet, avec identité managée pour tirer l'image**

```bash
# Identité managée affectée par l'utilisateur, avec le droit AcrPull
az identity create -g $RG_SHARED -n id-trackit-api -l $LOC
ID_RES=$(az identity show -g $RG_SHARED -n id-trackit-api --query id -o tsv)
ID_PRIN=$(az identity show -g $RG_SHARED -n id-trackit-api --query principalId -o tsv)
ACR_ID=$(az acr show -n $ACR --query id -o tsv)
az role assignment create --assignee-object-id $ID_PRIN --assignee-principal-type ServicePrincipal \
   --role AcrPull --scope $ACR_ID

SUBNET_APP=$(az network vnet subnet show -g $RG_NET --vnet-name vnet-trackit-prod -n snet-app --query id -o tsv)
az container create -g $RG_PROD -n aci-trackit-api -l $LOC \
   --image $ACR.azurecr.io/trackit-api:1.0 --acr-identity $ID_RES --assign-identity $ID_RES \
   --cpu 1 --memory 1.5 --ports 8080 --os-type Linux \
   --subnet $SUBNET_APP --restart-policy Always \
   --environment-variables API_VERSION=1.0 --tags $TAGS

API_IP=$(az container show -g $RG_PROD -n aci-trackit-api --query ipAddress.ip -o tsv); echo $API_IP
az container logs -g $RG_PROD -n aci-trackit-api
```

**5. Test de bout en bout depuis une VM web via Bastion**

```bash
# Depuis vm-web-02 (session Bastion) :
curl http://<API_IP>:8080/api/palettes/PAL-7781
# Résultat attendu : {"palette":"PAL-7781","statut":"En transit - Lyon vers Nantes", ...}
# Depuis Cloud Shell : curl échoue (pas d'IP publique, NSG). C'est voulu.
```

Puis brancher le front sur l'API : sur chaque VM web, ajouter dans la configuration nginx un bloc `location /api/ { proxy_pass http://<API_IP>:8080/api/; }` puis `sudo systemctl reload nginx`. Vérifier `http://trackit-<suffix>.francecentral.cloudapp.azure.com/api/palettes/PAL-7781`.

L'ACI n'est pas dans le pool du LB : **une ACI n'a pas de NIC**, on ne peut donc pas la placer dans un ASG. C'est le NSG `nsg-app` (source `asg-web`) qui la protège. Si l'exigence était l'équilibrage de plusieurs API, on parlerait d'**App Service**, de **Container Apps** ou d'**AKS** : les situer sur la carte AZ-104 (5 min).

### Reproduction par les participants (20 min)

Étapes 1 à 4 puis test `curl` depuis `vm-web-02` via Bastion. Bonus : `az container exec -g $RG_PROD -n aci-trackit-api --exec-command /bin/sh`.

### Bonnes pratiques

- **Jamais de compte administrateur ACR en production** : identité managée et `AcrPull` pour ceux qui tirent, principal de service et `AcrPush` pour la chaîne de construction.
- **Étiqueter les images avec une version explicite**, jamais uniquement `latest` : on ne sait plus ce qui tourne, et un redéploiement peut changer le code sans que personne ne l'ait demandé.
- **Images minimales** (`slim`, `alpine`, distroless), un processus par conteneur, exécution sans root, et analyse des vulnérabilités activée sur le registre.
- **La configuration vient de l'extérieur** (variables d'environnement, secrets ACI, Key Vault), l'image est identique en test et en production.
- **Un point de terminaison de santé** (`/health`) dans chaque API : il sert aux sondes du LB, d'App Service ou de Kubernetes.
- **ACI pour l'éphémère et le simple ; App Service ou Container Apps dès qu'il faut du HTTPS géré, de la mise à l'échelle et des emplacements de déploiement.**

### Checkpoint et pièges d'examen (5 min)

- [ ] Image `trackit-api:1.0` dans l'ACR
- [ ] `aci-trackit-api` en état *Running* avec une IP 10.10.2.x
- [ ] `curl` réussit depuis `vm-web-02`, échoue depuis Internet
- [ ] Le front répond sur `/api/palettes/...`

**Pièges :** ACI dans un VNet = pas d'IP publique, sous-réseau **délégué** et dédié ; groupe de conteneurs = même hôte, même IP, même cycle de vie (modèle sidecar) ; volumes ACI via **Azure Files** (pas de disque managé) ; `az acr import` pour copier depuis Docker Hub ; la géo-réplication ACR est Premium ; App Service : le plan porte la facturation, la mise à l'échelle **verticale** (changer de SKU) contre **horizontale** (ajouter des instances), les emplacements de déploiement à partir de Standard, le **swap** échange le trafic et conserve les paramètres marqués « slot setting » ; **Deployment Center** pour le déploiement continu ; AKS : le plan de contrôle est gratuit et géré, les nœuds sont des VMSS facturés, `kubectl` et les manifestes YAML ne sont pas au programme AZ-104 en profondeur.

---

## 9. Atelier 6 : App registration, principal de service, identité managée (15:30 à 16:15), ticket T6

### Le ticket

> « Les clients de Boréal doivent se connecter à TrackIt avec leur compte Microsoft d'entreprise. Le pipeline de NovaDev doit pouvoir pousser une nouvelle image et redéployer l'ACI **sans mot de passe stocké dans le code**. Et le mot de passe administrateur des VM ne doit plus traîner dans un paramètre. »

### Rappel des concepts

**Les trois objets à ne pas confondre :**

| Objet | Ce que c'est | Où il vit | Ce qu'on lui donne |
|---|---|---|---|
| **App registration** (objet application) | La définition d'une application : identifiant client, URI de redirection, secrets ou certificats, permissions demandées, API exposées | Une seule fois, dans le tenant d'origine | Rien directement : c'est une description |
| **Enterprise application** (principal de service) | L'instance de cette application dans un tenant donné ; c'est elle qui s'authentifie | Un par tenant qui utilise l'application | Des rôles Azure RBAC, des affectations d'utilisateurs, des consentements |
| **Identité managée** | Un principal de service dont Azure crée et fait tourner le secret ; aucune information d'identification à gérer | Liée à une ressource Azure (VM, ACI, App Service, Function) | Des rôles Azure RBAC, des rôles d'application |

**Identité managée affectée par le système** : créée avec la ressource, supprimée avec elle, une par ressource. **Affectée par l'utilisateur** : ressource indépendante, partageable entre plusieurs ressources, survit à leur suppression, à privilégier pour les flottes homogènes (nos VM web, notre ACI). La ressource obtient un jeton en interrogeant le point de terminaison IMDS (169.254.169.254) ou via les SDK (`DefaultAzureCredential`).

**Le vocabulaire OAuth 2.0 et OpenID Connect** utile pour l'examen : le **client** (TrackIt-Web) redirige l'utilisateur vers Entra ID (**fournisseur d'identité**), qui renvoie un **jeton d'identité** (qui est l'utilisateur) et un **jeton d'accès** (ce qu'il peut faire sur une **ressource**, par exemple Microsoft Graph ou notre API). Les **permissions déléguées** agissent au nom d'un utilisateur connecté ; les **permissions d'application** agissent sans utilisateur (démons, pipelines) et exigent un consentement administrateur. Les **étendues (scopes)** exposées par une API (`api://<app-id>/Palettes.Read`) permettent de découper finement les droits. Les **types de comptes pris en charge** : ce tenant seulement (single tenant), tout tenant Entra (multi-tenant), avec ou sans comptes Microsoft personnels.

**Informations d'identification d'une application** : secret client (durée limitée, à faire tourner), certificat (préférable), ou **informations d'identification fédérées** (workload identity federation : GitHub Actions, Azure DevOps ou Kubernetes présentent leur propre jeton OIDC, Entra l'échange contre un jeton Azure ; zéro secret à stocker).

**Azure Key Vault** stocke **secrets**, **clés** cryptographiques et **certificats**. Deux modèles d'autorisation : **RBAC Azure** (recommandé : Key Vault Administrator, Secrets Officer, Secrets User, Crypto User) ou les **stratégies d'accès** héritées. Protection : suppression réversible (obligatoire, 7 à 90 jours) et protection contre la purge. Références Key Vault depuis un template ARM ou Bicep, depuis App Service (`@Microsoft.KeyVault(...)`) ou via l'extension VM. Deux niveaux : Standard (clés logicielles) et Premium (clés protégées par HSM).

### Démo formateur (25 min)

**1. App registration « TrackIt-Web » : l'application que les utilisateurs voient**

Portail : *Microsoft Entra ID > App registrations > New registration* :

| Champ | Valeur |
|---|---|
| Nom | `TrackIt-Web` |
| Types de comptes | *Accounts in this organizational directory only* (single tenant) |
| URI de redirection (Web) | `http://trackit-<suffix>.francecentral.cloudapp.azure.com/signin-oidc` |

Puis :
- **Authentication** : activer *ID tokens* (flux OIDC), expliquer l'URI de redirection et l'URL de déconnexion.
- **Certificates and secrets** : créer un secret (expiration 6 mois), **le copier tout de suite**, expliquer pourquoi on ne le reverra plus.
- **API permissions** : `Microsoft Graph > User.Read` (déléguée), puis *Grant admin consent*.
- **Expose an API** : définir `api://<app-id>/Palettes.Read` ; c'est l'étendue que le front demandera pour appeler l'API.
- **Enterprise applications** : montrer le **principal de service** créé automatiquement, l'onglet *Users and groups* pour affecter `grp-trackit-readers`, et activer *Assignment required* dans *Properties* (seuls les membres affectés peuvent se connecter).

```bash
APP_ID=$(az ad app create --display-name TrackIt-Web --sign-in-audience AzureADMyOrg \
   --web-redirect-uris "http://trackit-$SUFFIX.francecentral.cloudapp.azure.com/signin-oidc" \
   --enable-id-token-issuance true --query appId -o tsv)
az ad sp create --id $APP_ID
az ad app permission add --id $APP_ID --api 00000003-0000-0000-c000-000000000000 \
   --api-permissions e1fe6dd8-ba31-4d61-89e7-88639da4683d=Scope   # User.Read
az ad app permission admin-consent --id $APP_ID
az ad sp update --id $APP_ID --set appRoleAssignmentRequired=true
```

Test : ouvrir dans une fenêtre privée `https://login.microsoftonline.com/<tenant-id>/oauth2/v2.0/authorize?client_id=<APP_ID>&response_type=id_token&redirect_uri=http://trackit-<suffix>.francecentral.cloudapp.azure.com/signin-oidc&scope=openid&nonce=123&response_mode=fragment` avec `chef.lyon` : consentement puis redirection vers le site (nginx affichera 404 sur `/signin-oidc`, c'est normal : on prouve l'authentification, pas l'application). Tester ensuite avec `dev.novadev`, non affecté : refus `AADSTS50105`.

**2. Principal de service « sp-trackit-deploy » : l'identité du pipeline**

```bash
az ad sp create-for-rbac -n sp-trackit-deploy --role Contributor \
   --scopes /subscriptions/$SUB/resourceGroups/$RG_PROD
az role assignment create --assignee $(az ad sp list --display-name sp-trackit-deploy --query [0].id -o tsv) \
   --role AcrPush --scope $ACR_ID
```

Distinguer clairement les trois objets (tableau ci-dessus). Montrer l'alternative moderne : **informations d'identification fédérées** (OIDC GitHub Actions), donc zéro secret.

Simuler le pipeline dans une seconde session Cloud Shell :

```bash
az login --service-principal -u <appId> -p <password> --tenant <tenant>
az acr build -r $ACR -t trackit-api:1.1 ./api        # nouvelle version
az container create ... --image $ACR.azurecr.io/trackit-api:1.1 --environment-variables API_VERSION=1.1 ...
```

**3. Key Vault et identité managée : plus de secret dans les paramètres**

```bash
KV="kv-trackit-$SUFFIX"
az keyvault create -g $RG_SHARED -n $KV -l $LOC --enable-rbac-authorization true \
   --enable-purge-protection true --tags $TAGS
az role assignment create --assignee $(az ad signed-in-user show --query id -o tsv) \
   --role "Key Vault Secrets Officer" --scope $(az keyvault show -n $KV --query id -o tsv)
az keyvault secret set --vault-name $KV -n vm-admin-password --value 'Bootcamp-AZ104-Passw0rd!'
az keyvault secret set --vault-name $KV -n trackit-web-client-secret --value '<secret copié plus haut>'
```

Modifier le déploiement Bicep pour lire le secret depuis Key Vault (fichier `main.bicepparam`) :

```bicep
using './trackit-web.bicep'
param suffix = 'ryo042'
param adminPassword = az.getSecret('<subscription-id>', 'rg-trackit-shared', 'kv-trackit-ryo042', 'vm-admin-password')
```

Puis donner à l'identité `id-trackit-api` (atelier 5) les rôles **Key Vault Secrets User** sur le coffre et **Storage Blob Data Reader** sur le compte de stockage : l'API pourra lire les bons de livraison sans clé. Montrer la chaîne : ACI, puis identité managée, puis jeton Entra, puis Storage via le point de terminaison privé.

```bash
az role assignment create --assignee-object-id $ID_PRIN --assignee-principal-type ServicePrincipal \
   --role "Key Vault Secrets User" --scope $(az keyvault show -n $KV --query id -o tsv)
az role assignment create --assignee-object-id $ID_PRIN --assignee-principal-type ServicePrincipal \
   --role "Storage Blob Data Reader" --scope $(az storage account show -g $RG_PROD -n $ST --query id -o tsv)
```

### Reproduction par les participants (15 min)

Créer l'app registration (portail), le secret, l'affectation de `grp-trackit-readers` ; tester la connexion `chef.lyon` puis `dev.novadev`. Bonus : Key Vault et `.bicepparam`.

### Bonnes pratiques

- **Identité managée d'abord, principal de service ensuite, secret en dernier recours.** Si un secret est indispensable : durée courte, rotation planifiée, stockage dans Key Vault, alerte avant expiration.
- **Certificat ou fédération OIDC plutôt que secret client** pour les pipelines ; les secrets copiés dans un fichier YAML finissent dans Git.
- **Un principal de service par usage et par environnement**, avec l'étendue la plus étroite : `sp-trackit-deploy` n'a rien à faire sur `rg-trackit-network`.
- **Activer « Assignment required »** sur les applications d'entreprise sensibles : par défaut tout utilisateur du tenant peut se connecter à une application enregistrée.
- **Limiter le consentement utilisateur** (paramètres de consentement Entra ID) : les permissions à fort impact passent par un consentement administrateur.
- **Key Vault : un coffre par application et par environnement**, modèle RBAC, suppression réversible et protection contre la purge, journaux de diagnostic vers Log Analytics, accès réseau restreint (point de terminaison privé) en production.
- **Surveiller les connexions** : journaux de connexion Entra ID, Identity Protection (P2) pour les connexions à risque, Conditional Access pour exiger MFA ou un appareil conforme.

### Checkpoint et pièges d'examen (5 min)

- [ ] `TrackIt-Web` existe, URI de redirection configurée, `User.Read` consentie
- [ ] `chef.lyon` s'authentifie, `dev.novadev` est refusé (assignment required)
- [ ] `sp-trackit-deploy` est Contributor sur `rg-trackit-prod` et AcrPush sur le registre
- [ ] (bonus) le mot de passe VM vient de Key Vault

**Pièges :** une application multi-tenant demande un éditeur vérifié et un consentement dans chaque tenant ; le secret n'est visible qu'à la création ; **identité managée affectée par le système** disparaît avec la ressource, **affectée par l'utilisateur** est indépendante et partageable ; Key Vault modèle **RBAC** contre **stratégies d'accès** (on ne mélange pas les deux) ; pour référencer un secret dans un template il faut soit `enabledForTemplateDeployment` (modèle stratégies d'accès) soit le rôle adéquat pour le déployeur (modèle RBAC) ; la suppression réversible Key Vault est obligatoire, la protection contre la purge est irréversible une fois activée ; **Conditional Access** et **MFA** requièrent Entra ID P1 (les paramètres de sécurité par défaut offrent une MFA de base gratuite) ; **SSPR** nécessite l'inscription de méthodes et peut écrire en retour vers AD DS avec Entra Connect ; un rôle Entra ID (Application Administrator) permet de gérer les enregistrements d'applications mais ne donne aucun droit sur les ressources Azure.

---

## 10. Atelier 7 : supervision, alertes, sauvegarde (16:15 à 16:50), ticket T7

### Le ticket

> « On veut savoir *avant* le client quand une VM web sature ou tombe, garder les journaux 90 jours, et pouvoir restaurer une VM en cas de mauvaise manipulation. »

### Rappel des concepts

**Azure Monitor** collecte deux grandes familles de données. Les **métriques** : valeurs numériques horodatées, quasi temps réel, conservées 93 jours, gratuites pour les métriques de plateforme, visibles dans Metrics Explorer. Les **journaux** : événements structurés stockés dans un **espace de travail Log Analytics**, interrogés en **KQL (Kusto Query Language)**, facturés à l'ingestion et à la rétention (31 jours inclus, configurable jusqu'à 2 ans en interactif, puis archive). S'y ajoutent le **journal d'activité** (opérations du plan de contrôle : qui a créé, modifié, supprimé quoi ; conservé 90 jours gratuitement, exportable), les **journaux de ressources** (plan de données : requêtes sur un compte de stockage, règles NSG déclenchées, activés par un **paramètre de diagnostic**), et les **insights** (VM Insights, Container Insights, Application Insights pour le code).

**Collecte sur les VM** : l'**Azure Monitor Agent (AMA)** remplace les anciens agents Log Analytics (MMA) et Diagnostics. Il est piloté par des **règles de collecte de données (DCR)** qui définissent quoi collecter (compteurs de performance, Syslog, journaux d'événements Windows, fichiers texte) et vers quel espace de travail l'envoyer. Un **point de terminaison de collecte (DCE)** est nécessaire pour certaines sources et pour les scénarios de liaison privée.

**Alertes** : une **règle d'alerte** associe une étendue, un **signal** (métrique, requête de journal, journal d'activité, Service Health, Resource Health), une **condition** (seuil statique ou dynamique, fenêtre d'agrégation, fréquence d'évaluation), une **gravité** (0 critique à 4 verbeuse) et un ou plusieurs **groupes d'actions** (e-mail, SMS, push, voix, webhook, Logic App, Function, runbook Automation, ITSM). Les **règles de traitement des alertes** permettent de suspendre les notifications pendant une maintenance. Les alertes métriques sont les moins chères et les plus rapides ; les alertes de journal permettent des conditions complexes mais avec une latence de quelques minutes.

**Azure Backup** protège les VM (via l'extension de sauvegarde, instantané puis transfert vers le coffre), les partages Azure Files, SQL Server et SAP HANA dans des VM, les disques managés, les blobs et les serveurs sur site (agent MARS, Azure Backup Server). Deux types de coffres : **Recovery Services vault** (VM, Files, SQL, MARS, et Site Recovery) et **Backup vault** (disques, blobs, PostgreSQL). Une **stratégie de sauvegarde** fixe la fréquence, l'heure et les rétentions (quotidienne, hebdomadaire, mensuelle, annuelle). La **redondance du coffre** (LRS, ZRS, GRS avec restauration inter-régions) se choisit avant la première sauvegarde. La **suppression réversible** du coffre conserve les données 14 jours après arrêt de la protection. La restauration peut recréer la VM, restaurer les disques seuls, remplacer les disques existants ou récupérer des fichiers individuels par montage.

**Azure Site Recovery (ASR)** réplique des VM vers une autre région (ou depuis VMware, Hyper-V, physique vers Azure) pour de la reprise d'activité : plans de récupération, tests de basculement sans impact, RPO de quelques minutes. Sauvegarde et réplication répondent à des besoins différents : la première à l'erreur et à la corruption, la seconde au sinistre régional.

**Network Watcher** regroupe les outils de diagnostic réseau : topologie, **IP flow verify** (une règle NSG bloque-t-elle ce flux ?), **NSG diagnostics**, **next hop**, **connection troubleshoot** et **connection monitor**, capture de paquets, **journaux de flux NSG** et **Traffic Analytics**. Il est activé automatiquement par région à la création d'un VNet.

### Démo formateur (20 min)

**1. Log Analytics et Azure Monitor Agent via DCR**

```bash
az monitor log-analytics workspace create -g $RG_SHARED -n log-trackit-prod -l $LOC --retention-time 90 --tags $TAGS
LAW=$(az monitor log-analytics workspace show -g $RG_SHARED -n log-trackit-prod --query id -o tsv)
# Portail : Monitor > Data Collection Rules > Create : cibler vm-web-01 et vm-web-02,
# collecter Syslog (auth, daemon) et performances (CPU, mémoire, disque, réseau) vers log-trackit-prod.
# L'AMA est installé automatiquement sur les VM à l'association de la DCR.
```

**2. Paramètres de diagnostic** sur le Load Balancer, le compte de stockage (blob) et le Key Vault, envoyés vers `log-trackit-prod` ; journaux de flux NSG via Network Watcher pour `nsg-web`.

```bash
az monitor diagnostic-settings create -n diag-lb --resource $(az network lb show -g $RG_PROD -n lb-trackit-web --query id -o tsv) \
   --workspace $LAW --metrics '[{"category":"AllMetrics","enabled":true}]' --logs '[{"categoryGroup":"allLogs","enabled":true}]'
az monitor diagnostic-settings create -n diag-kv --resource $(az keyvault show -n $KV --query id -o tsv) \
   --workspace $LAW --logs '[{"categoryGroup":"audit","enabled":true}]'
```

**3. Requête KQL et alertes**

```kusto
Perf
| where ObjectName == "Processor" and CounterName == "% Processor Time"
| summarize avg(CounterValue) by Computer, bin(TimeGenerated, 5m)
| render timechart
```

```kusto
// Qui a désalloué une VM aujourd'hui ?
AzureActivity
| where OperationNameValue endswith "virtualMachines/deallocate/action"
| project TimeGenerated, Caller, ResourceGroup, Resource=_ResourceId, ActivityStatusValue
```

```bash
az monitor action-group create -g $RG_SHARED -n ag-dsi --short-name dsi \
   --action email dsi abo@archia365.fr
az monitor metrics alert create -g $RG_PROD -n alert-cpu-web \
   --scopes $(az vm show -g $RG_PROD -n vm-web-01 --query id -o tsv) $(az vm show -g $RG_PROD -n vm-web-02 --query id -o tsv) \
   --condition "avg Percentage CPU > 80" --window-size 5m --evaluation-frequency 1m --severity 2 \
   --action ag-dsi --description "CPU web superieure a 80 % pendant 5 min"
# Alerte de journal d'activité : VM désallouée
az monitor activity-log alert create -g $RG_PROD -n alert-vm-deallocate --scope /subscriptions/$SUB \
   --condition category=Administrative and operationName=Microsoft.Compute/virtualMachines/deallocate/action \
   --action-group ag-dsi
# Alerte de disponibilité du LB : sonde de santé
az monitor metrics alert create -g $RG_PROD -n alert-lb-health \
   --scopes $(az network lb show -g $RG_PROD -n lb-trackit-web --query id -o tsv) \
   --condition "avg DipAvailability < 50" --window-size 5m --evaluation-frequency 1m --severity 1 --action ag-dsi
```

Déclencher : `stress` sur `vm-web-02` via Bastion (`sudo apt install -y stress && stress --cpu 2 --timeout 300`), ou simplement désallouer `vm-web-02` pour recevoir l'alerte du journal d'activité et celle du LB.

**4. Azure Backup**

```bash
az backup vault create -g $RG_SHARED -n rsv-trackit -l $LOC --tags $TAGS
az backup vault backup-properties set -g $RG_SHARED -n rsv-trackit --backup-storage-redundancy LocallyRedundant
az backup protection enable-for-vm -g $RG_SHARED -v rsv-trackit --vm vm-web-01 --policy-name DefaultPolicy
az backup protection backup-now -g $RG_SHARED -v rsv-trackit -c vm-web-01 -i vm-web-01 --retain-until 05-09-2026
az backup job list -g $RG_SHARED -v rsv-trackit -o table
```

Montrer dans le portail la stratégie (fréquence, rétention), les options de **restauration** (nouvelle VM, disques, remplacement, fichiers) et évoquer **Azure Site Recovery** pour la réplication inter-régions.

**5. Network Watcher** (5 min) : *IP flow verify* depuis Internet vers `vm-web-01:22`, résultat **refusé par `Deny-All-Inbound`** ; *Connection troubleshoot* de `vm-web-02` vers `<API_IP>:8080`, résultat réussi. La boucle est bouclée avec l'atelier 2.

### Reproduction par les participants (10 min)

Espace de travail, alerte métrique CPU, activation de la sauvegarde de `vm-web-01`. La DCR et les journaux de flux sont montrés par le formateur.

### Bonnes pratiques

- **Un espace de travail Log Analytics central par environnement** (ou par région pour la souveraineté), avec RBAC par table ou par ressource si des équipes différentes y accèdent.
- **Paramètres de diagnostic déployés par Azure Policy** (effet DeployIfNotExists) : une ressource créée sans journaux est une ressource invisible.
- **Alerter sur des symptômes utilisateurs** (disponibilité de la sonde, latence, erreurs 5xx) avant d'alerter sur des causes (CPU). Utiliser des **seuils dynamiques** pour les métriques saisonnières, et des gravités cohérentes : Sev 0 et 1 réveillent quelqu'un, Sev 3 et 4 vont dans un tableau de bord.
- **Un groupe d'actions par équipe et par canal**, pas par alerte ; tester le groupe d'actions à la création.
- **Sauvegarder tout ce qui a un état** (VM, Files, bases) avec une stratégie alignée sur le RPO ; **tester la restauration** au moins une fois par trimestre, une sauvegarde jamais restaurée n'existe pas.
- **Protéger le coffre** : suppression réversible activée, autorisation multi-utilisateur (Resource Guard) pour les opérations destructrices, redondance GRS avec restauration inter-régions pour la production.
- **Maîtriser les coûts d'observabilité** : plafond d'ingestion quotidien, tables en plan Basic pour les journaux verbeux, rétention d'archive pour la conformité, et un regard régulier sur **Azure Advisor** (coût, sécurité, fiabilité, performance, excellence opérationnelle).

### Checkpoint et pièges d'examen (5 min)

- [ ] Espace de travail `log-trackit-prod`, rétention 90 jours
- [ ] Alerte `alert-cpu-web` et groupe d'actions par e-mail, alerte reçue
- [ ] `vm-web-01` protégée par Azure Backup, une sauvegarde en cours ou terminée
- [ ] IP flow verify confirme le blocage du port 22 depuis Internet

**Pièges :** métriques (quasi temps réel, 93 jours) contre journaux (KQL, rétention configurable, coût à l'ingestion) ; le journal d'activité est du plan de contrôle, 90 jours gratuits, à exporter vers Log Analytics pour le conserver ; alerte métrique, alerte de recherche de journaux et alerte de journal d'activité ont des latences et des coûts différents ; **Azure Monitor Agent avec DCR** remplace l'agent Log Analytics (MMA), retiré ; un coffre Recovery Services ne peut pas être supprimé tant qu'il contient des éléments protégés (arrêter la protection **et** supprimer les données) ; la redondance du coffre est figée après la première sauvegarde ; la sauvegarde de VM ne prend qu'un instantané par jour en stratégie Standard (Enhanced permet plusieurs par jour) ; **Azure Advisor** = recommandations, **Service Health** = incidents de la plateforme et maintenance planifiée, **Resource Health** = état de ma ressource ; **VM Insights** nécessite l'AMA et la DCR associée ; les **classeurs (workbooks)** sont des rapports interactifs, les **tableaux de bord** des vues épinglées.

---

## 11. Clôture (16:50 à 17:00)

1. **Relecture du tableau des tickets** : T1 à T7 fermés, architecture cible en place. Rejouer le parcours d'une requête : navigateur, puis LB, puis VM web (ASG et NSG), puis ACI (NSG), puis Storage (point de terminaison privé, identité managée), en nommant à chaque saut la notion AZ-104 mobilisée.
2. **Nettoyage**, dans l'ordre (le verrou et le coffre bloqueront sinon : c'est volontaire, c'est un rappel) :

```bash
az backup protection disable -g $RG_SHARED -v rsv-trackit -c vm-web-01 -i vm-web-01 --delete-backup-data true --yes
az lock delete --name lock-no-delete-net --resource-group $RG_NET
az group delete -n $RG_PROD --yes --no-wait
az group delete -n $RG_NET --yes --no-wait
az group delete -n $RG_SHARED --yes --no-wait
az ad app delete --id $APP_ID
az ad sp delete --id $(az ad sp list --display-name sp-trackit-deploy --query [0].id -o tsv)
az policy assignment delete --name req-tag-costcenter
az policy assignment delete --name allowed-locations
# Le Key Vault reste en suppression réversible 90 jours (protection contre la purge activée) : c'est normal.
```

3. **Pièges du jour à retenir** (tour de table express, un par participant).
4. Pointer vers Microsoft Learn, parcours *AZ-104 : Prerequisites, Manage identities and governance, Implement and manage storage, Deploy and manage compute, Configure and manage virtual networking, Monitor and back up*, et les *practice assessments* gratuits. Rappeler le format de l'examen : 40 à 60 questions, 100 minutes, étude de cas, questions à réponses multiples, glisser-déposer, et un score de réussite de 700 sur 1000.

---

## 12. Couverture de l'examen AZ-104 par le scénario

| Domaine d'examen (pondération) | Couvert par | Notions vues |
|---|---|---|
| Gérer les identités et la gouvernance Azure (20 à 25 %) | Ateliers 1 et 6 | Utilisateurs et groupes, B2B, SSPR, rôles Entra ID contre RBAC, rôles intégrés et personnalisés, étendues, Azure Policy (définitions, initiatives, effets), verrous, tags, app registration, principaux de service, identités managées, Key Vault |
| Implémenter et gérer le stockage (15 à 20 %) | Atelier 3 (et 5, 6) | Types de comptes, redondance, niveaux d'accès, cycle de vie, SAS et stored access policy, rôles de données, Azure Files et File Sync, AzCopy, pare-feu, point de terminaison privé, DNS privé, soft delete et versioning |
| Déployer et gérer les ressources de calcul (20 à 25 %) | Ateliers 4 et 5 | Bicep et ARM, what-if, modes de déploiement, VM (tailles, disques, extensions), availability set, zones, VMSS, ACR, ACI, identité managée, App Service (plans, emplacements, mise à l'échelle), AKS en situation |
| Configurer et gérer les réseaux virtuels (15 à 20 %) | Ateliers 2 et 4 | VNet, sous-réseaux, délégation, adresses réservées, NSG, ASG, balises de service, Bastion, peering, UDR, Load Balancer Standard (sondes, règles, sortie), Application Gateway et Traffic Manager en situation, DNS privé, Network Watcher |
| Surveiller et maintenir les ressources (10 à 15 %) | Atelier 7 | Métriques et journaux, Log Analytics, AMA et DCR, paramètres de diagnostic, KQL, alertes (métrique, journal, activité), groupes d'actions, Azure Backup, Recovery Services, Site Recovery, Advisor, Service Health |

## 13. Kit formateur : checklist J-1

- [ ] Souscriptions des participants créées, quota d'au moins 4 vCPU Dsv5 en `francecentral`, fournisseurs `Microsoft.ContainerInstance`, `Microsoft.Network`, `Microsoft.Compute`, `Microsoft.Storage`, `Microsoft.KeyVault`, `Microsoft.RecoveryServices`, `Microsoft.OperationalInsights`, `Microsoft.Insights` enregistrés
- [ ] Droits Entra ID : chaque participant est au minimum *User Administrator* et *Application Administrator* sur son tenant de lab (ou un tenant dédié par participant)
- [ ] Dépôt Git du bootcamp : `prologue.sh`, `trackit-web.bicep`, `main.bicepparam`, `lifecycle.json`, dossier `api/`, `cleanup.sh`
- [ ] Architecture cible déjà déployée dans la souscription du formateur (plan B si un déploiement participant échoue)
- [ ] Bastion : lancer le déploiement en `--no-wait` en début d'atelier 2 (environ 10 min)
- [ ] Plan de secours quotas : basculer en `westeurope` ou réduire à `Standard_B2s` (ajuster le paramètre `vmSize`)
- [ ] Vérifier que Cloud Shell est autorisé par la Conditional Access du tenant de lab
- [ ] Préparer une adresse e-mail joignable pour le groupe d'actions de l'atelier 7 (l'alerte doit arriver en séance)

## 14. Glossaire express

| Terme | Définition en une phrase |
|---|---|
| ACI | Azure Container Instances : exécution de conteneurs sans serveur, facturée à la seconde |
| ACR | Azure Container Registry : registre privé d'images, avec construction à distance (ACR Tasks) |
| AMA / DCR | Azure Monitor Agent et Data Collection Rule : agent unique de collecte piloté par des règles |
| ARM | Azure Resource Manager : le plan de contrôle et le format de template JSON |
| ASG | Application Security Group : étiquette logique de NIC utilisée comme source ou destination dans un NSG |
| Bastion | Accès RDP et SSH via le portail, sans IP publique sur les VM |
| Bicep | Langage déclaratif qui se transpile en template ARM |
| DCE | Data Collection Endpoint : point de terminaison de collecte pour certaines sources et la liaison privée |
| IMDS | Instance Metadata Service (169.254.169.254) : fournit métadonnées et jetons d'identité managée aux VM |
| KQL | Kusto Query Language : langage de requête de Log Analytics |
| LRS / ZRS / GRS | Niveaux de redondance du stockage : local, zonal, géographique |
| NSG | Network Security Group : pare-feu à état de couche 3 et 4, sur sous-réseau ou NIC |
| PIM | Privileged Identity Management : élévation de rôle temporaire et approuvée (Entra ID P2) |
| RBAC | Role-Based Access Control : principal + rôle + étendue |
| RPO / RTO | Perte de données maximale admissible / délai de reprise maximal admissible |
| SAS | Shared Access Signature : URL signée donnant un accès limité au stockage |
| SKU | Référence commerciale d'un service (Basic, Standard, Premium) |
| UDR | User Defined Route : route personnalisée qui remplace une route système |
| VMSS | Virtual Machine Scale Set : groupe de VM identiques avec mise à l'échelle automatique |
| WAF | Web Application Firewall : protection de couche 7 (Application Gateway, Front Door) |
