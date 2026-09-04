# Bootcamp AZ-104 : scénario fil rouge « TrackIt chez Boréal Logistique », version PowerShell

| | |
|---|---|
| **Auteur** | Rodrigue YENGO |
| **Entreprise** | ARCHIA365 |
| **Adresse** | Bureau 326, 59 rue de Ponthieu, 75008 Paris |
| **LinkedIn** | https://www.linkedin.com/company/130004016 et https://www.linkedin.com/company/26302862 |
| **YouTube** | ArchiFridays : https://www.youtube.com/@ArchiFridays |
| **Version** | 1.1 PowerShell, septembre 2026 |

> **Durée :** 7 h de formation effective (2 pauses de 15 min incluses, déjeuner hors créneau)
> **Format :** démo formateur, puis reproduction par les participants (1 souscription par participant)
> **Public :** administrateurs et techniciens infrastructure préparant l'examen AZ-104 (Microsoft Azure Administrator)
> **Outils :** portail Azure, Azure Cloud Shell (PowerShell), modules **Az** et **Microsoft.Graph**, Bicep, VS Code avec les extensions PowerShell et Bicep (optionnel), Docker Desktop (optionnel)

> **Note sur cette version.** Elle reprend intégralement le scénario, le minutage, les rappels de concepts et les bonnes pratiques de la version Azure CLI, mais toutes les commandes utilisent **Azure PowerShell (module Az)** pour les ressources Azure et **Microsoft Graph PowerShell** pour Entra ID. Les deux versions sont interchangeables : un participant peut suivre l'une pendant que le formateur déroule l'autre, ce qui est d'ailleurs une bonne préparation à l'examen, qui mélange les deux syntaxes.

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
15. Table de correspondance Azure CLI / PowerShell

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

> **Rappel de concept : la hiérarchie des ressources Azure.** Tenant Entra ID (identités), puis groupes d'administration (management groups), puis souscriptions (facturation, quotas, limite de sécurité), puis groupes de ressources (cycle de vie commun), puis ressources. Le RBAC, les policies et les verrous se posent à chacun de ces niveaux et **s'héritent vers le bas**. Les préfixes `rg-`, `vnet-`, `nsg-`, `st` suivent le Cloud Adoption Framework (CAF) de Microsoft : un nom doit dire le type, l'application, l'environnement et éventuellement la région.

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

**Objectifs :** tout le monde dispose d'une souscription opérationnelle, Cloud Shell est ouvert en mode PowerShell, les modules sont chargés, les variables communes sont définies.

### Rappel des concepts

- **Les trois façons d'administrer Azure :** le portail (découverte, visualisation), Azure CLI et Azure PowerShell (répétable, scriptable), les templates ARM ou Bicep (déclaratif, idempotent). L'examen attend que vous sachiez lire les trois.
- **Azure PowerShell** est le module **Az** (qui remplace AzureRM, retiré). Il est organisé en sous-modules par service : `Az.Accounts`, `Az.Resources`, `Az.Network`, `Az.Storage`, `Az.Compute`, `Az.ContainerRegistry`, `Az.ContainerInstance`, `Az.KeyVault`, `Az.Monitor`, `Az.RecoveryServices`, `Az.OperationalInsights`. Les cmdlets suivent le schéma **Verbe-AzNom** : `Get-AzVM`, `New-AzResourceGroup`, `Set-AzVirtualNetwork`, `Remove-AzStorageAccount`. Trois réflexes : `Get-Command -Module Az.Network -Noun *Subnet*` pour trouver une cmdlet, `Get-Help New-AzVM -Examples` pour la syntaxe, et le paramètre `-WhatIf` pour simuler.
- **Le modèle objet.** Contrairement à Azure CLI qui renvoie du JSON, PowerShell manipule des **objets** : une cmdlet `Get-` renvoie un objet que l'on stocke dans une variable, modifie, puis renvoie à Azure avec `Set-`. Exemple typique du réseau : `$vnet = Get-AzVirtualNetwork`, puis `Set-AzVirtualNetworkSubnetConfig`, puis `$vnet | Set-AzVirtualNetwork`. **Tant que le `Set-` final n'est pas exécuté, rien n'est modifié dans Azure** : c'est un classique de l'examen.
- **Microsoft Graph PowerShell** (`Microsoft.Graph`) gère Entra ID : utilisateurs, groupes, applications, principaux de service. Il remplace les modules AzureAD et MSOnline, retirés. Les cmdlets suivent le schéma **Verbe-MgNom** (`New-MgUser`, `New-MgGroup`, `New-MgApplication`) et la connexion demande des **étendues** explicites (`Connect-MgGraph -Scopes ...`). Le module Az contient aussi quelques cmdlets Entra de base (`New-AzADUser`, `New-AzADGroup`, `New-AzADServicePrincipal`), suffisantes pour le RBAC mais pas pour la configuration fine des applications.
- **Azure Cloud Shell en mode PowerShell** est déjà authentifié, dispose d'Az, de Microsoft.Graph, de Bicep et d'Azure CLI, et d'un stockage persistant (`~/clouddrive`). Le lecteur `Azure:` permet de naviguer dans les ressources comme dans un système de fichiers.
- **Azure Resource Manager (ARM)** est le plan de contrôle unique : portail, CLI, PowerShell et SDK parlent tous à ARM, qui applique RBAC, Policy et verrous avant d'accepter une opération.

### Déroulé

1. Présentation de Boréal Logistique et du cahier des charges (10 min).
2. Lecture de l'architecture cible ; chaque participant note son `<suffix>`.
3. Ouverture de Cloud Shell (PowerShell) et exécution du prologue :

```powershell
# --- Prologue commun : à coller dans Cloud Shell (PowerShell) ---
$Suffix   = "ryo042"                 # à personnaliser
$Loc      = "francecentral"
$RgProd   = "rg-trackit-prod"
$RgNet    = "rg-trackit-network"
$RgShared = "rg-trackit-shared"
$Tags     = @{ env = "prod"; app = "trackit"; owner = $Suffix; costcenter = "DSI" }

Get-AzContext | Format-Table Name, Account, Subscription
$SubId = (Get-AzContext).Subscription.Id
$TenantId = (Get-AzContext).Tenant.Id

New-AzResourceGroup -Name $RgNet    -Location $Loc -Tag $Tags
New-AzResourceGroup -Name $RgProd   -Location $Loc -Tag $Tags
New-AzResourceGroup -Name $RgShared -Location $Loc -Tag $Tags

# Microsoft Graph pour Entra ID (installer si absent, puis se connecter avec les étendues nécessaires)
if (-not (Get-Module -ListAvailable Microsoft.Graph.Users)) { Install-Module Microsoft.Graph -Scope CurrentUser -Force }
Connect-MgGraph -Scopes "User.ReadWrite.All","Group.ReadWrite.All","Application.ReadWrite.All","AppRoleAssignment.ReadWrite.All","DelegatedPermissionGrant.ReadWrite.All","Domain.Read.All" -NoWelcome
```

4. Vérification des quotas (au moins 4 vCPU de la famille Dsv5 dans la région) :

```powershell
Get-AzVMUsage -Location $Loc | Where-Object { $_.Name.LocalizedValue -like "*DSv5*" } | Format-Table Name, CurrentValue, Limit
```

### Bonnes pratiques

- Sauvegarder le prologue dans `~/clouddrive/prologue.ps1` : les variables ne survivent pas à la fermeture de Cloud Shell ; après chaque pause, `. ~/clouddrive/prologue.ps1` (dot sourcing) les recharge.
- Utiliser le **splatting** (`@params`) pour les cmdlets à nombreux paramètres : plus lisible, plus facile à relire en séance.
- Toujours poser les tags à la création via une table de hachage : Azure Policy refusera de toute façon les ressources non taguées à partir de l'atelier 1.
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
| Où se gère | Entra ID > Rôles et administrateurs (Microsoft Graph) | Ressource > Access control (IAM) (`New-AzRoleAssignment`) |
| Lien entre les deux | Un Global Administrator peut s'accorder le rôle User Access Administrator sur toutes les souscriptions (« Elevate access »), mais ne l'a pas par défaut | |

**Une attribution RBAC = un principal de sécurité (utilisateur, groupe, principal de service, identité managée) + une définition de rôle + une étendue.** Les rôles s'additionnent (on obtient l'union des permissions). Les quatre rôles fondamentaux : **Owner** (tout, y compris déléguer les accès), **Contributor** (tout sauf déléguer les accès), **Reader** (lecture seule), **User Access Administrator** (gérer uniquement les accès). Les rôles de **plan de données** (Storage Blob Data Reader, Key Vault Secrets User) sont distincts des rôles de **plan de contrôle** : être Owner d'un compte de stockage ne donne pas le droit de lire les blobs avec un jeton Entra.

**Azure Policy** évalue les ressources par rapport à des règles métier. Une **définition** décrit la condition et l'effet (Audit, Deny, Append, Modify, DeployIfNotExists, AuditIfNotExists, Disabled). Une **initiative** regroupe plusieurs définitions. Une **assignation** applique la définition ou l'initiative à une étendue, avec des exclusions possibles. Policy complète le RBAC : le RBAC dit *qui* peut faire *quoi*, Policy dit *comment* les ressources doivent être configurées, quel que soit l'auteur.

**Les verrous de ressource** (`CanNotDelete`, `ReadOnly`) s'appliquent à tout le monde, Owner compris, et s'héritent. Ils protègent contre l'erreur humaine, pas contre un administrateur malveillant (qui peut retirer le verrou).

### Démo formateur (25 min)

**1. Utilisateurs et groupes Entra ID (Microsoft Graph PowerShell)**

| Objet | Nom | Membres |
|---|---|---|
| Groupe de sécurité | `grp-trackit-admins` | vous |
| Groupe de sécurité | `grp-trackit-readers` | `chef.lyon`, `chef.nantes`, `chef.lille` |
| Groupe de sécurité | `grp-novadev` | `dev.novadev` |
| Utilisateur invité | `externe@novadev.fr` | (B2B : montrer l'invitation, ne pas attendre l'acceptation) |

```powershell
$Domain = (Get-MgDomain | Where-Object IsDefault).Id

foreach ($u in "chef.lyon","chef.nantes","chef.lille","dev.novadev") {
    $profile = @{ Password = "Bootcamp-AZ104-$(Get-Random -Maximum 9999)!"; ForceChangePasswordNextSignIn = $true }
    New-MgUser -DisplayName $u -UserPrincipalName "$u@$Domain" -MailNickname $u `
               -AccountEnabled -PasswordProfile $profile -UsageLocation "FR" | Out-Null
}

$grpAdmins  = New-MgGroup -DisplayName "grp-trackit-admins"  -MailNickname "grp-trackit-admins"  -SecurityEnabled -MailEnabled:$false
$grpReaders = New-MgGroup -DisplayName "grp-trackit-readers" -MailNickname "grp-trackit-readers" -SecurityEnabled -MailEnabled:$false
$grpNovadev = New-MgGroup -DisplayName "grp-novadev"         -MailNickname "grp-novadev"         -SecurityEnabled -MailEnabled:$false

foreach ($u in "chef.lyon","chef.nantes","chef.lille") {
    $userId = (Get-MgUser -UserId "$u@$Domain").Id
    New-MgGroupMember -GroupId $grpReaders.Id -DirectoryObjectId $userId
}
New-MgGroupMember -GroupId $grpNovadev.Id -DirectoryObjectId (Get-MgUser -UserId "dev.novadev@$Domain").Id
New-MgGroupMember -GroupId $grpAdmins.Id  -DirectoryObjectId (Get-MgUser -UserId (Get-MgContext).Account).Id

# Invitation B2B (démonstration)
New-MgInvitation -InvitedUserEmailAddress "externe@novadev.fr" -InviteRedirectUrl "https://portal.azure.com" -SendInvitationMessage
```

**2. RBAC : le bon rôle, à la bonne étendue**

| Groupe | Rôle | Étendue |
|---|---|---|
| `grp-trackit-admins` | Owner | Souscription |
| `grp-trackit-readers` | Reader et Cost Management Reader | Souscription |
| `grp-novadev` | Contributor | `rg-trackit-prod` uniquement |

```powershell
$scopeSub = "/subscriptions/$SubId"
New-AzRoleAssignment -ObjectId $grpAdmins.Id  -RoleDefinitionName "Owner"                  -Scope $scopeSub
New-AzRoleAssignment -ObjectId $grpReaders.Id -RoleDefinitionName "Reader"                 -Scope $scopeSub
New-AzRoleAssignment -ObjectId $grpReaders.Id -RoleDefinitionName "Cost Management Reader" -Scope $scopeSub
New-AzRoleAssignment -ObjectId $grpNovadev.Id -RoleDefinitionName "Contributor"            -ResourceGroupName $RgProd

