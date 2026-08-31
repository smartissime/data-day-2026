# Fiche pratique : mon premier environnement de développement UDE

Formation D365 F&O Cloud, ARCHIA365.
Objet : monter de zéro un environnement de développement unifié (UDE), y connecter Visual Studio, et exécuter un premier développement X++.
À qui elle s'adresse : développeur ou consultant technique venant du monde AX 2009, AX 2012 ou D365 on premise.

---

## Ce qui change par rapport à votre VM de dev

| Avant, AX 2012 et D365 on premise | Maintenant, UDE |
|---|---|
| Une VM de dev qui porte l'AOS, IIS, SQL Server et Visual Studio | Visual Studio sur votre poste, AOS et base dans le cloud |
| Accès RDP à la machine | plus de RDP, plus de machine à administrer |
| CHE déployée depuis LCS sur votre abonnement Azure | environnement Power Platform provisionné en PowerShell |
| Snapshot de VM pour revenir en arrière | aucun snapshot, votre filet de sécurité s'appelle Git |
| Plusieurs développeurs sur la même VM | un UDE, un développeur, une seule instance AOS |
| PackagesLocalDirectory sur la VM | PackagesLocalDirectory téléchargé sur votre poste, en lecture, comme métadonnées de référence |

La bascule mentale à faire : votre poste ne contient plus que l'atelier, la pièce à usiner est dans le cloud.

---

## Vocabulaire : trois environnements à ne pas confondre

| Sigle | Type Power Platform | Usage | AOS |
|---|---|---|---|
| UPE, Unified Production Environment | Production | production | jusqu'à 80 instances |
| USE, Unified Sandbox Environment | Sandbox | recette, UAT, formation | jusqu'à 80 instances |
| UDE, Unified Developer Environment | Sandbox avec DevToolsEnabled | développement X++ | 1 instance, pas de scaling |

Deux avertissements :

- L'environnement Power Platform de type **Developer** n'est pas un UDE. Il ne supporte aucune charge Dynamics 365, il n'offre qu'un Dataverse allégé pour les canvas apps et les flux.
- Le type d'un environnement est **définitif**. Un USE ne deviendra jamais un UDE. En cas d'erreur, il faut supprimer et recréer, soit environ deux heures.

---

## 1. Prérequis

### Côté tenant

- Une licence Dynamics 365 Finance, ou Supply Chain Management, ou Project Operations, ou Operations Application Partner Sandbox, affectée à votre compte. Vérification : https://portal.office.com/account/?ref=MeControl
- Le rôle Power Platform Administrator ou Dynamics 365 Administrator. Attention, si le rôle vient d'être attribué, comptez 12 heures de cache avant de pouvoir créer un environnement.
- Au moins 1 Go de capacité Dataverse et 1 Go de capacité Operations disponibles.
- Le rôle System Administrator sur l'environnement cible, côté Power Platform et côté finance and operations.

### Côté poste

- Windows 10 ou 11, droits administrateur local.
- 16 Go d'espace libre au minimum sur le disque système. Prévoyez plutôt 40 à 60 Go.
- Visual Studio 2022 Professional ou Enterprise, avec :
  - charge de travail **Développement .NET Desktop**
  - composants individuels **Modeling SDK** et **DGML Editor**
  - SQL Server Express LocalDB, installé par défaut
- Extensions Visual Studio : **Power Platform Tools**, et **Microsoft Reporting Services Projects** si vous faites du SSRS.

---

## 2. Déployer l'UDE en PowerShell

L'interface graphique du Power Platform admin center ne sait pas créer un UDE. Elle crée un USE. Le drapeau `DevToolsEnabled` ne s'obtient qu'en PowerShell.

Exécutez les commandes **une par une**, dans une console PowerShell ouverte en administrateur.

### Étape 1, politique d'exécution

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

### Étape 2, module d'administration

```powershell
Install-Module -Name Microsoft.PowerApps.Administration.PowerShell -Scope CurrentUser
```

### Étape 3, connexion

```powershell
Add-PowerAppsAccount -Endpoint prod
```

`prod` désigne les régions commerciales. Les clouds souverains utilisent d'autres valeurs.

### Étape 4, métadonnées du template

