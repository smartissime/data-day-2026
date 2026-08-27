# Dynamics en 365

## Du poste de développement au premier composant X++ livré

### Guide pratique Dynamics 365 Finance and Operations, Visual Studio 2026 Professional

| Rubrique | Valeur |
| :-- | :-- |
| Série | Dynamics en 365 |
| Auteur | Rodrigue YENGO, [profil LinkedIn](https://www.linkedin.com/in/rodrigue-yengo/) |
| Éditeur | ARCHIA365 / ARCHIALEARN |
| Communauté | [Data & AI France Study Group](https://data-day.archifridays.com/), soutenu par ARCHIA365 et ARCHIALEARN |
| Objet | Installation des extensions Visual Studio, configuration d'Azure DevOps et du Power Platform, développement et livraison d'un composant simple |
| Public visé | Développeur débutant sur Dynamics 365 Finance and Operations |
| Contexte technique | Visual Studio 2026 Professional, environnement de développement unifié, dépôt Git |
| Durée totale | 5 à 7 heures |
| Version du document | 1.1 |
| Date | 25 août 2026 |
| Contact | contact@archia365.fr |

**Genèse du document.** Cette procédure a été rédigée à l'issue de deux mises en place complètes réalisées de bout en bout. Chaque étape a été exécutée, vérifiée, et corrigée à la lumière des blocages rencontrés.

**Appel à contribution.** Les portails Microsoft évoluent vite et les configurations de tenant varient. Si vous rencontrez un point de blocage, un libellé qui a changé, ou si vous identifiez une amélioration, faites-le nous remonter à l'adresse **contact@archia365.fr**. Précisez la phase concernée, le message d'erreur exact et le contexte de votre environnement.

**Convention de lecture.** Les libellés de l'interface Microsoft sont indiqués en anglais, en `police à chasse fixe`, suivis de leur équivalent français entre parenthèses. Les chemins de menu utilisent le signe `>` comme séparateur de niveau. Chaque phase est précédée de la mention des rôles requis.

## Sommaire

1. À lire avant de commencer
2. Phase 1 : Visual Studio 2026 Professional, installation et extensions
3. Phase 2 : Azure DevOps, organisation, projet et dépôt Git
4. Phase 3 : Modèle, package et projet
5. Phase 4 : Développement du composant
6. Phase 5 : Configuration du Power Platform pour l'automatisation
7. Phase 6 : Chaîne d'intégration continue et de déploiement
8. Phase 7 : Livraison du composant par le pipeline
9. Annexe A : Dépannage
10. Annexe B : Checklist séquentielle d'exhaustivité
11. Annexe C : Conventions de nommage et bonnes pratiques
12. Annexe D : Références officielles
13. À propos, contact et communauté

## 1. À lire avant de commencer

### 1.1 Objectif et livrable

Ce guide part d'un poste vierge et se termine par un composant X++ fonctionnel, versionné, compilé automatiquement et déployé sur un environnement cloud par un pipeline.

À l'issue de la procédure, vous disposerez :

- d'un poste équipé de **Visual Studio 2026 Professional**, de ses charges de travail, de ses composants individuels et de ses extensions Dynamics 365 ;
- d'une **organisation Azure DevOps** avec un projet et un dépôt Git structuré ;
- d'un **modèle**, d'un **package** et d'un **projet** X++ opérationnels ;
- d'un **composant fonctionnel complet** : un champ métier ajouté au client, affiché sur le formulaire standard et protégé par une règle de validation écrite en X++ ;
- d'une **chaîne d'intégration continue et de déploiement** qui compile ce composant et l'installe automatiquement sur votre environnement.

### 1.2 Position par rapport au document d'installation d'environnement

Ce guide **suppose qu'un environnement de développement unifié existe déjà**. Sa création, depuis l'ouverture du tenant jusqu'au provisionnement de l'environnement Sandbox, fait l'objet d'un document distinct de la même série, intitulé *Mise en place d'un environnement de développement complet Dynamics 365 Finance and Operations sur un nouveau tenant*.

Concrètement, vous devez disposer avant de commencer :

| Élément | Pourquoi |
| :-- | :-- |
| Un environnement `Sandbox` à l'état `Ready` | C'est la cible de vos déploiements et la source de vos métadonnées de référence |
| La `Finance and Operations Provisioning App` installée avec les outils de développement | Sans cette option, Visual Studio ne peut pas se connecter |
| L'`Environment URL` de l'environnement | Elle sera saisie dans Visual Studio |
| Une licence Dynamics 365 affectée à votre compte | Sans licence, l'accès à l'application est refusé |
| Le rôle `System administrator` (Administrateur système) dans l'environnement | Il conditionne la connexion depuis Visual Studio et le déploiement |
| Une Subscription Azure dans le tenant | Elle porte le Managed DevOps Pool de la phase 6 |

### 1.3 Ce que vous allez construire

Le composant retenu est volontairement simple sur le plan fonctionnel, mais il traverse **les quatre techniques d'extensibilité les plus utilisées au quotidien**. Un développeur qui les maîtrise couvre l'essentiel des demandes courantes.

**Besoin fonctionnel.** Le service crédit souhaite consigner, pour chaque client, la **date de la prochaine revue de son encours**. Cette date doit apparaître sur la fiche client, et le système doit refuser l'enregistrement d'une date antérieure à la date du jour, une revue ne pouvant être planifiée dans le passé.

**Traduction technique.**

| Objet à créer | Type | Technique | Section |
| :-- | :-- | :-- | :-- |
| `ArcLabels` | Fichier de libellés | Création | 5.2 |
| `ArcCreditReviewDate` | Type de données étendu | Création | 5.3 |
| `CustTable.ArcExtension` | Extension de table | Extension de données | 5.4 |
| `CustTable.ArcExtension` | Extension de formulaire | Extension d'interface | 5.5 |
| `ArcCustTable_Extension` | Classe d'extension | Chain of Command | 5.6 |

À ces cinq objets X++ s'ajoute la **solution Dataverse** créée en 2.5, qui sert de contexte à la connexion entre Visual Studio et l'environnement, et de conteneur à tout composant Power Platform qui viendrait compléter le dispositif.

**Point de méthode déterminant.** Vous ne modifierez **aucun objet standard**. Toutes les évolutions passent par des extensions, c'est-à-dire des objets qui vous appartiennent et qui se greffent sur le standard sans le toucher. C'est la règle absolue de l'extensibilité Dynamics 365 depuis la version 10 : le code Microsoft est scellé, et toute tentative de le modifier est techniquement impossible.

### 1.4 Prérequis du poste

| Élément | Minimum | Recommandé |
| :-- | :-- | :-- |
| Système d'exploitation | Windows 10, 64 bits | Windows 11 |
| Mémoire vive | 16 Go | 32 Go |
| Espace disque libre | 60 Go | 100 Go sur disque SSD |
| Connexion Internet | 20 Mbit/s | 100 Mbit/s ou plus |
| Droits | Administrateur local du poste | Administrateur local du poste |

L'espace disque est la contrainte la plus souvent sous-estimée. Visual Studio occupe environ 10 Go, les métadonnées de référence environ 24 Go après décompression, auxquelles s'ajoutent la base de références croisées et vos propres objets.

### 1.5 Visual Studio 2026, ce qui change

Visual Studio 2026 est la version courante de l'environnement de développement Microsoft, disponible en versions générales depuis novembre 2025. Pour le développement X++, la bascule est structurante : à partir de la mise à jour de plateforme 74, correspondant à la version 10.0.50 des applications Finance and Operations, **Visual Studio 2022 cesse d'être pris en charge** pour le développement X++, et Visual Studio 2026 devient la version de référence.

Trois conséquences pratiques.

1. **Les postes existants doivent basculer.** Un poste équipé de Visual Studio 2022 continue de fonctionner tant que l'environnement n'a pas atteint la version de plateforme concernée, mais la migration devient obligatoire ensuite.
2. **Les chaînes de génération doivent suivre.** L'image de l'agent de build doit embarquer Visual Studio 2026, et la tâche de compilation doit cibler la version correspondante de MSBuild.
3. **L'extension des outils suit la version de plateforme.** Dans l'expérience de développement unifiée, Visual Studio télécharge automatiquement l'extension Finance and Operations correspondant à la version de plateforme de l'environnement auquel vous vous connectez. Vous n'avez donc pas à choisir manuellement le fichier d'extension.

**Point de vigilance.** Selon la version de plateforme de votre environnement, le nom du fichier d'extension téléchargé peut encore porter la mention `VS2022`, l'alignement des noms d'actifs suivant parfois le cycle de mise à jour avec un décalage. Ce n'est pas un problème : c'est la version de plateforme de l'environnement qui détermine l'extension installée. En cas de doute sur la compatibilité entre la version de votre environnement et celle de Visual Studio, vérifiez la page de prérequis des outils de développement sur Microsoft Learn, référencée en annexe D.

### 1.6 Rôles requis

| Phase | Action | Rôle minimal requis | Plan concerné |
| :-- | :-- | :-- | :-- |
| 1 | Installer Visual Studio, les composants et les extensions | Administrateur local du poste | Poste local |
| 1 | Créer un éditeur et une solution dans le Power Platform | `System customizer` (Personnalisateur système) ou `System administrator` (Administrateur système) dans l'environnement | Power Platform |
| 1 | Se connecter à l'environnement depuis Visual Studio | `System administrator` (Administrateur système) dans l'environnement | Dynamics 365 |
| 2 | Créer une organisation Azure DevOps | Aucun rôle préalable, le créateur devient `Organization Owner` (Propriétaire de l'organisation) | Azure DevOps |
| 2 | Créer un projet d'équipe | `Project Collection Administrators` (Administrateurs de collection de projets) | Azure DevOps |
| 2 | Cloner, valider et publier du code | `Contributors` (Contributeurs), niveau d'accès `Basic` (De base) | Azure DevOps |
| 3 | Créer un modèle, un package et un projet | Administrateur local du poste | Poste local |
| 4 | Déployer un modèle et synchroniser la base | `System administrator` (Administrateur système) dans l'environnement | Dynamics 365 |
| 5 | Créer un principal de service | `System administrator` dans l'environnement, et droit de créer une inscription d'application dans Microsoft Entra ID | Les deux |
| 5 | Créer une connexion de service | `Project Administrators` (Administrateurs de projet) | Azure DevOps |
| 6 | Installer les extensions de l'organisation | `Project Collection Administrators` | Azure DevOps |
| 6 | Créer un flux Azure Artifacts | `Project Collection Administrators` | Azure DevOps |
| 6 | Enregistrer les fournisseurs de ressources Azure | `Owner` (Propriétaire) ou `Contributor` (Contributeur) sur la Subscription | Azure |
| 6 | Créer un `Managed DevOps Pool` (pool DevOps managé) | `DevOps Infrastructure Contributor` (Contributeur d'infrastructure DevOps) au minimum | Azure |
| 6 | Utiliser un pool d'agents dans un projet | Permission `Administrator` (Administrateur) ou `Creator` (Créateur) sur les pools d'agents | Azure DevOps |
| 7 | Créer et exécuter un pipeline | `Contributors` (Contributeurs) du projet | Azure DevOps |

## 2. Phase 1 : Visual Studio 2026 Professional, installation et extensions

**Objectif de la phase.** Disposer d'un poste capable de lire les métadonnées de l'application standard, de compiler du X++ et de dialoguer avec l'environnement cloud.

**Rôles requis.** Administrateur local du poste pour toutes les installations. `System administrator` (Administrateur système) dans l'environnement Finance and Operations pour la connexion.

### 2.1 Obtenir Visual Studio 2026 Professional

**Étape 1.** Rendez-vous sur `https://my.visualstudio.com`.

**Étape 2.** Connectez-vous avec le compte du tenant, de la forme `votreutilisateur@votresociete.onmicrosoft.com`. Le site vous inscrit au programme `Visual Studio Dev Essentials`. Cliquez sur `Confirm` (Confirmer).

**Étape 3.** Dans la section `Downloads` (Téléchargements), sélectionnez `Visual Studio 2026`, édition `Professional`.

**Étape 4.** Cliquez sur `Download` (Télécharger). Un programme d'amorçage de petite taille est téléchargé.

**Note sur la licence.** La connexion avec un compte Dev Essentials active un essai d'environ 90 jours de l'édition Professional. Au-delà, une licence est requise. L'édition `Community` est une alternative gratuite pour les usages qui y sont éligibles, mais vérifiez les conditions de licence avant de la retenir en contexte professionnel.

### 2.2 Installer les charges de travail et les composants individuels

**Étape 1.** Double-cliquez sur l'exécutable téléchargé, puis cliquez sur `Continue` (Continuer).

**Étape 2.** Dans l'onglet `Workloads` (Charges de travail), cochez **`.NET desktop development`** (Développement .NET pour le bureau).

**Étape 3.** Basculez sur l'onglet `Individual components` (Composants individuels).

**Étape 4.** Recherchez `Modeling` et cochez **`Modeling SDK`** (Kit de développement de modélisation). Ce composant est obligatoire : il fournit l'infrastructure de modélisation sur laquelle reposent les concepteurs d'objets Dynamics 365.

**Étape 5.** Recherchez `DGML` et cochez **`DGML editor`** (Éditeur DGML). Ce composant est facultatif mais recommandé : il permet la visualisation des graphes de dépendances entre objets.

**Étape 6.** Vérifiez la présence de **`Microsoft SQL Server Express LocalDB`**, généralement installé par défaut avec la charge de travail .NET. Il héberge la base de références croisées utilisée par la navigation dans le code.

**Étape 7.** Contrôlez la synthèse dans le panneau de droite, puis cliquez sur `Install` (Installer).

**Étape 8.** L'installation prend de 30 minutes à plus d'une heure selon la connexion. À la fin, cliquez sur `Launch` (Lancer).

**Étape 9.** Cliquez sur `Sign in with Microsoft` (Se connecter avec Microsoft) et utilisez le compte du tenant.

**Étape 10.** Aucun projet n'existant encore, cliquez sur `Continue without code` (Continuer sans code).

### 2.3 Installer les extensions requises

Deux extensions issues de la place de marché sont nécessaires, en plus de l'extension Finance and Operations qui sera installée automatiquement en 2.5.

#### 2.3.1 Microsoft Reporting Services Projects

Cette extension fournit le concepteur d'états. Elle est requise dès lors qu'un modèle contient un état, ce qui arrive rapidement.

**Étape 1.** Dans la barre de menus, cliquez sur `Extensions` puis sur `Manage Extensions` (Gérer les extensions).

**Étape 2.** Recherchez `Microsoft Reporting Services Projects` et cliquez sur `Install` (Installer).

**Étape 3.** **Fermez Visual Studio**, puis double-cliquez sur le fichier `.vsix` téléchargé si l'installation ne démarre pas d'elle-même.

**Étape 4.** Cliquez sur `Install` (Installer) et attendez le message de confirmation.

**Note.** L'extension `Microsoft RDLC Report Designer` (Concepteur d'états RDLC) est également requise pour le développement d'états. Installez-la selon la même méthode si votre périmètre inclut la restitution.

#### 2.3.2 Power Platform Tools

Cette extension est **le pivot de l'expérience de développement unifiée**. C'est elle qui établit la connexion avec l'environnement cloud, télécharge les métadonnées de référence et installe l'extension Finance and Operations.

**Étape 1.** Rouvrez Visual Studio et retournez dans `Extensions` > `Manage Extensions` (Gérer les extensions).

**Étape 2.** Recherchez `Power Platform Tools` et cliquez sur `Install` (Installer).

**Étape 3.** Une bannière indique que les modifications sont planifiées et que Visual Studio doit être fermé.

**Étape 4.** Fermez Visual Studio. Un programme d'installation se lance. Cliquez sur `Modify` (Modifier).

**Étape 5.** Attendez le message de confirmation.

**Note.** L'installation du profileur de plug-ins, parfois proposée par cette extension, n'est pas nécessaire pour le développement X++.

### 2.4 Configurer les options Power Platform Tools

**Étape 1.** Rouvrez Visual Studio et choisissez `Continue without code` (Continuer sans code).

**Étape 2.** Ouvrez `Tools` (Outils) > `Options`, puis recherchez `Power Platform` dans la fenêtre.

**Étape 3.** Réglez les options suivantes :

| Option | Valeur | Effet |
| :-- | :-- | :-- |
| `Auto setup for Dynamics 365 Finance and Operations` (Configuration automatique) | Activée | Extrait automatiquement les métadonnées et crée la configuration, ce qui évite une longue configuration manuelle |
| `Do not display Power Platform Explorer on connect` (Ne pas afficher l'explorateur à la connexion) | Activée | Accélère sensiblement la connexion |
| `Download logs` (Télécharger les journaux) | Activée | Génère les journaux de déploiement et de synchronisation, précieux au dépannage |
| `Download Dynamics 365 FnO NuGets for CI/CD` (Télécharger les NuGets pour CI/CD) | Activée | Rend disponible la commande utilisée en phase 6 pour récupérer les packages de compilation |

**Étape 4.** Validez par `OK`.

**Note.** La dernière option n'a d'effet immédiat visible qu'en phase 6, mais l'activer maintenant évite un aller-retour dans les options.

### 2.5 Créer la solution et son éditeur dans le Power Platform

La connexion de Visual Studio à l'environnement, décrite à la section suivante, vous demandera de **choisir une solution**. Cette section crée celle que vous choisirez. La faire maintenant évite de se retrouver, au moment de la connexion, devant une liste où seule la solution `Default` (Par défaut) est proposée.

**Rôle requis.** `System customizer` (Personnalisateur système) ou `System administrator` (Administrateur système) dans l'environnement.

#### 2.5.1 Ce qu'est une solution, et pourquoi elle compte

Une **solution** est le conteneur de personnalisation du Power Platform. Elle regroupe les composants que vous créez ou modifiez dans un environnement, et constitue l'unité de transport entre environnements : c'est elle que l'on exporte d'un environnement de développement pour l'importer dans un environnement de recette puis de production.

Chaque solution est rattachée à un **éditeur**, ou `publisher`, qui porte un **préfixe**. Ce préfixe est automatiquement apposé au nom technique de tout composant Dataverse créé dans la solution, ce qui garantit qu'aucune collision de nom ne peut survenir entre votre travail, celui de Microsoft et celui d'un éditeur tiers.

**Ce que la solution fait et ne fait pas dans notre cas.** Le composant construit en phase 4 est un composant **X++**, et à ce titre il est porté par le **modèle** créé en phase 3, non par la solution Dataverse. La solution joue ici deux rôles :

1. Elle constitue le **contexte de travail de la connexion** entre Visual Studio et l'environnement. C'est ce contexte que l'assistant de connexion vous demande de désigner.
2. Elle devient le conteneur réel dès que votre périmètre déborde du X++ pur : table Dataverse, table virtuelle, application pilotée par modèle, flux, rôle de sécurité. Ce cas se présente très vite en projet.

**Pourquoi ne jamais retenir la solution `Default`.** La solution par défaut de l'environnement présente trois défauts rédhibitoires. Elle utilise l'éditeur par défaut de Dataverse, dont le préfixe est une chaîne aléatoire de la forme `cr8a3`, illisible et non maîtrisée. Elle ne peut pas être exportée proprement, ce qui interdit tout transport vers un autre environnement. Enfin, elle mélange les composants de toutes provenances, ce qui rend impossible de savoir ce qui appartient à votre projet. Y déposer des composants est une erreur difficile à réparer par la suite.

#### 2.5.2 Créer l'éditeur

**Étape 1.** Ouvrez le portail des créateurs Power Apps à l'adresse `https://make.powerapps.com`.

**Étape 2.** En haut à droite, vérifiez que **l'environnement sélectionné est bien votre environnement de développement**. Le sélecteur d'environnement est la source d'erreur la plus fréquente de cette section : créer la solution dans l'environnement par défaut du tenant, puis la chercher en vain depuis Visual Studio, est un grand classique.

**Étape 3.** Dans le volet de navigation de gauche, cliquez sur `Solutions` (Solutions). Si l'entrée n'est pas visible, cliquez d'abord sur `... More` (Plus).

**Étape 4.** Cliquez sur `New solution` (Nouvelle solution).

**Étape 5.** Dans le panneau qui s'ouvre, sous le champ `Publisher` (Éditeur), cliquez sur `New publisher` (Nouvel éditeur).

**Étape 6.** Renseignez le formulaire de l'éditeur :

| Champ | Valeur | Commentaire |
| :-- | :-- | :-- |
| `Display name` (Nom d'affichage) | `ARCHIA365` | Nom lisible de votre organisation |
| `Name` (Nom) | `ARCHIA365` | Nom technique, sans espace ni accent |
| `Description` | Texte libre | Facultatif mais recommandé |
| `Prefix` (Préfixe) | `arc` | Deux à huit caractères alphanumériques, commençant par une lettre |
| `Choice value prefix` (Préfixe de valeur de choix) | Valeur proposée automatiquement | À conserver telle quelle |

**Point de vigilance sur le préfixe.** Choisissez-le avec soin : il sera apposé au nom technique de chaque composant Dataverse créé dans les solutions de cet éditeur, et le modifier après coup impose de recréer les composants concernés. Retenez un préfixe court, en minuscules, identifiant sans ambiguïté votre organisation. La valeur `_upgrade` est réservée par la plateforme et ne peut pas être utilisée.

**Cohérence avec le monde X++.** Le préfixe de l'éditeur Dataverse et le préfixe de nommage X++ défini en annexe C sont deux mécanismes distincts, mais il est fortement recommandé de les aligner. Un préfixe `arc` côté Dataverse et un préfixe `Arc` côté X++ donnent une lecture immédiate de l'origine de chaque objet, quel que soit le monde dans lequel on se trouve.

**Étape 7.** Cliquez sur `Save` (Enregistrer). Vous revenez au formulaire de création de la solution, l'éditeur étant désormais sélectionné.

#### 2.5.3 Créer la solution

**Étape 1.** Renseignez le formulaire de la solution :

| Champ | Valeur | Commentaire |
| :-- | :-- | :-- |
| `Display name` (Nom d'affichage) | `ARC Revue de credit client` | Nom lisible, modifiable ultérieurement |
| `Name` (Nom) | `ARCRevueCreditClient` | Nom technique, lettres, chiffres et tirets bas uniquement. **Non modifiable après enregistrement** |
| `Publisher` (Éditeur) | `ARCHIA365`, créé en 2.5.2 | |
| `Version` | `1.0.0.0` | Figure dans le nom du fichier lors d'un export |
| `Set as your preferred solution` (Définir comme solution préférée) | Coché | Les composants créés hors contexte de solution atterrissent alors ici plutôt que dans `Default` |

**Point de vigilance.** Le champ `Name` ne peut plus être modifié après enregistrement, contrairement au `Display name`. Prenez le temps de le formuler correctement.

**Étape 2.** Dépliez `More options` (Plus d'options) et renseignez la `Description`, par exemple : `Ajout de la date de revue du credit sur la fiche client. Auteur ARCHIA365.`

**Étape 3.** Cliquez sur `Create` (Créer).

**Étape 4.** La solution apparaît dans la liste des solutions de l'environnement. Ouvrez-la : elle est vide, ce qui est normal à ce stade.

#### 2.5.4 Ce que contiendra cette solution

Le périmètre retenu pour ce guide est volontairement minimal, conformément au principe énoncé en 1.3 : **ajouter un champ à une table existante et simple**, en l'occurrence la table des clients.

| Élément | Où il vit réellement | Pourquoi |
| :-- | :-- | :-- |
| Le champ `ArcCreditReviewDate` sur la table client | Modèle X++ `ArchiaExtensions`, via une extension de table | Il s'agit d'une extension de la table `CustTable` de Finance and Operations, portée par le modèle et livrée par le package |
| Le type de données étendu, les libellés, l'extension de formulaire, la classe de validation | Modèle X++ `ArchiaExtensions` | Objets X++ purs |
| La solution `ARC Revue de credit client` | Dataverse | Contexte de la connexion, et conteneur de tout composant Dataverse qui viendrait compléter le dispositif |

**À quoi ressemblerait un débordement vers Dataverse.** Si, dans un second temps, vous souhaitiez exposer cette date de revue à une application pilotée par modèle, à un flux d'alerte, ou à un tableau de bord, les composants correspondants seraient créés dans cette solution. C'est précisément pour cette raison que la créer proprement dès le départ, plutôt que de s'appuyer sur `Default`, évite une reprise ultérieure.

#### 2.5.5 Checklist de la section

- [ ] L'environnement sélectionné dans le portail des créateurs est le bon.
- [ ] L'éditeur `ARCHIA365` est créé, avec un préfixe maîtrisé.
- [ ] La solution est créée et rattachée à cet éditeur.
- [ ] Le nom technique de la solution est correct, sachant qu'il n'est plus modifiable.
- [ ] La solution est définie comme solution préférée.
- [ ] La solution apparaît dans la liste des solutions de l'environnement.

### 2.6 Se connecter à l'environnement et télécharger les métadonnées

**Rôle requis.** `System administrator` (Administrateur système) dans l'environnement.

**Étape 1.** Munissez-vous de l'**`Environment URL`** de votre environnement, relevée dans le Power Platform Admin Center sur la page `Overview` (Vue d'ensemble) de l'environnement.

**Point de vigilance.** Deux adresses figurent sur cette page. Celle qui vous intéresse est l'adresse **Dataverse**, de la forme `https://<nom>.crm4.dynamics.com`, et non l'adresse de l'application, de la forme `https://<nom>.sandbox.operations.dynamics.com`. Utiliser la seconde produit une liste d'environnements vide, sans message explicite.

**Étape 2.** Dans Visual Studio, ouvrez `Tools` (Outils) > `Connect to Dataverse` (Se connecter à Dataverse). Selon la version de l'extension, ce libellé peut apparaître sous la forme `Connect to Database` (Se connecter à la base de données).

**Étape 3.** Sélectionnez `Office 365`, puis cochez l'option permettant de saisir manuellement l'adresse de l'organisation.

**Note sur l'authentification multifacteur.** Si votre compte est protégé par MFA, décochez au contraire toutes les cases de l'écran de connexion. Visual Studio ouvre alors le navigateur pour un flux interactif compatible.

**Étape 4.** Cliquez sur `Login` (Se connecter), collez l'`Environment URL`, puis validez par `OK`.

**Étape 5.** Sélectionnez votre environnement dans la liste, puis cliquez sur `Login` (Se connecter).

**Étape 6.** Une solution vous est demandée. Sélectionnez **`ARC Revue de credit client`**, créée en 2.5.

**Point de vigilance.** **Ne choisissez jamais la solution `Default`** (Par défaut), pour les trois raisons exposées en 2.5.1 : préfixe aléatoire, impossibilité d'export propre, et mélange des composants de toutes provenances. Si votre solution n'apparaît pas dans la liste, c'est presque toujours qu'elle a été créée dans un autre environnement que celui auquel Visual Studio est connecté. Retournez sur `https://make.powerapps.com`, vérifiez le sélecteur d'environnement en haut à droite, et recréez la solution dans le bon environnement.

**Étape 7.** À la première connexion, Visual Studio détecte l'absence des métadonnées de référence et propose de les télécharger. Cliquez sur `Yes` (Oui).

**Étape 8.** Le téléchargement démarre. Suivez sa progression dans `View` (Affichage) > `Output` (Sortie), en sélectionnant la source `FinOps Cloud Runtime` dans la liste déroulante.

**Étape 9.** À la fin du téléchargement, un programme d'installation se lance et installe l'extension Finance and Operations correspondant à la version de plateforme de votre environnement. Cliquez sur `Install` (Installer).

**Étape 10.** Redémarrez Visual Studio. À la première ouverture, acceptez les demandes d'élévation de privilèges relatives à l'enregistrement du gestionnaire de protocole, à la mise en place des cibles de génération et à l'extraction des fichiers du compilateur.

**Étape 11.** Vérification. Le dossier suivant doit contenir environ 24 Go de fichiers :

```
C:\Users\<VotreUtilisateur>\AppData\Local\Microsoft\Dynamics365\<VersionApplication>
```

Un volume nettement inférieur signale un téléchargement incomplet. Dans ce cas, exécutez `Tools` (Outils) > `Download Dynamics 365 assets` (Télécharger les assets Dynamics 365), qui purge le dossier et relance le téléchargement intégralement.

### 2.7 Vérifier la configuration des métadonnées

L'option `Auto setup` ayant été activée en 2.4, la configuration a normalement été créée automatiquement. Cette section vérifie qu'elle est correcte, et explique comment la créer à la main si nécessaire.

**Étape 1.** Ouvrez `Extensions` > `Dynamics 365` > `Configure Metadata` (Configurer les métadonnées).

**Étape 2.** Une configuration doit exister. Vérifiez ses champs :

| Champ | Valeur attendue |
| :-- | :-- |
| `Cross reference database server` (Serveur de la base de références croisées) | `(localdb)\.` |
| `Cross reference database name` (Nom de la base de références croisées) | `DYNAMICSXREFDB` |
| `Application version to restore cross reference database from` (Version d'application source) | La version téléchargée en 2.6 |
| `Folders for reference metadata` (Dossiers des métadonnées de référence) | Le dossier `PackagesLocalDirectory` décompressé |
| `Folder for your own custom metadata` (Dossier de vos métadonnées personnalisées) | Un dossier dédié, que vous repointerez en phase 2 vers l'intérieur du dépôt Git |

**Étape 3.** Vérification déterminante. Ouvrez `View` (Affichage) > `Application Explorer` (Explorateur d'applications). L'arborescence complète des objets de l'application standard doit s'afficher. C'est la preuve que les métadonnées de référence sont correctement chargées et indexées.

**Si le bouton `Save` reste grisé**, un champ est invalide. Il apparaît encadré en rouge et une infobulle en précise la cause. La valeur `(localdb)\.` doit être saisie exactement ainsi, point final compris. Si la connexion à LocalDB échoue, ouvrez une invite de commandes et exécutez :

```
sqllocaldb create MSSQLLocalDB -s
```

### 2.8 Checklist de validation de la phase 1

- [ ] Visual Studio 2026 Professional est installé et activé.
- [ ] La charge de travail `.NET desktop development` est présente.
- [ ] Les composants `Modeling SDK` et `DGML editor` sont présents.
- [ ] `Microsoft SQL Server Express LocalDB` est installé.
- [ ] L'extension `Microsoft Reporting Services Projects` est installée.
- [ ] L'extension `Power Platform Tools` est installée.
- [ ] Les quatre options `Power Platform` sont réglées.
- [ ] L'éditeur `ARCHIA365` est créé, avec un préfixe maîtrisé.
- [ ] La solution est créée dans le bon environnement, rattachée à cet éditeur.
- [ ] La solution est définie comme solution préférée.
- [ ] La connexion à l'environnement aboutit, sur **votre** solution et non sur `Default`.
- [ ] Le dossier des assets contient environ 24 Go de fichiers.
- [ ] L'extension Finance and Operations est installée.
- [ ] Le menu `Dynamics 365` est visible dans Visual Studio.
- [ ] L'`Application Explorer` s'ouvre et affiche l'arborescence standard.

## 3. Phase 2 : Azure DevOps, organisation, projet et dépôt Git

**Objectif de la phase.** Disposer d'un dépôt Git structuré de telle sorte que le pipeline de la phase 6 puisse le compiler sans adaptation.

**Rôles requis.** Aucun pour créer l'organisation. `Project Collection Administrators` (Administrateurs de collection de projets) pour créer le projet. `Contributors` (Contributeurs) avec un niveau d'accès `Basic` (De base) pour publier du code.

### 3.1 Pourquoi le dépôt avant le code

Il est tentant de développer d'abord et de versionner ensuite. C'est une erreur de séquence, pour une raison simple : dans l'expérience de développement unifiée, **l'emplacement physique de vos métadonnées détermine ce qui est versionné**. Git ne dispose pas du mécanisme de mapping qui existait dans les systèmes centralisés. Vos modèles doivent donc résider à l'intérieur du dépôt cloné, ce qui suppose que le dépôt existe avant qu'ils ne soient créés.

Créer le dépôt en second oblige à déplacer les fichiers, à repointer la configuration des métadonnées et à actualiser les modèles. C'est faisable, mais c'est une source d'erreurs évitable.

### 3.2 Créer l'organisation Azure DevOps

**Étape 1.** Ouvrez `https://dev.azure.com`, connecté avec le compte du tenant.

**Point de vigilance.** L'organisation doit être **connectée à l'annuaire Microsoft Entra ID du tenant**. C'est une condition obligatoire du Managed DevOps Pool mis en place en phase 6. Une organisation créée avec une identité personnelle ne satisfait pas cette condition et devra être recréée.

**Étape 2.** Cliquez sur `Start free` (Commencer gratuitement) ou `New organization` (Nouvelle organisation).

**Étape 3.** Renseignez le nom, par exemple `archia365-d365fo`, et l'emplacement d'hébergement, par exemple `West Europe`.

**Étape 4.** Vérification. Ouvrez `Organization settings` (Paramètres de l'organisation) > `Microsoft Entra`. L'annuaire de votre tenant doit y figurer.

### 3.3 Créer le projet d'équipe

**Étape 1.** Cliquez sur `New project` (Nouveau projet).

**Étape 2.** Renseignez :

| Champ | Valeur |
| :-- | :-- |
| `Project name` (Nom du projet) | `D365FO-DEV`, sans espace ni accent |
| `Visibility` (Visibilité) | `Private` (Privé) |
| `Version control` (Contrôle de version), sous `Advanced` | `Git`, valeur par défaut |
| `Work item process` (Processus des éléments de travail) | `Agile`, sans incidence technique |

**Étape 3.** Cliquez sur `Create` (Créer), puis notez l'adresse du dépôt, de la forme `https://dev.azure.com/<organisation>/<projet>/_git/<projet>`.

### 3.4 La structure de dépôt attendue

Cette structure n'est pas une convention esthétique : c'est celle que le pipeline de la phase 6 attend, chaque chemin du fichier YAML y faisant référence.

```
D365FO-DEV
  BuildPipeline
    nuget.config
    packages.config
    ci-build.yml
  XppMetadata
  VS_Solutions
  DataverseSolutions
  .gitignore
  README.md
```

| Dossier | Contenu | Rôle dans le pipeline |
| :-- | :-- | :-- |
| `BuildPipeline` | Fichiers de configuration NuGet et fichier YAML | Indique à l'agent quels packages installer et depuis quelle source |
| `XppMetadata` | Vos modèles et packages X++, fichiers descripteurs compris | Répertoire de métadonnées passé au compilateur |
| `VS_Solutions` | Fichiers de solution `.sln` et de projet `.rnrproj` | Cible de la compilation |
| `DataverseSolutions` | Optionnel, solutions Dataverse exportées au format `.zip` | Ajoutées au package unifié si présentes |

**Point de vigilance majeur.** Ne placez **jamais** le dossier `PackagesLocalDirectory` sous contrôle de source. Il contient les métadonnées de référence de Microsoft, soit environ 24 Go que vous ne modifiez pas et que le poste retélécharge à la demande. L'agent de build n'en a pas besoin non plus : il obtient ses références par les packages NuGet de compilation.

### 3.5 Cloner le dépôt et repointer la configuration

**Étape 1.** Dans Visual Studio, ouvrez `Git` > `Clone Repository` (Cloner un dépôt).

**Étape 2.** Saisissez l'adresse relevée en 3.3 et choisissez un dossier local **court**, par exemple `C:\D365\Repos\D365FO-DEV`.

**Point de vigilance.** Les chemins X++ sont longs. Un dossier de clonage profond expose à la limite de longueur de chemin de Windows, avec des erreurs de compilation difficiles à diagnostiquer. Restez proche de la racine du disque.

**Étape 3.** Cliquez sur `Clone` (Cloner).

**Étape 4.** Créez à la main les quatre dossiers de la structure décrite en 3.4, à la racine du dépôt cloné.

**Étape 5.** Ouvrez `Extensions` > `Dynamics 365` > `Configure Metadata` (Configurer les métadonnées) et modifiez le champ `Folder for your own custom metadata` (Dossier de vos métadonnées personnalisées) pour le faire pointer sur :

```
C:\D365\Repos\D365FO-DEV\XppMetadata
```

**Étape 6.** Enregistrez, puis redémarrez Visual Studio.

**Vérification déterminante.** Le chemin déclaré dans `Configure Metadata` et le chemin réel de vos modèles doivent être identiques. Une divergence produit une situation trompeuse : le dépôt se remplit normalement, mais il ne contient pas le code que Visual Studio compile, et le pipeline compilera une version obsolète.

### 3.6 Créer le fichier .gitignore

**Étape 1.** Créez un fichier nommé `.gitignore` à la racine du dépôt.

**Étape 2.** Renseignez-le comme suit :

```
# Sorties de compilation
[Bb]in/
[Oo]bj/
[Dd]ebug/
[Rr]elease/
*.dll
*.pdb
*.netmodule

# Fichiers temporaires Visual Studio
.vs/
*.user
*.suo

# Packages NuGet restaures localement
NuGets/
packages/

# Metadonnees de reference Microsoft, jamais versionnees
PackagesLocalDirectory/

# Secrets
*.env
appsettings.*.json
```

**Note.** L'exclusion de `*.dll` vise les sorties de compilation. Si votre modèle référence des bibliothèques tierces livrées sous forme de fichiers `.dll` qui doivent être versionnées, ajoutez une exception explicite pour leur dossier, au moyen d'une ligne commençant par un point d'exclamation.

### 3.7 Checklist de validation de la phase 2

- [ ] L'organisation Azure DevOps est créée avec l'identité du tenant.
- [ ] L'organisation est connectée à Microsoft Entra ID.
- [ ] Le projet est créé en visibilité `Private`, avec un dépôt `Git`.
- [ ] Le dépôt est cloné dans un chemin court.
- [ ] Les quatre dossiers de la structure existent.
- [ ] `Configure Metadata` pointe sur `XppMetadata` à l'intérieur du dépôt.
- [ ] Le fichier `.gitignore` est en place.

## 4. Phase 3 : Modèle, package et projet

**Objectif de la phase.** Créer les conteneurs qui accueilleront votre code.

**Rôles requis.** Administrateur local du poste.

### 4.1 Comprendre la hiérarchie des conteneurs

Trois niveaux d'emboîtement structurent tout développement X++. Les confondre est la source de confusion la plus fréquente chez les débutants.

| Niveau | Nature | Rôle |
| :-- | :-- | :-- |
| **Package** | Unité de déploiement | Ce qui est compilé, livré et installé sur un environnement. C'est le grain de la livraison. |
| **Modèle** (`model`) | Unité logique de personnalisation | Regroupe des objets appartenant à un même périmètre fonctionnel. Un package peut contenir plusieurs modèles. |
| **Projet** (`project`) | Unité de travail Visual Studio | Vue de travail sur un sous-ensemble d'objets. Il n'a aucune existence à l'exécution. |

**Analogie utile.** Le package est le carton d'expédition, le modèle est le produit qu'il contient, le projet est la liste de courses du développeur. Supprimer un projet ne supprime aucun objet ; supprimer un modèle supprime tous les objets qu'il contient.

### 4.2 Créer le modèle et son package

**Étape 1.** Ouvrez `Extensions` > `Dynamics 365` > `Model Management` (Gestion des modèles) > `Create model` (Créer un modèle).

**Étape 2.** Renseignez :

| Champ | Valeur |
| :-- | :-- |
| `Model name` (Nom du modèle) | `ArchiaExtensions` |
| `Model publisher` (Éditeur du modèle) | `ARCHIA365` |
| `Layer` (Couche) | `ISV` ou `VAR` selon votre statut, `USR` pour un travail purement local |
| `Version` | Valeur par défaut |
| `Description` | Texte libre décrivant le périmètre fonctionnel |

Cliquez sur `Next` (Suivant).

**Étape 3.** Sélectionnez **`Create new package`** (Créer un package), puis `Next` (Suivant).

**Pourquoi un package dédié.** Un package dédié rend votre modèle indépendant : il peut être compilé, déployé et désinstallé isolément. Placer un modèle dans un package existant crée une adhérence forte entre les deux, à réserver à des cas particuliers.

**Étape 4.** Sélectionnez les **packages de référence**, c'est-à-dire ceux dont votre code va dépendre. Pour le composant de ce guide, trois suffisent :

- `ApplicationFoundation`
- `ApplicationPlatform`
- `ApplicationSuite`

**Pourquoi ces trois.** `ApplicationPlatform` fournit l'infrastructure technique, `ApplicationFoundation` les objets transverses tels que la gestion des adresses et des dimensions, et `ApplicationSuite` les objets métier, dont la table `CustTable` que nous allons étendre. Sans cette dernière référence, l'extension de `CustTable` serait impossible.

**Note.** Des références peuvent être ajoutées ultérieurement via `Model Management` > `Update model parameters` (Mettre à jour les paramètres du modèle). Ajouter une référence est simple, en retirer une l'est beaucoup moins.

**Étape 5.** Un écran de synthèse s'affiche, avec la case `Create new project` (Créer un projet) cochée par défaut. Validez.

### 4.3 Créer le projet

**Étape 1.** Saisissez le nom du projet, par exemple `ArcCreditReview`.

**Étape 2.** Indiquez son emplacement : **à l'intérieur du dépôt cloné**, soit `C:\D365\Repos\D365FO-DEV\VS_Solutions`.

**Étape 3.** Cochez `Create directory for solution` (Créer un répertoire pour la solution) et nommez la solution `ArchiaExtensions`.

**Étape 4.** Cliquez sur `Create` (Créer).

**Étape 5.** Vérification de la structure sur disque :

| Élément | Emplacement attendu |
| :-- | :-- |
| Métadonnées du modèle | `C:\D365\Repos\D365FO-DEV\XppMetadata\ArchiaExtensions` |
| Fichier descripteur du modèle | `...\XppMetadata\ArchiaExtensions\Descriptor\ArchiaExtensions.xml` |
| Solution et projet | `C:\D365\Repos\D365FO-DEV\VS_Solutions\ArchiaExtensions` |

**Point de vigilance.** Le **fichier descripteur** est le fichier XML qui déclare l'existence du modèle, ses références et sa version. Il doit impérativement être versionné. Son absence dans le dépôt provoque, côté pipeline, un échec de compilation au message peu explicite, et côté collègue, la récupération d'objets orphelins que Visual Studio ne rattache à aucun modèle.

### 4.4 Premier commit

**Étape 1.** Ouvrez `View` (Affichage) > `Git Changes` (Modifications Git).

**Étape 2.** Vérifiez la liste des fichiers détectés. Contrôlez que `PackagesLocalDirectory` n'y figure pas, et que le dossier `Descriptor` y figure bien.

**Étape 3.** Saisissez un message de commit, par exemple `Initialisation du modele ArchiaExtensions et de la solution`.

**Étape 4.** Cliquez sur `Commit All` (Valider tout), puis sur `Push` (Envoyer).

**Étape 5.** Vérification dans le portail Azure DevOps, sous `Repos` (Dépôts) > `Files` (Fichiers).

### 4.5 Checklist de validation de la phase 3

- [ ] Le modèle `ArchiaExtensions` est créé, avec un package dédié.
- [ ] Les trois packages de référence sont déclarés.
- [ ] Le projet est créé dans `VS_Solutions`, à l'intérieur du dépôt.
- [ ] Les métadonnées du modèle sont dans `XppMetadata`, à l'intérieur du dépôt.
- [ ] Le fichier descripteur existe et est versionné.
- [ ] Le premier commit est publié et visible dans le portail.

## 5. Phase 4 : Développement du composant

**Objectif de la phase.** Construire, dans l'ordre, les cinq objets du composant décrit en 1.3, puis le déployer et le tester.

**Rôles requis.** Administrateur local du poste pour le développement. `System administrator` (Administrateur système) dans l'environnement pour le déploiement et la synchronisation de la base.

### 5.1 Spécification et ordre de construction

**Rappel du besoin.** Consigner sur chaque client la date de la prochaine revue de son encours, l'afficher sur la fiche client, et refuser une date antérieure à la date du jour.

**Ordre de construction, et pourquoi cet ordre.** Les objets X++ s'appuient les uns sur les autres. Les construire dans le désordre oblige à revenir en arrière.

| Ordre | Objet | Dépend de |
| :-- | :-- | :-- |
| 1 | Fichier de libellés `ArcLabels` | Rien |
| 2 | Type de données étendu `ArcCreditReviewDate` | Le fichier de libellés |
| 3 | Extension de table `CustTable` | Le type de données étendu |
| 4 | Extension de formulaire `CustTable` | L'extension de table |
| 5 | Classe d'extension `ArcCustTable_Extension` | L'extension de table |

### 5.2 Étape 1 : le fichier de libellés

Un **libellé** est une chaîne de caractères traduisible, identifiée par une clé. En X++, aucun texte visible par l'utilisateur ne doit être écrit en dur : tout passe par un libellé, ce qui permet la traduction et la reprise centralisée des formulations.

**Étape 1.** Dans le `Solution Explorer` (Explorateur de solutions), faites un clic droit sur le projet, puis `Add` (Ajouter) > `New Item` (Nouvel élément).

**Étape 2.** Dans la catégorie `Labels and Resources` (Libellés et ressources), sélectionnez `Label File` (Fichier de libellés).

**Étape 3.** Nommez-le `ArcLabels` et cliquez sur `Add` (Ajouter).

**Étape 4.** Un assistant s'ouvre. Sélectionnez la langue `en-US` comme langue de base, puis ajoutez `fr` si vous souhaitez fournir la traduction française. Validez.

**Étape 5.** L'éditeur de libellés s'ouvre. Créez trois libellés :

| Identifiant du libellé | Libellé en-US | Libellé fr |
| :-- | :-- | :-- |
| `CreditReviewDate` | `Credit review date` | `Date de revue du crédit` |
| `CreditReviewDateHelp` | `Date of the next scheduled review of the customer credit limit.` | `Date de la prochaine revue planifiée de la limite de crédit du client.` |
| `CreditReviewDateInPast` | `The credit review date cannot be earlier than today.` | `La date de revue du crédit ne peut pas être antérieure à la date du jour.` |

**Étape 6.** Enregistrez le fichier.

**Comment référencer un libellé.** La syntaxe est `@<IdentifiantDuFichier>:<IdentifiantDuLibellé>`. Ici, le libellé du champ s'écrira donc :

```
@ArcLabels:CreditReviewDate
```

**Point de vigilance.** L'identifiant du fichier de libellés est celui saisi à l'étape 3, et non le nom du modèle. Une erreur ici produit un affichage littéral de la chaîne de référence à l'écran, ce qui est immédiatement visible au test.

### 5.3 Étape 2 : le type de données étendu

Un **type de données étendu**, ou EDT pour `Extended Data Type`, est un type nommé qui porte son libellé, son aide, son format et sa longueur. Utiliser un EDT plutôt qu'un type primitif permet de définir ces propriétés une seule fois et de les réutiliser partout.

**Étape 1.** Clic droit sur le projet, `Add` (Ajouter) > `New Item` (Nouvel élément).

**Étape 2.** Dans la catégorie `Data Types` (Types de données), sélectionnez `Extended Data Type Date` (Type de données étendu Date).

**Étape 3.** Nommez-le `ArcCreditReviewDate` et cliquez sur `Add` (Ajouter).

**Étape 4.** Dans la fenêtre `Properties` (Propriétés), renseignez :

| Propriété | Valeur |
| :-- | :-- |
| `Extends` (Étend) | `TransDate` |
| `Label` (Libellé) | `@ArcLabels:CreditReviewDate` |
| `Help Text` (Texte d'aide) | `@ArcLabels:CreditReviewDateHelp` |

**Pourquoi étendre `TransDate`.** `TransDate` est l'EDT standard des dates de transaction. En l'étendant, votre type hérite du format d'affichage et du comportement attendus par les utilisateurs, sans que vous ayez à les redéfinir.

**Étape 5.** Enregistrez.

### 5.4 Étape 3 : l'extension de la table CustTable

**Étape 1.** Ouvrez `View` (Affichage) > `Application Explorer` (Explorateur d'applications).

**Étape 2.** Dépliez `Data Model` (Modèle de données) > `Tables`, puis recherchez `CustTable`. La barre de recherche de l'explorateur accélère considérablement cette étape.

**Étape 3.** Faites un clic droit sur `CustTable`, puis choisissez **`Create extension in the current project`** (Créer une extension dans le projet courant).

**Point de méthode.** Deux entrées voisines existent dans ce menu contextuel : `Create extension` et `Create extension in the current project`. La seconde ajoute directement l'objet créé à votre projet, ce qui évite un oubli fréquent. L'extension est nommée automatiquement selon le motif `CustTable.<NomDuModèle>`, ce qui garantit son unicité entre éditeurs.

**Étape 4.** L'extension s'ouvre dans le concepteur. Faites un clic droit sur le nœud `Fields` (Champs), puis `New` (Nouveau) > `Date`.

**Étape 5.** Sélectionnez le champ créé et renseignez ses propriétés :

| Propriété | Valeur |
| :-- | :-- |
| `Name` (Nom) | `ArcCreditReviewDate` |
| `Extended Data Type` (Type de données étendu) | `ArcCreditReviewDate` |
| `Label` (Libellé) | Laisser vide, le libellé est hérité de l'EDT |

**Pourquoi laisser le libellé vide.** L'héritage depuis l'EDT est le comportement souhaité : si le libellé doit changer, il suffira de le modifier à un seul endroit. Renseigner le libellé au niveau du champ rompt cet héritage.

**Étape 6.** Ajoutez le champ à un groupe de champs, ce qui facilitera son placement sur le formulaire. Dépliez `Field Groups` (Groupes de champs), repérez le groupe `Credit`, faites un clic droit dessus puis `New` (Nouveau) > `Field Group Extension` si nécessaire, et faites glisser votre champ depuis le nœud `Fields`.

**Note.** Si l'extension du groupe standard s'avère délicate sur votre version, l'alternative consiste à poser directement le champ sur le formulaire en 5.5. Le résultat visible est identique ; passer par le groupe de champs est simplement plus maintenable.

**Étape 7.** Enregistrez.

### 5.5 Étape 4 : l'extension du formulaire CustTable

**Étape 1.** Dans l'`Application Explorer`, dépliez `User Interface` (Interface utilisateur) > `Forms` (Formulaires) et recherchez `CustTable`.

**Étape 2.** Clic droit, puis `Create extension in the current project` (Créer une extension dans le projet courant).

**Étape 3.** Le concepteur de formulaire s'ouvre. Dépliez `Design` (Conception) jusqu'à atteindre l'onglet consacré au crédit, généralement nommé `TabCredit` ou équivalent selon la version.

**Étape 4.** Faites un clic droit sur le groupe qui vous intéresse, puis `New` (Nouveau) > `Date`, afin d'ajouter un contrôle de type date.

**Étape 5.** Sélectionnez le contrôle et renseignez ses propriétés :

| Propriété | Valeur |
| :-- | :-- |
| `Name` (Nom) | `ArcCreditReviewDate` |
| `Data Source` (Source de données) | `CustTable` |
| `Data Field` (Champ de données) | `ArcCreditReviewDate` |

**Étape 6.** Enregistrez.

**Point de vigilance.** Sur une extension de formulaire, vous ne pouvez ajouter que des contrôles et des gestionnaires d'événements. Vous ne pouvez ni supprimer ni renommer un contrôle standard. Cette limitation est volontaire : elle garantit que les mises à jour Microsoft ne casseront pas votre extension.

### 5.6 Étape 5 : la logique de validation en Chain of Command

La **Chain of Command**, abrégée CoC, est le mécanisme qui permet d'intercaler votre code dans l'exécution d'une méthode standard, sans modifier cette méthode. Votre code s'exécute avant, après, ou autour de l'appel d'origine, matérialisé par le mot-clé `next`.

**Étape 1.** Clic droit sur le projet, `Add` (Ajouter) > `New Item` (Nouvel élément).

**Étape 2.** Dans la catégorie `Dynamics 365 Items` (Éléments Dynamics 365), sélectionnez `Class` (Classe).

**Étape 3.** Nommez-la `ArcCustTable_Extension` et cliquez sur `Add` (Ajouter).

**Point de vigilance sur le nommage.** Le suffixe `_Extension` est **obligatoire** pour une classe d'extension. Sans lui, le compilateur refuse l'attribut `ExtensionOf` avec un message qui ne pointe pas explicitement vers la cause.

**Étape 4.** Remplacez le contenu du fichier par le code suivant :

```xpp
using System;

/// <summary>
/// Extension de la table CustTable pour la gestion de la date de revue du credit.
/// Auteur : ARCHIA365
/// </summary>
[ExtensionOf(tableStr(CustTable))]
final class ArcCustTable_Extension
{
    /// <summary>
    /// Valide l'enregistrement du client.
    /// Refuse une date de revue du credit anterieure a la date du jour.
    /// </summary>
    /// <returns>true si l'enregistrement est valide, false sinon.</returns>
    public boolean validateWrite()
    {
        boolean ret = next validateWrite();

        if (ret && this.ArcCreditReviewDate)
        {
            if (this.ArcCreditReviewDate < systemDateGet())
            {
                ret = checkFailed("@ArcLabels:CreditReviewDateInPast");
            }
        }

        return ret;
    }
}
```

**Lecture ligne à ligne du code.**

| Élément | Signification |
| :-- | :-- |
| `[ExtensionOf(tableStr(CustTable))]` | Déclare que cette classe étend la table `CustTable`. La fonction `tableStr` produit une référence vérifiée à la compilation, ce qui évite les fautes de frappe silencieuses. |
| `final class` | Une classe d'extension doit être `final`. Elle ne peut pas être héritée. |
| `next validateWrite()` | Appelle la méthode d'origine, ainsi que les éventuelles extensions d'autres éditeurs. **Omettre cet appel casse la chaîne** et neutralise la validation standard, ce qui est une faute grave. |
| `this.ArcCreditReviewDate` | Accède au champ ajouté en 5.4. Le mot-clé `this` désigne l'enregistrement courant de `CustTable`. |
| `if (ret && this.ArcCreditReviewDate)` | Ne valide que si le standard a déjà accepté l'enregistrement, et que si le champ est renseigné. Une date vide est une valeur légitime. |
| `systemDateGet()` | Retourne la date de session de l'utilisateur, et non la date du serveur. C'est la fonction correcte pour toute comparaison métier avec la date du jour. |
| `checkFailed("@ArcLabels:...")` | Affiche le message d'erreur à l'utilisateur et **retourne toujours `false`**, ce qui bloque l'enregistrement. Le libellé est référencé, jamais écrit en dur. |

**Trois règles à retenir de cet exemple.**

1. **Appelez toujours `next`.** Une extension qui omet cet appel supprime le comportement standard et celui des autres extensions. C'est la première cause de régression en environnement multi-éditeurs.
2. **Vérifiez le retour du standard avant d'ajouter vos contrôles.** Si le standard a déjà refusé l'enregistrement, il est inutile d'empiler un second message d'erreur.
3. **Ne jamais écrire de texte en dur.** `checkFailed("La date est invalide")` compile parfaitement, mais rend la traduction impossible et sera refusé en revue de code.

**Étape 5.** Enregistrez.

### 5.7 Étape 6 : générer et déployer

**Étape 1.** Faites un clic droit sur le projet, puis `Build` (Générer).

**Étape 2.** Ouvrez `View` (Affichage) > `Error List` (Liste d'erreurs) et corrigez les éventuelles erreurs jusqu'à obtenir une génération sans erreur.

**Erreurs les plus fréquentes à ce stade :**

| Message | Cause | Correction |
| :-- | :-- | :-- |
| Type `CustTable` introuvable | Le package `ApplicationSuite` n'est pas référencé | `Model Management` > `Update model parameters`, ajoutez la référence |
| Le champ `ArcCreditReviewDate` n'existe pas | Extension de table non enregistrée, ou nom différent | Vérifiez le nom exact dans le concepteur d'extension de table |
| Attribut `ExtensionOf` non valide | Suffixe `_Extension` manquant sur le nom de la classe | Renommez la classe |
| Libellé affiché littéralement | Identifiant du fichier de libellés erroné | Comparez avec le nom du fichier créé en 5.2 |

**Étape 3.** Déployez le modèle sur l'environnement cloud. Ouvrez `Extensions` > `Dynamics 365` > `Deploy` (Déployer), puis choisissez le déploiement du modèle, en cochant l'option de synchronisation de la base de données.

**Pourquoi la synchronisation est obligatoire ici.** Vous avez ajouté un **champ**, donc modifié le schéma de la table. Tant que la base n'est pas synchronisée, la colonne n'existe pas physiquement et le formulaire produit une erreur à l'ouverture. La synchronisation n'est nécessaire que lorsque la structure de données change ; une modification purement algorithmique n'en a pas besoin.

**Étape 4.** Suivez la progression dans `View` (Affichage) > `Output` (Sortie), en sélectionnant la source `FinOps Cloud Runtime`. Comptez de dix à trente minutes selon la taille du modèle et la charge de l'environnement.

**Variantes de déploiement disponibles.**

| Commande | Emplacement | Usage |
| :-- | :-- | :-- |
| `Deploy model for project` (Déployer le modèle du projet) | Clic droit sur le projet | Déploiement ciblé, le plus rapide au quotidien |
| `Build models` (Générer les modèles) avec l'option de déploiement | `Dynamics 365` | Génération complète suivie du déploiement |
| `Synchronize database` (Synchroniser la base de données) | `Dynamics 365` | Synchronisation seule, sans redéploiement |
| `Deploy changes to online environment` (Déployer les modifications) | Propriété du projet dans le `Solution Explorer` | Déploiement incrémental automatique à chaque génération |

### 5.8 Étape 7 : tester dans l'application

**Étape 1.** Ouvrez l'application Finance and Operations dans le navigateur, à l'adresse de la forme `https://<nom>.sandbox.operations.dynamics.com`.

**Étape 2.** Naviguez vers `Accounts receivable` (Comptabilité client) > `Customers` (Clients) > `All customers` (Tous les clients).

**Étape 3.** Ouvrez un client existant, par exemple un client de démonstration Contoso.

**Étape 4.** Ouvrez l'onglet consacré au crédit et aux relances. Votre champ `Credit review date` (Date de revue du crédit) doit y figurer.

**Étape 5.** Test du chemin nominal. Saisissez une date future, par exemple dans trois mois, puis enregistrez. L'enregistrement doit aboutir sans message.

**Étape 6.** Test du chemin d'erreur. Saisissez une date passée, par exemple celle de la veille, puis enregistrez. Le message `La date de revue du crédit ne peut pas être antérieure à la date du jour.` doit apparaître, et l'enregistrement doit être refusé.

**Étape 7.** Test de la valeur vide. Videz le champ et enregistrez. L'enregistrement doit aboutir : une date non renseignée est une valeur légitime, conformément à la condition posée en 5.6.

**Ces trois tests forment le jeu minimal.** Un composant validé uniquement sur son chemin nominal n'est pas validé. Le chemin d'erreur et le cas limite de la valeur vide révèlent la majorité des défauts de logique.

### 5.9 Déboguer le composant

Si le comportement observé ne correspond pas à celui attendu, le débogueur permet de suivre l'exécution pas à pas.

**Étape 1.** Configurez le chargement des symboles. Ouvrez `Extensions` > `Options` > onglet `Debugging` (Débogage), et activez le chargement des symboles pour votre solution ainsi que pour les packages `ApplicationFoundation` et `ApplicationPlatform`.

**Étape 2.** Dans le fichier `ArcCustTable_Extension`, cliquez dans la marge de gauche en regard de la ligne `boolean ret = next validateWrite();` pour poser un point d'arrêt.

**Étape 3.** Appuyez sur **F5**, ou cliquez sur la flèche verte de la barre d'outils. Le navigateur s'ouvre et les symboles se chargent.

**Étape 4.** Alternative si le processus est déjà en cours. Ouvrez `Dynamics 365` > `Launch debugger` (Lancer le débogueur), puis saisissez dans le navigateur l'adresse permettant de déclencher votre code.

**Étape 5.** Reproduisez le scénario dans l'application. L'exécution s'arrête sur votre point d'arrêt.

**Étape 6.** Inspectez les valeurs. La fenêtre `Locals` (Variables locales) affiche le contenu de `this.ArcCreditReviewDate` et de `ret`. Utilisez `F10` pour exécuter la ligne courante et `F11` pour entrer dans un appel.

**Étape 7.** Pour terminer la session, utilisez **`Detach`** (Détacher) plutôt que `Stop` (Arrêter).

**Point de vigilance.** Utiliser `Stop` provoque un redémarrage du serveur d'application, ce qui immobilise l'environnement plusieurs minutes et affecte les autres utilisateurs connectés. `Detach` libère le débogueur sans interruption de service.

**Note sur le partage d'environnement.** Le débogage suspend l'exécution du serveur d'application. Sur un environnement partagé, prévenez vos collègues, ou travaillez sur un environnement de développement dédié.

### 5.10 Checklist de validation de la phase 4

- [ ] Le fichier de libellés `ArcLabels` contient les trois libellés.
- [ ] L'EDT `ArcCreditReviewDate` étend `TransDate` et porte les libellés.
- [ ] L'extension de table ajoute le champ, typé par l'EDT.
- [ ] L'extension de formulaire affiche le champ, lié à la bonne source de données.
- [ ] La classe d'extension porte le suffixe `_Extension` et l'attribut `ExtensionOf`.
- [ ] L'appel à `next` est présent dans la méthode.
- [ ] Aucun texte n'est écrit en dur dans le code.
- [ ] La génération se termine sans erreur.
- [ ] Le modèle est déployé et la base synchronisée.
- [ ] Le test du chemin nominal aboutit.
- [ ] Le test du chemin d'erreur affiche le message et bloque l'enregistrement.
- [ ] Le test de la valeur vide aboutit.

## 6. Phase 5 : Configuration du Power Platform pour l'automatisation

**Objectif de la phase.** Doter le pipeline d'une identité propre, capable de déployer sur l'environnement sans intervention humaine.

**Rôles requis.** `System administrator` (Administrateur système) dans l'environnement, et droit de créer une inscription d'application dans Microsoft Entra ID. `Project Administrators` (Administrateurs de projet) dans Azure DevOps pour créer la connexion de service.

### 6.1 Pourquoi un principal de service

Un pipeline s'exécute sans utilisateur devant l'écran. Il ne peut donc ni saisir un mot de passe, ni valider une authentification multifacteur. Il lui faut une **identité applicative**, appelée principal de service, dotée de ses propres droits sur l'environnement.

Cette identité présente trois avantages sur un compte nominatif : elle n'est pas soumise à l'expiration de mot de passe des comptes utilisateurs, elle ne consomme pas de licence utilisateur, et son départ n'est pas lié à celui d'une personne de l'équipe.

### 6.2 Créer le principal de service

**Étape 1.** Installez l'interface en ligne de commande Power Platform si ce n'est pas déjà fait. Dans une invite de commandes :

```
dotnet tool install --global Microsoft.PowerApps.CLI.Tool
```

**Étape 2.** Authentifiez-vous de façon interactive :

```
pac auth create --environment <adresse de votre environnement>
```

**Étape 3.** Créez le principal de service et attribuez-lui le rôle d'administrateur système sur l'environnement :

```
pac admin create-service-principal --environment <identifiant de votre environnement>
```

**Étape 4.** La commande retourne trois valeurs. **Consignez-les immédiatement en lieu sûr**, le secret n'étant affiché qu'une seule fois.

| Valeur retournée | Usage ultérieur |
| :-- | :-- |
| `Tenant ID` (Identifiant du locataire) | Connexion de service et groupe de variables |
| `Application ID` (Identifiant de l'application) | Connexion de service et groupe de variables |
| `Client Secret` (Secret client) | Connexion de service et groupe de variables, à traiter comme un mot de passe |

**Point de vigilance.** Le secret client possède une durée de vie limitée, fixée par la politique de votre tenant. Notez sa date d'expiration : passée cette date, l'étage de déploiement du pipeline échouera avec une erreur d'authentification.

### 6.3 Créer la connexion de service dans Azure DevOps

**Étape 1.** Ouvrez `Project settings` (Paramètres du projet) > `Service connections` (Connexions de service) > `New service connection` (Nouvelle connexion de service).

**Étape 2.** Sélectionnez `Power Platform`, puis `Next` (Suivant).

**Étape 3.** Renseignez :

| Champ | Valeur |
| :-- | :-- |
| `Authentication method` (Méthode d'authentification) | `Service Principal and Client Secret` (Principal de service et secret client) |
| `Server URL` (Adresse du serveur) | L'`Environment URL` de votre environnement |
| `Tenant ID` (Identifiant du locataire) | La valeur relevée en 6.2 |
| `Application ID` (Identifiant de l'application) | La valeur relevée en 6.2 |
| `Client secret` (Secret client) | La valeur relevée en 6.2 |
| `Service connection name` (Nom de la connexion de service) | `PPAC-Sandbox-DEV` |

**Étape 4.** Cochez `Grant access permission to all pipelines` (Accorder l'autorisation d'accès à tous les pipelines), puis `Save` (Enregistrer).

**Note sur l'authentification fédérée.** Si votre organisation impose l'authentification multifacteur pour les identités applicatives, préférez la méthode `Workload Identity Federation` (Fédération d'identité de charge de travail), qui supprime la gestion d'un secret et donc son expiration.

### 6.4 Créer le groupe de variables

Le pipeline aura besoin des mêmes valeurs pour la commande de déploiement. Un groupe de variables les centralise et protège le secret.

**Étape 1.** Ouvrez `Pipelines` > `Library` (Bibliothèque) > `+ Variable group` (Groupe de variables).

**Étape 2.** Nommez-le `PowerPlatform-Sandbox` et déclarez :

| Variable | Valeur | Secret |
| :-- | :-- | :-- |
| `PP_TENANT_ID` | L'identifiant de locataire | Non |
| `PP_APP_ID` | L'identifiant d'application | Non |
| `PP_CLIENT_SECRET` | Le secret client | **Oui**, activez le cadenas |
| `PP_ENVIRONMENT_URL` | L'`Environment URL` de l'environnement | Non |

**Étape 3.** Enregistrez.

**Point de vigilance.** Une variable marquée comme secrète n'est plus jamais affichée en clair, y compris pour vous. Si vous perdez le secret, il faut le régénérer. C'est le comportement attendu.

### 6.5 Checklist de validation de la phase 5

- [ ] L'interface `pac` est installée et authentifiée.
- [ ] Le principal de service est créé.
- [ ] Les trois valeurs retournées sont consignées.
- [ ] La date d'expiration du secret est notée.
- [ ] La connexion de service `PPAC-Sandbox-DEV` est créée et accessible aux pipelines.
- [ ] Le groupe de variables est créé, le secret marqué comme secret.

## 7. Phase 6 : Chaîne d'intégration continue et de déploiement

**Objectif de la phase.** Mettre en place le pipeline qui compilera votre composant à chaque publication et le déploiera sur l'environnement.

**Rôles requis.** `Project Collection Administrators` pour les extensions et le flux d'artefacts. `Owner` ou `Contributor` sur la Subscription Azure pour les fournisseurs de ressources. `DevOps Infrastructure Contributor` au minimum pour le pool. `Contributors` pour créer le pipeline.

### 7.1 Vue d'ensemble de la chaîne

| Étage | Ce qu'il fait | Résultat |
| :-- | :-- | :-- |
| `Build` (Génération) | Restaure les packages NuGet de compilation, compile le X++, produit le package unifié Power Platform | Un artefact `UnifiedPackage.zip` |
| `Deploy` (Déploiement) | Authentifie le principal de service, installe le package sur l'environnement | Le composant est installé |

**Ce que cette chaîne remplace.** Dans le modèle antérieur, la compilation exigeait une machine virtuelle de build dédiée, provisionnée, maintenue et facturée en permanence. Elle s'effectue désormais sur des agents éphémères, à partir de packages NuGet, sans aucune machine à maintenir.

### 7.2 Installer les extensions Azure DevOps

**Étape 1.** Cliquez sur l'icône de sac de courses en haut à droite, puis `Browse marketplace` (Parcourir la place de marché).

**Étape 2.** Installez `Dynamics 365 Finance and Operations Tools`, qui fournit la tâche de création du package déployable.

**Étape 3.** Installez `Power Platform Build Tools`, qui fournit l'outillage `pac` et les tâches de déploiement.

**Étape 4.** Vérification dans `Organization settings` (Paramètres de l'organisation) > `Extensions`.

### 7.3 Récupérer les packages NuGet de compilation

L'agent ne dispose ni de l'application standard, ni du compilateur X++. Il les obtient sous forme de cinq packages NuGet.

| Package | Contenu |
| :-- | :-- |
| `Microsoft.Dynamics.AX.Platform.CompilerPackage` | Le compilateur X++ et les tâches de génération |
| `Microsoft.Dynamics.AX.Platform.DevALM.BuildXpp` | Les références compilées du module Platform |
| `Microsoft.Dynamics.AX.Application1.DevALM.BuildXpp` | Les références du module Application, première partie |
| `Microsoft.Dynamics.AX.Application2.DevALM.BuildXpp` | Les références du module Application, seconde partie |
| `Microsoft.Dynamics.AX.ApplicationSuite.DevALM.BuildXpp` | Les références du module Application Suite |

**Point important sur la provenance.** Ces packages étaient historiquement téléchargés depuis la bibliothèque d'actifs partagés de Lifecycle Services. Cette voie n'est plus adaptée aux nouveaux projets. **Visual Studio les met à disposition directement**, ce qui garantit en outre la cohérence entre la version de votre environnement et celle des packages de compilation.

**Étape 1.** Dans Visual Studio, ouvrez `Tools` (Outils) > `Download Dynamics 365 FnO NuGets for CI/CD` (Télécharger les NuGets Dynamics 365 FnO pour CI/CD). Cette commande est disponible car l'option correspondante a été activée en 2.4.

**Étape 2.** Patientez. Les cinq fichiers `.nupkg` sont déposés dans un dossier local dont le chemin est indiqué à la fin de l'opération.

**Étape 3.** Relevez les **numéros de version exacts**, visibles dans le nom des fichiers : la version **plateforme**, au format `7.0.XXXX.XX`, et la version **application**, au format `10.0.XXXX.XX`.

**Point de vigilance.** Ces deux valeurs seront reprises telles quelles dans `packages.config` et dans les variables du pipeline. Une divergence entre les quatre emplacements est la cause d'échec la plus fréquente de cette phase.

### 7.4 Publier les packages dans un flux Azure Artifacts

**Étape 1.** Dans Azure DevOps, ouvrez `Artifacts` (Artefacts) puis `Create Feed` (Créer un flux).

**Étape 2.** Nommez-le `FinOpsNuGet`, portée `Project` (Projet), visibilité limitée aux membres de l'organisation, sources en amont décochées.

**Étape 3.** Ouvrez le flux, cliquez sur `Connect to feed` (Se connecter au flux) puis `NuGet.exe`, et relevez l'adresse du flux.

**Étape 4.** Téléchargez `nuget.exe` depuis le site officiel NuGet et placez-le dans le dossier contenant les cinq fichiers `.nupkg`.

**Étape 5.** Ouvrez une invite de commandes dans ce dossier et publiez les cinq packages :

```
nuget.exe push -Source "https://pkgs.dev.azure.com/<organisation>/<projet>/_packaging/FinOpsNuGet/nuget/v3/index.json" -ApiKey AZ Microsoft.Dynamics.AX.Platform.CompilerPackage.nupkg
nuget.exe push -Source "https://pkgs.dev.azure.com/<organisation>/<projet>/_packaging/FinOpsNuGet/nuget/v3/index.json" -ApiKey AZ Microsoft.Dynamics.AX.Platform.DevALM.BuildXpp.nupkg
nuget.exe push -Source "https://pkgs.dev.azure.com/<organisation>/<projet>/_packaging/FinOpsNuGet/nuget/v3/index.json" -ApiKey AZ Microsoft.Dynamics.AX.Application1.DevALM.BuildXpp.nupkg
nuget.exe push -Source "https://pkgs.dev.azure.com/<organisation>/<projet>/_packaging/FinOpsNuGet/nuget/v3/index.json" -ApiKey AZ Microsoft.Dynamics.AX.Application2.DevALM.BuildXpp.nupkg
nuget.exe push -Source "https://pkgs.dev.azure.com/<organisation>/<projet>/_packaging/FinOpsNuGet/nuget/v3/index.json" -ApiKey AZ Microsoft.Dynamics.AX.ApplicationSuite.DevALM.BuildXpp.nupkg
```

**Note.** La valeur `AZ` de l'argument `-ApiKey` est une valeur factice attendue par Azure Artifacts. L'authentification réelle s'effectue de façon interactive à la première commande.

### 7.5 Déclarer nuget.config et packages.config

**Étape 1.** Créez `BuildPipeline/nuget.config` :

```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <packageSources>
    <clear />
    <add key="FinOpsNuGet" value="https://pkgs.dev.azure.com/<organisation>/<projet>/_packaging/FinOpsNuGet/nuget/v3/index.json" />
  </packageSources>
</configuration>
```

**Étape 2.** Créez `BuildPipeline/packages.config`, en reportant les versions relevées en 7.3 :

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

**Point de vigilance.** Les deux premières lignes portent une version plateforme en `7.0`, les trois suivantes une version application en `10.0`. Les valeurs ci-dessus sont des exemples : substituez celles de votre environnement.

### 7.6 Créer le Managed DevOps Pool

Un `Managed DevOps Pool` (pool DevOps managé) fournit des agents éphémères hébergés dans **votre** souscription Azure, provisionnés à la demande et détruits en fin d'exécution, sans aucune maintenance de votre part.

#### 7.6.1 Prérequis

**Étape 1.** Enregistrez les fournisseurs de ressources. Portail Azure > `Subscriptions` (Abonnements) > votre souscription > `Resource providers` (Fournisseurs de ressources). Enregistrez `Microsoft.DevOpsInfrastructure` puis `Microsoft.DevCenter`.

**Étape 2.** Patientez deux à trois minutes et vérifiez que les deux statuts affichent `Registered` (Enregistré).

**Étape 3.** Vérifiez vos permissions sur les pools d'agents. Azure DevOps > `Project settings` (Paramètres du projet) > `Agent pools` (Pools d'agents) > `Security` (Sécurité). Vous devez y figurer comme `Administrator` (Administrateur) ou `Creator` (Créateur).

**Sur le quota.** La taille d'agent par défaut, `Standard D2ads v5`, consomme deux cœurs. Le quota par défaut de cinq cœurs par famille et par région autorise donc deux agents simultanés, ce qui suffit ici.

#### 7.6.2 Créer le pool

**Étape 1.** Dans le portail Azure, recherchez `Managed DevOps Pools` et cliquez sur `Create` (Créer).

**Étape 2.** Sous `Basics` (Informations de base), renseignez :

| Champ | Valeur |
| :-- | :-- |
| `Subscription` (Abonnement) | Votre Subscription |
| `Resource group` (Groupe de ressources) | Un groupe existant, ou à créer |
| `Dev center` (Centre de développement) | `Create new` (Créer), par exemple `dc-d365fo` |
| `Dev center project` (Projet du centre de développement) | `Create new` (Créer), par exemple `dcp-d365fo` |
| `Name` (Nom) | `mdp-d365fo-build`, globalement unique |
| `Region` (Région) | La même que le groupe de ressources |
| `Maximum agents` (Nombre maximal d'agents) | `2` |

**Étape 3.** Sous `Azure DevOps organization` (Organisation Azure DevOps), sélectionnez l'organisation créée en phase 2.

**Étape 4.** Sous `Images`, cliquez sur `Add from Image Library` (Ajouter depuis la bibliothèque d'images) et sélectionnez une image **Windows** récente incluant Visual Studio.

**Point de vigilance déterminant.** L'image doit être Windows et embarquer Visual Studio. La compilation X++ repose sur MSBuild et sur les tâches du package compilateur, absentes des images Linux. Une image Linux échoue dès le premier appel de la tâche de génération. Si votre environnement a atteint la version de plateforme imposant Visual Studio 2026, retenez une image embarquant cette version.

**Étape 5.** Sous `Scaling` (Mise à l'échelle), conservez les valeurs par défaut : agents sans état, aucun agent en attente. Aucun coût n'est ainsi engagé entre deux exécutions.

**Étape 6.** Cliquez sur `Review + create` (Vérifier et créer) puis `Create` (Créer).

**Étape 7.** Vérification. Azure DevOps > `Organization settings` > `Pipelines` > `Agent pools`. Votre pool doit y figurer.

#### 7.6.3 Coût et repli

**Sur le coût.** Un Managed DevOps Pool consomme de la puissance de calcul Azure, facturée sur votre Subscription au tarif des machines virtuelles, à la seconde d'exécution. Une compilation X++ dure typiquement de dix à trente minutes. Le montant reste modeste à raison de quelques exécutions par jour, mais il n'est pas nul et n'est pas couvert par le quota gratuit d'Azure DevOps. Configurez une alerte de budget dans le portail Azure.

**Repli documenté.** Si le quota vous est refusé, si la région n'est pas éligible, ou si vous souhaitez démarrer sans engagement financier, les agents Microsoft-hosted constituent un repli fonctionnel. Remplacez dans le fichier YAML :

```yaml
pool:
  name: mdp-d365fo-build
```

par :

```yaml
pool:
  vmImage: 'windows-latest'
```

Aucune autre modification n'est nécessaire. Les limites sont l'absence de réseau privé, l'impossibilité de dimensionner la machine, et le plafond mensuel de minutes.

### 7.7 Créer le fichier de pipeline

**Étape 1.** Créez dans le dépôt le fichier `BuildPipeline/ci-build.yml` avec le contenu ci-dessous.

**Étape 2.** Adaptez les valeurs signalées par un commentaire.

```yaml
# Pipeline d'integration continue et de deploiement
# Dynamics 365 Finance and Operations, environnement de developpement unifie

trigger:
  branches:
    include:
      - main
  paths:
    include:
      - XppMetadata/*
      - VS_Solutions/*
      - BuildPipeline/*

schedules:
  - cron: '0 3 * * *'
    displayName: Build nocturne de securite
    branches:
      include:
        - main
    always: true

pool:
  name: mdp-d365fo-build        # A ADAPTER : nom du Managed DevOps Pool
                                # Repli : remplacer par  vmImage: 'windows-latest'

variables:
  - group: PowerPlatform-Sandbox
  - name: PlatformVersion
    value: '7.0.7367.146'       # A ADAPTER : version plateforme relevee en 7.3
  - name: ApplicationVersion
    value: '10.0.1935.21'       # A ADAPTER : version application relevee en 7.3
  - name: NuGetConfigPath
    value: '$(Build.SourcesDirectory)/BuildPipeline'
  - name: NuGetInstallDir
    value: '$(Build.SourcesDirectory)/NuGets'
  - name: MetadataPath
    value: '$(Build.SourcesDirectory)/XppMetadata'
  - name: SolutionPath
    value: '$(Build.SourcesDirectory)/VS_Solutions/ArchiaExtensions/ArcCreditReview.sln'   # A ADAPTER
  - name: CompilerPackage
    value: '$(NuGetInstallDir)/Microsoft.Dynamics.AX.Platform.CompilerPackage'
  - name: PlatformBuildRef
    value: '$(NuGetInstallDir)/Microsoft.Dynamics.AX.Platform.DevALM.BuildXpp'
  - name: App1BuildRef
    value: '$(NuGetInstallDir)/Microsoft.Dynamics.AX.Application1.DevALM.BuildXpp'
  - name: App2BuildRef
    value: '$(NuGetInstallDir)/Microsoft.Dynamics.AX.Application2.DevALM.BuildXpp'
  - name: AppSuiteBuildRef
    value: '$(NuGetInstallDir)/Microsoft.Dynamics.AX.ApplicationSuite.DevALM.BuildXpp'
  - name: UnifiedPackageOutput
    value: '$(Build.ArtifactStagingDirectory)/UnifiedPackage'

stages:

  # ============================================================
  # ETAGE 1 : INTEGRATION CONTINUE
  # ============================================================
  - stage: Build
    displayName: Compilation X++ et creation du package unifie
    jobs:
      - job: BuildXpp
        displayName: Compiler et empaqueter
        timeoutInMinutes: 120
        steps:

          - checkout: self
            displayName: Recuperer le code source
            clean: true

          - task: NuGetCommand@2
            displayName: Restaurer les packages de compilation
            inputs:
              command: custom
              arguments: >
                install "$(NuGetConfigPath)/packages.config"
                -ConfigFile "$(NuGetConfigPath)/nuget.config"
                -OutputDirectory "$(NuGetInstallDir)"
                -ExcludeVersion
                -Verbosity Detailed
                -Noninteractive

          - task: VSBuild@1
            displayName: Compiler le code X++
            inputs:
              solution: '$(SolutionPath)'
              vsVersion: 'latest'
              msbuildArgs: >
                /p:BuildTasksDirectory="$(CompilerPackage)/DevAlm"
                /p:MetadataDirectory="$(MetadataPath)"
                /p:FrameworkDirectory="$(CompilerPackage)"
                /p:ReferenceFolder="$(PlatformBuildRef)/ref/net40;$(App1BuildRef)/ref/net40;$(App2BuildRef)/ref/net40;$(AppSuiteBuildRef)/ref/net40;$(MetadataPath);$(Build.BinariesDirectory)"
                /p:ReferencePath="$(CompilerPackage)"
                /p:OutputDirectory="$(Build.BinariesDirectory)"
                /p:CompilerMetadata="$(Build.BinariesDirectory)"

          - task: NuGetToolInstaller@1
            displayName: Installer NuGet 3.3.0 pour l empaquetage
            inputs:
              versionSpec: '3.3.0'

          - task: XppCreatePackage@3
            displayName: Creer le package unifie Power Platform
            inputs:
              XppToolsPath: '$(CompilerPackage)'
              CreateCloudPackage: true
              CloudPackagePlatVersion: '$(PlatformVersion)'
              CloudPackageAppVersion: '$(ApplicationVersion)'
              CloudPackageOutputLocation: '$(UnifiedPackageOutput)'
              DeployablePackagePath: '$(Build.ArtifactStagingDirectory)/AXDeployableRuntime.zip'

          - task: ArchiveFiles@2
            displayName: Compresser le package unifie
            inputs:
              rootFolderOrFile: '$(UnifiedPackageOutput)'
              includeRootFolder: false
              archiveType: zip
              archiveFile: '$(Build.ArtifactStagingDirectory)/UnifiedPackage.zip'

          - task: PublishBuildArtifacts@1
            displayName: Publier l artefact
            inputs:
              PathtoPublish: '$(Build.ArtifactStagingDirectory)/UnifiedPackage.zip'
              ArtifactName: UnifiedPackage

  # ============================================================
  # ETAGE 2 : DEPLOIEMENT VERS LA SANDBOX
  # ============================================================
  - stage: Deploy
    displayName: Deploiement sur l environnement Sandbox
    dependsOn: Build
    condition: succeeded()
    jobs:
      - deployment: DeploySandbox
        displayName: Deployer le package unifie
        environment: 'D365FO-Sandbox'
        strategy:
          runOnce:
            deploy:
              steps:

                - task: PowerPlatformToolInstaller@2
                  displayName: Installer l outillage Power Platform
                  inputs:
                    DefaultVersion: true
                    AddToolsToPath: true

                - task: PowerPlatformWhoAmi@2
                  displayName: Verifier la connexion a l environnement
                  inputs:
                    authenticationType: PowerPlatformSPN
                    PowerPlatformSPN: 'PPAC-Sandbox-DEV'      # A ADAPTER

                - task: PowerShell@2
                  displayName: Deployer le package unifie
                  inputs:
                    targetType: inline
                    script: |
                      $ErrorActionPreference = 'Stop'
                      $package = "$(Pipeline.Workspace)/UnifiedPackage/UnifiedPackage.zip"
                      Write-Host "Package a deployer : $package"
                      pac auth create `
                        --applicationId "$(PP_APP_ID)" `
                        --clientSecret "$(PP_CLIENT_SECRET)" `
                        --tenant "$(PP_TENANT_ID)" `
                        --environment "$(PP_ENVIRONMENT_URL)"
                      pac package deploy --package $package
```

**Note sur la syntaxe des variables.** Le bloc `variables` est écrit sous forme de **liste**, chaque entrée étant une paire `name` et `value`. Cette forme est imposée dès lors qu'un groupe de variables est référencé par `- group:`. Mélanger la forme abrégée et la forme en liste produit une erreur de syntaxe au premier enregistrement, et c'est l'erreur la plus fréquente à la mise en place.

**Note sur `vsVersion`.** La valeur `latest` (la plus récente) laisse la tâche sélectionner la version de Visual Studio présente sur l'image de l'agent. C'est le réglage le plus robuste face à la transition de Visual Studio 2022 vers Visual Studio 2026. Si vous devez figer la version, utilisez le numéro de version majeure correspondant à l'édition installée sur l'image.

### 7.8 Créer et exécuter le pipeline

**Étape 1.** Publiez le fichier sur la branche principale, par un `Commit` puis un `Push` depuis Visual Studio.

**Étape 2.** Dans Azure DevOps, ouvrez `Pipelines` > `New pipeline` (Nouveau pipeline).

**Étape 3.** Sélectionnez `Azure Repos Git`, puis votre dépôt.

**Étape 4.** Choisissez `Existing Azure Pipelines YAML file` (Fichier YAML Azure Pipelines existant).

**Étape 5.** Sélectionnez la branche `main` et le chemin `/BuildPipeline/ci-build.yml`, puis `Continue` (Continuer).

**Étape 6.** Cliquez sur `Run` (Exécuter).

**Étape 7.** À la première exécution, une autorisation est demandée pour l'accès à la connexion de service et à l'environnement de déploiement. Cliquez sur `View` (Afficher) puis `Permit` (Autoriser).

**Étape 8.** Suivez l'exécution. Durées typiques :

| Tâche | Durée typique |
| :-- | :-- |
| Restauration des packages | 2 à 5 min |
| Compilation X++ | 10 à 30 min |
| Création du package unifié | 2 à 5 min |
| Déploiement | 20 à 60 min |

### 7.9 Checklist de validation de la phase 6

- [ ] Les deux extensions Azure DevOps sont installées.
- [ ] Les cinq packages NuGet sont téléchargés depuis Visual Studio.
- [ ] Les versions plateforme et application sont relevées.
- [ ] Le flux `FinOpsNuGet` contient les cinq packages.
- [ ] `nuget.config` et `packages.config` sont versionnés.
- [ ] Les fournisseurs de ressources Azure sont enregistrés.
- [ ] Le Managed DevOps Pool est créé, avec une image Windows incluant Visual Studio.
- [ ] Le pool est visible dans les pools d'agents d'Azure DevOps.
- [ ] Le fichier YAML est versionné et le pipeline créé à partir de celui-ci.
- [ ] Une exécution complète réussit sur les deux étages.

## 8. Phase 7 : Livraison du composant par le pipeline

**Objectif de la phase.** Vérifier que la chaîne fonctionne de bout en bout, en modifiant le composant et en observant sa livraison automatique.

**Rôles requis.** `Contributors` (Contributeurs) du projet.

### 8.1 Publier le composant

**Étape 1.** Dans Visual Studio, ouvrez `View` (Affichage) > `Git Changes` (Modifications Git).

**Étape 2.** Vérifiez la liste des fichiers modifiés. Elle doit contenir les cinq objets créés en phase 4, ainsi que le fichier descripteur du modèle.

**Étape 3.** Saisissez un message de commit décrivant **l'intention**, et non le contenu technique. Par exemple :

```
Ajout de la date de revue du credit sur le client, avec controle de coherence
```

**Étape 4.** Cliquez sur `Commit All` (Valider tout), puis sur `Push` (Envoyer).

### 8.2 Observer le déclenchement automatique

**Étape 1.** Ouvrez `Pipelines` dans Azure DevOps. Une exécution doit avoir démarré dans la minute suivant la publication.

**Étape 2.** Ouvrez l'exécution. Le nom du commit et son auteur y figurent, ce qui établit la traçabilité entre le code publié et le déploiement.

**Étape 3.** Suivez la progression étage par étage.

**Si l'étage de compilation échoue**, le journal indique la ligne fautive. Corrigez dans Visual Studio, validez et publiez de nouveau : une nouvelle exécution démarre automatiquement.

### 8.3 Vérifier le résultat

**Étape 1.** Dans le Power Platform Admin Center, ouvrez votre environnement. L'opération de déploiement doit apparaître dans l'historique des opérations.

**Étape 2.** Ouvrez l'application Finance and Operations et vérifiez que votre champ est présent et que la règle de validation s'applique, en rejouant les trois tests de la section 5.8.

**Étape 3.** Vérification de la traçabilité complète. Vous devez pouvoir remonter, sans ambiguïté, du champ affiché à l'écran jusqu'au commit qui l'a produit, en passant par l'exécution du pipeline. C'est la finalité de toute la chaîne mise en place.

### 8.4 Le cycle de travail au quotidien

| Moment | Action | Commande |
| :-- | :-- | :-- |
| Début de session | Récupérer les modifications de l'équipe | `Git` > `Pull` (Extraire) |
| Après un `Pull` apportant des modèles | Actualiser les modèles | `Dynamics 365` > `Model Management` > `Refresh models` |
| Pendant le développement | Générer localement et corriger | Clic droit sur le projet > `Build` (Générer) |
| Après une modification de structure | Synchroniser la base locale | `Dynamics 365` > `Synchronize database` |
| Pour tester avant publication | Déployer sur l'environnement | `Dynamics 365` > `Deploy` (Déployer) |
| Évolution achevée | Publier et déclencher la chaîne | `Git Changes` > `Commit All` puis `Push` |

**Bonne pratique de branche.** Dès que vous travaillez à plusieurs, protégez la branche `main` par une stratégie exigeant une pull request et une compilation réussie avant fusion. Azure DevOps > `Repos` > `Branches` > menu de la branche > `Branch policies` (Stratégies de branche).

### 8.5 Checklist de validation de la phase 7

- [ ] La publication déclenche automatiquement le pipeline.
- [ ] L'exécution porte le nom du commit et son auteur.
- [ ] Les deux étages se terminent avec succès.
- [ ] L'opération de déploiement apparaît dans le Power Platform Admin Center.
- [ ] Le composant est fonctionnel dans l'application après déploiement automatique.
- [ ] Les trois tests de la section 5.8 passent toujours.

## 9. Annexe A : Dépannage

### 9.1 Phase 1, Visual Studio et connexion

| Symptôme | Cause probable | Résolution |
| :-- | :-- | :-- |
| Le menu `Dynamics 365` est absent | L'extension Finance and Operations n'est pas installée | Relancez la connexion à l'environnement, qui déclenche son installation |
| La liste des environnements est vide | L'adresse de l'application a été saisie au lieu de l'`Environment URL` | Utilisez l'adresse Dataverse en `*.dynamics.com` |
| L'authentification échoue en boucle | Blocage lié à l'authentification multifacteur | Décochez toutes les cases de l'écran de connexion pour déclencher le flux navigateur |
| Seule la solution `Default` est proposée à la connexion | Aucune solution créée, ou solution créée dans un autre environnement | Vérifiez le sélecteur d'environnement sur `make.powerapps.com` et recréez la solution selon la section 2.5 |
| Le bouton `New publisher` est inactif | Rôle insuffisant dans l'environnement | Faites-vous attribuer `System customizer` ou `System administrator` |
| Le préfixe de l'éditeur est une chaîne aléatoire | L'éditeur par défaut de Dataverse a été retenu | Créez un éditeur dédié, le préfixe d'un éditeur existant n'étant pas modifiable proprement |
| Le nom technique de la solution est erroné | Le champ `Name` n'est plus modifiable après enregistrement | Créez une nouvelle solution et supprimez la précédente si elle est vide |
| Le téléchargement des assets s'interrompt | Coupure réseau ou espace disque insuffisant | `Tools` > `Download Dynamics 365 assets`, qui purge et relance intégralement |
| Le dossier des assets pèse moins de 24 Go | Téléchargement incomplet | Même résolution que ci-dessus |
| Aucune visibilité sur la progression | Fenêtre de sortie masquée | `View` > `Output`, source `FinOps Cloud Runtime` |
| L'`Application Explorer` reste vide | Chemin des métadonnées de référence erroné | Vérifiez qu'il pointe sur `PackagesLocalDirectory` décompressé |
| Le bouton `Save` reste grisé dans `Configure Metadata` | Un champ est invalide | Repérez le champ encadré en rouge et lisez l'infobulle |
| Erreur de connexion à LocalDB | Instance absente | Exécutez `sqllocaldb create MSSQLLocalDB -s` |
| Doute sur la compatibilité Visual Studio et version de plateforme | Transition Visual Studio 2022 vers 2026 en cours | Consultez la page de prérequis des outils de développement citée en annexe D |

### 9.2 Phase 2 et phase 3, dépôt, modèle et projet

| Symptôme | Cause probable | Résolution |
| :-- | :-- | :-- |
| Erreur de chemin trop long à la compilation | Dossier de clonage trop profond | Reclonez dans un chemin proche de la racine du disque |
| Le dépôt se remplit mais le pipeline compile une version obsolète | `Configure Metadata` pointe hors du dépôt | Comparez le chemin déclaré et le chemin réel, corrigez selon la section 3.5 |
| Le dépôt grossit anormalement | `PackagesLocalDirectory` a été ajouté | Retirez-le du suivi et vérifiez le fichier `.gitignore` |
| Un collègue récupère des objets orphelins | Le fichier descripteur du modèle n'est pas versionné | Ajoutez le fichier XML du dossier `Descriptor` |
| Le modèle n'apparaît pas après création | Rafraîchissement nécessaire | Fermez et rouvrez Visual Studio, puis `Refresh models` |
| Le `Push` est refusé | Niveau d'accès `Stakeholder` (Partie prenante) | Faites élever votre accès à `Basic` et vérifier le groupe `Contributors` |

### 9.3 Phase 4, développement du composant

| Symptôme | Cause probable | Résolution |
| :-- | :-- | :-- |
| Type `CustTable` introuvable à la compilation | Le package `ApplicationSuite` n'est pas référencé | `Model Management` > `Update model parameters`, ajoutez la référence |
| Attribut `ExtensionOf` refusé | Suffixe `_Extension` manquant sur le nom de la classe | Renommez la classe |
| Le champ n'existe pas selon le compilateur | Extension de table non enregistrée, ou nom différent | Vérifiez le nom exact dans le concepteur |
| Le libellé s'affiche littéralement à l'écran | Identifiant du fichier de libellés erroné | Comparez avec le nom saisi à la création du fichier |
| Le formulaire produit une erreur à l'ouverture | Base non synchronisée après ajout du champ | Exécutez `Dynamics 365` > `Synchronize database` |
| Le champ n'apparaît pas sur le formulaire | Contrôle non lié à la source de données | Vérifiez les propriétés `Data Source` et `Data Field` du contrôle |
| La validation ne se déclenche jamais | Modèle non déployé sur l'environnement | Déployez le modèle, la validation s'exécute côté serveur |
| La validation standard ne fonctionne plus | Appel à `next` omis dans la méthode d'extension | Rétablissez `boolean ret = next validateWrite();` |
| Le message d'erreur s'affiche deux fois | Contrôle ajouté sans vérifier le retour du standard | Encadrez votre contrôle par `if (ret && ...)` |
| Le point d'arrêt n'est jamais atteint | Symboles non chargés, ou modèle non déployé | Activez le chargement des symboles, puis redéployez |
| L'environnement redémarre après le débogage | Utilisation de `Stop` au lieu de `Detach` | Utilisez systématiquement `Detach` (Détacher) |

### 9.4 Phase 5 et phase 6, automatisation

| Symptôme | Cause probable | Résolution |
| :-- | :-- | :-- |
| La restauration NuGet retourne une erreur 401 | Le compte de service de build n'a pas accès au flux | `Artifacts` > `Feed settings` > `Permissions`, ajoutez le compte de service en `Reader` (Lecteur) |
| La restauration ne trouve pas les packages | Adresse de flux erronée, ou versions absentes | Comparez avec l'adresse de `Connect to feed` et les versions publiées |
| Le pipeline reste en attente sans démarrer | Aucun agent disponible, quota atteint | Vérifiez le pool et le quota, ou basculez sur `vmImage: 'windows-latest'` |
| La compilation échoue immédiatement | Image Linux sélectionnée pour le pool | Recréez le pool avec une image Windows incluant Visual Studio |
| Erreur de versionnement sémantique à l'empaquetage | NuGet postérieur à la version 3.3.0 | Vérifiez la présence de `NuGetToolInstaller@1` avec `versionSpec: '3.3.0'` |
| Message `fnomoduledefinition.json not found` | Chemins de la tâche d'empaquetage erronés | Contrôlez `CloudPackageOutputLocation` et `XppToolsPath` |
| Versions du package unifié incohérentes | Variables désynchronisées de `packages.config` | Alignez les quatre valeurs sur celles relevées en 7.3 |
| Erreur de syntaxe sur le bloc `variables` | Formes abrégée et en liste mélangées | Écrivez toutes les variables sous forme de paires `name` et `value` |
| La tâche `PowerPlatformWhoAmi` échoue | Principal de service sans droits, ou secret expiré | Réexécutez `pac admin create-service-principal` et mettez à jour la connexion |
| Le déploiement échoue sans message explicite | Environnement indisponible ou opération concurrente | Vérifiez l'état de l'environnement et relancez |
| Autorisation demandée à chaque exécution | Accès aux ressources non accordé durablement | Ouvrez l'exécution, `View` puis `Permit`, en cochant l'accès permanent |

## 10. Annexe B : Checklist séquentielle d'exhaustivité

Cette annexe répond à une question précise : ai-je oublié une étape ? Elle suit l'ordre chronologique exact des actions.

### 10.1 Préparation

| Fait | Action | Rôle requis | Section |
| :-- | :-- | :-- | :-- |
| [ ] | Vérifier l'existence d'un environnement `Sandbox` à l'état `Ready` | `Power Platform admin` | 1.2 |
| [ ] | Vérifier l'installation de la `Provisioning App` avec les outils de développement | `Power Platform admin` | 1.2 |
| [ ] | Relever l'`Environment URL` | `Power Platform admin` | 1.2 |
| [ ] | Vérifier l'affectation d'une licence Dynamics 365 | `License administrator` | 1.2 |
| [ ] | Vérifier le rôle `System administrator` dans l'environnement | `System administrator` | 1.2 |
| [ ] | Vérifier les 60 Go d'espace disque libre | Aucun | 1.4 |

### 10.2 Phase 1, Visual Studio

| Fait | Action | Rôle requis | Section |
| :-- | :-- | :-- | :-- |
| [ ] | Télécharger Visual Studio 2026 Professional via Dev Essentials | Aucun | 2.1 |
| [ ] | Installer la charge de travail `.NET desktop development` | Administrateur local | 2.2 |
| [ ] | Ajouter le composant `Modeling SDK` | Administrateur local | 2.2 |
| [ ] | Ajouter le composant `DGML editor` | Administrateur local | 2.2 |
| [ ] | Vérifier la présence de `SQL Server Express LocalDB` | Administrateur local | 2.2 |
| [ ] | Se connecter à Visual Studio avec le compte du tenant | Aucun | 2.2 |
| [ ] | Installer `Microsoft Reporting Services Projects` | Administrateur local | 2.3.1 |
| [ ] | Installer `Power Platform Tools` | Administrateur local | 2.3.2 |
| [ ] | Régler les quatre options `Power Platform` | Aucun | 2.4 |
| [ ] | Ouvrir `make.powerapps.com` et **vérifier le sélecteur d'environnement** | Aucun | 2.5.2 |
| [ ] | Créer l'éditeur avec un préfixe maîtrisé | `System customizer` | 2.5.2 |
| [ ] | Créer la solution rattachée à cet éditeur | `System customizer` | 2.5.3 |
| [ ] | **Vérifier le nom technique, non modifiable ensuite** | `System customizer` | 2.5.3 |
| [ ] | Cocher `Set as your preferred solution` | `System customizer` | 2.5.3 |
| [ ] | **Se connecter avec l'`Environment URL`, et non l'adresse de l'application** | `System administrator` | 2.6 |
| [ ] | **Sélectionner votre solution, et non `Default`** | `System administrator` | 2.6 |
| [ ] | Télécharger les métadonnées de référence | `System administrator` | 2.6 |
| [ ] | Installer l'extension Finance and Operations | Administrateur local | 2.6 |
| [ ] | Vérifier les 24 Go du dossier des assets | Aucun | 2.6 |
| [ ] | Vérifier l'ouverture de l'`Application Explorer` | Aucun | 2.7 |

### 10.3 Phase 2, Azure DevOps et dépôt

| Fait | Action | Rôle requis | Section |
| :-- | :-- | :-- | :-- |
| [ ] | Créer l'organisation avec l'identité du tenant | Aucun | 3.2 |
| [ ] | **Vérifier le rattachement à Microsoft Entra ID** | `Organization Owner` | 3.2 |
| [ ] | Créer le projet en visibilité `Private`, contrôle de version `Git` | `Project Collection Administrators` | 3.3 |
| [ ] | Cloner le dépôt dans un chemin court | `Contributors` | 3.5 |
| [ ] | Créer les quatre dossiers de la structure | `Contributors` | 3.5 |
| [ ] | **Repointer `Configure Metadata` sur `XppMetadata` dans le dépôt** | Administrateur local | 3.5 |
| [ ] | Créer le fichier `.gitignore` | `Contributors` | 3.6 |

### 10.4 Phase 3, modèle et projet

| Fait | Action | Rôle requis | Section |
| :-- | :-- | :-- | :-- |
| [ ] | Créer le modèle avec son éditeur et sa couche | Administrateur local | 4.2 |
| [ ] | Choisir `Create new package` | Administrateur local | 4.2 |
| [ ] | Déclarer les trois packages de référence | Administrateur local | 4.2 |
| [ ] | Créer le projet dans `VS_Solutions` | Administrateur local | 4.3 |
| [ ] | **Vérifier la présence du fichier descripteur** | Administrateur local | 4.3 |
| [ ] | Réaliser et publier le premier commit | `Contributors` | 4.4 |

### 10.5 Phase 4, développement

| Fait | Action | Rôle requis | Section |
| :-- | :-- | :-- | :-- |
| [ ] | Créer le fichier de libellés `ArcLabels` | Administrateur local | 5.2 |
| [ ] | Saisir les trois libellés | Administrateur local | 5.2 |
| [ ] | Créer l'EDT `ArcCreditReviewDate`, étendant `TransDate` | Administrateur local | 5.3 |
| [ ] | Renseigner le libellé et le texte d'aide de l'EDT | Administrateur local | 5.3 |
| [ ] | Créer l'extension de table `CustTable` | Administrateur local | 5.4 |
| [ ] | Ajouter le champ, typé par l'EDT | Administrateur local | 5.4 |
| [ ] | Créer l'extension de formulaire `CustTable` | Administrateur local | 5.5 |
| [ ] | Ajouter le contrôle et le lier à la source de données | Administrateur local | 5.5 |
| [ ] | Créer la classe `ArcCustTable_Extension` | Administrateur local | 5.6 |
| [ ] | **Vérifier la présence de l'appel à `next`** | Administrateur local | 5.6 |
| [ ] | **Vérifier qu'aucun texte n'est écrit en dur** | Administrateur local | 5.6 |
| [ ] | Générer le projet sans erreur | Administrateur local | 5.7 |
| [ ] | Déployer le modèle avec synchronisation de la base | `System administrator` | 5.7 |
| [ ] | Tester le chemin nominal, date future | Licence Dynamics 365 | 5.8 |
| [ ] | Tester le chemin d'erreur, date passée | Licence Dynamics 365 | 5.8 |
| [ ] | Tester la valeur vide | Licence Dynamics 365 | 5.8 |

### 10.6 Phase 5, Power Platform

| Fait | Action | Rôle requis | Section |
| :-- | :-- | :-- | :-- |
| [ ] | Installer l'interface `pac` | Administrateur local | 6.2 |
| [ ] | Créer le principal de service | `System administrator` | 6.2 |
| [ ] | **Consigner les trois valeurs retournées** | Aucun | 6.2 |
| [ ] | Noter la date d'expiration du secret | Aucun | 6.2 |
| [ ] | Créer la connexion de service `Power Platform` | `Project Administrators` | 6.3 |
| [ ] | Créer le groupe de variables | `Contributors` | 6.4 |
| [ ] | **Marquer le secret client comme secret** | `Contributors` | 6.4 |

### 10.7 Phase 6, chaîne CI/CD

| Fait | Action | Rôle requis | Section |
| :-- | :-- | :-- | :-- |
| [ ] | Installer `Dynamics 365 Finance and Operations Tools` | `Project Collection Administrators` | 7.2 |
| [ ] | Installer `Power Platform Build Tools` | `Project Collection Administrators` | 7.2 |
| [ ] | Télécharger les cinq packages NuGet depuis Visual Studio | Administrateur local | 7.3 |
| [ ] | **Relever les versions plateforme et application** | Aucun | 7.3 |
| [ ] | Créer le flux `FinOpsNuGet` | `Project Collection Administrators` | 7.4 |
| [ ] | Publier les cinq packages | `Contributors` du flux | 7.4 |
| [ ] | Créer `nuget.config` | `Contributors` | 7.5 |
| [ ] | Créer `packages.config` avec les versions relevées | `Contributors` | 7.5 |
| [ ] | Enregistrer `Microsoft.DevOpsInfrastructure` | `Owner` ou `Contributor` Azure | 7.6.1 |
| [ ] | Enregistrer `Microsoft.DevCenter` | `Owner` ou `Contributor` Azure | 7.6.1 |
| [ ] | Vérifier la permission sur les pools d'agents | `Project Administrators` | 7.6.1 |
| [ ] | Créer le Managed DevOps Pool | `DevOps Infrastructure Contributor` | 7.6.2 |
| [ ] | **Sélectionner une image Windows incluant Visual Studio** | Idem | 7.6.2 |
| [ ] | Vérifier l'apparition du pool dans `Agent pools` | `Project Administrators` | 7.6.2 |
| [ ] | Configurer une alerte de budget Azure | `Cost Management Contributor` | 7.6.3 |
| [ ] | Créer `ci-build.yml` et adapter les valeurs signalées | `Contributors` | 7.7 |
| [ ] | Créer le pipeline à partir du fichier existant | `Contributors` | 7.8 |
| [ ] | Autoriser l'accès aux ressources | `Contributors` | 7.8 |
| [ ] | Obtenir une exécution complète réussie | `Contributors` | 7.8 |

### 10.8 Phase 7, livraison

| Fait | Action | Rôle requis | Section |
| :-- | :-- | :-- | :-- |
| [ ] | Publier le composant avec un message d'intention | `Contributors` | 8.1 |
| [ ] | Vérifier le déclenchement automatique du pipeline | `Contributors` | 8.2 |
| [ ] | Vérifier la réussite des deux étages | `Contributors` | 8.2 |
| [ ] | Vérifier l'opération dans le Power Platform Admin Center | `Power Platform admin` | 8.3 |
| [ ] | Rejouer les trois tests fonctionnels | Licence Dynamics 365 | 8.3 |
| [ ] | Mettre en place une stratégie de branche sur `main` | `Project Administrators` | 8.4 |
| [ ] | **Signaler tout point de blocage à contact@archia365.fr** | Aucun | 13 |

## 11. Annexe C : Conventions de nommage et bonnes pratiques

### 11.1 Conventions de nommage

Une convention de nommage n'est pas une coquetterie : dans un environnement où votre code cohabite avec celui de Microsoft et d'éventuels éditeurs tiers, elle évite les collisions et rend l'origine de chaque objet immédiatement lisible.

| Type d'objet | Convention | Exemple |
| :-- | :-- | :-- |
| Préfixe d'éditeur X++ | Trois lettres, appliquées à tout objet créé | `Arc` pour ARCHIA365 |
| Préfixe d'éditeur Dataverse | Deux à huit caractères, en minuscules, aligné sur le précédent | `arc` pour ARCHIA365 |
| Solution Dataverse | Préfixe, puis périmètre fonctionnel | `ARC Revue de credit client` |
| Type de données étendu | Préfixe, puis nom métier | `ArcCreditReviewDate` |
| Champ ajouté par extension | Préfixe, puis nom métier | `ArcCreditReviewDate` |
| Classe d'extension | Préfixe, objet étendu, suffixe obligatoire | `ArcCustTable_Extension` |
| Gestionnaire d'événements | Préfixe, objet, événement, suffixe | `ArcCustTable_EventHandler` |
| Fichier de libellés | Préfixe, puis `Labels` | `ArcLabels` |
| Modèle | Nom de l'éditeur, puis périmètre | `ArchiaExtensions` |
| Table créée | Préfixe, entité, puis `Table` | `ArcCreditReviewTable` |

**Pourquoi un préfixe.** Deux éditeurs qui ajouteraient tous deux un champ nommé `CreditReviewDate` sur `CustTable` provoqueraient un conflit de compilation insoluble sans renommage. Le préfixe rend la collision impossible.

**Pourquoi le suffixe `_Extension` est différent.** Ce suffixe n'est pas une convention, c'est une **exigence du compilateur** pour les classes portant l'attribut `ExtensionOf`. Il ne se négocie pas.

### 11.2 Règles d'extensibilité

1. **Ne modifiez jamais un objet standard.** C'est techniquement impossible depuis la version 10, et toute tentative de contournement produit du code non maintenable.
2. **Appelez toujours `next` dans une Chain of Command.** Omettre cet appel neutralise le comportement standard et celui des autres extensions.
3. **Préférez une extension à un gestionnaire d'événements lorsque les deux sont possibles.** La Chain of Command est vérifiée à la compilation, ce qui n'est pas le cas des gestionnaires liés par délégué.
4. **Ne stockez jamais de texte visible en dur.** Tout passe par un libellé.
5. **Une extension par objet et par modèle.** Multiplier les extensions du même objet dans un même modèle rend le comportement difficile à suivre.
6. **Vérifiez le retour du standard avant d'ajouter vos propres contrôles.** Cela évite l'empilement de messages d'erreur.

### 11.3 Règles de contrôle de source

1. **Ne versionnez jamais `PackagesLocalDirectory`.** Environ 24 Go de métadonnées Microsoft que le poste retélécharge à la demande.
2. **Versionnez toujours le fichier descripteur du modèle.** Sans lui, le modèle n'existe pas pour le compilateur.
3. **Publiez souvent, avec des messages d'intention.** Un message décrivant le besoin métier vaut mieux qu'une liste d'objets modifiés.
4. **Générez localement avant de publier.** Un pipeline qui échoue sur une faute de frappe fait perdre du temps à toute l'équipe.
5. **Protégez la branche principale dès que vous êtes plusieurs.**

### 11.4 Règles de déploiement

1. **Synchronisez la base après toute modification de structure.** Ajout de champ, de table, d'index ou de relation.
2. **Utilisez `Detach` et non `Stop` pour terminer une session de débogage.**
3. **Prévenez avant de déboguer sur un environnement partagé.** Le débogage suspend le serveur d'application.
4. **Alignez systématiquement les versions.** Celles des packages NuGet, celles de `packages.config` et celles des variables du pipeline doivent être identiques.

## 12. Annexe D : Références officielles

- [Unified developer experience for finance and operations apps, Microsoft Learn](https://learn.microsoft.com/en-us/power-platform/developer/unified-experience/finance-operations-dev-overview)
- [Create a solution in Power Apps, Microsoft Learn](https://learn.microsoft.com/en-us/power-apps/maker/data-platform/create-solution)
- [Install and configure development tools, Microsoft Learn](https://learn.microsoft.com/en-us/power-platform/developer/unified-experience/finance-operations-install-config-tools)
- [Visual Studio requirements for X++, Microsoft Learn](https://learn.microsoft.com/en-us/dynamics365/fin-ops-core/dev-itpro/dev-tools/developer-tools-vs2017)
- [Write, deploy, and debug X++ code, Microsoft Learn](https://learn.microsoft.com/en-us/power-platform/developer/unified-experience/finance-operations-debug)
- [Workflow to write, deploy, debug, and troubleshoot X++ code across multiple environments, Microsoft Learn](https://learn.microsoft.com/en-us/power-platform/developer/unified-experience/finance-operations-innerloop)
- [Continuous integration and deployment pour finance and operations, Microsoft Learn](https://learn.microsoft.com/en-us/power-platform/developer/unified-experience/finance-operations-pipelines)
- [Tutorial: Set up a build pipeline for finance and operations apps using Azure DevOps, Microsoft Learn](https://learn.microsoft.com/en-us/power-platform/admin/unified-experience/tutorial-build-pipeline-azure-devops)
- [Build automation that uses Microsoft-hosted agents and Azure Pipelines, Microsoft Learn](https://learn.microsoft.com/en-us/dynamics365/fin-ops-core/dev-itpro/dev-tools/hosted-build-automation)
- [Create deployable packages in Azure Pipelines, Microsoft Learn](https://learn.microsoft.com/en-us/dynamics365/fin-ops-core/dev-itpro/dev-tools/pipeline-create-deployable-package)
- [X++ in Git, Microsoft Learn](https://learn.microsoft.com/en-us/dynamics365/fin-ops-core/dev-itpro/dev-tools/git-intro)
- [Managed DevOps Pools, vue d'ensemble](https://learn.microsoft.com/en-us/azure/devops/managed-devops-pools/overview)
- [Prerequisites for Managed DevOps Pools](https://learn.microsoft.com/en-us/azure/devops/managed-devops-pools/prerequisites)
- [Create a Managed DevOps Pool using the Azure portal](https://learn.microsoft.com/en-us/azure/devops/managed-devops-pools/quickstart-azure-portal)
- [Microsoft Power Platform Build Tools for Azure DevOps](https://learn.microsoft.com/en-us/power-platform/alm/devops-build-tools)
- [Microsoft Power Platform Build Tools tasks](https://learn.microsoft.com/en-us/power-platform/alm/devops-build-tool-tasks)

## 13. À propos, contact et communauté

### 13.1 Auteur et éditeur

Document rédigé par **Rodrigue YENGO** pour **ARCHIA365** et **ARCHIALEARN**, dans le cadre de la série **Dynamics en 365**.

| Ressource | Lien |
| :-- | :-- |
| Profil de l'auteur | [Rodrigue YENGO sur LinkedIn](https://www.linkedin.com/in/rodrigue-yengo/) |
| Communauté | [Data & AI France Study Group](https://data-day.archifridays.com/) |
| Contact | contact@archia365.fr |

### 13.2 Data & AI France Study Group

Le **Data & AI France Study Group** est une communauté ouverte, soutenue par **ARCHIA365** et **ARCHIALEARN**, dont l'ambition est de bâtir la plus grande communauté Data francophone. Elle réunit celles et ceux qui souhaitent apprendre, partager et progresser autour des technologies Data et intelligence artificielle, à travers des sessions de formation, des parcours de préparation aux certifications et des événements réguliers.

### 13.3 Documents liés de la même série

| Document | Objet |
| :-- | :-- |
| *Mise en place d'un environnement de développement complet Dynamics 365 Finance and Operations sur un nouveau tenant* | Création du tenant, licences, Subscription Azure, capacité, environnement Sandbox, poste local, dépôt et chaîne CI/CD |
| *Du poste de développement au premier composant X++ livré* | Le présent document, centré sur l'outillage du développeur et la construction d'un composant |

### 13.4 Méthode d'élaboration

Ce document a été rédigé à l'issue de mises en place complètes menées de bout en bout. Les avertissements et les tableaux de dépannage correspondent à des difficultés réellement rencontrées.

Contenu vérifié au regard de la documentation Microsoft en vigueur au 25 août 2026. Les interfaces Microsoft évoluant fréquemment, certains libellés peuvent différer légèrement de ceux constatés à l'écran. La transition de Visual Studio 2022 vers Visual Studio 2026 étant en cours au moment de la rédaction, vérifiez la page de prérequis des outils de développement citée en annexe D si vous constatez un écart.

### 13.5 Vos retours

Cette procédure est vivante. Si vous rencontrez un point de blocage, si un libellé a changé, si une étape ne se déroule pas comme décrit, ou si vous souhaitez proposer une amélioration, écrivez-nous à **contact@archia365.fr**.

Pour que votre retour soit exploitable, précisez si possible :

- la **phase** et la **section** concernées, par exemple 5.6 ;
- le **message d'erreur exact**, copié tel quel ;
- la **version de plateforme** de votre environnement et celle de Visual Studio ;
- votre **rôle** au moment de l'action.

Chaque retour est étudié et alimente directement la version suivante de ce document.