# Vérifier : qui a quoi sur rg-trackit-prod (avec héritage)
Get-AzRoleAssignment -ResourceGroupName $RgProd | Format-Table DisplayName, RoleDefinitionName, Scope
```

Montrer dans le portail **Access control (IAM) > Check access** avec `dev.novadev` : Contributor sur `rg-trackit-prod`, rien sur `rg-trackit-network`. Insister sur l'**héritage** (souscription, puis RG, puis ressource) et sur la différence entre **rôle Entra ID** (Global Administrator) et **rôle Azure RBAC** (Owner). Montrer `Get-AzRoleDefinition "Contributor" | Select-Object -ExpandProperty NotActions` pour expliquer pourquoi Contributor ne peut pas déléguer.

**3. Azure Policy : tags obligatoires et régions autorisées**

```powershell
# Définitions intégrées
$defTag = Get-AzPolicyDefinition -Name "1e30110a-5ceb-460c-a204-c1c3969c6d62"   # Require a tag and its value on resources
$defLoc = Get-AzPolicyDefinition -Name "e56962a6-4747-49cd-b67b-bf8b01975c4c"   # Allowed locations

New-AzPolicyAssignment -Name "req-tag-costcenter" -DisplayName "Tag costcenter obligatoire" `
    -PolicyDefinition $defTag -Scope $scopeSub `
    -PolicyParameterObject @{ tagName = "costcenter"; tagValue = "DSI" }

New-AzPolicyAssignment -Name "allowed-locations" -DisplayName "Regions autorisees" `
    -PolicyDefinition $defLoc -Scope $scopeSub `
    -PolicyParameterObject @{ listOfAllowedLocations = @("francecentral","westeurope") }

# État de conformité (après quelques minutes)
Get-AzPolicyState -SubscriptionId $SubId | Group-Object ComplianceState | Format-Table Name, Count
```

Créer dans le portail une **initiative** « Gouvernance Boréal » regroupant les deux définitions (montrer le concept, assignation facultative).

**4. Verrou de ressource**

```powershell
New-AzResourceLock -LockName "lock-no-delete-net" -LockLevel CanNotDelete -ResourceGroupName $RgNet `
    -LockNotes "Reseau de production TrackIt" -Force
Get-AzResourceLock -ResourceGroupName $RgNet
```

### Reproduction par les participants (25 min)

Reproduire les 4 étapes. **Test à réaliser :** `New-AzResourceGroup -Name rg-test -Location $Loc` sans tag, puis une ressource dans `northeurope`. Les deux doivent être refusés par Policy avec une erreur `RequestDisallowedByPolicy` (compter jusqu'à 5 min de propagation ; sinon montrer le refus côté formateur).

### Bonnes pratiques

- **Attribuer les rôles à des groupes, jamais à des utilisateurs.** Un départ ou une arrivée se gère par l'appartenance au groupe, pas par une chasse aux attributions.
- **Moindre privilège et étendue la plus étroite possible.** Contributor sur un groupe de ressources plutôt qu'Owner sur la souscription. Réserver Owner à un petit groupe et envisager **PIM** (Privileged Identity Management, Entra ID P2) pour des élévations temporaires.
- **Préférer les rôles intégrés.** Un rôle personnalisé (`Get-AzRoleDefinition Reader | ConvertTo-Json` comme point de départ, puis `New-AzRoleDefinition`) ne se crée que quand aucun rôle intégré ne convient, et se documente.
- **Commencer Policy en mode Audit**, observer la conformité, puis passer en Deny. Sur un existant, un Deny immédiat bloque les redéploiements légitimes.
- **Un verrou `CanNotDelete` sur le réseau, les coffres et les journaux** ; éviter `ReadOnly` sur les comptes de stockage et les Key Vault (il bloque la lecture des clés et casse des applications).
- **Activer MFA pour tous les administrateurs** (paramètres de sécurité par défaut, ou Conditional Access si Entra ID P1) et documenter des comptes de secours (« break glass »).
- **Scripts idempotents** : encadrer les créations par un `Get-` préalable (`if (-not (Get-AzResourceGroup -Name $RgNet -ErrorAction SilentlyContinue)) { New-AzResourceGroup ... }`) pour pouvoir rejouer un script sans erreur.

### Checkpoint et pièges d'examen (10 min)

- [ ] 3 groupes et 4 utilisateurs existent dans Entra ID, les membres sont affectés
- [ ] `dev.novadev` est Contributor sur `rg-trackit-prod` **seulement**
- [ ] La création d'une ressource sans tag `costcenter` ou hors régions autorisées est refusée
- [ ] `rg-trackit-network` est protégé contre la suppression

**Pièges classiques :** Owner n'est pas Contributor (Owner peut gérer le RBAC) ; un verrou `ReadOnly` bloque aussi certaines opérations qui ressemblent à de la lecture (lister les clés d'un compte de stockage est un POST) ; Azure Policy évalue les **nouvelles** ressources immédiatement mais les ressources existantes seulement au cycle de conformité (environ 24 h, ou `Start-AzPolicyComplianceScan`) ; un utilisateur invité B2B a besoin d'une attribution RBAC comme n'importe quel utilisateur ; **Cost Management Reader** ne donne pas accès aux ressources ; l'effet **Append** ajoute un tag à la création alors que **Modify** peut aussi corriger l'existant via une tâche de correction ; les groupes dynamiques nécessitent Entra ID P1 ; `New-AzRoleAssignment -SignInName` cible un utilisateur, `-ObjectId` un objet quelconque, `-ApplicationId` un principal de service ; la **réinitialisation de mot de passe en libre-service (SSPR)** se configure par groupe et impose l'inscription de méthodes d'authentification.

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

**Particularité PowerShell du réseau :** les objets réseau sont **composés** en mémoire (`New-AzVirtualNetworkSubnetConfig`, `New-AzNetworkSecurityRuleConfig`) puis envoyés à Azure en une fois (`New-AzVirtualNetwork`, `New-AzNetworkSecurityGroup`). Pour modifier, on récupère l'objet (`Get-`), on le modifie (`Set-...Config`, `Add-...Config`) et on le renvoie (`Set-AzVirtualNetwork`). Oublier ce dernier `Set-` est l'erreur la plus fréquente.

### Démo formateur (25 min)

**1. VNet et sous-réseaux**

```powershell
$delegAci = New-AzDelegation -Name "aci" -ServiceName "Microsoft.ContainerInstance/containerGroups"

$snetWeb  = New-AzVirtualNetworkSubnetConfig -Name "snet-web"  -AddressPrefix "10.10.1.0/24"
$snetApp  = New-AzVirtualNetworkSubnetConfig -Name "snet-app"  -AddressPrefix "10.10.2.0/24" -Delegation $delegAci
$snetData = New-AzVirtualNetworkSubnetConfig -Name "snet-data" -AddressPrefix "10.10.3.0/24"
$snetBas  = New-AzVirtualNetworkSubnetConfig -Name "AzureBastionSubnet" -AddressPrefix "10.10.250.0/26"

$vnet = New-AzVirtualNetwork -Name "vnet-trackit-prod" -ResourceGroupName $RgNet -Location $Loc `
          -AddressPrefix "10.10.0.0/16" -Subnet $snetWeb, $snetApp, $snetData, $snetBas -Tag $Tags
```

Expliquer les 5 adresses réservées, le nom imposé `AzureBastionSubnet` et le `/26` minimum, et la **délégation** de `snet-app` à ACI (obligatoire pour l'atelier 5 : un sous-réseau délégué ne peut plus héberger d'autres types de ressources).

**2. Application Security Groups : nommer les rôles, pas les adresses**

```powershell
$asgWeb = New-AzApplicationSecurityGroup -Name "asg-web" -ResourceGroupName $RgNet -Location $Loc
$asgApp = New-AzApplicationSecurityGroup -Name "asg-app" -ResourceGroupName $RgNet -Location $Loc
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

```powershell
# ---- nsg-web ----
$rWebLb = New-AzNetworkSecurityRuleConfig -Name "Allow-HTTP-From-LB" -Priority 100 -Direction Inbound -Access Allow `
    -Protocol Tcp -SourceAddressPrefix "AzureLoadBalancer" -SourcePortRange * `
    -DestinationApplicationSecurityGroup $asgWeb -DestinationPortRange 80
$rWebInet = New-AzNetworkSecurityRuleConfig -Name "Allow-HTTP-Internet" -Priority 110 -Direction Inbound -Access Allow `
    -Protocol Tcp -SourceAddressPrefix "Internet" -SourcePortRange * `
    -DestinationApplicationSecurityGroup $asgWeb -DestinationPortRange 80, 443
$rWebSsh = New-AzNetworkSecurityRuleConfig -Name "Allow-SSH-From-Bastion" -Priority 120 -Direction Inbound -Access Allow `
    -Protocol Tcp -SourceAddressPrefix "10.10.250.0/26" -SourcePortRange * `
    -DestinationApplicationSecurityGroup $asgWeb -DestinationPortRange 22
$rDeny = New-AzNetworkSecurityRuleConfig -Name "Deny-All-Inbound" -Priority 4000 -Direction Inbound -Access Deny `
    -Protocol * -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange *

$nsgWeb = New-AzNetworkSecurityGroup -Name "nsg-web" -ResourceGroupName $RgNet -Location $Loc `
    -SecurityRules $rWebLb, $rWebInet, $rWebSsh, $rDeny -Tag $Tags

# ---- nsg-app ----
$rAppFromWeb = New-AzNetworkSecurityRuleConfig -Name "Allow-API-From-Web" -Priority 100 -Direction Inbound -Access Allow `
    -Protocol Tcp -SourceApplicationSecurityGroup $asgWeb -SourcePortRange * `
    -DestinationApplicationSecurityGroup $asgApp -DestinationPortRange 8080
$nsgApp = New-AzNetworkSecurityGroup -Name "nsg-app" -ResourceGroupName $RgNet -Location $Loc `
    -SecurityRules $rAppFromWeb, $rDeny -Tag $Tags

# ---- nsg-data ----
$rDataFromApp = New-AzNetworkSecurityRuleConfig -Name "Allow-HTTPS-From-App" -Priority 100 -Direction Inbound -Access Allow `
    -Protocol Tcp -SourceApplicationSecurityGroup $asgApp -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange 443
$nsgData = New-AzNetworkSecurityGroup -Name "nsg-data" -ResourceGroupName $RgNet -Location $Loc `
    -SecurityRules $rDataFromApp, $rDeny -Tag $Tags

# ---- Association aux sous-réseaux : modifier l'objet VNet, puis Set-AzVirtualNetwork ----
$vnet = Get-AzVirtualNetwork -Name "vnet-trackit-prod" -ResourceGroupName $RgNet
Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name "snet-web"  -AddressPrefix "10.10.1.0/24" -NetworkSecurityGroup $nsgWeb | Out-Null
Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name "snet-app"  -AddressPrefix "10.10.2.0/24" -NetworkSecurityGroup $nsgApp -Delegation $delegAci | Out-Null
Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name "snet-data" -AddressPrefix "10.10.3.0/24" -NetworkSecurityGroup $nsgData | Out-Null
$vnet | Set-AzVirtualNetwork | Out-Null

# Vérifier
(Get-AzVirtualNetwork -Name "vnet-trackit-prod" -ResourceGroupName $RgNet).Subnets |
    Select-Object Name, AddressPrefix, @{n="NSG";e={ ($_.NetworkSecurityGroup.Id -split "/")[-1] }} | Format-Table
```

Pourquoi une règle `Deny-All` explicite alors qu'il en existe une par défaut ? Pour **neutraliser `AllowVnetInBound`** (65000) qui laisserait passer tout le trafic intra-VNet, y compris de `snet-web` vers `snet-data`. C'est LA question piège des NSG.

**4. Bastion** (déploiement long, 8 à 10 min : lancer en tâche de fond avec `-AsJob` puis continuer)

```powershell
$pipBas = New-AzPublicIpAddress -Name "pip-bastion" -ResourceGroupName $RgNet -Location $Loc `
    -Sku Standard -AllocationMethod Static -Tag $Tags
New-AzBastion -Name "bas-trackit" -ResourceGroupName $RgNet -VirtualNetworkName "vnet-trackit-prod" `
    -VirtualNetworkRgName $RgNet -PublicIpAddressRgName $RgNet -PublicIpAddressName "pip-bastion" -Sku Basic -AsJob