```powershell
$jsonObject = @"
{
  "PostProvisioningPackages":
  [
    {
      "applicationUniqueName": "msdyn_FinanceAndOperationsProvisioningAppAnchor",
      "parameters": "DevToolsEnabled=true|DemoDataEnabled=true"
    }
  ]
}
"@ | ConvertFrom-Json
```

- `DevToolsEnabled=true` : c'est ce paramètre, et lui seul, qui fait de ce Sandbox un environnement de développement. Sans lui, Visual Studio ne pourra jamais y déployer de modèle.
- `DemoDataEnabled=true` : installe les sociétés de démonstration USMF, DEMF et les autres. Mettez `false` si l'environnement doit recevoir une copie de données client.

### Étape 5, création

```powershell
New-AdminPowerAppEnvironment `
    -DisplayName "ARCHIA365-DEV01" `
    -EnvironmentSku Sandbox `
    -Templates "D365_FinOps_Finance" `
    -TemplateMetadata $jsonObject `
    -LocationName "Europe" `
    -ProvisionDatabase
```

| Paramètre | À retenir |
|---|---|
| `-DisplayName` | unique au niveau global, sous 20 caractères pour obtenir une URL lisible |
| `-EnvironmentSku` | `Sandbox` obligatoire. `Trial` ne fonctionne pas, le téléchargement des métadonnées échouera |
| `-Templates` | selon votre licence : `D365_FinOps_Finance`, `D365_FinOps_SCM`, `D365_FinOps_ProjOps`, `D365_FinOps_Commerce` |
| `-TemplateMetadata` | l'objet de l'étape 4, c'est lui qui porte `DevToolsEnabled` |
| `-LocationName` | `Europe`, `UnitedStates`, etc. Alignez sur la région de votre tenant |
| `-ProvisionDatabase` | obligatoire |
| `-DomainName` | optionnel, fixe l'URL de façon déterministe |
| `-FirstRelease` | optionnel, accès anticipé aux nouvelles versions |

### Étape 6, attendre

Comptez **1 h 15 à 2 h**. Suivez l'état dans le Power Platform admin center, Manage puis Environments : l'environnement passe de **Preparing** à **Ready** sans action de votre part.

### Étape 7, relever les informations utiles

Sur la fiche de l'environnement, notez les deux URL :

- URL **Dataverse**, du type `https://<org>.crm4.dynamics.com`
- URL **finance and operations**, du type `https://<nom>.sandbox.operations.dynamics.com`

C'est **l'URL Dataverse** qui sert à connecter Visual Studio. Utiliser l'URL finance and operations est l'erreur la plus fréquente à cette étape.

### Étape 8, si le script ne passe plus : le script de secours `New-ARCFODEV.ps1`

Le script simple ci-dessus dépend du module `Microsoft.PowerApps.Administration.PowerShell`. Ce module est figé en version **2.0.217 (30/03/2026)**, antérieure au déploiement du provisionnement par macro région. Selon votre tenant et votre région, `New-AdminPowerAppEnvironment` peut donc renvoyer :

```
HTTP 400 : MacroRegionRequired
```

Ni une mise à jour du module, ni un changement de paramètre ne corrigent ce cas : le module n'expose aucun `-MacroRegion`. Utilisez alors le script d'annexe **`New-ARCFODEV.ps1`**, fourni avec cette fiche, qui appelle directement l'API BAP :

```
POST https://api.bap.microsoft.com/providers/Microsoft.BusinessAppPlatform/environments?api-version=2021-04-01
```

#### Utilisation, dans l'ordre

Ouvrez une **nouvelle** fenêtre PowerShell 5.1. Une fenêtre déjà utilisée peut porter un `Set-StrictMode` résiduel qui fait échouer le script.

```powershell
.\New-ARCFODEV.ps1 -ListMacroRegions   # affiche les macro régions valides, ne crée rien
.\New-ARCFODEV.ps1 -DryRun             # affiche le JSON complet, n'envoie rien
.\New-ARCFODEV.ps1                     # création réelle, avec confirmation
```

#### Variables à renseigner en tête de script

