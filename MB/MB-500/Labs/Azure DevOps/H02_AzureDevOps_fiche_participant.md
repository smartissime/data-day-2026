# Fiche pratique : Azure DevOps pour un projet D365 F&O en environnement unifié, en 1 heure

Formation D365 F&O Cloud, ARCHIA365.
Objet : partir d'une organisation Azure DevOps vide et obtenir, en une heure, un dépôt Git structuré, Visual Studio connecté, un premier modèle versionné, des politiques de branche actives et un pipeline de build qui produit un package unifié.
À qui elle s'adresse : développeur ou consultant technique venant d'AX 2009, AX 2012 ou D365 on premise, disposant déjà d'un UDE et d'un Visual Studio configuré (fiche H01).
Source : FastTrack Tech Talk « Unified Development ALM for Finance and Operations », adapté au contexte de la formation.

---

## Ce qui change par rapport à votre ALM AX

| Avant, AX 2012 et D365 on premise | Maintenant, environnement unifié |
|---|---|
| TFVC, un workspace mappé sur la VM de dev | Git, un clone complet du dépôt sur votre poste |
| Check-in directement dans Main | Aucun commit direct dans main, tout passe par une pull request |
| Build sur une VM de build dédiée, provisionnée depuis LCS | Build sur un agent hébergé Microsoft, sans VM, avec les outils X++ livrés en packages NuGet |
| Package déployable appliqué via LCS | Package unifié appliqué via Power Platform, par pipeline ou `pac package deploy` |
| Pipelines classiques cliqués dans l'interface | Pipeline YAML, versionné dans le dépôt comme le reste du code |
| Le code vit sur la VM, le contrôle de source est une sécurité | Le code vit dans Git, l'UDE est jetable |

La bascule mentale : dans AX, le contrôle de source protégeait la VM. Ici, il n'y a plus de VM à protéger, Git est le seul endroit où votre travail existe durablement.

---

## Correspondance TFVC et Git

| Vous faisiez en TFVC | Vous faites en Git |
|---|---|
| Créer un workspace et mapper un dossier | `git clone`, ou Clone dans Visual Studio |
| Get latest | `git pull` (fetch puis merge) |
| Check-out implicite à la modification | rien, Git détecte les modifications |
| Check-in | `git commit` en local, puis `git push` vers Azure DevOps |
| Shelveset | branche de fonctionnalité, ou `git stash` pour du temporaire |
| Branch dans l'explorateur de contrôle de code source | `git branch`, opération légère et locale |
| Merge de branche à branche | pull request, avec revue et build de validation |
| Historique d'un fichier | `git log`, ou l'historique dans Azure Repos |

Un commit Git est local. Tant que vous n'avez pas fait `push`, personne d'autre ne voit votre travail, et il n'est pas sauvegardé hors de votre poste.

---

## Avant l'heure : prérequis

Ces éléments doivent être prêts avant de lancer le chronomètre. Aucun ne se fait en cinq minutes.

### Côté tenant et Azure DevOps

- Un compte Microsoft Entra avec le droit de créer une organisation Azure DevOps, ou une organisation existante où vous êtes Project Collection Administrator.
- Un UDE à l'état Ready (fiche H01, section 2), avec son URL Dataverse notée.
- Un compte disposant d'un parallel job Azure Pipelines. Une organisation neuve doit en demander un via le formulaire Microsoft, comptez deux à trois jours ouvrés. Sans parallel job, le pipeline reste en attente indéfiniment.

### Côté poste

- Visual Studio 2022 configuré selon la fiche H01 : Power Platform Tools, assets téléchargés, menu Dynamics 365 présent, Application Explorer fonctionnel.
- Git pour Windows installé. Vérification : `git --version` dans une invite de commandes.
- Les cinq packages NuGet de build X++ téléchargés sur le poste, dans un dossier `C:\NuGets`. En environnement unifié, ils ne viennent plus de LCS : dans Visual Studio, menu **Tools**, puis **Download Dynamics365 FnO NuGets for CI/CD**, choisissez la version d'application de votre UDE. Le téléchargement dépasse le gigaoctet.

| Package | Rôle |
|---|---|
| `Microsoft.Dynamics.AX.Platform.CompilerPackage` | compilateur X++ et outils de packaging |
| `Microsoft.Dynamics.AX.Platform.DevALM.BuildXpp` | références des modules Platform |
| `Microsoft.Dynamics.AX.Application1.DevALM.BuildXpp` | références des modules Application, partie 1 |
| `Microsoft.Dynamics.AX.Application2.DevALM.BuildXpp` | références des modules Application, partie 2 |
| `Microsoft.Dynamics.AX.ApplicationSuite.DevALM.BuildXpp` | références du module ApplicationSuite |