Get-Job | Format-Table Id, Name, State      # suivre l'avancement ; Receive-Job à la fin
```

**5. Aperçu peering et DNS** (5 min, démo portail uniquement) : créer `vnet-trackit-mgmt` 10.20.0.0/16 et un peering bidirectionnel (`Add-AzVirtualNetworkPeering` dans chaque sens) ; expliquer la non-transitivité (un hub avec pare-feu et des UDR pour router entre spokes) et annoncer la zone DNS privée `privatelink.blob.core.windows.net` de l'atelier 3.

### Reproduction par les participants (30 min)

Reproduire VNet, ASG, NSG. Bastion avec `-AsJob`. Les VM arriveront à l'atelier 4 : les ASG seront alors rattachés aux NIC par le template.

### Bonnes pratiques

- **Planifier l'adressage avant de créer quoi que ce soit** : un espace d'adressage qui chevauche le réseau sur site interdira le VPN plus tard, et redimensionner un sous-réseau peuplé est pénible.
- **Un NSG par sous-réseau, des règles écrites entre ASG et balises de service.** Éviter les NSG sur les NIC sauf besoin ponctuel : deux niveaux d'évaluation rendent le diagnostic difficile.
- **Toujours terminer par un Deny explicite** et laisser de l'espace entre les priorités (100, 110, 120) pour insérer des règles.
- **Zéro port d'administration exposé sur Internet.** Bastion, ou à défaut JIT (Defender for Cloud), ou VPN. Un NSG « Allow 22 depuis Internet » est la première chose qu'un scanner trouve.
- **Activer les journaux de flux NSG** (Network Watcher) et Traffic Analytics dès la mise en production : on ne peut pas dépanner ce qu'on ne voit pas.
- **Topologie hub and spoke** dès que l'on dépasse deux ou trois VNet : services partagés (pare-feu, passerelles, DNS) dans le hub, applications dans les spokes.
- **En PowerShell, relire l'objet avant de le modifier** (`Get-AzVirtualNetwork` frais) : un objet obsolète en mémoire écrase les modifications faites entre-temps par un collègue ou par le portail.

### Checkpoint et pièges d'examen (5 min)

- [ ] 4 sous-réseaux, `snet-app` délégué à ACI
- [ ] `nsg-web` associé à `snet-web`, `nsg-app` à `snet-app`, `nsg-data` à `snet-data`
- [ ] 2 ASG créés (encore vides)
- [ ] Bastion en cours de provisionnement (`Get-Job`)

**Pièges :** les NSG s'appliquent au sous-réseau et/ou à la NIC, les deux sont évalués ; un ASG ne peut contenir que des NIC du même VNet ; les balises de service `AzureLoadBalancer` (sondes de santé), `Internet`, `VirtualNetwork` (inclut les peerings et les réseaux joints par passerelle) ; priorité basse = évaluée en premier ; Bastion impose `AzureBastionSubnet` en `/26` minimum et une IP publique Standard ; le peering n'est pas transitif ; les UDR priment sur les routes système ; le peering global ne permet pas d'utiliser la passerelle distante ; un VNet ne peut pas changer de région, il faut le recréer ; **Azure DNS** public héberge des zones, les **zones privées** résolvent dans les VNet liés (avec auto-inscription possible) ; en PowerShell, `Set-AzVirtualNetworkSubnetConfig` ne fait rien sans `Set-AzVirtualNetwork`.

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

**Particularité PowerShell du stockage :** le plan de contrôle (`New-AzStorageAccount`, `Set-AzStorageAccount`) et le plan de données (`Set-AzStorageBlobContent`, `New-AzStorageContainer`) sont distincts. Le plan de données passe par un **contexte** (`New-AzStorageContext`) construit soit avec une clé, soit avec `-UseConnectedAccount` (jeton Entra ID, ce que nous utilisons). Les cmdlets `-Rm` (`New-AzRmStorageShare`) passent par ARM, les autres par l'API de données.

### Démo formateur (20 min)

**1. Compte de stockage**

```powershell
$StName = "sttrackitprod$Suffix"
$st = New-AzStorageAccount -ResourceGroupName $RgProd -Name $StName -Location $Loc `
        -SkuName Standard_LRS -Kind StorageV2 -AccessTier Hot -MinimumTlsVersion TLS1_2 `
        -AllowBlobPublicAccess $false -AllowSharedKeyAccess $true -Tag $Tags

# Protection des données : soft delete blobs et conteneurs, versioning
Enable-AzStorageBlobDeleteRetentionPolicy      -ResourceGroupName $RgProd -StorageAccountName $StName -RetentionDays 14
Enable-AzStorageContainerDeleteRetentionPolicy -ResourceGroupName $RgProd -StorageAccountName $StName -RetentionDays 14
Update-AzStorageBlobServiceProperty            -ResourceGroupName $RgProd -StorageAccountName $StName -IsVersioningEnabled $true

# Contexte Entra ID (plan de données)
$ctx = New-AzStorageContext -StorageAccountName $StName -UseConnectedAccount
```

Décision d'architecture à expliquer : pourquoi **LRS** suffit ici (données reproductibles depuis les scanners, budget PME) et quand passer en **ZRS, GRS ou RA-GZRS**. Comparer les niveaux Hot, Cool, Cold, Archive et le coût de réhydratation.

**2. Chargement et niveaux d'accès**

```powershell
# Rôle de plan de données pour soi-même (nécessaire même pour un Owner)
$me = (Get-AzADUser -SignedIn).Id
New-AzRoleAssignment -ObjectId $me -RoleDefinitionName "Storage Blob Data Contributor" -Scope $st.Id
Start-Sleep -Seconds 30   # propagation du rôle

New-AzStorageContainer -Name "bons-livraison" -Context $ctx -Permission Off
"Bon de livraison n 1001 - Lyon" | Out-File -FilePath ./BL-1001.pdf
Set-AzStorageBlobContent -File ./BL-1001.pdf -Container "bons-livraison" -Blob "2026/09/BL-1001.pdf" -Context $ctx
$blob = Get-AzStorageBlob -Container "bons-livraison" -Blob "2026/09/BL-1001.pdf" -Context $ctx
$blob.BlobClient.SetAccessTier("Cool")
Get-AzStorageBlob -Container "bons-livraison" -Context $ctx | Format-Table Name, Length, AccessTier, LastModified
```

Si `Set-AzStorageBlobContent` échoue avec `AuthorizationPermissionMismatch` avant l'attribution du rôle : montrer que **Storage Blob Data Contributor** (plan de données) est requis même pour un Owner (plan de contrôle). Excellente illustration RBAC.

**3. Politique de cycle de vie**

```powershell
$action = Add-AzStorageAccountManagementPolicyAction -BaseBlobAction TierToCool    -DaysAfterModificationGreaterThan 30
$action = Add-AzStorageAccountManagementPolicyAction -BaseBlobAction TierToArchive -DaysAfterModificationGreaterThan 90  -InputObject $action
$action = Add-AzStorageAccountManagementPolicyAction -BaseBlobAction Delete        -DaysAfterModificationGreaterThan 3650 -InputObject $action
$filter = New-AzStorageAccountManagementPolicyFilter -PrefixMatch "bons-livraison/" -BlobType blockBlob
$rule   = New-AzStorageAccountManagementPolicyRule -Name "archive-bons-livraison" -Action $action -Filter $filter
Set-AzStorageAccountManagementPolicy -ResourceGroupName $RgProd -StorageAccountName $StName -Rule $rule
```

Montrer l'équivalent JSON dans le portail (Data management > Lifecycle management > Code view) : c'est le format que l'examen affiche.

**4. SAS limitée dans le temps (délégation utilisateur, signée par Entra ID)**

```powershell
$sasUri = New-AzStorageBlobSASToken -Container "bons-livraison" -Blob "2026/09/BL-1001.pdf" `
    -Permission r -Protocol HttpsOnly -StartTime (Get-Date).AddMinutes(-5) -ExpiryTime (Get-Date).AddHours(1) `
    -Context $ctx -FullUri
$sasUri
```

Comparer **SAS de compte** (`New-AzStorageAccountSASToken`, clé de compte), **de service** (`New-AzStorageBlobSASToken` avec un contexte à clé) et **de délégation utilisateur** (celle-ci, obtenue avec un contexte `-UseConnectedAccount`), et la **stored access policy** (`New-AzStorageContainerStoredAccessPolicy`, révocable). Montrer la révocation d'une SAS de compte par rotation de clé (`New-AzStorageAccountKey -KeyName key1`).

**5. Azure Files pour les agences**

```powershell
New-AzRmStorageShare -ResourceGroupName $RgProd -StorageAccountName $StName -Name "agences" -QuotaGiB 100 -EnabledProtocol SMB
Get-AzRmStorageShare -ResourceGroupName $RgProd -StorageAccountName $StName | Format-Table Name, QuotaGiB, EnabledProtocols
# Portail : partage agences > Connect : script de montage Windows (New-PSDrive / net use) ou Linux (mount -t cifs)
```

**6. Point de terminaison privé et pare-feu** (10 min, peut être fait par le formateur seul si le temps manque)

```powershell
$vnet     = Get-AzVirtualNetwork -Name "vnet-trackit-prod" -ResourceGroupName $RgNet
$snetData = Get-AzVirtualNetworkSubnetConfig -Name "snet-data" -VirtualNetwork $vnet

$plsConn = New-AzPrivateLinkServiceConnection -Name "pe-st-blob-conn" -PrivateLinkServiceId $st.Id -GroupId "blob"
$pe = New-AzPrivateEndpoint -Name "pe-st-blob" -ResourceGroupName $RgNet -Location $Loc `
        -Subnet $snetData -PrivateLinkServiceConnection $plsConn

$zone = New-AzPrivateDnsZone -ResourceGroupName $RgNet -Name "privatelink.blob.core.windows.net"
New-AzPrivateDnsVirtualNetworkLink -ResourceGroupName $RgNet -ZoneName $zone.Name -Name "link-trackit" `
    -VirtualNetworkId $vnet.Id -EnableRegistration:$false | Out-Null
$zoneConfig = New-AzPrivateDnsZoneConfig -Name "blob" -PrivateDnsZoneId $zone.ResourceId
New-AzPrivateDnsZoneGroup -ResourceGroupName $RgNet -PrivateEndpointName "pe-st-blob" -Name "zg-blob" -PrivateDnsZoneConfig $zoneConfig | Out-Null