| Variable | Exemple | Remarque |
|---|---|---|
| `$MacroRegion` | `'the-americas'` | obligatoire, à récupérer avec `-ListMacroRegions` |
| `$Location` | `'canada'` | exclusif avec la macro région, ignoré tant que `$MacroRegion` est renseigné |
| `$AzureRegion` | `'canadacentral'` | envoyé comme `azureRegionHint` |
| `$DisplayName` et `$DomainName` | `'ARCFODEV30'` et `'arcfodev30'` | le domainName doit être unique mondialement, en minuscules |
| `$Sku` | `'Sandbox'` | obligatoire pour un UDE |
| `$Template` | `'D365_FinOps_Finance'` | selon votre licence |
| `$BaseLanguage` | `1036` | 1033 anglais, 1036 français. **Définitif** |
| `$Currency` | `'USD'` | **Définitif**, la devise de base ne se change plus après création |
| `$DevTools` et `$DemoData` | `$true` | produisent la même chaîne `DevToolsEnabled=true|DemoDataEnabled=true` |

Prenez trente secondes sur ces deux lignes définitives, langue et devise, avant de valider. Elles ne sont pas rattrapables.

#### Si l'authentification échoue

```powershell
Connect-AzAccount -AuthScope "https://api.bap.microsoft.com/"
```

Ou contournez `Az` complètement :

```powershell
.\New-ARCFODEV.ps1 -UsePowerAppsSession -ListMacroRegions
.\New-ARCFODEV.ps1 -AccessToken "eyJ0..." -ListMacroRegions   # jeton récupéré via F12 dans le PPAC
```

Si le navigateur ou le broker Windows ne répond pas ("A window handle must be configured"), le script bascule seul en device code. Vous pouvez le forcer avec `-UseDeviceCode`.

#### À la fin

Le script suit l'opération toutes les 60 secondes jusqu'à `Succeeded` ou `Failed`. Attention, `Succeeded` ne veut pas dire prêt à l'emploi : l'application finance and operations continue de se déployer **1 à 3 heures en arrière-plan**. Suivez la progression dans le PPAC, Ressources puis Applications Dynamics 365.


---


## 3. Configurer Visual Studio

### 3.1 Extensions

Extensions puis Gérer les extensions, installer **Power Platform Tools**, puis **fermer Visual Studio** pour finaliser l'installation. Si vous ne fermez pas Visual Studio, les nouveaux menus n'apparaîtront pas.

### 3.2 Vérifier LocalDB

```cmd
sqllocaldb create MSSQLLocalDB -s
SqlLocalDB.exe start MSSQLLocalDB
```

### 3.3 Se connecter à Dataverse

1. Rouvrir Visual Studio, choisir **Continue without code**.
2. Menu **Tools**, puis **Connect to Dataverse**.
3. Dans la boîte de dialogue : **décocher** "Sign in as current user", **cocher** "Display list of available organizations".
4. **Login**, puis vos identifiants d'administrateur.
5. Sélectionner votre environnement UDE dans la liste.
6. Sélectionner une solution, celle qui n'est pas la solution Default, puis **Done**.

Si vous êtes en MFA : décochez toutes les cases de l'écran de connexion.
Si vous êtes invité sur un autre tenant : Tools, Options, Power Platform Tools, activer **Skip Discovery when connecting to Dataverse**, décocher toutes les cases, puis saisir l'URI Dataverse à la main.

### 3.4 Télécharger les assets

Répondez **Yes** ou **OK** à la proposition de téléchargement. Suivez la progression dans **View** puis **Output**.

Les fichiers arrivent dans :

```
C:\Users\<Utilisateur>\AppData\Local\Microsoft\Dynamics365\<VersionApplication>
```

| Fichier | Rôle |
|---|---|
| `PackagesLocalDirectory.zip` | métadonnées système de référence |
| `Microsoft.Dynamics.FinOps.ToolsVS2022.vsix` | extension finance and operations pour Visual Studio |
| `DYNAMICSXREFDB.bak` | base de cross references |
| `TraceParser.msi` | outil Trace Parser |

Laissez active l'option **Auto setup for Dynamics 365 if using Unified environment**. Elle enchaîne seule l'extraction, la restauration de la base de cross references et la configuration.