- `nuget.exe` en ligne de commande, téléchargé depuis nuget.org et placé dans `C:\NuGets`.

Notez les deux numéros de version des packages, ils serviront deux fois : dans `packages.config` et dans le pipeline. Exemple, Platform `7.0.7367.146`, Application `10.0.1935.21`. Prenez une version égale ou postérieure à celle de votre UDE.

---

## Plan de l'heure

| Minute | Étape | Résultat visible |
|---|---|---|
| 0 à 5 | 1. Organisation et projet | un projet Azure DevOps vide, en Git |
| 5 à 10 | 2. Extensions | deux extensions installées sur l'organisation |
| 10 à 15 | 3. Structure du dépôt | quatre fichiers de fondation dans `main` |
| 15 à 25 | 4. Flux Azure Artifacts | les cinq NuGets publiés dans le flux |
| 25 à 35 | 5. Visual Studio et premier modèle | un modèle X++ dans une branche de fonctionnalité, poussé |
| 35 à 45 | 6. Pull request et politiques de branche | `main` protégée, première PR fusionnée |
| 45 à 55 | 7. Pipeline de build YAML | un build en cours d'exécution |
| 55 à 60 | 8. Build de validation et contrôle | la politique complète, la checklist cochée |

Le premier build dure quinze à trente minutes sur un agent hébergé. Il se termine après l'heure, c'est prévu. Ce qui doit être fait à la soixantième minute, c'est qu'il tourne.

---

## Étape 1, minute 0 à 5 : organisation et projet

1. Ouvrez https://dev.azure.com et connectez-vous avec le compte de travail.
2. Si vous n'avez pas d'organisation : **New organization**, nommez-la, par exemple `archia365`, choisissez la région **Europe**.
3. **Organization settings**, **Repositories** : cochez **Disable creation of TFVC repositories**. Cela n'affecte aucun dépôt TFVC existant, cela empêche seulement d'en créer un nouveau par erreur.
4. **New project** :

| Champ | Valeur |
|---|---|
| Project name | `ARC-D365FO` |
| Visibility | Private |
| Version control | **Git** |
| Work item process | Agile, ou celui de votre organisation |

5. **Create**. Le projet s'ouvre avec un dépôt Git vide portant le nom du projet.

Pourquoi Git et pas TFVC : Git est le système par défaut d'Azure Repos et celui que Microsoft recommande. TFVC reste supporté, Microsoft n'a pas l'intention de le retirer, mais tout ce qui suit dans cette fiche suppose Git.

---

## Étape 2, minute 5 à 10 : extensions

Les extensions apportent les tâches de pipeline. Elles s'installent une fois par organisation, pas par projet.

1. **Organization settings**, **Extensions**, **Browse marketplace**.
2. Cherchez et installez, dans l'ordre :

| Extension | Éditeur à vérifier | Ce qu'elle apporte |
|---|---|---|
| **Dynamics 365 Finance and Operations Tools** | Dyn365FinOps, Microsoft | tâches de build X++, Create Deployable Package, Add Licenses, tests unitaires |
| **Power Platform Build Tools** | microsoft-IsvExpTools, Microsoft | Tool Installer, WhoAmI, Deploy Package, type de service connection Power Platform |

3. Sur chaque page, contrôlez l'éditeur avant de cliquer sur **Get it free**. Le marketplace contient des extensions homonymes d'éditeurs tiers.
4. Sélectionnez votre organisation, **Install**.
5. Revenez dans **Organization settings**, **Extensions**, onglet **Installed** : les deux doivent y figurer.

---

## Étape 3, minute 10 à 15 : structure du dépôt

Le dépôt est initialisé directement dans le navigateur avec quatre fichiers de fondation. Cela évite de dépendre de Visual Studio pour la première mise en place, et cela crée `main` proprement.

1. **Repos**, **Files**. Sur le dépôt vide, cliquez **Initialize** avec l'option **Add a README**. Le dépôt et la branche `main` existent maintenant.
2. Créez la structure cible :

```
ARC-D365FO/
├── README.md
├── .gitignore
├── Metadata/                  dossier des modèles X++, un sous-dossier par package
│   └── .gitkeep
├── Projects/                  solutions et projets Visual Studio
│   └── .gitkeep
└── BuildPipeline/
    ├── nuget.config
    ├── packages.config
    └── build.yml
```

Git ne versionne pas les dossiers vides, d'où les fichiers `.gitkeep`. Créez chaque fichier par **New**, **File**, en tapant le chemin complet, par exemple `Metadata/.gitkeep`.

3. Contenu de `.gitignore`. Le point important : les descripteurs de modèle sont versionnés, les binaires jamais.