# Pare-feu : refuser tout sauf le réseau privé, en gardant l'accès depuis l'IP publique du participant
$myIp = (Invoke-RestMethod -Uri "https://ifconfig.me/ip").Trim()
Update-AzStorageAccountNetworkRuleSet -ResourceGroupName $RgProd -Name $StName -DefaultAction Deny -Bypass AzureServices | Out-Null
Add-AzStorageAccountNetworkRule       -ResourceGroupName $RgProd -Name $StName -IPAddressOrRange $myIp | Out-Null
```

### Reproduction par les participants (20 min)

Étapes 1 à 5 obligatoires, étape 6 en bonus.

### Bonnes pratiques

- **Désactiver l'accès public anonyme aux blobs** au niveau du compte et imposer TLS 1.2 : ce sont deux réglages que Defender for Cloud remonte immédiatement.
- **Privilégier Entra ID et les rôles de données** ; interdire à terme l'accès par clé partagée (`Set-AzStorageAccount -AllowSharedKeyAccess $false`) une fois que toutes les applications utilisent une identité. Si des SAS restent nécessaires, préférer la délégation utilisateur, une durée courte, HTTPS seul et une plage IP.
- **Activer soft delete, versioning et instantanés** avant la première donnée de production ; un `Remove-AzStorageBlob` sans filet est irréversible.
- **Laisser le cycle de vie faire le travail de FinOps** : le niveau Archive coûte environ dix fois moins cher que Hot, mais chaque transition précoce facture une pénalité de durée minimale.
- **Un point de terminaison privé par service** (blob, file, etc.) et une zone DNS privée par type ; vérifier la résolution depuis le VNet (`Resolve-DnsName` sur une VM Windows, `nslookup` sur Linux) avant de fermer le pare-feu.
- **Choisir la redondance selon le RPO/RTO réel**, pas par réflexe : GRS n'est pas une sauvegarde (une suppression est répliquée), c'est de la continuité d'activité.

### Checkpoint et pièges d'examen (5 min)

- [ ] Blob `2026/09/BL-1001.pdf` en niveau Cool, politique de cycle de vie active
- [ ] Une URL SAS fonctionne depuis une fenêtre de navigation privée et expire à H+1
- [ ] Partage `agences` créé
- [ ] (bonus) `nslookup sttrackitprod<suffix>.blob.core.windows.net` depuis une VM du VNet renvoie 10.10.3.x

**Pièges :** Archive n'est pas lisible sans réhydratation (heures, priorité Standard ou High) ; changer LRS en GRS se fait en ligne (`Set-AzStorageAccount -SkuName Standard_GRS`), mais passer vers ou depuis ZRS demande une conversion ou une migration ; **AzCopy** contre Storage Explorer contre `Set-AzStorageBlobContent` ; Azure Files SMB utilise le port 445, souvent bloqué par les FAI, d'où **Azure File Sync** ou VPN ; soft delete des blobs et soft delete des conteneurs sont deux réglages distincts ; réplication d'objets n'est pas la géo-réplication ; une SAS est une signature, pas une authentification, la révoquer signifie régénérer la clé ou supprimer la stored access policy ; **Storage Blob Data Reader** n'est pas **Reader** ; un point de terminaison de service reste une adresse publique filtrée, un point de terminaison privé est une adresse privée ; le nom du compte est en minuscules et chiffres, 3 à 24 caractères, unique au monde ; un contexte créé avec `-UseConnectedAccount` ne peut pas générer de SAS de compte (il faut la clé).

---

## 7. Atelier 4 : templates Bicep, VM web et Load Balancer (13:30 à 14:30), ticket T4

### Le ticket

> « Le front web doit être déployé de manière identique et rejouable. Il doit continuer de répondre si un serveur ou un datacenter tombe. Même IP publique pour les clients quoi qu'il arrive. »

### Rappel des concepts

**Infrastructure as Code avec ARM et Bicep.** Un template ARM est un document JSON déclaratif (paramètres, variables, ressources, sorties) soumis à Azure Resource Manager. **Bicep** est un langage de plus haut niveau qui se transpile en JSON ARM : syntaxe plus courte, typage, références symboliques entre ressources, modules, boucles, mot-clé `existing` pour référencer une ressource déjà créée. Le déploiement est **idempotent** : rejouer le même template produit le même état. Deux **modes de déploiement** : **Incremental** (par défaut, n'efface rien) et **Complete** (supprime du groupe de ressources tout ce qui n'est pas dans le template). L'étendue peut être un groupe de ressources (`New-AzResourceGroupDeployment`), une souscription (`New-AzSubscriptionDeployment`), un groupe d'administration (`New-AzManagementGroupDeployment`) ou le tenant (`New-AzTenantDeployment`). Le paramètre `-WhatIf` prévisualise les changements. Les **specs de template** (`New-AzTemplateSpec`) et les **modules** publiés dans un registre permettent de partager des briques validées. `Export-AzResourceGroup` exporte un template depuis un groupe de ressources existant (utile pour apprendre, rarement propre à réutiliser tel quel).

**Machines virtuelles.** Une VM Azure se compose d'une taille (famille : B pour le burst, D pour l'usage général, E pour la mémoire, F pour le calcul, N pour le GPU), d'une image (Marketplace, galerie partagée ou image personnalisée), d'un disque système managé (Standard HDD, Standard SSD, Premium SSD, Ultra), d'un disque temporaire (perdu à la désallocation) et d'au moins une NIC. **Arrêter depuis l'OS** ne libère pas la facturation ; **désallouer** (`Stop-AzVM`, état `Stopped (deallocated)`) oui ; `Stop-AzVM -StayProvisioned` arrête sans désallouer et continue de facturer. Redimensionner nécessite un redémarrage. Les **extensions** (Custom Script, DSC, Azure Monitor Agent, Key Vault) exécutent des actions post-déploiement.

**Disponibilité.** Un **groupe à haute disponibilité (availability set)** répartit les VM sur des domaines de panne (racks, jusqu'à 3) et des domaines de mise à jour (jusqu'à 20) dans un même datacenter : SLA 99,95 %. Les **zones de disponibilité** répartissent les VM sur des datacenters distincts de la région : SLA 99,99 %. Les **groupes de machines virtuelles identiques (VMSS)** ajoutent la mise à l'échelle automatique et le mode d'orchestration flexible. Une VM seule sur disque Premium a un SLA de 99,9 %.

**Azure Load Balancer** est un équilibreur de **couche 4** (TCP, UDP), interne ou public. Composants : configuration IP frontale, pool principal (NIC ou adresses IP), **sonde d'intégrité** (TCP, HTTP, HTTPS : une instance qui échoue est retirée du pool), règles d'équilibrage (distribution par hachage 5-tuple, avec affinité de session possible), règles NAT entrantes (accès à une instance précise), règles de sortie (SNAT). Le SKU **Standard** est le seul à supporter les zones, le SLA de 99,99 %, les règles de sortie et les pools de grande taille ; il est **sécurisé par défaut** (un NSG doit autoriser explicitement le trafic). Le SKU Basic est en fin de vie.

**Situer les autres équilibreurs :** **Application Gateway** (couche 7 : routage par URL, terminaison TLS, WAF, régional), **Azure Front Door** (couche 7, global, CDN, WAF), **Traffic Manager** (routage DNS global : priorité, performance, pondéré, géographique).

**Créer une VM en PowerShell sans template**, pour référence à l'examen : `New-AzVM` en mode simplifié (crée VNet, IP publique et NSG par défaut, à éviter en production) ou en mode complet avec `New-AzVMConfig`, `Set-AzVMOperatingSystem`, `Set-AzVMSourceImage`, `Add-AzVMNetworkInterface`, `Set-AzVMOSDisk`, puis `New-AzVM -VM $vmConfig`. Le template Bicep remplace tout cela par du déclaratif.

### Démo formateur (25 min)

**1. Le template Bicep** `trackit-web.bicep` est **identique à la version Azure CLI** : le langage Bicep est indépendant de l'outil qui le soumet. Le présenter section par section (paramètres, ressources existantes, Load Balancer, boucles, extension, sorties).

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

**2. Validation et déploiement avec PowerShell**

```powershell
bicep build ./trackit-web.bicep                          # génère trackit-web.json : montrer le lien Bicep vers ARM
$AdminPassword = Read-Host -Prompt "Mot de passe admin VM" -AsSecureString

$deployParams = @{
    ResourceGroupName = $RgProd
    Name              = "deploy-web-01"
    TemplateFile      = "./trackit-web.bicep"
    suffix            = $Suffix
    adminPassword     = $AdminPassword
}
New-AzResourceGroupDeployment @deployParams -WhatIf              # prévisualisation
$dep = New-AzResourceGroupDeployment @deployParams -Verbose
$dep.Outputs.lbFqdn.Value
$dep.Outputs.vmNames.Value
```

Faire remarquer que les paramètres du template deviennent des **paramètres dynamiques** de la cmdlet (`-suffix`, `-adminPassword`), et que le mot de passe est passé en `SecureString`, jamais en clair.

**3. Test du Load Balancer** : ouvrir `http://trackit-<suffix>.francecentral.cloudapp.azure.com` et rafraîchir plusieurs fois : alternance `vm-web-01` et `vm-web-02`. Puis **désallouer `vm-web-01`** : la sonde retire l'instance du pool en une dizaine de secondes, le site répond toujours. Redémarrer ensuite la VM.

```powershell
Stop-AzVM -ResourceGroupName $RgProd -Name "vm-web-01" -Force        # désallocation (facturation arrêtée)
Get-AzVM -ResourceGroupName $RgProd -Status | Format-Table Name, PowerState, @{n="Zone";e={$_.Zones -join ","}}
Invoke-WebRequest -Uri "http://$($dep.Outputs.lbFqdn.Value)" -UseBasicParsing | Select-Object -ExpandProperty Content
Start-AzVM -ResourceGroupName $RgProd -Name "vm-web-01" -NoWait
```

**4. Ce que le template a fait pour vous** (à montrer dans le portail et en PowerShell) : les NIC sont membres de `asg-web`, donc les règles NSG de l'atelier 2 s'appliquent ; les VM sont réparties en **zones 1 et 2** ; le mode de déploiement était **Incremental** (rejouer le déploiement ne casse rien).

```powershell
Get-AzNetworkInterface -ResourceGroupName $RgProd |
    Select-Object Name, @{n="ASG";e={ ($_.IpConfigurations[0].ApplicationSecurityGroups.Id -split "/")[-1] }},
                        @{n="IP";e={ $_.IpConfigurations[0].PrivateIpAddress }} | Format-Table
Get-AzResourceGroupDeployment -ResourceGroupName $RgProd | Format-Table DeploymentName, ProvisioningState, Timestamp, Mode
Export-AzResourceGroup -ResourceGroupName $RgProd -Resource (Get-AzVM -ResourceGroupName $RgProd -Name vm-web-01).Id -Path ./export-vm-web-01.json
```

### Reproduction par les participants (30 min)

Déployer le template (fourni dans le dépôt du bootcamp). Pendant le déploiement (environ 5 min), exercice de lecture : « Que se passe-t-il si je passe `-webVmCount 3` ? » (réponse : une troisième VM en zone 3, dans le pool). Tester la bascule.

### Bonnes pratiques

- **Tout passer par le template, rien à la main dans le portail** après le premier déploiement, sinon la dérive de configuration rend le template inutilisable. Le template vit dans Git, il est revu comme du code.
- **Toujours lancer `-WhatIf` avant le déploiement réel**, et ne jamais utiliser `-Mode Complete` sans l'avoir prévisualisé.
- **Marquer `@secure()` les secrets**, les passer en `SecureString` et ne jamais les mettre en dur dans un fichier de paramètres : lecture depuis Key Vault (atelier 6) ou variables de pipeline.
- **Découper en modules** (réseau, calcul, supervision) et **épingler les versions d'API** : un changement de version d'API peut modifier les valeurs par défaut.
- **Zones de disponibilité plutôt qu'availability set** pour tout nouveau déploiement dans une région qui les supporte ; VMSS dès que la charge varie.
- **Sonde HTTP sur une page de santé applicative** plutôt qu'une sonde TCP : un service qui répond au TCP mais renvoie des erreurs 500 doit sortir du pool.
- **Disques : Premium SSD pour la production**, chiffrement au repos par défaut (SSE), Azure Disk Encryption ou chiffrement sur l'hôte si exigé, et sauvegarde (atelier 7).
- **Utiliser `-AsJob` ou `-NoWait`** pour les opérations longues et `Get-Job` / `Wait-Job` pour les orchestrer dans un script.

### Checkpoint et pièges d'examen (5 min)

- [ ] Le FQDN du LB répond et alterne entre les 2 VM
- [ ] `vm-web-01` désallouée : le site répond toujours
- [ ] Les 2 NIC sont dans `asg-web`
- [ ] `Get-AzResourceGroupDeployment` montre `deploy-web-01` en `Succeeded`

**Pièges :** LB Basic n'a pas de SLA, pas de zones, pas de règles de sortie ; LB Standard exige une IP publique Standard et un **NSG qui autorise le trafic** (tout est refusé par défaut) ; LB = couche 4, Application Gateway = couche 7 (WAF, routage URL), Traffic Manager = DNS, Front Door = couche 7 globale ; availability set (domaines de panne et de mise à jour, 99,95 %) contre zones (99,99 %) contre VMSS ; `-Mode Complete` supprime ce qui n'est pas dans le template ; `@secure()` masque le paramètre dans l'historique ; redimensionner une VM (`Update-AzVM` après modification de `HardwareProfile.VmSize`) = redémarrage ; le disque temporaire est perdu à la désallocation ; une VM ne peut pas être déplacée d'une zone à une autre sans recréation ; `Stop-AzVM` désalloue, `Stop-AzVM -StayProvisioned` ne désalloue pas ; les **spot VM** peuvent être évincées et ne conviennent pas au front web ; une IP publique Standard est **statique et zone-redondante** par défaut, une Basic est dynamique.

---

## 8. Atelier 5 : conteneurs avec ACR et ACI (14:30 à 15:15), ticket T5

### Le ticket

> « NovaDev a livré l'API TrackIt sous forme d'image Docker. Elle doit tourner dans notre réseau privé (sous-réseau `snet-app`), être appelable par les serveurs web sur le port 8080, sans que la DSI ait à gérer de serveur. »

### Rappel des concepts

**Conteneur, image, registre.** Un conteneur est un processus isolé qui partage le noyau de l'hôte, démarré à partir d'une **image** immuable (couches décrites par un Dockerfile). Les images sont stockées dans un **registre** (Docker Hub, ou un registre privé). Avantages par rapport à la VM : démarrage en secondes, densité, portabilité, reproductibilité ; en contrepartie, pas d'isolation noyau et une durée de vie courte (l'état va ailleurs : volume, base, stockage).

**Azure Container Registry (ACR)** est le registre privé managé. Trois SKU : **Basic** (apprentissage), **Standard** (production courante), **Premium** (géo-réplication, point de terminaison privé, zones, quotas plus élevés). **ACR Tasks** construit l'image dans Azure : pas besoin de Docker sur le poste. L'authentification se fait par Entra ID (rôles **AcrPull**, **AcrPush**, **AcrDelete**), par principal de service, par identité managée, ou par le compte administrateur (à laisser désactivé). ACR peut aussi scanner les images (Defender for Containers) et purger les anciens tags.

**Azure Container Instances (ACI)** exécute des conteneurs à la demande, facturés à la seconde, sans cluster à gérer. Unité de déploiement : le **groupe de conteneurs** (un ou plusieurs conteneurs sur le même hôte, partageant IP, ports, cycle de vie et volumes, comme un pod). Options : IP publique avec étiquette DNS, ou **déploiement dans un VNet** (sous-réseau délégué, IP privée uniquement), volumes **Azure Files**, secrets, variables d'environnement, politique de redémarrage (Always, OnFailure, Never), identité managée, GPU. Cas d'usage : tâches ponctuelles, traitements par lots, API légères, montée en charge « virtual node » pour AKS.

**Situer les autres options de calcul conteneur et PaaS :**

| Service | Vous gérez | Idéal pour |
|---|---|---|
| VM avec Docker | OS, moteur, mises à jour | Contrôle total, existant |
| ACI | Rien, une image | Tâches, API simples, tests |
| App Service (Web App for Containers) | L'application | Sites et API web, emplacements de déploiement, mise à l'échelle |
| Azure Container Apps | L'application, la mise à l'échelle par événements | Microservices, scale to zero |
| AKS | Les nœuds (VMSS), les manifestes | Orchestration Kubernetes complète |