**Comptez 1 h à 2 h.** Ne coupez pas le réseau et ne mettez pas le poste en veille pendant le transfert : une interruption produit un package corrompu, qu'il faut alors supprimer avant de relancer via **Tools** puis **Download Dynamics 365 FinOps assets**.

Deux options à activer dans Tools, Options, Power Platform Tools :

- **Do not display Power Platform Explorer**, pour accélérer la connexion.
- **Download logs**, pour récupérer les journaux de déploiement et de synchronisation.

### 3.5 Vérifier la configuration

**Extensions**, **Dynamics 365**, **Configure Metadata**. Vous devez y voir le nom de l'environnement, la version, le serveur de cross references et les dossiers de métadonnées.

Si vous devez créer la configuration à la main :

| Champ | Valeur |
|---|---|
| Cross reference database server | `(localdb)\.` exactement, ou `localhost` pour un SQL Server complet |
| Cross reference database name | nom libre, la base est créée si elle n'existe pas |
| Folder for your own custom metadata | votre dépôt Git local |
| Folders for reference metadata | le chemin du `PackagesLocalDirectory` extrait, plus les dossiers de modules ISV |

Bouton Save grisé : cherchez le champ à bordure rouge, l'infobulle donne l'erreur. Neuf fois sur dix, c'est la valeur du serveur de cross references.

Une seule configuration est active à la fois. Le changement prend effet dans les nouvelles instances de Visual Studio.

### 3.6 Contrôle final

**View**, puis **Application Explorer**. La fenêtre doit s'ouvrir et afficher l'AOT. Redémarrez Visual Studio si elle ne s'ouvre pas. Vous êtes prêt.

### 3.7 Le menu **Dynamics 365** n'apparaît pas dans **Extensions**

C'est le blocage le plus fréquent. Avant de chercher loin, comprenez le mécanisme : le menu **Dynamics 365** n'est pas fourni par Power Platform Tools. Il vient d'une **seconde** extension, `Microsoft.Dynamics.FinOps.ToolsVS2022.vsix`, qui n'est téléchargée qu'après une connexion réussie à un environnement **doté des outils de développement**. Menu absent signifie donc, presque toujours, que cette seconde extension n'a jamais été installée ou n'a pas pu se charger.

Déroulez les points **dans l'ordre**.

**1. Bonne version de Visual Studio.** Aide, À propos. Il faut Visual Studio 2022 (17.x), Professional ou Enterprise. L'extension s'appelle `ToolsVS2022`. Si plusieurs éditions ou une Preview cohabitent, vérifiez que vous ouvrez celle dans laquelle le VSIX a été installé.

**2. Power Platform Tools installé et activé.** Extensions, Gérer les extensions, onglet Installées. Si l'extension est marquée Disabled, activez-la, fermez et rouvrez Visual Studio.
Contrôle rapide : si le menu **Tools** ne contient pas **Connect to Dataverse**, c'est Power Platform Tools qui manque. Inutile d'aller plus loin.

**3. Visual Studio a bien été fermé après l'installation.** Un VSIX ne finit son installation qu'à la fermeture de Visual Studio. Fermez toutes les fenêtres, vérifiez dans le gestionnaire des tâches qu'aucun `devenv.exe` ne subsiste, puis rouvrez.

**4. L'environnement connecté est bien un UDE.** C'est la cause la plus trompeuse, parce que tout semble normal côté poste. Sur un **USE** (sans `DevToolsEnabled`) ou un environnement **Trial**, la connexion Dataverse réussit mais aucun asset n'est proposé, donc l'extension finance and operations n'est jamais installée.
Vérification : **Tools**, **Download Dynamics 365 FinOps assets**, puis lisez **View**, **Output**. Si le message indique qu'aucun asset n'est disponible, aucune correction locale n'est possible, il faut recréer un UDE.

**5. Les assets sont réellement là.**

```powershell
Get-ChildItem "$env:LOCALAPPDATA\Microsoft\Dynamics365" -Recurse -File |
    Select-Object FullName, @{n='Mo';e={[math]::Round($_.Length/1MB,1)}}
Get-PSDrive C | Select-Object Used, Free
```

