# Bootcamp AZ-104 : depot du scenario « TrackIt chez Boreal Logistique »

| | |
|---|---|
| Auteur | Rodrigue YENGO |
| Entreprise | ARCHIA365, Bureau 326, 59 rue de Ponthieu, 75008 Paris |
| LinkedIn | https://www.linkedin.com/company/130004016 et https://www.linkedin.com/company/26302862 |
| YouTube | ArchiFridays : https://www.youtube.com/@ArchiFridays |
| Version | 1.1, septembre 2026 |

Ce depot contient tout le materiel necessaire pour derouler le bootcamp de 7 h : le scenario complet (deux versions, Azure CLI et Azure PowerShell), les scripts d'un atelier chacun, le template Bicep, l'API conteneurisee et les fichiers de configuration.

## Arborescence

```
bootcamp-az104-trackit/
|-- README.md                       ce fichier
|-- docs/
|   |-- scenario-bootcamp-az104-bash.md          scenario complet, commandes Azure CLI
|   `-- scenario-bootcamp-az104-powershell.md    scenario complet, commandes Az et Microsoft.Graph
|-- bash/                           kit Azure CLI (Cloud Shell Bash)
|   |-- 00-prologue.sh              variables communes, groupes de ressources (a sourcer)
|   |-- 01-identite-gouvernance.sh  atelier 1 : Entra ID, RBAC, Policy, verrous
|   |-- 02-reseau.sh                atelier 2 : VNet, NSG, ASG, Bastion
|   |-- 03-storage.sh               atelier 3 : compte de stockage, SAS, Files, point de terminaison prive
|   |-- 04-compute-bicep.sh         atelier 4 : deploiement Bicep VM + Load Balancer, test de bascule
|   |-- 05-conteneurs.sh            atelier 5 : ACR, ACI, proxy nginx via Run Command
|   |-- 06-identites-applicatives.sh atelier 6 : app registration, principal de service, Key Vault
|   |-- 07-supervision-backup.sh    atelier 7 : Log Analytics, DCR, alertes, Backup, Network Watcher
|   |-- 99-cleanup.sh               nettoyage complet
|   |-- trackit-web.bicep           template de l'atelier 4
|   |-- main.bicepparam             parametres avec secret Key Vault (atelier 6)
|   |-- lifecycle.json              politique de cycle de vie Blob
|   |-- dcr-linux.json              regle de collecte Azure Monitor (perf + Syslog)
|   |-- nginx-proxy.sh              script execute sur les VM web (Run Command)
|   `-- api/                        Dockerfile et app.py de l'API TrackIt
`-- powershell/                     kit Azure PowerShell (Cloud Shell PowerShell), meme structure en .ps1
```

Les deux dossiers sont autonomes : chacun contient sa copie du Bicep, de l'API et des fichiers JSON.

## Prerequis

- Une souscription Azure par participant, avec au moins 4 vCPU de la famille Dsv5 disponibles en `francecentral` (repli `westeurope`).
- Droits Entra ID : au minimum *User Administrator* et *Application Administrator* sur le tenant de lab.
- Fournisseurs de ressources enregistres : `Microsoft.ContainerInstance`, `Microsoft.Network`, `Microsoft.Compute`, `Microsoft.Storage`, `Microsoft.KeyVault`, `Microsoft.RecoveryServices`, `Microsoft.OperationalInsights`, `Microsoft.Insights`, `Microsoft.ManagedIdentity`.
- Azure Cloud Shell (Bash ou PowerShell). Les scripts PowerShell installent le module `Microsoft.Graph` s'il est absent.

## Utilisation

1. Televerser le dossier `bash/` ou `powershell/` dans Cloud Shell (bouton « Upload » ou `git clone`).
2. Modifier le suffixe dans `00-prologue.sh` ou `00-prologue.ps1` (ou exporter `SUFFIX` / `$Suffix` avant de lancer).
3. Executer les scripts dans l'ordre, un par atelier. Chaque script recharge le prologue et peut etre relance (les creations sont idempotentes ou tolerantes a l'existant).
4. Terminer par `99-cleanup`.

```bash
# Bash
cd bash && chmod +x *.sh
export SUFFIX=ryo042
./01-identite-gouvernance.sh
./02-reseau.sh
...
```

```powershell
# PowerShell
cd powershell
$Suffix = "ryo042"
./01-identite-gouvernance.ps1
./02-reseau.ps1
...
```

Options utiles : `WEB_VM_COUNT=3 ./04-compute-bicep.sh` ou `./04-compute-bicep.ps1 -WebVmCount 3` ; `WITH_PRIVATE_ENDPOINT=no ./03-storage.sh` ou `./03-storage.ps1 -SkipPrivateEndpoint` ; `API_VERSION=1.1 ./05-conteneurs.sh` ou `./05-conteneurs.ps1 -ApiVersion 1.1` ; `DELETE_ENTRA_TEST_OBJECTS=yes ./99-cleanup.sh` ou `./99-cleanup.ps1 -DeleteEntraTestObjects`.

## Points d'attention pour le formateur

- **Test a blanc obligatoire la veille** dans la souscription formateur : les scripts ont ete verifies syntaxiquement mais pas executes contre Azure. Les identifiants de definitions Policy, les versions d'API Bicep et la syntaxe des cmdlets `Az.ContainerInstance`, `Az.Monitor` et `Az.RecoveryServices` evoluent d'une version de module a l'autre.
- Le module Az n'a pas d'equivalent a `az acr build` : le script PowerShell de l'atelier 5 appelle Azure CLI pour construire l'image (les deux outils cohabitent dans Cloud Shell).
- Bastion prend 8 a 10 min : le script de l'atelier 2 le lance en arriere-plan.
- Les attributions de roles mettent parfois 30 s a 2 min a se propager ; les scripts marquent une pause de 30 s aux endroits sensibles. En cas d'erreur `AuthorizationPermissionMismatch`, relancer le script.
- Le Key Vault a la protection contre la purge activee : il reste visible 90 jours apres le nettoyage, c'est attendu.
- Aucun secret n'est ecrit sur disque par les scripts ; le secret du principal de service `sp-trackit-deploy` est affiche une seule fois a la creation.