**App Service**, très présent à l'examen : un **plan App Service** définit la région, le SKU (Free, Shared, Basic, Standard, Premium, Isolated) et donc la facturation et les fonctionnalités (mise à l'échelle automatique dès Standard, emplacements de déploiement, sauvegardes, domaines personnalisés et certificats, intégration VNet). Plusieurs applications peuvent partager un plan. Les **emplacements de déploiement (slots)** permettent un basculement sans interruption (`Switch-AzWebAppSlot`) ; certains paramètres suivent l'emplacement, d'autres l'application.

**Particularité PowerShell des conteneurs :** le module `Az.ContainerRegistry` gère le registre (création, jetons, import d'images) mais **ne propose pas d'équivalent à ACR Tasks** (`az acr build`). Deux options en séance : appeler `az acr build` depuis PowerShell (Azure CLI est disponible dans Cloud Shell, les deux outils cohabitent sans problème), ou construire localement avec Docker Desktop et pousser après `Connect-AzContainerRegistry`. Le module `Az.ContainerInstance` (version 3 et suivantes) construit le groupe de conteneurs à partir d'objets : `New-AzContainerInstanceObject` puis `New-AzContainerGroup`.

### Démo formateur (20 min)

**1. Le registre**

```powershell
$AcrName = "acrtrackit$Suffix"
$acr = New-AzContainerRegistry -ResourceGroupName $RgShared -Name $AcrName -Location $Loc -Sku Standard -EnableAdminUser:$false -Tag $Tags
$acr.LoginServer
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

**3. Construction de l'image**

```powershell
# Option A (recommandée en séance) : ACR Tasks via Azure CLI, appelé depuis PowerShell
az acr build --registry $AcrName --image trackit-api:1.0 ./api

# Option B : Docker local, puis push authentifié par Entra ID
Connect-AzContainerRegistry -Name $AcrName
docker build -t "$($acr.LoginServer)/trackit-api:1.0" ./api
docker push "$($acr.LoginServer)/trackit-api:1.0"

# Option C (pour montrer l'import) : copier une image publique dans le registre
Import-AzContainerRegistryImage -ResourceGroupName $RgShared -RegistryName $AcrName `
    -SourceRegistryUri "docker.io" -SourceImage "library/nginx:alpine" -TargetTag "nginx:alpine"

Get-AzContainerRegistryRepository -RegistryName $AcrName
Get-AzContainerRegistryTag -RegistryName $AcrName -RepositoryName "trackit-api"
```

Expliquer les SKU Basic, Standard et Premium.

**4. Déploiement en ACI dans le VNet, avec identité managée pour tirer l'image**

```powershell
# Identité managée affectée par l'utilisateur, avec le droit AcrPull
$id = New-AzUserAssignedIdentity -ResourceGroupName $RgShared -Name "id-trackit-api" -Location $Loc
Start-Sleep -Seconds 30
New-AzRoleAssignment -ObjectId $id.PrincipalId -RoleDefinitionName "AcrPull" -Scope $acr.Id

$vnet     = Get-AzVirtualNetwork -Name "vnet-trackit-prod" -ResourceGroupName $RgNet
$snetApp  = Get-AzVirtualNetworkSubnetConfig -Name "snet-app" -VirtualNetwork $vnet

$port  = New-AzContainerInstancePortObject -Port 8080 -Protocol TCP
$env   = New-AzContainerInstanceEnvironmentVariableObject -Name "API_VERSION" -Value "1.0"
$cont  = New-AzContainerInstanceObject -Name "api-trackit" -Image "$($acr.LoginServer)/trackit-api:1.0" `
           -RequestCpu 1 -RequestMemoryInGb 1.5 -Port $port -EnvironmentVariable $env
$cred  = New-AzContainerGroupImageRegistryCredentialObject -Server $acr.LoginServer -Identity $id.Id

$aci = New-AzContainerGroup -ResourceGroupName $RgProd -Name "aci-trackit-api" -Location $Loc `
         -Container $cont -OsType Linux -RestartPolicy Always `
         -SubnetId @{ id = $snetApp.Id; name = "snet-app" } `
         -IdentityType UserAssigned -IdentityUserAssignedIdentity @{ $id.Id = @{} } `
         -ImageRegistryCredential $cred -Tag $Tags

$ApiIp = $aci.IPAddressIP; $ApiIp
Get-AzContainerInstanceLog -ResourceGroupName $RgProd -ContainerGroupName "aci-trackit-api" -ContainerName "api-trackit"
```

**5. Test de bout en bout depuis une VM web via Bastion**

```bash
# Depuis vm-web-02 (session Bastion, shell Linux) :
curl http://<API_IP>:8080/api/palettes/PAL-7781
# Résultat attendu : {"palette":"PAL-7781","statut":"En transit - Lyon vers Nantes", ...}
# Depuis Cloud Shell : Invoke-WebRequest échoue (pas d'IP publique, NSG). C'est voulu.
```

Puis brancher le front sur l'API : sur chaque VM web, ajouter dans la configuration nginx un bloc `location /api/ { proxy_pass http://<API_IP>:8080/api/; }` puis `sudo systemctl reload nginx`. Cette étape peut aussi être poussée sans session interactive grâce à **Run Command** :

```powershell
$script = @"
sed -i 's#location / {#location /api/ { proxy_pass http://$ApiIp:8080/api/; }\n\tlocation / {#' /etc/nginx/sites-available/default
systemctl reload nginx
"@
foreach ($vmName in "vm-web-01","vm-web-02") {
    Invoke-AzVMRunCommand -ResourceGroupName $RgProd -VMName $vmName -CommandId "RunShellScript" -ScriptString $script
}
Invoke-WebRequest -Uri "http://$($dep.Outputs.lbFqdn.Value)/api/palettes/PAL-7781" -UseBasicParsing | Select-Object -ExpandProperty Content
```

L'ACI n'est pas dans le pool du LB : **une ACI n'a pas de NIC**, on ne peut donc pas la placer dans un ASG. C'est le NSG `nsg-app` (source `asg-web`) qui la protège. Si l'exigence était l'équilibrage de plusieurs API, on parlerait d'**App Service**, de **Container Apps** ou d'**AKS** : les situer sur la carte AZ-104 (5 min).

### Reproduction par les participants (20 min)

Étapes 1 à 4 puis test `curl` depuis `vm-web-02` via Bastion. Bonus : `Invoke-AzVMRunCommand` pour le proxy nginx, et `az container exec` pour entrer dans le conteneur.

### Bonnes pratiques

- **Jamais de compte administrateur ACR en production** : identité managée et `AcrPull` pour ceux qui tirent, principal de service et `AcrPush` pour la chaîne de construction.
- **Étiqueter les images avec une version explicite**, jamais uniquement `latest` : on ne sait plus ce qui tourne, et un redéploiement peut changer le code sans que personne ne l'ait demandé.
- **Images minimales** (`slim`, `alpine`, distroless), un processus par conteneur, exécution sans root, et analyse des vulnérabilités activée sur le registre.
- **La configuration vient de l'extérieur** (variables d'environnement, secrets ACI, Key Vault), l'image est identique en test et en production.
- **Un point de terminaison de santé** (`/health`) dans chaque API : il sert aux sondes du LB, d'App Service ou de Kubernetes.
- **ACI pour l'éphémère et le simple ; App Service ou Container Apps dès qu'il faut du HTTPS géré, de la mise à l'échelle et des emplacements de déploiement.**
- **Run Command plutôt que session interactive** pour les actions répétables sur plusieurs VM : c'est traçable dans le journal d'activité et scriptable.

### Checkpoint et pièges d'examen (5 min)

- [ ] Image `trackit-api:1.0` dans l'ACR
- [ ] `aci-trackit-api` en état *Running* avec une IP 10.10.2.x
- [ ] `curl` réussit depuis `vm-web-02`, échoue depuis Internet
- [ ] Le front répond sur `/api/palettes/...`

**Pièges :** ACI dans un VNet = pas d'IP publique, sous-réseau **délégué** et dédié ; groupe de conteneurs = même hôte, même IP, même cycle de vie (modèle sidecar) ; volumes ACI via **Azure Files** (pas de disque managé) ; `Import-AzContainerRegistryImage` pour copier depuis Docker Hub ; la géo-réplication ACR est Premium ; App Service : le plan porte la facturation, la mise à l'échelle **verticale** (changer de SKU, `Set-AzAppServicePlan -Tier`) contre **horizontale** (ajouter des instances, `-NumberofWorkers`), les emplacements de déploiement à partir de Standard, le **swap** échange le trafic et conserve les paramètres marqués « slot setting » ; **Deployment Center** pour le déploiement continu ; AKS : le plan de contrôle est gratuit et géré, les nœuds sont des VMSS facturés, `kubectl` et les manifestes YAML ne sont pas au programme AZ-104 en profondeur.

---

## 9. Atelier 6 : App registration, principal de service, identité managée (15:30 à 16:15), ticket T6

### Le ticket

> « Les clients de Boréal doivent se connecter à TrackIt avec leur compte Microsoft d'entreprise. Le pipeline de NovaDev doit pouvoir pousser une nouvelle image et redéployer l'ACI **sans mot de passe stocké dans le code**. Et le mot de passe administrateur des VM ne doit plus traîner dans un paramètre. »

### Rappel des concepts

**Les trois objets à ne pas confondre :**

| Objet | Ce que c'est | Où il vit | Ce qu'on lui donne | Cmdlets |
|---|---|---|---|---|
| **App registration** (objet application) | La définition d'une application : identifiant client, URI de redirection, secrets ou certificats, permissions demandées, API exposées | Une seule fois, dans le tenant d'origine | Rien directement : c'est une description | `New-MgApplication`, `New-AzADApplication` |
| **Enterprise application** (principal de service) | L'instance de cette application dans un tenant donné ; c'est elle qui s'authentifie | Un par tenant qui utilise l'application | Des rôles Azure RBAC, des affectations d'utilisateurs, des consentements | `New-MgServicePrincipal`, `New-AzADServicePrincipal` |
| **Identité managée** | Un principal de service dont Azure crée et fait tourner le secret ; aucune information d'identification à gérer | Liée à une ressource Azure (VM, ACI, App Service, Function) | Des rôles Azure RBAC, des rôles d'application | `New-AzUserAssignedIdentity`, `Update-AzVM -IdentityType` |

**Identité managée affectée par le système** : créée avec la ressource, supprimée avec elle, une par ressource. **Affectée par l'utilisateur** : ressource indépendante, partageable entre plusieurs ressources, survit à leur suppression, à privilégier pour les flottes homogènes (nos VM web, notre ACI). La ressource obtient un jeton en interrogeant le point de terminaison IMDS (169.254.169.254) ou via les SDK (`DefaultAzureCredential`) ; en PowerShell sur une VM, `Connect-AzAccount -Identity` suffit.

**Le vocabulaire OAuth 2.0 et OpenID Connect** utile pour l'examen : le **client** (TrackIt-Web) redirige l'utilisateur vers Entra ID (**fournisseur d'identité**), qui renvoie un **jeton d'identité** (qui est l'utilisateur) et un **jeton d'accès** (ce qu'il peut faire sur une **ressource**, par exemple Microsoft Graph ou notre API). Les **permissions déléguées** agissent au nom d'un utilisateur connecté ; les **permissions d'application** agissent sans utilisateur (démons, pipelines) et exigent un consentement administrateur. Les **étendues (scopes)** exposées par une API (`api://<app-id>/Palettes.Read`) permettent de découper finement les droits. Les **types de comptes pris en charge** : ce tenant seulement (single tenant), tout tenant Entra (multi-tenant), avec ou sans comptes Microsoft personnels.

**Informations d'identification d'une application** : secret client (durée limitée, à faire tourner), certificat (préférable), ou **informations d'identification fédérées** (workload identity federation : GitHub Actions, Azure DevOps ou Kubernetes présentent leur propre jeton OIDC, Entra l'échange contre un jeton Azure ; zéro secret à stocker).

**Azure Key Vault** stocke **secrets**, **clés** cryptographiques et **certificats**. Deux modèles d'autorisation : **RBAC Azure** (recommandé : Key Vault Administrator, Secrets Officer, Secrets User, Crypto User) ou les **stratégies d'accès** héritées (`Set-AzKeyVaultAccessPolicy`). Protection : suppression réversible (obligatoire, 7 à 90 jours) et protection contre la purge. Références Key Vault depuis un template ARM ou Bicep, depuis App Service (`@Microsoft.KeyVault(...)`) ou via l'extension VM. Deux niveaux : Standard (clés logicielles) et Premium (clés protégées par HSM).

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

L'équivalent complet en Microsoft Graph PowerShell :

```powershell
$redirect = "http://trackit-$Suffix.francecentral.cloudapp.azure.com/signin-oidc"
$graphAppId  = "00000003-0000-0000-c000-000000000000"      # Microsoft Graph
$userReadId  = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"      # permission déléguée User.Read

$app = New-MgApplication -DisplayName "TrackIt-Web" -SignInAudience "AzureADMyOrg" `
    -Web @{ RedirectUris = @($redirect); ImplicitGrantSettings = @{ EnableIdTokenIssuance = $true } } `
    -RequiredResourceAccess @(@{ ResourceAppId = $graphAppId; ResourceAccess = @(@{ Id = $userReadId; Type = "Scope" }) })

# Exposer une API : identifiant d'application et étendue Palettes.Read
$scopeId = [guid]::NewGuid().Guid
Update-MgApplication -ApplicationId $app.Id -IdentifierUris @("api://$($app.AppId)") -Api @{
    Oauth2PermissionScopes = @(@{
        Id = $scopeId; Value = "Palettes.Read"; Type = "User"; IsEnabled = $true
        AdminConsentDisplayName = "Lire les palettes"; AdminConsentDescription = "Permet de lire le suivi des palettes"
        UserConsentDisplayName  = "Lire les palettes"; UserConsentDescription  = "Permet de lire le suivi des palettes"
    })
}

# Secret client (visible une seule fois)
$secret = Add-MgApplicationPassword -ApplicationId $app.Id -PasswordCredential @{ DisplayName = "bootcamp"; EndDateTime = (Get-Date).AddMonths(6) }
$ClientSecret = $secret.SecretText

# Principal de service (Enterprise application) et consentement administrateur pour User.Read
$sp      = New-MgServicePrincipal -AppId $app.AppId
$graphSp = Get-MgServicePrincipal -Filter "appId eq '$graphAppId'"
New-MgOauth2PermissionGrant -ClientId $sp.Id -ConsentType "AllPrincipals" -ResourceId $graphSp.Id -Scope "User.Read" | Out-Null

# Assignment required + affectation du groupe des lecteurs (rôle par défaut de l'application)
Update-MgServicePrincipal -ServicePrincipalId $sp.Id -AppRoleAssignmentRequired:$true
New-MgGroupAppRoleAssignment -GroupId $grpReaders.Id -PrincipalId $grpReaders.Id -ResourceId $sp.Id `
    -AppRoleId "00000000-0000-0000-0000-000000000000" | Out-Null

"AppId (client id) : $($app.AppId)"
```

Test : ouvrir dans une fenêtre privée `https://login.microsoftonline.com/<tenant-id>/oauth2/v2.0/authorize?client_id=<AppId>&response_type=id_token&redirect_uri=<redirect>&scope=openid&nonce=123&response_mode=fragment` avec `chef.lyon` : consentement puis redirection vers le site (nginx affichera 404 sur `/signin-oidc`, c'est normal : on prouve l'authentification, pas l'application). Tester ensuite avec `dev.novadev`, non affecté : refus `AADSTS50105`.

```powershell
"https://login.microsoftonline.com/$TenantId/oauth2/v2.0/authorize?client_id=$($app.AppId)&response_type=id_token&redirect_uri=$([uri]::EscapeDataString($redirect))&scope=openid&nonce=123&response_mode=fragment"
```

**2. Principal de service « sp-trackit-deploy » : l'identité du pipeline**

```powershell
$spDeploy = New-AzADServicePrincipal -DisplayName "sp-trackit-deploy" -Role "Contributor" `
    -Scope "/subscriptions/$SubId/resourceGroups/$RgProd"
New-AzRoleAssignment -ObjectId $spDeploy.Id -RoleDefinitionName "AcrPush" -Scope $acr.Id

$spDeploy.AppId
$spDeploy.PasswordCredentials.SecretText     # à transmettre une seule fois au pipeline, puis à oublier
```

Distinguer clairement les trois objets (tableau ci-dessus). Montrer l'alternative moderne : **informations d'identification fédérées** (`New-AzADAppFederatedCredential` pour GitHub Actions), donc zéro secret.

Simuler le pipeline dans une seconde session Cloud Shell :

```powershell
$cred = New-Object System.Management.Automation.PSCredential($spDeploy.AppId, (ConvertTo-SecureString $spDeploy.PasswordCredentials.SecretText -AsPlainText -Force))
Connect-AzAccount -ServicePrincipal -Credential $cred -Tenant $TenantId
az acr build --registry $AcrName --image trackit-api:1.1 ./api          # nouvelle version
# Redéployer le groupe de conteneurs avec l'image 1.1 (même commande New-AzContainerGroup, image et API_VERSION modifiées)
```

**3. Key Vault et identité managée : plus de secret dans les paramètres**

```powershell
$KvName = "kv-trackit-$Suffix"
$kv = New-AzKeyVault -ResourceGroupName $RgShared -Name $KvName -Location $Loc `
        -EnableRbacAuthorization -EnablePurgeProtection -SoftDeleteRetentionInDays 90 -Tag $Tags
New-AzRoleAssignment -ObjectId $me -RoleDefinitionName "Key Vault Secrets Officer" -Scope $kv.ResourceId
Start-Sleep -Seconds 30

Set-AzKeyVaultSecret -VaultName $KvName -Name "vm-admin-password"         -SecretValue $AdminPassword
Set-AzKeyVaultSecret -VaultName $KvName -Name "trackit-web-client-secret" -SecretValue (ConvertTo-SecureString $ClientSecret -AsPlainText -Force)
Get-AzKeyVaultSecret -VaultName $KvName | Format-Table Name, Enabled, Updated
```

Modifier le déploiement Bicep pour lire le secret depuis Key Vault (fichier `main.bicepparam`, identique à la version CLI) :

```bicep
using './trackit-web.bicep'
param suffix = 'ryo042'
param adminPassword = az.getSecret('<subscription-id>', 'rg-trackit-shared', 'kv-trackit-ryo042', 'vm-admin-password')
```

```powershell
New-AzResourceGroupDeployment -ResourceGroupName $RgProd -Name "deploy-web-02" -TemplateParameterFile ./main.bicepparam -WhatIf
```

Puis donner à l'identité `id-trackit-api` (atelier 5) les rôles **Key Vault Secrets User** sur le coffre et **Storage Blob Data Reader** sur le compte de stockage : l'API pourra lire les bons de livraison sans clé. Montrer la chaîne : ACI, puis identité managée, puis jeton Entra, puis Storage via le point de terminaison privé.

```powershell
New-AzRoleAssignment -ObjectId $id.PrincipalId -RoleDefinitionName "Key Vault Secrets User"   -Scope $kv.ResourceId
New-AzRoleAssignment -ObjectId $id.PrincipalId -RoleDefinitionName "Storage Blob Data Reader" -Scope $st.Id
```

Bonus VM : activer une identité managée sur une VM existante et l'utiliser depuis la VM.

```powershell
$vm = Get-AzVM -ResourceGroupName $RgProd -Name "vm-web-01"
Update-AzVM -ResourceGroupName $RgProd -VM $vm -IdentityType UserAssigned -IdentityId $id.Id
# Depuis la VM (Bastion) : Connect-AzAccount -Identity -AccountId <clientId de id-trackit-api> ; Get-AzKeyVaultSecret -VaultName kv-trackit-<suffix> -Name vm-admin-password -AsPlainText
```

### Reproduction par les participants (15 min)

Créer l'app registration (portail ou script), le secret, l'affectation de `grp-trackit-readers` ; tester la connexion `chef.lyon` puis `dev.novadev`. Bonus : Key Vault et `.bicepparam`.

### Bonnes pratiques

- **Identité managée d'abord, principal de service ensuite, secret en dernier recours.** Si un secret est indispensable : durée courte, rotation planifiée, stockage dans Key Vault, alerte avant expiration.
- **Certificat ou fédération OIDC plutôt que secret client** pour les pipelines ; les secrets copiés dans un fichier YAML finissent dans Git.
- **Un principal de service par usage et par environnement**, avec l'étendue la plus étroite : `sp-trackit-deploy` n'a rien à faire sur `rg-trackit-network`.
- **Activer « Assignment required »** sur les applications d'entreprise sensibles : par défaut tout utilisateur du tenant peut se connecter à une application enregistrée.
- **Limiter le consentement utilisateur** (paramètres de consentement Entra ID) : les permissions à fort impact passent par un consentement administrateur.
- **Key Vault : un coffre par application et par environnement**, modèle RBAC, suppression réversible et protection contre la purge, journaux de diagnostic vers Log Analytics, accès réseau restreint (point de terminaison privé) en production.
- **En PowerShell, ne jamais afficher un secret dans la console ni le stocker en clair** : `SecureString`, `Read-Host -AsSecureString`, `Get-AzKeyVaultSecret -AsPlainText` uniquement au moment de l'usage, et jamais dans un fichier de transcription.
- **Surveiller les connexions** : journaux de connexion Entra ID, Identity Protection (P2) pour les connexions à risque, Conditional Access pour exiger MFA ou un appareil conforme.

### Checkpoint et pièges d'examen (5 min)

- [ ] `TrackIt-Web` existe, URI de redirection configurée, `User.Read` consentie
- [ ] `chef.lyon` s'authentifie, `dev.novadev` est refusé (assignment required)
- [ ] `sp-trackit-deploy` est Contributor sur `rg-trackit-prod` et AcrPush sur le registre
- [ ] (bonus) le mot de passe VM vient de Key Vault

**Pièges :** une application multi-tenant demande un éditeur vérifié et un consentement dans chaque tenant ; le secret n'est visible qu'à la création ; **identité managée affectée par le système** disparaît avec la ressource, **affectée par l'utilisateur** est indépendante et partageable ; Key Vault modèle **RBAC** contre **stratégies d'accès** (on ne mélange pas les deux) ; pour référencer un secret dans un template il faut soit `-EnabledForTemplateDeployment` (modèle stratégies d'accès) soit le rôle adéquat pour le déployeur (modèle RBAC) ; la suppression réversible Key Vault est obligatoire, la protection contre la purge est irréversible une fois activée ; **Conditional Access** et **MFA** requièrent Entra ID P1 (les paramètres de sécurité par défaut offrent une MFA de base gratuite) ; **SSPR** nécessite l'inscription de méthodes et peut écrire en retour vers AD DS avec Entra Connect ; un rôle Entra ID (Application Administrator) permet de gérer les enregistrements d'applications mais ne donne aucun droit sur les ressources Azure ; `New-AzADServicePrincipal` sans `-Role` ne crée aucune attribution RBAC (contrairement à l'ancien comportement qui donnait Contributor sur la souscription).

---

## 10. Atelier 7 : supervision, alertes, sauvegarde (16:15 à 16:50), ticket T7

### Le ticket

> « On veut savoir *avant* le client quand une VM web sature ou tombe, garder les journaux 90 jours, et pouvoir restaurer une VM en cas de mauvaise manipulation. »

### Rappel des concepts

**Azure Monitor** collecte deux grandes familles de données. Les **métriques** : valeurs numériques horodatées, quasi temps réel, conservées 93 jours, gratuites pour les métriques de plateforme, visibles dans Metrics Explorer (`Get-AzMetric`). Les **journaux** : événements structurés stockés dans un **espace de travail Log Analytics**, interrogés en **KQL (Kusto Query Language)** (`Invoke-AzOperationalInsightsQuery`), facturés à l'ingestion et à la rétention (31 jours inclus, configurable jusqu'à 2 ans en interactif, puis archive). S'y ajoutent le **journal d'activité** (opérations du plan de contrôle : qui a créé, modifié, supprimé quoi ; conservé 90 jours gratuitement, `Get-AzActivityLog`), les **journaux de ressources** (plan de données : requêtes sur un compte de stockage, règles NSG déclenchées, activés par un **paramètre de diagnostic**, `New-AzDiagnosticSetting`), et les **insights** (VM Insights, Container Insights, Application Insights pour le code).

**Collecte sur les VM** : l'**Azure Monitor Agent (AMA)** remplace les anciens agents Log Analytics (MMA) et Diagnostics. Il est piloté par des **règles de collecte de données (DCR)** qui définissent quoi collecter (compteurs de performance, Syslog, journaux d'événements Windows, fichiers texte) et vers quel espace de travail l'envoyer. Un **point de terminaison de collecte (DCE)** est nécessaire pour certaines sources et pour les scénarios de liaison privée.

**Alertes** : une **règle d'alerte** associe une étendue, un **signal** (métrique, requête de journal, journal d'activité, Service Health, Resource Health), une **condition** (seuil statique ou dynamique, fenêtre d'agrégation, fréquence d'évaluation), une **gravité** (0 critique à 4 verbeuse) et un ou plusieurs **groupes d'actions** (e-mail, SMS, push, voix, webhook, Logic App, Function, runbook Automation, ITSM). Les **règles de traitement des alertes** permettent de suspendre les notifications pendant une maintenance. Les alertes métriques sont les moins chères et les plus rapides ; les alertes de journal permettent des conditions complexes mais avec une latence de quelques minutes.