```gitignore
# Sorties de compilation X++ et binaires
**/bin/
**/obj/
*.dll
*.pdb
*.netmodule
*.md5
*.xref
*.log

# Visual Studio
.vs/
*.user
*.suo
*.rnrproj.user

# Packages NuGet restaurés localement
NuGets/
packages/
```

4. Contenu de `BuildPipeline/nuget.config`. L'URL sera complétée à l'étape 4, laissez les balises en place.

```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <packageSources>
    <clear />
    <add key="FinOpsNuGet" value="https://pkgs.dev.azure.com/<org>/ARC-D365FO/_packaging/FinOpsNuGet/nuget/v3/index.json" />
  </packageSources>
</configuration>
```

5. Contenu de `BuildPipeline/packages.config`, avec vos deux numéros de version relevés dans les prérequis.

```xml
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package id="Microsoft.Dynamics.AX.Platform.CompilerPackage" version="7.0.7367.146" targetFramework="net40" />
  <package id="Microsoft.Dynamics.AX.Platform.DevALM.BuildXpp" version="7.0.7367.146" targetFramework="net40" />
  <package id="Microsoft.Dynamics.AX.Application1.DevALM.BuildXpp" version="10.0.1935.21" targetFramework="net40" />
  <package id="Microsoft.Dynamics.AX.Application2.DevALM.BuildXpp" version="10.0.1935.21" targetFramework="net40" />
  <package id="Microsoft.Dynamics.AX.ApplicationSuite.DevALM.BuildXpp" version="10.0.1935.21" targetFramework="net40" />
</packages>
```

6. `BuildPipeline/build.yml` sera rempli à l'étape 7. Créez-le avec une seule ligne de commentaire `# build X++ ARC-D365FO` pour réserver le chemin.

Chaque fichier créé dans le navigateur est un commit direct dans `main`. C'est acceptable maintenant, ce sera interdit à partir de l'étape 6.

---

## Étape 4, minute 15 à 25 : flux Azure Artifacts et publication des NuGets

L'agent de build hébergé n'a pas de compilateur X++. Il le récupère dans un flux NuGet privé de votre projet.

1. **Artifacts**, **Create Feed** :

| Champ | Valeur |
|---|---|
| Name | `FinOpsNuGet` |
| Visibility | Members of `ARC-D365FO` |
| Upstream sources | décoché, le flux ne doit servir que vos cinq packages |
| Scope | Project |

2. **Connect to feed**, **NuGet.exe** : copiez l'URL du flux. Remplacez `<org>` dans `nuget.config` par votre organisation si l'URL diffère de celle du modèle.
3. Sur le poste, dans une invite de commandes placée dans `C:\NuGets`, publiez les cinq packages. La première commande ouvre une authentification dans le navigateur.

```cmd
nuget.exe push -Source "https://pkgs.dev.azure.com/<org>/ARC-D365FO/_packaging/FinOpsNuGet/nuget/v3/index.json" -ApiKey AZ Microsoft.Dynamics.AX.Platform.CompilerPackage.nupkg
nuget.exe push -Source "https://pkgs.dev.azure.com/<org>/ARC-D365FO/_packaging/FinOpsNuGet/nuget/v3/index.json" -ApiKey AZ Microsoft.Dynamics.AX.Platform.DevALM.BuildXpp.nupkg
nuget.exe push -Source "https://pkgs.dev.azure.com/<org>/ARC-D365FO/_packaging/FinOpsNuGet/nuget/v3/index.json" -ApiKey AZ Microsoft.Dynamics.AX.Application1.DevALM.BuildXpp.nupkg
nuget.exe push -Source "https://pkgs.dev.azure.com/<org>/ARC-D365FO/_packaging/FinOpsNuGet/nuget/v3/index.json" -ApiKey AZ Microsoft.Dynamics.AX.Application2.DevALM.BuildXpp.nupkg
nuget.exe push -Source "https://pkgs.dev.azure.com/<org>/ARC-D365FO/_packaging/FinOpsNuGet/nuget/v3/index.json" -ApiKey AZ Microsoft.Dynamics.AX.ApplicationSuite.DevALM.BuildXpp.nupkg
```

Les fichiers `.nupkg` portent le numéro de version dans leur nom, adaptez les noms de fichier à ce que vous avez sur le disque.

4. Laissez tourner. Le transfert prend cinq à dix minutes selon la ligne. Passez à l'étape 5 pendant ce temps, et revenez vérifier dans **Artifacts**, flux `FinOpsNuGet`, que les cinq packages sont listés avant de lancer l'étape 7.

5. Donnez au pipeline le droit de lire le flux : **Artifacts**, `FinOpsNuGet`, roue crantée, **Permissions**, vérifiez que **`ARC-D365FO` Build Service** a le rôle **Reader** ou **Collaborator**. Sur un projet neuf il l'a par défaut.