Vous devez trouver quatre fichiers sous `%LOCALAPPDATA%\Microsoft\Dynamics365\<VersionApplication>` : `PackagesLocalDirectory.zip` et `DYNAMICSXREFDB.bak` (plusieurs Go chacun), `Microsoft.Dynamics.FinOps.ToolsVS2022.vsix` (quelques dizaines de Mo) et `TraceParser.msi`. Dossier vide, incomplet, ou tailles anormales : renommez le dossier de version, puis relancez **Tools**, **Download Dynamics 365 FinOps assets**. Vérifiez aussi l'espace disque, une extraction qui manque de place échoue sans le dire clairement.

**6. Les fichiers ne sont pas bloqués par Windows.** Un fichier téléchargé porte une marque de provenance qui peut empêcher le chargement de l'extension.

```powershell
Get-ChildItem "$env:LOCALAPPDATA\Microsoft\Dynamics365" -Recurse -File | Unblock-File
```

**7. Installez le VSIX à la main.** Extensions, Gérer les extensions, onglet Installées : cherchez une entrée Dynamics 365 ou Finance and Operations Tools. Si elle est absente, fermez Visual Studio, double-cliquez sur `Microsoft.Dynamics.FinOps.ToolsVS2022.vsix` dans le dossier ci-dessus, laissez l'installeur finir, puis rouvrez. C'est une manipulation normale, l'Output de Visual Studio la demande parfois explicitement.

**8. Acceptez l'élévation administrateur.** Au premier lancement suivant l'installation, Visual Studio demande une élévation pour enregistrer le gestionnaire de protocole d'URL, poser les cibles de build et extraire les fichiers du compilateur. Un refus laisse l'extension installée mais inerte, donc sans menu. Relancez Visual Studio par clic droit, **Exécuter en tant qu'administrateur**, et acceptez.

**9. Vérifiez les composants Visual Studio.** Visual Studio Installer, Modifier : **Modeling SDK** et **DGML Editor** en composants individuels, **Développement .NET Desktop** en charge de travail. Sans le Modeling SDK, l'extension ne se charge pas. Redémarrez Visual Studio après ajout.

**10. Lisez le journal.** C'est le verdict factuel quand rien n'a fonctionné.

```powershell
devenv /log
```

Puis ouvrez `%APPDATA%\Microsoft\VisualStudio\<instance>\ActivityLog.xml` et cherchez les entrées `Error`, en particulier `SetSite failed for package` associé au package Dynamics.

**11. Purgez les caches.** Fermez Visual Studio, renommez (plutôt que supprimer) le dossier `%LOCALAPPDATA%\Microsoft\VisualStudio\<instance>\ComponentModelCache`, puis depuis une invite de commandes développeur :

```cmd
devenv /updateconfiguration
devenv /clearcache
```

Le premier démarrage suivant est plus lent, c'est normal.

**12. Stratégie d'entreprise ou antivirus.** Si l'installation semble réussir mais que l'extension n'apparaît jamais dans la liste, le VSIX est probablement bloqué. Récupérez `%TEMP%\VSIXInstaller_*.log` et transmettez-le à votre IT.

#### Cas voisin : le menu Dynamics 365 est là, mais **Configure Metadata** manque

Ce n'est pas le même problème. L'extension est chargée mais pas encore initialisée. Ouvrez **Extensions**, **Dynamics 365**, **Infolog**, puis rouvrez le menu.

#### Table de décision rapide

| Ce que vous observez | Point à traiter |
|---|---|
| Pas de **Connect to Dataverse** dans le menu Tools | point 2 |
| Connexion réussie, aucun téléchargement proposé | point 4, ce n'est pas un UDE |
| Téléchargement lancé puis interrompu | points 5 et 6 |
| Tout est téléchargé, menu toujours absent | points 7, 8 et 9 |
| Rien d'explicable | points 10, 11 et 12 |


---


## 4. Premier développement

Objectif : écrire, compiler, déployer dans le cloud, exécuter et déboguer une classe X++.

### 4.1 Créer un modèle

**Extensions**, **Dynamics 365**, **Model management**, **Create model...**

- Nom : `ARCDeliveryModel`
- Choisir **Create new package**
- Modèles référencés : `ApplicationPlatform` et `ApplicationFoundation` suffisent ici. Ajoutez `ApplicationSuite` dès que vous touchez à `CustTable`.
- Enchaîner **Next** jusqu'à la création