**Azure Backup** protège les VM (via l'extension de sauvegarde, instantané puis transfert vers le coffre), les partages Azure Files, SQL Server et SAP HANA dans des VM, les disques managés, les blobs et les serveurs sur site (agent MARS, Azure Backup Server). Deux types de coffres : **Recovery Services vault** (VM, Files, SQL, MARS, et Site Recovery) et **Backup vault** (disques, blobs, PostgreSQL). Une **stratégie de sauvegarde** fixe la fréquence, l'heure et les rétentions (quotidienne, hebdomadaire, mensuelle, annuelle). La **redondance du coffre** (LRS, ZRS, GRS avec restauration inter-régions) se choisit avant la première sauvegarde. La **suppression réversible** du coffre conserve les données 14 jours après arrêt de la protection. La restauration peut recréer la VM, restaurer les disques seuls, remplacer les disques existants ou récupérer des fichiers individuels par montage.

**Azure Site Recovery (ASR)** réplique des VM vers une autre région (ou depuis VMware, Hyper-V, physique vers Azure) pour de la reprise d'activité : plans de récupération, tests de basculement sans impact, RPO de quelques minutes. Sauvegarde et réplication répondent à des besoins différents : la première à l'erreur et à la corruption, la seconde au sinistre régional.

**Network Watcher** regroupe les outils de diagnostic réseau : topologie, **IP flow verify** (`Test-AzNetworkWatcherIPFlow`), **NSG diagnostics**, **next hop** (`Get-AzNetworkWatcherNextHop`), **connection troubleshoot** (`Test-AzNetworkWatcherConnectivity`) et **connection monitor**, capture de paquets, **journaux de flux NSG** et **Traffic Analytics**. Il est activé automatiquement par région à la création d'un VNet.

**Particularité PowerShell de la sauvegarde :** les cmdlets `Az.RecoveryServices` travaillent dans un **contexte de coffre** (`Set-AzRecoveryServicesVaultContext` ou paramètre `-VaultId`) et manipulent des objets **conteneur** (la VM vue par le coffre) et **élément** (l'objet protégé). L'enchaînement est toujours : coffre, stratégie, `Enable-...Protection`, puis `Get-...Container`, `Get-...Item`, `Backup-...Item`.

### Démo formateur (20 min)

**1. Log Analytics et Azure Monitor Agent via DCR**

```powershell
$law = New-AzOperationalInsightsWorkspace -ResourceGroupName $RgShared -Name "log-trackit-prod" -Location $Loc -Sku PerGB2018 -RetentionInDays 90 -Tag $Tags
# Portail : Monitor > Data Collection Rules > Create : cibler vm-web-01 et vm-web-02,
# collecter Syslog (auth, daemon) et performances (CPU, mémoire, disque, réseau) vers log-trackit-prod.
# L'AMA est installé automatiquement sur les VM à l'association de la DCR.
# En script : New-AzDataCollectionRule -RuleFile dcr-linux.json puis New-AzDataCollectionRuleAssociation -TargetResourceId <vmId>
```

**2. Paramètres de diagnostic** sur le Load Balancer, le compte de stockage (blob) et le Key Vault, envoyés vers `log-trackit-prod` ; journaux de flux NSG via Network Watcher pour `nsg-web`.

```powershell
$lbId = (Get-AzLoadBalancer -ResourceGroupName $RgProd -Name "lb-trackit-web").Id
$logAll   = New-AzDiagnosticSettingLogSettingsObject    -Enabled $true -CategoryGroup "allLogs"
$logAudit = New-AzDiagnosticSettingLogSettingsObject    -Enabled $true -CategoryGroup "audit"
$metAll   = New-AzDiagnosticSettingMetricSettingsObject -Enabled $true -Category "AllMetrics"

New-AzDiagnosticSetting -Name "diag-lb" -ResourceId $lbId          -WorkspaceId $law.ResourceId -Log $logAll   -Metric $metAll
New-AzDiagnosticSetting -Name "diag-kv" -ResourceId $kv.ResourceId -WorkspaceId $law.ResourceId -Log $logAudit
New-AzDiagnosticSetting -Name "diag-st-blob" -ResourceId "$($st.Id)/blobServices/default" -WorkspaceId $law.ResourceId -Log $logAll -Metric $metAll
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

```powershell
# Exécuter une requête KQL depuis PowerShell
$q = 'AzureActivity | where OperationNameValue endswith "virtualMachines/deallocate/action" | project TimeGenerated, Caller, _ResourceId'
(Invoke-AzOperationalInsightsQuery -WorkspaceId $law.CustomerId -Query $q).Results | Format-Table

# Groupe d'actions
$emailDsi = New-AzActionGroupEmailReceiverObject -Name "dsi" -EmailAddress "abo@archia365.fr"
$ag = New-AzActionGroup -ResourceGroupName $RgShared -Name "ag-dsi" -ShortName "dsi" -Location "Global" -EmailReceiver $emailDsi

# Alerte métrique : CPU des VM web
$vmIds = (Get-AzVM -ResourceGroupName $RgProd | Where-Object Name -like "vm-web-*").Id
$condCpu = New-AzMetricAlertRuleV2Criteria -MetricName "Percentage CPU" -MetricNamespace "Microsoft.Compute/virtualMachines" `
             -TimeAggregation Average -Operator GreaterThan -Threshold 80
Add-AzMetricAlertRuleV2 -Name "alert-cpu-web" -ResourceGroupName $RgProd -Severity 2 `
    -TargetResourceScope $vmIds -TargetResourceType "Microsoft.Compute/virtualMachines" -TargetResourceRegion $Loc `
    -WindowSize (New-TimeSpan -Minutes 5) -Frequency (New-TimeSpan -Minutes 1) -Condition $condCpu -ActionGroupId $ag.Id `
    -Description "CPU web superieure a 80 % pendant 5 min"

# Alerte de journal d'activité : VM désallouée
$c1 = New-AzActivityLogAlertAlertRuleAnyOfOrLeafConditionObject -Field "category"      -Equal "Administrative"
$c2 = New-AzActivityLogAlertAlertRuleAnyOfOrLeafConditionObject -Field "operationName" -Equal "Microsoft.Compute/virtualMachines/deallocate/action"
$agRef = New-AzActivityLogAlertActionGroupObject -Id $ag.Id
New-AzActivityLogAlert -Name "alert-vm-deallocate" -ResourceGroupName $RgProd -Location "Global" `
    -Scope "/subscriptions/$SubId" -Condition @($c1, $c2) -Action $agRef

# Alerte de disponibilité du LB : sonde de santé
$condLb = New-AzMetricAlertRuleV2Criteria -MetricName "DipAvailability" -MetricNamespace "Microsoft.Network/loadBalancers" `
            -TimeAggregation Average -Operator LessThan -Threshold 50
Add-AzMetricAlertRuleV2 -Name "alert-lb-health" -ResourceGroupName $RgProd -Severity 1 `
    -TargetResourceId $lbId -WindowSize (New-TimeSpan -Minutes 5) -Frequency (New-TimeSpan -Minutes 1) `
    -Condition $condLb -ActionGroupId $ag.Id
```

Déclencher : `stress` sur `vm-web-02` via Bastion (`sudo apt install -y stress && stress --cpu 2 --timeout 300`), ou plus simplement `Stop-AzVM -ResourceGroupName $RgProd -Name vm-web-02 -Force` pour recevoir l'alerte du journal d'activité et celle du LB.

**4. Azure Backup**

```powershell
$vault = New-AzRecoveryServicesVault -ResourceGroupName $RgShared -Name "rsv-trackit" -Location $Loc -Tag $Tags
Set-AzRecoveryServicesBackupProperty -Vault $vault -BackupStorageRedundancy LocallyRedundant
Set-AzRecoveryServicesVaultContext -Vault $vault

$policy = Get-AzRecoveryServicesBackupProtectionPolicy -Name "DefaultPolicy"
Enable-AzRecoveryServicesBackupProtection -Policy $policy -Name "vm-web-01" -ResourceGroupName $RgProd

$container = Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM -FriendlyName "vm-web-01"
$item      = Get-AzRecoveryServicesBackupItem -Container $container -WorkloadType AzureVM
Backup-AzRecoveryServicesBackupItem -Item $item -ExpiryDateTimeUTC (Get-Date).AddDays(3).ToUniversalTime()
Get-AzRecoveryServicesBackupJob | Format-Table WorkloadName, Operation, Status, StartTime
```

Montrer dans le portail la stratégie (fréquence, rétention), les options de **restauration** (nouvelle VM, disques, remplacement, fichiers ; en PowerShell `Get-AzRecoveryServicesBackupRecoveryPoint` puis `Restore-AzRecoveryServicesBackupItem`) et évoquer **Azure Site Recovery** pour la réplication inter-régions.

**5. Network Watcher** (5 min)

```powershell
$nw   = Get-AzNetworkWatcher -Location $Loc
$vm1  = Get-AzVM -ResourceGroupName $RgProd -Name "vm-web-01"
$nic1 = Get-AzNetworkInterface -ResourceId $vm1.NetworkProfile.NetworkInterfaces[0].Id
$ip1  = $nic1.IpConfigurations[0].PrivateIpAddress

# IP flow verify : SSH depuis Internet vers vm-web-01, attendu : Deny par Deny-All-Inbound
Test-AzNetworkWatcherIPFlow -NetworkWatcher $nw -TargetVirtualMachineId $vm1.Id -Direction Inbound -Protocol TCP `
    -LocalIPAddress $ip1 -LocalPort 22 -RemoteIPAddress 203.0.113.10 -RemotePort 50000

# Connection troubleshoot : vm-web-02 vers l'API sur 8080, attendu : Reachable
$vm2 = Get-AzVM -ResourceGroupName $RgProd -Name "vm-web-02"
Test-AzNetworkWatcherConnectivity -NetworkWatcher $nw -SourceId $vm2.Id -DestinationAddress $ApiIp -DestinationPort 8080
```

La boucle est bouclée avec l'atelier 2.

### Reproduction par les participants (10 min)

Espace de travail, alerte métrique CPU, activation de la sauvegarde de `vm-web-01`. La DCR et les journaux de flux sont montrés par le formateur.

### Bonnes pratiques

- **Un espace de travail Log Analytics central par environnement** (ou par région pour la souveraineté), avec RBAC par table ou par ressource si des équipes différentes y accèdent.
- **Paramètres de diagnostic déployés par Azure Policy** (effet DeployIfNotExists) : une ressource créée sans journaux est une ressource invisible.
- **Alerter sur des symptômes utilisateurs** (disponibilité de la sonde, latence, erreurs 5xx) avant d'alerter sur des causes (CPU). Utiliser des **seuils dynamiques** pour les métriques saisonnières, et des gravités cohérentes : Sev 0 et 1 réveillent quelqu'un, Sev 3 et 4 vont dans un tableau de bord.
- **Un groupe d'actions par équipe et par canal**, pas par alerte ; tester le groupe d'actions à la création.
- **Sauvegarder tout ce qui a un état** (VM, Files, bases) avec une stratégie alignée sur le RPO ; **tester la restauration** au moins une fois par trimestre, une sauvegarde jamais restaurée n'existe pas.
- **Protéger le coffre** : suppression réversible activée, autorisation multi-utilisateur (Resource Guard) pour les opérations destructrices, redondance GRS avec restauration inter-régions pour la production.
- **Maîtriser les coûts d'observabilité** : plafond d'ingestion quotidien, tables en plan Basic pour les journaux verbeux, rétention d'archive pour la conformité, et un regard régulier sur **Azure Advisor** (`Get-AzAdvisorRecommendation`).
- **Industrialiser les alertes en script ou en Bicep** : une règle d'alerte créée à la main dans le portail n'existe pas dans l'environnement suivant.

### Checkpoint et pièges d'examen (5 min)

- [ ] Espace de travail `log-trackit-prod`, rétention 90 jours
- [ ] Alerte `alert-cpu-web` et groupe d'actions par e-mail, alerte reçue
- [ ] `vm-web-01` protégée par Azure Backup, une sauvegarde en cours ou terminée
- [ ] `Test-AzNetworkWatcherIPFlow` confirme le blocage du port 22 depuis Internet

**Pièges :** métriques (quasi temps réel, 93 jours) contre journaux (KQL, rétention configurable, coût à l'ingestion) ; le journal d'activité est du plan de contrôle, 90 jours gratuits, à exporter vers Log Analytics pour le conserver ; alerte métrique, alerte de recherche de journaux et alerte de journal d'activité ont des latences et des coûts différents ; **Azure Monitor Agent avec DCR** remplace l'agent Log Analytics (MMA), retiré ; un coffre Recovery Services ne peut pas être supprimé tant qu'il contient des éléments protégés (arrêter la protection **et** supprimer les données) ; la redondance du coffre est figée après la première sauvegarde ; la sauvegarde de VM ne prend qu'un instantané par jour en stratégie Standard (Enhanced permet plusieurs par jour) ; **Azure Advisor** = recommandations, **Service Health** = incidents de la plateforme et maintenance planifiée, **Resource Health** = état de ma ressource ; **VM Insights** nécessite l'AMA et la DCR associée ; les **classeurs (workbooks)** sont des rapports interactifs, les **tableaux de bord** des vues épinglées ; `Get-AzActivityLog` ne remonte que 90 jours.

---

## 11. Clôture (16:50 à 17:00)

1. **Relecture du tableau des tickets** : T1 à T7 fermés, architecture cible en place. Rejouer le parcours d'une requête : navigateur, puis LB, puis VM web (ASG et NSG), puis ACI (NSG), puis Storage (point de terminaison privé, identité managée), en nommant à chaque saut la notion AZ-104 mobilisée.
2. **Nettoyage**, dans l'ordre (le verrou et le coffre bloqueront sinon : c'est volontaire, c'est un rappel) :

```powershell
# Sauvegarde : arrêter la protection et supprimer les données, sinon le coffre bloque la suppression du groupe
Set-AzRecoveryServicesVaultContext -Vault (Get-AzRecoveryServicesVault -ResourceGroupName $RgShared -Name "rsv-trackit")
$item = Get-AzRecoveryServicesBackupItem -BackupManagementType AzureVM -WorkloadType AzureVM -Name "vm-web-01"
Disable-AzRecoveryServicesBackupProtection -Item $item -RemoveRecoveryPoints -Force

# Verrou
Remove-AzResourceLock -LockName "lock-no-delete-net" -ResourceGroupName $RgNet -Force

# Groupes de ressources (en parallèle)
Remove-AzResourceGroup -Name $RgProd   -Force -AsJob
Remove-AzResourceGroup -Name $RgNet    -Force -AsJob
Remove-AzResourceGroup -Name $RgShared -Force -AsJob

# Entra ID et Policy
Remove-MgApplication -ApplicationId $app.Id
Remove-AzADServicePrincipal -ObjectId $spDeploy.Id
Remove-AzADApplication -ApplicationId $spDeploy.AppId
Remove-AzPolicyAssignment -Name "req-tag-costcenter" -Scope "/subscriptions/$SubId"
Remove-AzPolicyAssignment -Name "allowed-locations"  -Scope "/subscriptions/$SubId"

Get-Job | Wait-Job | Format-Table Name, State
# Le Key Vault reste en suppression réversible 90 jours (protection contre la purge activée) : c'est normal.
# Les utilisateurs et groupes de test peuvent être supprimés avec Remove-MgUser / Remove-MgGroup.
```

3. **Pièges du jour à retenir** (tour de table express, un par participant).
4. Pointer vers Microsoft Learn, parcours *AZ-104 : Prerequisites, Manage identities and governance, Implement and manage storage, Deploy and manage compute, Configure and manage virtual networking, Monitor and back up*, et les *practice assessments* gratuits. Rappeler le format de l'examen : 40 à 60 questions, 100 minutes, étude de cas, questions à réponses multiples, glisser-déposer, et un score de réussite de 700 sur 1000. Les questions de syntaxe mélangent Azure CLI et PowerShell : savoir reconnaître `Verbe-AzNom` contre `az groupe sous-commande` fait gagner des points faciles.

---

## 12. Couverture de l'examen AZ-104 par le scénario

| Domaine d'examen (pondération) | Couvert par | Notions vues |
|---|---|---|
| Gérer les identités et la gouvernance Azure (20 à 25 %) | Ateliers 1 et 6 | Utilisateurs et groupes (Microsoft Graph), B2B, SSPR, rôles Entra ID contre RBAC, rôles intégrés et personnalisés, étendues, Azure Policy (définitions, initiatives, effets), verrous, tags, app registration, principaux de service, identités managées, Key Vault |
| Implémenter et gérer le stockage (15 à 20 %) | Atelier 3 (et 5, 6) | Types de comptes, redondance, niveaux d'accès, cycle de vie, SAS et stored access policy, contexte de stockage, rôles de données, Azure Files et File Sync, AzCopy, pare-feu, point de terminaison privé, DNS privé, soft delete et versioning |
| Déployer et gérer les ressources de calcul (20 à 25 %) | Ateliers 4 et 5 | Bicep et ARM, `New-AzResourceGroupDeployment -WhatIf`, modes de déploiement, VM (tailles, disques, extensions, Run Command), availability set, zones, VMSS, ACR, ACI, identité managée, App Service (plans, emplacements, mise à l'échelle), AKS en situation |
| Configurer et gérer les réseaux virtuels (15 à 20 %) | Ateliers 2 et 4 | VNet, sous-réseaux, délégation, adresses réservées, NSG, ASG, balises de service, Bastion, peering, UDR, Load Balancer Standard (sondes, règles, sortie), Application Gateway et Traffic Manager en situation, DNS privé, Network Watcher |
| Surveiller et maintenir les ressources (10 à 15 %) | Atelier 7 | Métriques et journaux, Log Analytics, AMA et DCR, paramètres de diagnostic, KQL, alertes (métrique, journal, activité), groupes d'actions, Azure Backup, Recovery Services, Site Recovery, Advisor, Service Health |

## 13. Kit formateur : checklist J-1

- [ ] Souscriptions des participants créées, quota d'au moins 4 vCPU Dsv5 en `francecentral`, fournisseurs `Microsoft.ContainerInstance`, `Microsoft.Network`, `Microsoft.Compute`, `Microsoft.Storage`, `Microsoft.KeyVault`, `Microsoft.RecoveryServices`, `Microsoft.OperationalInsights`, `Microsoft.Insights`, `Microsoft.ManagedIdentity` enregistrés (`Register-AzResourceProvider`)
- [ ] Droits Entra ID : chaque participant est au minimum *User Administrator* et *Application Administrator* sur son tenant de lab (ou un tenant dédié par participant)
- [ ] Modules vérifiés dans Cloud Shell : `Get-Module -ListAvailable Az.Accounts, Az.ContainerInstance, Az.Monitor, Az.RecoveryServices, Microsoft.Graph.Users, Microsoft.Graph.Applications` ; noter les versions utilisées pour la démo
- [ ] Dépôt Git du bootcamp : `prologue.ps1`, `trackit-web.bicep`, `main.bicepparam`, `dcr-linux.json`, dossier `api/`, `cleanup.ps1`
- [ ] Architecture cible déjà déployée dans la souscription du formateur (plan B si un déploiement participant échoue)
- [ ] Bastion : lancer le déploiement avec `-AsJob` en début d'atelier 2 (environ 10 min)
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
| Az | Module PowerShell officiel pour Azure, cmdlets `Verbe-AzNom`, remplace AzureRM |
| Bastion | Accès RDP et SSH via le portail, sans IP publique sur les VM |
| Bicep | Langage déclaratif qui se transpile en template ARM |
| Contexte de stockage | Objet PowerShell (`New-AzStorageContext`) qui porte l'authentification vers le plan de données d'un compte |
| DCE | Data Collection Endpoint : point de terminaison de collecte pour certaines sources et la liaison privée |
| IMDS | Instance Metadata Service (169.254.169.254) : fournit métadonnées et jetons d'identité managée aux VM |
| KQL | Kusto Query Language : langage de requête de Log Analytics |
| LRS / ZRS / GRS | Niveaux de redondance du stockage : local, zonal, géographique |
| Microsoft.Graph | Module PowerShell pour Entra ID et Microsoft 365, cmdlets `Verbe-MgNom`, remplace AzureAD et MSOnline |
| NSG | Network Security Group : pare-feu à état de couche 3 et 4, sur sous-réseau ou NIC |
| PIM | Privileged Identity Management : élévation de rôle temporaire et approuvée (Entra ID P2) |
| RBAC | Role-Based Access Control : principal + rôle + étendue |
| RPO / RTO | Perte de données maximale admissible / délai de reprise maximal admissible |
| SAS | Shared Access Signature : URL signée donnant un accès limité au stockage |
| SecureString | Type PowerShell pour manipuler un secret sans l'exposer en clair en mémoire ou à l'écran |
| SKU | Référence commerciale d'un service (Basic, Standard, Premium) |
| Splatting | Passage des paramètres d'une cmdlet via une table de hachage (`@params`) |
| UDR | User Defined Route : route personnalisée qui remplace une route système |
| VMSS | Virtual Machine Scale Set : groupe de VM identiques avec mise à l'échelle automatique |
| WAF | Web Application Firewall : protection de couche 7 (Application Gateway, Front Door) |

## 15. Table de correspondance Azure CLI / PowerShell

À distribuer aux participants : les deux syntaxes apparaissent à l'examen.

| Action | Azure CLI | Azure PowerShell |
|---|---|---|
| Se connecter | `az login` | `Connect-AzAccount` |
| Choisir la souscription | `az account set -s <id>` | `Set-AzContext -Subscription <id>` |
| Créer un groupe de ressources | `az group create` | `New-AzResourceGroup` |
| Créer un utilisateur Entra | `az ad user create` | `New-MgUser` (ou `New-AzADUser`) |
| Créer un groupe Entra | `az ad group create` | `New-MgGroup` (ou `New-AzADGroup`) |
| Attribuer un rôle | `az role assignment create` | `New-AzRoleAssignment` |
| Lister les rôles d'une étendue | `az role assignment list` | `Get-AzRoleAssignment` |
| Assigner une policy | `az policy assignment create` | `New-AzPolicyAssignment` |
| Poser un verrou | `az lock create` | `New-AzResourceLock` |
| Créer un VNet | `az network vnet create` | `New-AzVirtualNetwork` (+ `New-AzVirtualNetworkSubnetConfig`) |
| Modifier un sous-réseau | `az network vnet subnet update` | `Set-AzVirtualNetworkSubnetConfig` puis `Set-AzVirtualNetwork` |
| Créer un NSG et une règle | `az network nsg create`, `az network nsg rule create` | `New-AzNetworkSecurityGroup`, `New-AzNetworkSecurityRuleConfig` |
| Créer un ASG | `az network asg create` | `New-AzApplicationSecurityGroup` |
| Créer Bastion | `az network bastion create` | `New-AzBastion` |
| Créer un peering | `az network vnet peering create` | `Add-AzVirtualNetworkPeering` |
| Créer un compte de stockage | `az storage account create` | `New-AzStorageAccount` |
| Charger un blob | `az storage blob upload` | `Set-AzStorageBlobContent` |
| Changer le niveau d'un blob | `az storage blob set-tier` | `$blob.BlobClient.SetAccessTier()` |
| Générer une SAS | `az storage blob generate-sas` | `New-AzStorageBlobSASToken` |
| Créer un partage Files | `az storage share-rm create` | `New-AzRmStorageShare` |
| Cycle de vie | `az storage account management-policy create` | `Set-AzStorageAccountManagementPolicy` |
| Point de terminaison privé | `az network private-endpoint create` | `New-AzPrivateEndpoint` |
| Zone DNS privée | `az network private-dns zone create` | `New-AzPrivateDnsZone` |
| Déployer un template | `az deployment group create` | `New-AzResourceGroupDeployment` |
| Prévisualiser | `az deployment group what-if` | `New-AzResourceGroupDeployment -WhatIf` |
| Créer une VM | `az vm create` | `New-AzVM` |
| Désallouer une VM | `az vm deallocate` | `Stop-AzVM` |
| Arrêter sans désallouer | `az vm stop` | `Stop-AzVM -StayProvisioned` |
| Redimensionner une VM | `az vm resize` | `Update-AzVM` (après `$vm.HardwareProfile.VmSize = ...`) |
| Exécuter un script dans une VM | `az vm run-command invoke` | `Invoke-AzVMRunCommand` |
| Créer un ACR | `az acr create` | `New-AzContainerRegistry` |
| Construire une image dans ACR | `az acr build` | pas d'équivalent Az (utiliser `az acr build` ou Docker) |
| Importer une image | `az acr import` | `Import-AzContainerRegistryImage` |
| Créer une ACI | `az container create` | `New-AzContainerGroup` |
| Journaux d'une ACI | `az container logs` | `Get-AzContainerInstanceLog` |
| Identité managée | `az identity create` | `New-AzUserAssignedIdentity` |
| App registration | `az ad app create` | `New-MgApplication` |
| Principal de service | `az ad sp create-for-rbac` | `New-AzADServicePrincipal` |
| Key Vault | `az keyvault create` | `New-AzKeyVault` |
| Secret | `az keyvault secret set` | `Set-AzKeyVaultSecret` |
| Espace de travail Log Analytics | `az monitor log-analytics workspace create` | `New-AzOperationalInsightsWorkspace` |
| Requête KQL | `az monitor log-analytics query` | `Invoke-AzOperationalInsightsQuery` |
| Paramètre de diagnostic | `az monitor diagnostic-settings create` | `New-AzDiagnosticSetting` |
| Groupe d'actions | `az monitor action-group create` | `New-AzActionGroup` |
| Alerte métrique | `az monitor metrics alert create` | `Add-AzMetricAlertRuleV2` |
| Alerte journal d'activité | `az monitor activity-log alert create` | `New-AzActivityLogAlert` |
| Coffre Recovery Services | `az backup vault create` | `New-AzRecoveryServicesVault` |
| Activer la sauvegarde d'une VM | `az backup protection enable-for-vm` | `Enable-AzRecoveryServicesBackupProtection` |
| Sauvegarde immédiate | `az backup protection backup-now` | `Backup-AzRecoveryServicesBackupItem` |
| IP flow verify | `az network watcher test-ip-flow` | `Test-AzNetworkWatcherIPFlow` |
| Supprimer un groupe de ressources | `az group delete` | `Remove-AzResourceGroup` |