---

## Étape 5, minute 25 à 35 : Visual Studio et premier modèle

### 5.1 Cloner

1. Dans Azure DevOps, **Repos**, **Clone**, copiez l'URL HTTPS.
2. Visual Studio, **Git**, **Clone Repository**, collez l'URL, chemin local `C:\Git\ARC-D365FO`, **Clone**.
3. **Git**, **Fetch** pour vérifier que le local est synchronisé avec le distant. Dans la fenêtre **Git Changes**, la branche affichée est `main`.

### 5.2 Pointer les métadonnées sur le dépôt

**Extensions**, **Dynamics 365**, **Configure Metadata**. Champ **Folder for your own custom metadata** : `C:\Git\ARC-D365FO\Metadata`. **Save**, puis **Extensions**, **Dynamics 365**, **Model management**, **Refresh models**.

C'est la même configuration que dans la fiche H01, section 3.5. La différence est le chemin : il tombe maintenant dans un clone Git. Tout modèle créé à partir de maintenant naît versionné.

### 5.3 Créer la branche de fonctionnalité

Fenêtre **Git Changes**, menu déroulant de la branche, **New Branch** :

| Champ | Valeur |
|---|---|
| Branch name | `feature/arc-delivery-model` |
| Based on | `main` |
| Checkout branch | coché |

On ne développe jamais dans `main`. Même une correction d'une ligne a sa branche.

### 5.4 Créer le modèle

**Extensions**, **Dynamics 365**, **Model management**, **Create model**, exactement comme dans la fiche H01, section 4.2 : `ARCDeliveryModel`, éditeur `ARCHIA365`, couche `usr`, nouveau package, références `ApplicationPlatform`, `ApplicationFoundation`, `ApplicationSuite`, case **Create new project** cochée. Enregistrez le projet dans `C:\Git\ARC-D365FO\Projects\ARCDelivery`.

Ajoutez la classe exécutable `ARCDeliveryHello` de la fiche H01, section 4.4, et faites un **Build** du projet pour vérifier que tout compile.

### 5.5 Valider et pousser

1. Fenêtre **Git Changes**. Vous devez voir le descripteur `Metadata/ARCDeliveryModel/Descriptor/ARCDeliveryModel.xml`, le fichier XML de la classe, le projet `.rnrproj` et la solution. Vous ne devez pas voir de dossier `bin`. Si vous en voyez un, le `.gitignore` de l'étape 3 n'est pas au bon endroit.
2. Message de commit : `Ajout du modele ARCDeliveryModel et de la classe ARCDeliveryHello`. Un message dit ce que le changement fait, pas « modifs ».
3. **Commit All**, puis **Push**. Visual Studio crée la branche distante et vous propose un lien pour créer la pull request.

Le commit est local, le push est ce qui envoie les objets vers Azure DevOps. Dans la démo du Tech Talk, l'orateur a fait deux commits locaux avant un seul push. C'est le fonctionnement normal.

---

## Étape 6, minute 35 à 45 : pull request et politiques de branche

### 6.1 Protéger `main`

À faire avant de fusionner quoi que ce soit. **Repos**, **Branches**, sur `main`, menu **...**, **Branch policies** :

| Politique | Réglage | Pourquoi |
|---|---|---|
| **Require a minimum number of reviewers** | 1, **Allow requestors to approve their own changes** décoché en projet réel, coché pour cet exercice si vous êtes seul | personne ne fusionne son propre code sans relecture |
| **Check for linked work items** | Required | chaque changement est rattaché à une tâche, c'est la traçabilité |
| **Check for comment resolution** | Required | une remarque de relecture ne reste pas ignorée |
| **Limit merge types** | Squash merge uniquement | un commit lisible par PR dans `main` |
| **Build validation** | sera ajouté à l'étape 8, le pipeline n'existe pas encore | la PR ne fusionne que si le code compile |

Dès que la première politique est enregistrée, le commit direct dans `main` devient impossible, y compris pour vous. C'est le but.

### 6.2 Créer la pull request

1. **Repos**, **Pull requests**, **New pull request**, de `feature/arc-delivery-model` vers `main`.
2. Titre : `Modele ARCDeliveryModel`. Description en deux lignes : ce qui est ajouté, comment le vérifier.
3. **Work items** : créez ou liez une tâche, par exemple `Mettre en place le modele ARC Delivery`. Sans elle, la politique bloque la fusion.
4. **Reviewers** : un collègue, ou vous-même pour l'exercice.
5. **Create**. Vous pouvez créer en brouillon, **Create as draft**, puis publier quand le code est prêt à être relu.