### 4.2 Créer le projet et la classe

1. Nouveau projet **Finance Operations**, nommé `ARCDeliveryProject`, rattaché à `ARCDeliveryModel`.
2. Dans le **Solution Explorer**, clic droit sur le projet, **Add**, **New item**.
3. **Dynamics 365 Items**, catégorie **Code**, choisir **Runnable Class**, la nommer `ARCDeliveryHello`.

```xpp
internal final class ARCDeliveryHello
{
    public static void main(Args _args)
    {
        Info('Hello ARC Delivery, execute cote serveur dans le cloud');
    }
}
```

### 4.3 Compiler

Clic droit sur le projet, **Build**. La compilation est locale. À ce stade, rien n'est encore parti dans le cloud.

### 4.4 Déployer

**Extensions**, **Dynamics 365**, **Deploy**, **Deploy Models to Online Environment...**, cocher `ARCDeliveryModel`, valider.

Les autres voies de déploiement, à connaître :

| Situation | Chemin | Synchronisation de base |
|---|---|---|
| Modèle complet déjà construit | **Dynamics 365** > **Deploy** > **Deploy models ...** | optionnelle |
| Build complet avec déploiement | **Dynamics 365** > **Build models**, option **Deploy to connected online environment** | optionnelle |
| Build incrémental | propriété **Deploy changes to online environment** à true, puis Build | optionnelle |
| Un seul projet | clic droit sur le projet, **Deploy model for project ...** | non |
| Base uniquement | **Dynamics 365** > **Synchronize database...** | DBSync complet |

Règle pratique : déploiement incrémental par projet pendant que vous développez, déploiement de modèle complet avant de livrer, synchronisation de base seulement quand vous avez touché à une table, une vue ou un EDT.

### 4.5 Déboguer

1. **Extensions**, **Options**, onglet **Debugging** : chargez les symboles de `ARCDeliveryModel`, `ApplicationPlatform` et `ApplicationFoundation`.
2. Point d'arrêt sur la ligne `Info(...)`.
3. **F5**.
4. Un navigateur s'ouvre sur l'URL du class runner. Le débogueur charge les symboles et s'arrête sur votre point d'arrêt.
5. **F5** pour continuer. Le message s'affiche dans le volet **Infolog** de Visual Studio.

Pour vous attacher à l'AOS déjà en cours d'exécution : **Dynamics 365**, **Launch debugger**.
Pour vous détacher sans redémarrer l'AOS : **Detach**, et surtout pas **Stop**.

Ce qui vient de se passer : le point d'arrêt est dans Visual Studio sur votre poste, le code s'exécute sur un AOS hébergé dans un datacenter Azure, et le pas à pas fonctionne. C'est le débogage que vous connaissez, sans la VM.

### 4.6 La boucle de développement

Écrire, construire, déployer, synchroniser la base si nécessaire, déboguer, tester, **valider dans Git**.

Cette dernière étape n'est pas négociable. Un UDE n'a pas de snapshot, pas de point de restauration, pas de sauvegarde de métadonnées. Le contrôle de source Azure DevOps ou Git est votre seul moyen de revenir en arrière.

---

## 5. Checklist

**Avant de commencer**

- [ ] Licence F&O affectée et visible sur mon compte
- [ ] Rôle Power Platform Administrator ou Dynamics 365 Administrator, attribué depuis plus de 12 heures
- [ ] 1 Go de capacité Dataverse et 1 Go de capacité Operations disponibles
- [ ] Visual Studio 2022 avec .NET Desktop, Modeling SDK, DGML Editor
- [ ] LocalDB démarré
- [ ] 40 Go d'espace disque libre

**Déploiement**

- [ ] Module `Microsoft.PowerApps.Administration.PowerShell` installé
- [ ] `Add-PowerAppsAccount -Endpoint prod` réussi
- [ ] JSON avec `DevToolsEnabled=true` préparé
- [ ] `New-AdminPowerAppEnvironment` lancé en `Sandbox`, ou script d'annexe `New-ARCFODEV.ps1` si le premier échoue
- [ ] Langue de base et devise vérifiées avant validation (choix définitifs)
- [ ] État **Ready** dans le Power Platform admin center
- [ ] URL Dataverse et URL finance and operations notées
- [ ] Rôle System Administrator vérifié sur les deux plans