### 6.3 Relire et fusionner

Dans la PR : onglet **Files** pour lire le diff, **Commits** pour l'historique, **Updates** pour les poussées successives. Le relecteur clique **Approve**. Puis **Complete**, avec **Delete feature/arc-delivery-model after merging** coché.

Revenez dans Visual Studio : **Git**, **Fetch**, basculez sur `main`, **Pull**. Votre modèle est dans `main`. Supprimez la branche locale de fonctionnalité, elle a fini sa vie.

### 6.4 Le minimum de branches d'un projet F&O

| Branche | Rôle | Créée depuis | Retour vers |
|---|---|---|---|
| `main` | code relu, compilé, toujours sain | | |
| `feature/*` | une fonctionnalité ou une correction, une par sujet | `main` | `main` par PR |
| `release/*` | stabilisation pour SIT et UAT, une par livraison | `main` | `main` par PR |
| `hotfix/*` | correctif de production | `release/*` | `release/*` puis `main` |

Le principe derrière ce tableau, tel que Microsoft le formule : isoler le code non testé, isoler le code en cours du code éligible aux tests fonctionnels, ne jamais laisser partir en production un changement qui n'a pas fini sa validation. Le nombre de branches se discute, ces trois isolements ne se discutent pas.

---

## Étape 7, minute 45 à 55 : pipeline de build YAML

Le pipeline est un fichier dans le dépôt. Il est relu, versionné et restauré comme le code X++. C'est la raison de préférer YAML aux pipelines classiques cliqués : tout ce qui touche la production, code, configuration ou script, doit être dans le contrôle de source.

Avant de commencer, vérifiez dans **Artifacts** que les cinq packages de l'étape 4 sont bien publiés.

1. Créez une branche `feature/build-pipeline` depuis `main`, dans le navigateur ou dans Visual Studio.
2. Remplacez le contenu de `BuildPipeline/build.yml` par le fichier ci-dessous, en ajustant les deux versions et le chemin de la solution.

```yaml
# Build X++ ARC-D365FO : compile les modeles et produit un package unifie Power Platform
trigger:
  branches:
    include:
      - main
      - release/*

pool:
  vmImage: 'windows-latest'

variables:
  PlatformVersion: '7.0.7367.146'
  ApplicationVersion: '10.0.1935.21'
  NuGetConfigPath: '$(Build.SourcesDirectory)/BuildPipeline'
  NuGetInstallDir: '$(Build.SourcesDirectory)/NuGets'
  MetadataPath: '$(Build.SourcesDirectory)/Metadata'
  SolutionPath: '$(Build.SourcesDirectory)/Projects/ARCDelivery/ARCDelivery.sln'
  CompilerPackage: '$(NuGetInstallDir)/Microsoft.Dynamics.AX.Platform.CompilerPackage'
  PlatformBuildRef: '$(NuGetInstallDir)/Microsoft.Dynamics.AX.Platform.DevALM.BuildXpp'
  App1BuildRef: '$(NuGetInstallDir)/Microsoft.Dynamics.AX.Application1.DevALM.BuildXpp'
  App2BuildRef: '$(NuGetInstallDir)/Microsoft.Dynamics.AX.Application2.DevALM.BuildXpp'
  AppSuiteBuildRef: '$(NuGetInstallDir)/Microsoft.Dynamics.AX.ApplicationSuite.DevALM.BuildXpp'
  UnifiedPackageOutput: '$(Build.ArtifactStagingDirectory)/UnifiedPackage'

stages:
  - stage: Build
    displayName: 'Compiler X++ et creer le package unifie'
    jobs:
      - job: BuildXpp
        timeoutInMinutes: 120
        steps:

          - task: NuGetCommand@2
            displayName: 'Restaurer les NuGets de build X++'
            inputs:
              command: 'custom'
              arguments: >
                install "$(NuGetConfigPath)/packages.config"
                -ConfigFile "$(NuGetConfigPath)/nuget.config"
                -OutputDirectory "$(NuGetInstallDir)"
                -ExcludeVersion
                -Verbosity Detailed
                -Noninteractive

          - task: VSBuild@1
            displayName: 'Compiler la solution X++'
            inputs:
              solution: '$(SolutionPath)'
              vsVersion: '17.0'
              msbuildArgs: >
                /p:BuildTasksDirectory="$(CompilerPackage)/DevAlm"
                /p:MetadataDirectory="$(MetadataPath)"
                /p:FrameworkDirectory="$(CompilerPackage)"
                /p:ReferenceFolder="$(PlatformBuildRef)/ref/net40;$(App1BuildRef)/ref/net40;$(App2BuildRef)/ref/net40;$(AppSuiteBuildRef)/ref/net40;$(MetadataPath);$(Build.BinariesDirectory)"
                /p:ReferencePath="$(CompilerPackage)"
                /p:OutputDirectory="$(Build.BinariesDirectory)"
                /p:CompilerMetadata="$(Build.BinariesDirectory)"

          - task: CopyFiles@2
            displayName: 'Copier les journaux de compilation'
            condition: always()
            inputs:
              SourceFolder: '$(Build.BinariesDirectory)'
              Contents: '**/*.log'
              TargetFolder: '$(Build.ArtifactStagingDirectory)/Logs'

          - task: NuGetToolInstaller@1
            displayName: 'Installer NuGet 3.3.0 pour le packaging'
            inputs:
              versionSpec: '3.3.0'

          - task: XppCreatePackage@3
            displayName: 'Creer le package unifie Power Platform'
            inputs:
              XppToolsPath: '$(CompilerPackage)'
              XppBinariesPath: '$(Build.BinariesDirectory)'
              XppBinariesSearch: '*'
              CreateCloudPackage: true
              CloudPackagePlatVersion: '$(PlatformVersion)'
              CloudPackageAppVersion: '$(ApplicationVersion)'
              CloudPackageOutputLocation: '$(UnifiedPackageOutput)'
              DeployablePackagePath: '$(Build.ArtifactStagingDirectory)/AXDeployableRuntime_$(Build.BuildNumber).zip'

          - task: ArchiveFiles@2
            displayName: 'Zipper le package unifie'
            inputs:
              rootFolderOrFile: '$(UnifiedPackageOutput)'
              includeRootFolder: false
              archiveType: 'zip'
              archiveFile: '$(Build.ArtifactStagingDirectory)/UnifiedPackage_$(Build.BuildNumber).zip'

          - task: PublishBuildArtifacts@1
            displayName: 'Publier le package unifie'
            inputs:
              PathtoPublish: '$(Build.ArtifactStagingDirectory)/UnifiedPackage_$(Build.BuildNumber).zip'
              ArtifactName: 'UnifiedPackage'

          - task: PublishBuildArtifacts@1
            displayName: 'Publier les journaux'
            condition: always()
            inputs:
              PathtoPublish: '$(Build.ArtifactStagingDirectory)/Logs'
              ArtifactName: 'Logs'
```

Ce que fait chaque bloc, à lire une fois :

| Bloc | Rôle | Équivalent que vous connaissez |
|---|---|---|
| `trigger` | build automatique à chaque fusion dans `main` ou `release/*` | build planifié sur la VM de build |
| `NuGetCommand` | installe compilateur et références depuis votre flux | le `PackagesLocalDirectory` de la VM de build |
| `VSBuild` | compile la solution avec les cibles X++ | Build models |
| `XppCreatePackage@3` | produit le package unifié, version 3 obligatoire, case **Create Power Platform Unified Package** | Create deployable package, version LCS |
| `ArchiveFiles` puis `PublishBuildArtifacts` | met le zip à disposition du pipeline de release | le package uploadé dans LCS |

3. Validez la branche, ouvrez la PR vers `main`, liez un work item, approuvez, fusionnez.
4. **Pipelines**, **New pipeline**, **Azure Repos Git**, dépôt `ARC-D365FO`, **Existing Azure Pipelines YAML file**, branche `main`, chemin `/BuildPipeline/build.yml`, **Continue**, puis **Run**.
5. Renommez le pipeline `ARC-D365FO Build` dans son menu **...**, **Rename/move**.

Le build démarre. Suivez le premier job : la restauration NuGet dure plusieurs minutes, la compilation aussi. Ne l'attendez pas pour passer à l'étape 8.

Pourquoi ne pas déployer depuis ce pipeline : le build valide et produit, le release déploie. Séparer les deux permet de redéployer un artefact existant sans recompiler, et de mettre des approbations avant chaque environnement. Le release fait l'objet de l'annexe A.

---

## Étape 8, minute 55 à 60 : build de validation et contrôle

1. **Repos**, **Branches**, `main`, **Branch policies**, **Build validation**, **+** :

| Champ | Valeur |
|---|---|
| Build pipeline | `ARC-D365FO Build` |
| Trigger | Automatic |
| Policy requirement | Required |
| Build expiration | Immediately when `main` is updated |

Désormais, toute PR vers `main` déclenche une compilation, et ne peut pas fusionner si elle échoue. C'est le point où le contrôle de source cesse d'être une simple sauvegarde et devient un contrôle qualité.

2. Retournez dans **Pipelines**. Le build est encore en cours, c'est attendu. À sa fin, l'onglet **Summary** doit montrer, dans **Related**, deux artefacts publiés : `UnifiedPackage` et `Logs`. Ouvrez `UnifiedPackage`, le zip contient votre module `ARCDeliveryModel`. Notez le numéro de run, c'est lui que le release consommera.