**Visual Studio**

- [ ] Power Platform Tools installé, Visual Studio fermé puis rouvert
- [ ] Connexion Dataverse réussie sur l'URL Dataverse
- [ ] Assets téléchargés, auto setup terminé
- [ ] Élévation administrateur acceptée au premier lancement
- [ ] Menu **Extensions > Dynamics 365** présent (sinon, section 3.7)
- [ ] Application Explorer visible

**Premier développement**

- [ ] Modèle `ARCDeliveryModel` créé
- [ ] Classe `ARCDeliveryHello` compilée sans erreur
- [ ] Modèle déployé dans l'environnement en ligne
- [ ] Point d'arrêt atteint en F5
- [ ] Message visible dans l'Infolog
- [ ] Code validé dans Git

---

## 6. Si ça coince

| Symptôme | Cause probable | Ce que vous faites |
|---|---|---|
| `Install-Module` refuse de s'exécuter | politique d'exécution | `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned` |
| `New-AdminPowerAppEnvironment` renvoie `HTTP 400 MacroRegionRequired` | module PowerApps figé en 2.0.217 | utilisez le script d'annexe `New-ARCFODEV.ps1`, voir étape 8 |
| Erreur de licence au provisionnement | licence absente, ou rôle attribué depuis moins de 12 h | affectez la licence, ou attendez |
| Erreur de capacité | capacité Dataverse ou Operations saturée | supprimez un environnement inutilisé, ou demandez une extension de capacité |
| Visual Studio ne propose pas l'environnement comme cible de déploiement | `DevToolsEnabled` oublié, vous avez un USE | supprimez et recréez, le type ne se change pas |
| Le téléchargement des métadonnées échoue | environnement de type Trial | recréez en Sandbox |
| Connexion Visual Studio en échec | vous avez saisi l'URL finance and operations | utilisez l'URL Dataverse |
| Connexion bloquée par MFA | cases cochées sur l'écran de connexion | décochez toutes les cases |
| Erreur LocalDB | instance arrêtée | `SqlLocalDB.exe start MSSQLLocalDB` |
| Bouton Save grisé dans Configure Metadata | champ invalide | bordure rouge, lisez l'infobulle, vérifiez `(localdb)\.` |
| Menu Dynamics 365 absent dans Extensions | plusieurs causes possibles | déroulez le diagnostic en 12 points de la section 3.7 |
| `Configure Metadata` invisible | extension pas initialisée | ouvrez **Extensions** > **Dynamics 365** > **Infolog**, réessayez |
| Package corrompu après coupure réseau | transfert interrompu | renommez le dossier incomplet, relancez **Tools** > **Download Dynamics 365 FinOps assets** |

---

## 7. Annexe et pour aller plus loin

### Annexe fournie avec cette fiche

- `New-ARCFODEV.ps1` : script de provisionnement par appel direct à l'API BAP, à utiliser si `New-AdminPowerAppEnvironment` échoue. Voir l'étape 8.

### Documentation

- Microsoft Learn, [Install and configure development tools](https://learn.microsoft.com/en-us/power-platform/developer/unified-experience/finance-operations-install-config-tools)
- Microsoft Learn, [Provision a new environment with an ERP-based template](https://learn.microsoft.com/en-us/power-platform/admin/unified-experience/tutorial-deploy-new-environment-with-erp-template)
- Microsoft Learn, [Unified environment types and templates](https://learn.microsoft.com/en-us/power-platform/admin/unified-experience/unified-environment-types-and-templates)
- Microsoft Learn, [Write, deploy, and debug X++ code](https://learn.microsoft.com/en-us/power-platform/developer/unified-experience/finance-operations-debug)
- Microsoft Learn, [Inner loop workflow](https://learn.microsoft.com/en-us/power-platform/developer/unified-experience/finance-operations-innerloop)
- FastTrack TechTalk, [Unified Development Experience for Finance and Operations](https://www.youtube.com/watch?v=OuEZ1rXkpYY)
- TechTalk, [Unified Admin Experience for Finance and Operations](https://www.youtube.com/watch?v=24RS5YgXnEc)