3. Cochez la checklist.

---

## Checklist

**Prérequis, avant l'heure**

- [ ] UDE Ready, URL Dataverse notée
- [ ] Visual Studio configuré selon H01, Application Explorer fonctionnel
- [ ] Git installé
- [ ] Cinq NuGets téléchargés via **Tools**, **Download Dynamics365 FnO NuGets for CI/CD**, versions Platform et Application notées
- [ ] `nuget.exe` disponible
- [ ] Parallel job Azure Pipelines disponible sur l'organisation

**Organisation et projet**

- [ ] Organisation créée ou accessible, création de dépôts TFVC désactivée
- [ ] Projet `ARC-D365FO` en Git
- [ ] Extensions Dynamics 365 Finance and Operations Tools et Power Platform Build Tools installées, éditeur Microsoft vérifié

**Dépôt**

- [ ] `main` initialisée avec README
- [ ] `.gitignore`, `Metadata/`, `Projects/`, `BuildPipeline/` en place
- [ ] `nuget.config` et `packages.config` avec les bonnes versions
- [ ] Flux `FinOpsNuGet` créé, cinq packages visibles, Build Service en lecture

**Visual Studio**

- [ ] Dépôt cloné dans `C:\Git\ARC-D365FO`
- [ ] Configure Metadata pointe sur `C:\Git\ARC-D365FO\Metadata`
- [ ] Branche `feature/arc-delivery-model` créée depuis `main`
- [ ] Modèle `ARCDeliveryModel` et classe `ARCDeliveryHello` compilés
- [ ] Commit sans aucun dossier `bin`, push réussi

**Pull request et branches**

- [ ] Politiques sur `main` : relecteur, work item, commentaires résolus, squash
- [ ] PR créée, work item lié, approuvée, fusionnée, branche supprimée
- [ ] `main` mise à jour en local

**Pipeline**

- [ ] `build.yml` fusionné dans `main` par PR
- [ ] Pipeline `ARC-D365FO Build` créé et lancé
- [ ] Build validation ajoutée aux politiques de `main`
- [ ] Après la fin du build : artefact `UnifiedPackage` présent, numéro de run noté

---

## Si ça coince

| Symptôme | Cause probable | Ce que vous faites |
|---|---|---|
| L'option Git n'apparaît pas à la création du projet | vous êtes dans un projet existant, pas dans la création | **New project**, la liste Version control est sur l'écran de création |
| L'extension est installée mais la tâche `XppCreatePackage` est introuvable | mauvaise extension, éditeur tiers | désinstallez, réinstallez celle de l'éditeur Dyn365FinOps |
| `nuget.exe push` renvoie 401 | authentification expirée ou refusée | relancez, une fenêtre de connexion s'ouvre, ou créez un Personal Access Token avec le scope Packaging Read et Write et passez-le comme mot de passe |
| `nuget.exe push` renvoie 409 | le package existe déjà dans cette version | rien à faire, passez au suivant |
| Le commit contient des dossiers `bin` | `.gitignore` absent ou à la racine du mauvais dossier | corrigez le `.gitignore`, puis `git rm -r --cached Metadata/*/bin` et recommitez |
| Push refusé sur `main` | politique de branche active | c'est normal, passez par une branche et une PR |
| La PR ne peut pas être fusionnée, message sur le work item | politique **Check for linked work items** | liez une tâche dans le volet **Work items** de la PR |
| Le pipeline reste en attente, « no hosted parallelism » | organisation neuve sans parallel job | demandez le parallel job gratuit via le formulaire Microsoft, en attendant utilisez un agent auto-hébergé |
| `NuGetCommand` échoue, package introuvable | version dans `packages.config` différente de celle publiée, ou droits du Build Service | comparez les versions dans **Artifacts**, vérifiez les permissions du flux |
| `VSBuild` échoue, solution introuvable | `SolutionPath` incorrect | ouvrez **Repos**, copiez le chemin exact du `.sln`, respectez la casse |
| `VSBuild` échoue sur une référence de modèle | une référence cochée dans le modèle n'est pas dans les packages de build | vérifiez les références dans **Update model parameters**, tout ce qui n'est pas Platform, Application ou ApplicationSuite doit être dans `Metadata/` |
| `XppCreatePackage` échoue, version de tâche | tâche en version 1 ou 2 | `XppCreatePackage@3` dans le YAML |
| Le build passe, aucun artefact | `XppBinariesSearch` ne trouve rien | ouvrez le journal de la tâche, vérifiez que `$(Build.BinariesDirectory)` contient `ARCDeliveryModel/bin` |
| Le build dépasse une heure | premier run, restauration complète des NuGets | normal une fois, les runs suivants sont plus rapides si vous ajoutez une tâche `Cache@2` sur `NuGets/` |

---

## Annexe A : pipeline de release vers l'UDE, hors de l'heure

À traiter dans une seconde séance. Les étapes, telles que présentées dans le Tech Talk :

1. Installer PAC CLI, par exemple l'extension Power Platform Tools de VS Code, ou `dotnet tool install --global Microsoft.PowerApps.CLI.Tool`.
2. S'authentifier : `pac auth create --environment https://<org>.crm4.dynamics.com`.
3. Créer un principal de service et lui donner accès à l'environnement : `pac admin create-service-principal --environment <id ou url>`. La commande enregistre une application Entra, génère un secret et affecte le rôle System Administrator sur l'environnement. Notez l'Application Id, le Tenant Id et le secret, il ne sera plus affiché.
4. Dans Azure DevOps, **Project settings**, **Service connections**, **New**, type **Power Platform**, authentification par Application Id et Client secret, URL de l'environnement. Ce type n'existe que si l'extension Power Platform Build Tools est installée.
5. Pipeline de release, artefact d'entrée `UnifiedPackage` du pipeline `ARC-D365FO Build`, puis trois tâches dans l'ordre : **Power Platform Tool Installer**, **Power Platform WhoAmI** avec la service connection, **Power Platform Deploy Package** avec le chemin du zip téléchargé.
6. Une étape par environnement, avec une **pre-deployment approval** avant chaque déploiement en sandbox partagée.
7. Après déploiement, contrôle dans **Finance and Operations Package Manager**, volet **Operation History**, comme dans la fiche H01, section 4.7.

Le release peut lui aussi être écrit en YAML, dans un second stage ou un second fichier. La démo du Tech Talk l'a fait en classique pour montrer la correspondance, avec la recommandation de passer en YAML.

## Annexe B : ce que le Tech Talk couvre en plus

| Sujet | Où le trouver | Quand vous en aurez besoin |
|---|---|---|
| Tests unitaires X++ dans le pipeline | tâche de la même extension, exécutée après déploiement sur l'environnement | dès que vous avez une classe de test, DJ3 |
| Ajout de licence ISV au package | tâche **Add Licenses to Deployable Package**, version 1, type Power Platform Unified Package, une tâche par modèle | si vous livrez un module sous licence |
| Paramètres de pipeline | bloc `parameters` en tête de YAML, valeurs par défaut, cases à cocher au lancement | pour un même pipeline avec ou sans tests, avec ou sans déploiement |
| Journaux côté environnement | **Operation History** dans le Package Manager Dataverse, téléchargeables | pour compléter les journaux Azure DevOps en cas d'échec de déploiement |

---

## Pour aller plus loin

- FastTrack Tech Talk, [Unified Development ALM for Finance and Operations](https://www.youtube.com/@MSFTDynamics365) (sessions 1 et 2 de la série sur l'UDE recommandées en préalable)
- Microsoft Learn, [Continuous integration and deployment, unified experience](https://learn.microsoft.com/en-us/power-platform/developer/unified-experience/finance-operations-pipelines)
- Microsoft Learn, [Tutorial: set up a build pipeline for finance and operations apps using Azure DevOps](https://learn.microsoft.com/en-us/power-platform/admin/unified-experience/tutorial-build-pipeline-azure-devops)
- Microsoft Learn, [Tutorial: set up a release pipeline](https://learn.microsoft.com/en-us/power-platform/admin/unified-experience/tutorial-release-pipeline-azure-devops)
- Microsoft Learn, [Build automation that uses Microsoft-hosted agents and Azure Pipelines](https://learn.microsoft.com/en-us/dynamics365/fin-ops-core/dev-itpro/dev-tools/hosted-build-automation)
- Microsoft Learn, [Create deployable packages in Azure Pipelines](https://learn.microsoft.com/en-us/dynamics365/fin-ops-core/dev-itpro/dev-tools/pipeline-create-deployable-package)
- GitHub, [Dynamics365-Xpp-Samples-Tools, CI-CD](https://github.com/microsoft/Dynamics365-Xpp-Samples-Tools/tree/master/CI-CD)
- Marketplace, [Dynamics 365 Finance and Operations Tools](https://marketplace.visualstudio.com/items?itemName=Dyn365FinOps.dynamics365-finops-tools) et [Power Platform Build Tools](https://marketplace.visualstudio.com/items?itemName=microsoft-IsvExpTools.PowerPlatform-BuildTools)
- Microsoft Learn, [Adopt a Git branching strategy](https://learn.microsoft.com/en-us/azure/devops/repos/git/git-branching-guidance)
