# Dynamics en 365

## Mise en place d'un environnement de développement complet Dynamics 365 Finance and Operations sur un nouveau tenant

### Procédure détaillée via le Power Platform Admin Center (PPAC)

| Rubrique | Valeur |
| :-- | :-- |
| Série | Dynamics en 365 |
| Auteur | Rodrigue YENGO, [profil LinkedIn](https://www.linkedin.com/in/rodrigue-yengo/) |
| Éditeur | ARCHIA365 / ARCHIALEARN |
| Communauté | [Data & AI France Study Group](https://data-day.archifridays.com/), soutenu par ARCHIA365 et ARCHIALEARN |
| Objet | Création de bout en bout d'un environnement de développement D365 F&O sur un tenant Microsoft neuf |
| Public visé | Consultant, développeur ou administrateur débutant sur la plateforme |
| Méthode | Provisionnement via Power Platform Admin Center, en remplacement de Lifecycle Services |
| Durée totale | 6 à 8 heures, dont environ 3 heures d'attente automatisée |
| Version du document | 4.0 |
| Date | 25 août 2026 |
| Contact | contact@archia365.fr |

**Genèse du document.** Cette procédure a été rédigée puis réécrite à l'issue de **deux déploiements complets réalisés de bout en bout**, sur deux tenants distincts. Chaque étape décrite ci-dessous a été exécutée, vérifiée, et le cas échéant corrigée à la lumière des blocages rencontrés lors du second déploiement. Les avertissements et les sections de dépannage ne sont pas théoriques : ils correspondent à des difficultés réellement observées.

**Appel à contribution.** Malgré cette double validation, les portails Microsoft évoluent vite et les configurations de tenant varient. Si vous rencontrez un point de blocage, un libellé qui a changé, une étape qui ne se déroule pas comme décrit, ou si vous identifiez une amélioration, faites-le nous remonter à l'adresse **contact@archia365.fr**. Précisez si possible la phase concernée, le message d'erreur exact et le contexte de votre tenant. Vos retours alimentent directement les versions suivantes de ce document.

**Convention de lecture.** Les libellés de l'interface Microsoft sont indiqués en anglais, en `police à chasse fixe`, suivis de leur équivalent français entre parenthèses. Exemple : `Try Azure for free` (Essayer Azure gratuitement). Les chemins de menu utilisent le signe `>` comme séparateur de niveau. Chaque phase et chaque action sensible sont précédées de la mention des **rôles requis** pour les exécuter.

## Sommaire

1. À lire avant de commencer
2. Phase 1 : Licences, création du tenant et activation des essais
3. Phase 2 : Compte Azure et création de la Subscription
4. Phase 3 : Liaison de la Subscription au Power Platform et gestion de la capacité
5. Phase 4 : Environnement Sandbox et applications Finance and Operations
6. Phase 5 : Poste de développement local
7. Phase 6 : Métadonnées, modèle et projet
8. Phase 7 : Azure DevOps et contrôle de source
9. Phase 8 : Accès direct à la base de données
10. Annexe A : Dépannage
11. Annexe B : Checklist séquentielle d'exhaustivité, de bout en bout
12. Annexe C : Checklist thématique de validation
13. Annexe D : Fin d'essai, coûts et nettoyage
14. Annexe E : Références officielles
15. À propos, contact et communauté

## 1. À lire avant de commencer

### 1.1 Objectif de la procédure

À l'issue de cette procédure, vous disposerez des éléments suivants :

- un **tenant Microsoft 365** neuf, avec son domaine `votresociete.onmicrosoft.com` ;
- une **licence d'essai Microsoft 365 E3**, socle d'identité et de productivité de l'organisation ;
- une **licence d'essai Dynamics 365 Finance Premium** affectée à votre compte ;
- une **Subscription Azure** (abonnement Azure) créée dans le tenant et rattachée à un compte de facturation ;
- un **Billing plan** (plan de facturation) de type `Pay-as-you-go` (paiement à l'usage) reliant le Power Platform à cette Subscription ;
- un **environnement Sandbox** contenant une instance complète de Dynamics 365 Finance and Operations, avec les outils de développement et les données de démonstration Contoso ;
- un **poste de développement local** opérationnel : Visual Studio 2022 Professional, extensions requises, environ 24 Go de métadonnées de référence, un modèle et un projet X++ ;
- une **organisation Azure DevOps** dotée d'un projet d'équipe et d'un dépôt configuré, avec le mapping du contrôle de source établi dans Visual Studio et votre premier modèle archivé ;
- un **accès SQL direct** à la base de données produit via SQL Server Management Studio.

### 1.2 Pourquoi le Power Platform Admin Center et non Lifecycle Services

Historiquement, tout environnement Dynamics 365 Finance and Operations était provisionné depuis **Lifecycle Services** (LCS). Microsoft a engagé la convergence de l'administration F&O vers le **Power Platform Admin Center**.

Trois points sont à retenir :

1. Depuis le **16 février 2026**, la création de nouveaux projets d'implémentation cloud dans LCS est **gelée** pour Finance, Supply Chain Management et Project Operations, pour les nouveaux clients et les nouveaux tenants.
2. Les clients existants disposant déjà d'un projet LCS actif continuent de l'utiliser normalement. Les projets Commerce, les migrations depuis AX 2012, les déploiements sur site et les migrations d'un tenant vers un autre ne sont pas concernés.
3. Concrètement, sur un tenant neuf, une connexion à LCS renvoie vers le Power Platform Admin Center.

**Alternative sans cloud.** Si votre seul objectif est de vous entraîner au développement X++ sur votre poste, un environnement **VHD local** téléchargeable reste possible. Le compromis est important : aucune fonctionnalité nécessitant le cloud, telle que les intégrations, Dataverse, les environnements liés ou le déploiement, ne sera disponible. La présente procédure couvre l'approche cloud.

### 1.3 Vue d'ensemble du parcours

| Phase | Objet | Temps actif | Temps d'attente |
| :-- | :-- | :-- | :-- |
| 1 | Tenant Microsoft 365 E3 et licences Dynamics 365 | 30 min | Aucun |
| 2 | Compte Azure et création de la Subscription | 30 min | 5 à 10 min |
| 3 | Resource group et Billing plan dans le PPAC | 20 min | 10 à 15 min |
| 4 | Environnement Sandbox et applications F&O | 20 min | 1 h à 2 h |
| 5 | SSMS, Visual Studio, extensions et assets | 45 min | 1 h à 2 h |
| 6 | Configuration des métadonnées, modèle et projet | 20 min | Aucun |
| 7 | Azure DevOps, dépôt et mapping du contrôle de source | 40 min | Aucun |
| 8 | Accès SQL direct | 10 min | Aucun |

**Conseil d'organisation.** Les phases 4 et 5 peuvent être menées en parallèle. Lancez l'installation de la `Finance and Operations Provisioning App` (application de provisionnement Finance and Operations), puis installez Visual Studio pendant que le provisionnement se déroule. La création de l'organisation et du projet Azure DevOps, décrite en 8.3 à 8.5, est également indépendante du reste et peut être réalisée à tout moment pendant ces temps d'attente. Seules les étapes de mapping, à partir de 8.7, exigent que les phases 5 et 6 soient achevées.

### 1.4 Glossaire

| Terme | Définition |
| :-- | :-- |
| **Tenant** (locataire) | Unité fondamentale d'organisation dans l'écosystème Microsoft. Identifiant unique attribué à une entreprise, auquel sont rattachés les utilisateurs, les licences et les services tels qu'Azure, Dynamics 365 et Microsoft 365. Il porte un domaine par défaut de la forme `votresociete.onmicrosoft.com`. |
| **Subscription** (abonnement) | Conteneur de facturation et de déploiement des ressources Azure. Un tenant peut héberger plusieurs Subscriptions. C'est l'unité à laquelle sont imputés les coûts. |
| **Billing account** (compte de facturation) | Entité commerciale créée lors de l'inscription à Azure. Elle porte le contrat, le mode de paiement et les profils de facturation sous lesquels les Subscriptions sont créées. |
| **Environment** (environnement) | Conteneur Power Platform hébergeant une base Dataverse, des applications et, dans le cas présent, l'instance Finance and Operations. Un tenant contient plusieurs environnements. |
| **Sandbox** (bac à sable) | Type d'environnement non productif, destiné au développement, aux tests et à la formation. Type requis pour le développement X++. |
| **Dataverse** | Plateforme de données commune du Power Platform, sur laquelle repose l'expérience unifiée Finance and Operations. |
| **Capacité** | Volume de stockage, en gigaoctets, alloué au tenant et réparti entre base de données, fichiers et journaux. Un essai n'en fournit qu'une dotation minimale. |
| **Billing plan** (plan de facturation) | Également appelé `Pay-as-you-go plan` (plan de paiement à l'usage) ou `billing policy` (stratégie de facturation). Mécanisme reliant un environnement Power Platform à une Subscription Azure, afin que la consommation soit facturée à l'usage plutôt que plafonnée par la capacité achetée. |
| **Resource group** (groupe de ressources) | Conteneur logique de ressources Azure, rattaché à une Subscription et à une région. |
| **Modèle** (`model`) | Unité logique de personnalisation X++ regroupant des éléments tels que tables, classes et formulaires. Il est contenu dans un `package` (paquet). |
| **PackagesLocalDirectory** | Dossier local contenant les métadonnées de référence de l'application standard, d'un volume approximatif de 24 Go. |
| **X++** | Langage de programmation propriétaire de Dynamics 365 Finance and Operations. |
| **PPAC** | Power Platform Admin Center, accessible à l'adresse `admin.powerplatform.microsoft.com`. |

### 1.5 Prérequis

#### 1.5.1 Prérequis matériels du poste de développement

| Élément | Minimum | Recommandé |
| :-- | :-- | :-- |
| Système d'exploitation | Windows 10, 64 bits | Windows 11 |
| Mémoire vive | 16 Go | 32 Go |
| Espace disque libre | 60 Go | 100 Go sur disque SSD |
| Connexion Internet | 20 Mbit/s | 100 Mbit/s ou plus |
| Droits | Administrateur local du poste | Administrateur local du poste |

L'espace disque est la contrainte la plus souvent sous-estimée. Visual Studio occupe environ 10 Go, les assets Dynamics 365 environ 24 Go après décompression, auxquels s'ajoutent la base de références croisées et vos propres métadonnées.

#### 1.5.2 Prérequis administratifs

- Une **adresse de messagerie personnelle** non encore rattachée à un tenant Microsoft. Une adresse Gmail convient parfaitement.
- Un **numéro de téléphone mobile** pour la validation et l'authentification multifacteur.
- Une **carte bancaire**, de débit ou de crédit, dont les **paiements en ligne sont activés**. Elle est exigée deux fois : à la création du tenant, puis à l'ouverture du compte Azure.
- Un **identifiant fiscal** si votre pays l'exige. En France, le numéro de TVA intracommunautaire est généralement accepté, et le champ peut rester vide pour un particulier.
- Une **adresse postale** valide et vérifiable.

#### 1.5.3 Prérequis navigateur

Utilisez **Microsoft Edge** ou **Google Chrome**, de préférence dans un **profil dédié** ou une fenêtre de navigation privée. Cette précaution évite les conflits de session entre votre identité personnelle et le compte administrateur du nouveau tenant, source fréquente d'erreurs de connexion au cours des phases 2 et 3.

### 1.6 Coûts réels et pièges de facturation

Cette procédure repose sur des offres d'essai, mais elle n'est pas gratuite en toutes circonstances. Le tableau ci-dessous récapitule la réalité économique.

| Élément | Coût affiché | Réalité |
| :-- | :-- | :-- |
| Microsoft 365 E3 | Essai de 30 jours, 25 utilisateurs | Se renouvelle automatiquement en abonnement payant si vous ne le désactivez pas. Le tarif E3 est nettement supérieur à celui des offres Business. |
| Dynamics 365 Finance Premium | Essai de 30 jours, 25 licences | Se renouvelle également. Sélectionnez impérativement l'option de non-renouvellement lors de la souscription. |
| Compte Azure | 200 USD de crédit sur 30 jours | Le crédit ne couvre pas toutes les consommations. Passé les 30 jours, la Subscription bascule en paiement à l'usage. |
| Billing plan Power Platform | Aucun coût d'activation | La consommation de l'environnement au-delà de la capacité incluse est facturée sur la Subscription Azure, donc sur votre carte bancaire. |
| Visual Studio Professional | Essai d'environ 90 jours via Dev Essentials | Une licence est requise ensuite. Visual Studio Community constitue une alternative gratuite pour les usages éligibles. |

**Trois règles de prudence.**

1. À la souscription de chaque essai, choisissez systématiquement l'option de non-renouvellement, libellée `No, cancel at expiration` (Non, annuler à l'expiration) ou équivalent.
2. Dans le portail Azure, créez une **alerte de budget** à un montant faible, par exemple 10 euros, dès l'ouverture du compte.
3. Notez dans votre agenda la date d'expiration des essais et appliquez l'annexe D avant cette échéance.

### 1.7 Rôles et permissions requis

La question des droits est la deuxième cause de blocage de cette procédure, juste après celle de la capacité. Trois familles de rôles interviennent, sur trois plans distincts, et il est essentiel de ne pas les confondre.

#### 1.7.1 Les trois plans de gouvernance

| Plan | Où les rôles sont attribués | Ce qu'ils gouvernent |
| :-- | :-- | :-- |
| **Microsoft Entra ID et Microsoft 365** | Microsoft 365 Admin Center, ou Microsoft Entra admin center | Achat des abonnements, création et gestion des utilisateurs, affectation des licences |
| **Azure** | Portail Azure, au niveau du compte de facturation, de la Subscription ou du groupe de ressources | Création de Subscriptions, création de ressources, enregistrement des fournisseurs de ressources, gestion des budgets |
| **Power Platform et Dynamics 365** | Power Platform Admin Center, puis application Finance and Operations | Création d'environnements, plans de facturation, installation d'applications, administration fonctionnelle |
| **Azure DevOps** | Portail `dev.azure.com`, au niveau de l'organisation ou du projet | Création de l'organisation et des projets, paramétrage des dépôts, droits d'archivage du code |

Un même compte peut cumuler les trois. C'est d'ailleurs le cas du compte créé en phase 1, qui devient automatiquement `Global admin` (Administrateur général) du tenant et `Owner` (Propriétaire) du compte de facturation Azure. C'est la configuration la plus simple pour dérouler cette procédure. En entreprise, ces droits sont en revanche répartis entre plusieurs personnes, et la matrice ci-dessous devient un outil de coordination.

#### 1.7.2 Matrice consolidée des rôles par action

| Phase | Action | Rôle minimal requis | Plan concerné |
| :-- | :-- | :-- | :-- |
| 1 | Créer le tenant via l'essai Microsoft 365 E3 | Aucun rôle préalable. Le souscripteur devient automatiquement `Global admin` (Administrateur général) | Entra ID |
| 1 | Souscrire l'essai Dynamics 365 Finance Premium | `Billing administrator` (Administrateur de facturation) ou `Global admin` | Microsoft 365 |
| 1 | Affecter les licences à un utilisateur | `License administrator` (Administrateur de licences), `User administrator` (Administrateur d'utilisateurs) ou `Global admin` | Microsoft 365 |
| 1 | Configurer l'authentification multifacteur d'un utilisateur | `Authentication administrator` (Administrateur d'authentification) ou `Global admin` | Entra ID |
| 2 | S'inscrire à Azure et créer le compte de facturation | Aucun rôle préalable. Le souscripteur devient `Owner` (Propriétaire) du compte de facturation | Azure |
| 2 | Créer une Subscription supplémentaire | `Owner` (Propriétaire), `Contributor` (Contributeur) ou `Azure subscription creator` (Créateur d'abonnement Azure) sur la section de facture, le profil de facturation ou le compte de facturation | Azure |
| 2 | Enregistrer le fournisseur de ressources `Microsoft.PowerPlatform` | `Owner` (Propriétaire) ou `Contributor` (Contributeur) sur la Subscription | Azure |
| 2 | Créer un `Resource group` (groupe de ressources) | `Owner` (Propriétaire) ou `Contributor` (Contributeur) sur la Subscription | Azure |
| 2 | Créer un budget et des alertes de coût | `Cost Management Contributor` (Contributeur de gestion des coûts), `Owner` ou `Contributor` sur la Subscription | Azure |
| 3 | Créer un `Billing plan` (plan de facturation) dans le PPAC | Côté Power Platform : `Power Platform admin`, `Global admin`, `Dynamics 365 admin` ou `Environment admin`. Côté Azure, sur la Subscription visée : **`Owner` (Propriétaire) ou `Contributor` (Contributeur)** | Les deux |
| 3 | Lier un environnement à un `Billing plan` existant | `Power Platform admin`, `Global admin` ou `Dynamics 365 admin` pour tout environnement. `Environment admin` pour ses propres environnements uniquement | Power Platform |
| 4 | Créer un environnement `Sandbox` | `Power Platform admin` (Administrateur Power Platform), `Dynamics 365 admin` (Administrateur Dynamics 365) ou `Global admin` | Power Platform |
| 4 | Installer `Platform Tools` et la `Provisioning App` | `Power Platform admin`, `Dynamics 365 admin` ou `Global admin`, ou détenir une licence Dynamics 365 éligible | Power Platform |
| 4 | Attribuer le rôle `System administrator` dans l'application | `System administrator` (Administrateur système) dans l'environnement Finance and Operations | Dynamics 365 |
| 5 | Installer SSMS, Visual Studio et les extensions | Administrateur local du poste de travail | Poste local |
| 5 | Connecter Visual Studio à l'environnement | `System administrator` (Administrateur système) dans l'environnement Finance and Operations | Dynamics 365 |
| 6 | Créer un modèle et un projet, générer et déployer | `System administrator` (Administrateur système) dans l'environnement | Dynamics 365 |
| 7 | Créer une organisation Azure DevOps | Aucun rôle préalable. Le créateur devient `Organization Owner` (Propriétaire de l'organisation) | Azure DevOps |
| 7 | Autoriser la création de dépôts TFVC au niveau de l'organisation | `Project Collection Administrators` (Administrateurs de collection de projets) ou `Organization Owner` | Azure DevOps |
| 7 | Créer un projet d'équipe | `Project Collection Administrators` (Administrateurs de collection de projets) | Azure DevOps |
| 7 | Créer l'arborescence de contrôle de source et mapper l'espace de travail | `Contributors` (Contributeurs) du projet, niveau d'accès `Basic` (De base) | Azure DevOps |
| 7 | Archiver du code, `Check In` | `Contributors` (Contributeurs) du projet | Azure DevOps |
| 8 | Demander des identifiants SQL temporaires | `System administrator` (Administrateur système) dans l'environnement | Dynamics 365 |

#### 1.7.3 Point d'attention sur la double exigence de la phase 3

La création du `Billing plan` est la seule action de la procédure qui exige des droits **simultanément sur deux plans**. Il ne suffit pas d'être administrateur du Power Platform : sans le rôle `Owner` (Propriétaire) ou `Contributor` (Contributeur) sur la Subscription Azure visée, celle-ci n'apparaîtra pas dans la liste déroulante de l'assistant, ou la validation échouera au moment de l'enregistrement.

Si vous opérez sur un tenant d'entreprise où ces responsabilités sont séparées, prévoyez cette coordination en amont. Le contournement habituel consiste à demander à l'équipe Azure de vous attribuer le rôle `Contributor` sur une Subscription dédiée, plutôt que sur l'ensemble du parc.

#### 1.7.4 Délai de propagation des rôles

L'attribution d'un rôle d'administration n'est pas instantanée dans tous les services. Un délai de mise en cache pouvant atteindre **douze heures** est documenté pour certaines vérifications de droits liées à l'installation des applications Finance and Operations. Si une action est refusée alors que le rôle vient d'être attribué, déconnectez-vous, reconnectez-vous, puis patientez avant de conclure à une erreur de configuration.

## 2. Phase 1 : Licences, création du tenant et activation des essais

**Objectif de la phase.** Disposer d'un tenant Microsoft 365 propre, doté d'une licence Microsoft 365 E3 et d'une licence Dynamics 365 Finance Premium affectées à votre compte administrateur.

**Rôles requis pour cette phase.** Aucun rôle préalable n'est nécessaire pour créer le tenant : la personne qui souscrit l'essai en devient automatiquement `Global admin` (Administrateur général). Pour les actions suivantes, le rôle `Billing administrator` (Administrateur de facturation) est requis pour souscrire un abonnement, et `License administrator` (Administrateur de licences) ou `User administrator` (Administrateur d'utilisateurs) pour affecter les licences. Le rôle `Global admin` couvre l'ensemble de ces actions.

### 2.1 Comprendre ce que vous créez

Le **tenant** est la brique de base. Toutes les licences acquises par l'organisation y sont rattachées : la licence Microsoft 365 comme la licence Finance and Operations que nous souscrirons ensuite. Il porte un domaine par défaut au format `votresociete.onmicrosoft.com`, que vous choisissez librement.

Deux points sont essentiels :

1. La souscription à Microsoft 365 E3 est ici le **moyen de créer le tenant**. Ce n'est pas la seule voie possible, mais c'est celle qui reflète le mieux une organisation d'entreprise réelle.
2. Une fois créé, le **tenant existe indépendamment de l'abonnement**. À l'expiration de l'essai de 30 jours, le tenant ne disparaît pas. Seules les licences associées cessent d'être actives.

### 2.2 Pourquoi Microsoft 365 E3 plutôt qu'une offre Business

Le choix de l'offre E3 n'est pas anodin. Il conditionne la représentativité de votre environnement de formation ou de démonstration.

| Critère | Offres Business | Microsoft 365 E3 |
| :-- | :-- | :-- |
| Cible | Organisations de moins de 300 utilisateurs | Entreprise, sans limite de sièges |
| Identité | Microsoft Entra ID Free | Microsoft Entra ID P1, avec accès conditionnel et gouvernance |
| Sécurité et conformité | Fonctions de base | Rétention, protection de l'information, audit avancé |
| Représentativité | Partielle | Alignée sur les tenants clients réels de Dynamics 365 |
| Droits Power Platform inclus | Limités | Droits d'usage étendus pour Power Apps et Power Automate dans le contexte des applications Microsoft 365 |

En pratique, la quasi-totalité des clients Dynamics 365 Finance and Operations exploitent une base E3 ou E5. Bâtir votre environnement de formation sur E3 vous évite de rencontrer, en situation réelle, des écrans et des comportements que vous n'aurez jamais vus.

### 2.3 Créer le tenant via l'essai Microsoft 365 E3

**Étape 1.** Ouvrez votre navigateur et recherchez `Microsoft 365 E3` dans un moteur de recherche, ou rendez-vous directement sur la page produit officielle de Microsoft consacrée à l'offre E3.

**Étape 2.** Sur la page de l'offre, repérez le bouton `Try free for one month` (Essayer gratuitement pendant un mois) ou `Try for free` (Essayer gratuitement). Cliquez dessus.

**Étape 3.** Vous êtes redirigé vers un formulaire de souscription. L'essai octroie **25 licences utilisateur pour 30 jours**, quel que soit le nombre d'utilisateurs que vous indiquez.

**Étape 4.** Saisissez votre **adresse de messagerie**. Une adresse Gmail est acceptée.

Microsoft vérifie alors si cette adresse est déjà rattachée à un tenant existant. Si ce n'est pas le cas, un message vous propose de créer un compte. Cliquez sur `Set up account` (Configurer le compte).

**Point de vigilance.** Si Microsoft indique que l'adresse est déjà associée à un compte, utilisez une autre adresse. Créer le tenant sur une identité déjà engagée dans une autre organisation est la première cause de blocage ultérieur.

**Étape 5.** Renseignez le formulaire d'identité :

- `First name` (Prénom) et `Last name` (Nom) ;
- `Company size` (Taille de l'entreprise) ;
- `Phone number` (Numéro de téléphone).

**Étape 6.** Saisissez votre **adresse postale**, puis cliquez sur `Save` (Enregistrer).

Un avertissement indiquant que l'adresse n'a pas pu être validée peut apparaître. Relisez attentivement les champs. Si la saisie est correcte, cliquez sur `Use this address` (Utiliser cette adresse).

**Étape 7.** Définissez votre **nom de domaine**, c'est-à-dire l'identifiant unique de votre organisation. Le résultat sera de la forme `votresociete.onmicrosoft.com`.

Sur le même écran, définissez :

- votre `Username` (Nom d'utilisateur), par exemple `admin`, ce qui produira l'identifiant complet `admin@votresociete.onmicrosoft.com` ;
- votre `Password` (Mot de passe).

**Point de vigilance.** Consignez immédiatement ces informations. L'identifiant complet et le mot de passe seront utilisés à chaque phase de la procédure. Choisissez un nom de domaine court, en minuscules, sans caractère spécial ni accent.

**Étape 8.** Saisissez votre **identifiant fiscal** si le formulaire l'exige.

**Étape 9.** Saisissez vos **coordonnées bancaires**. Une carte de débit ou de crédit convient. Vérifiez simplement que les transactions en ligne sont autorisées sur cette carte.

**Étape 10.** Relisez l'ensemble des informations, puis cliquez sur `Save` (Enregistrer).

**Étape 11.** Cliquez sur `Start trial` (Démarrer l'essai).

**Étape 12.** Microsoft vous invite à configurer l'**authentification multifacteur** (`Multi-factor authentication`, MFA). Suivez les instructions affichées. Le plus simple consiste à utiliser l'application Microsoft Authenticator ou la réception d'un code par SMS.

**Étape 13.** Un écran de confirmation indique que votre abonnement est prêt.

**Point de contrôle.** Vous pouvez vous connecter à `https://admin.microsoft.com` avec l'identifiant `votreutilisateur@votresociete.onmicrosoft.com`.

### 2.4 Souscrire l'essai Dynamics 365 Finance Premium

**Rôle requis.** `Billing administrator` (Administrateur de facturation) ou `Global admin` (Administrateur général). Un simple administrateur d'utilisateurs ne peut pas souscrire un abonnement.

**Étape 1.** Depuis la page de confirmation, ouvrez le **Microsoft 365 Admin Center** (Centre d'administration Microsoft 365) via le lien `admin.cloud.microsoft` présent dans le volet de gauche, ou directement à l'adresse `https://admin.microsoft.com`.

**Étape 2.** Dans le volet de navigation, cliquez sur `Marketplace` (Place de marché).

**Étape 3.** Dans la barre de recherche, saisissez `Finance`, puis validez.

**Étape 4.** Dans les résultats, repérez `Dynamics 365 Finance Premium` portant l'étiquette `Trial available` (Essai disponible). Cliquez sur `Details` (Détails).

**Étape 5.** Sur l'écran suivant, cliquez sur `Select a plan` (Sélectionner un plan) et choisissez le **plan d'essai**, deuxième option de la liste.

**Étape 6.** Les informations de facturation sont préremplies à partir de la souscription Microsoft 365 E3. Cliquez sur `Next` (Suivant).

**Étape 7.** Microsoft demande si l'essai doit se transformer en abonnement payant à son échéance.

**Étape critique.** Sélectionnez la deuxième option, `No, cancel at expiration` (Non, annuler à l'expiration). L'abonnement sera alors automatiquement annulé au bout de 30 jours, sans facturation.

**Étape 8.** Cliquez sur `Start trial` (Démarrer l'essai).

**Étape 9.** Un écran de confirmation indique que l'essai Dynamics 365 Finance Premium a été ajouté, accompagné de 25 licences.

### 2.5 Affecter les licences à votre compte

**Rôle requis.** `License administrator` (Administrateur de licences), `User administrator` (Administrateur d'utilisateurs) ou `Global admin` (Administrateur général).

Posséder les licences ne suffit pas. Il faut en attribuer une à votre utilisateur.

**Étape 1.** Revenez à la page d'accueil du Microsoft 365 Admin Center.

**Étape 2.** Ouvrez `Users` (Utilisateurs) puis `Active users` (Utilisateurs actifs), et cliquez sur votre compte.

**Étape 3.** Ouvrez l'onglet `Licenses and apps` (Licences et applications).

**Étape 4.** Cochez `Dynamics 365 Finance Premium`. Vérifiez également que la licence `Microsoft 365 E3` est cochée.

**Étape 5.** Cliquez sur `Save changes` (Enregistrer les modifications).

### 2.6 Checklist de validation de la phase 1

- [ ] Le tenant est créé et son domaine `*.onmicrosoft.com` est noté.
- [ ] L'identifiant administrateur et le mot de passe sont consignés en lieu sûr.
- [ ] L'authentification multifacteur est configurée et fonctionnelle.
- [ ] L'essai Microsoft 365 E3 est actif.
- [ ] L'essai Dynamics 365 Finance Premium est actif, avec 25 licences visibles.
- [ ] L'option `No, cancel at expiration` a bien été retenue pour l'essai Dynamics.
- [ ] Les licences E3 et Finance Premium apparaissent comme affectées à votre compte utilisateur.

## 3. Phase 2 : Compte Azure et création de la Subscription

**Objectif de la phase.** Disposer d'une **Subscription Azure** active dans le tenant. C'est le prérequis indispensable du `Billing plan` (plan de facturation) Dataverse qui sera créé en phase 3.

**Rôles requis pour cette phase.** Aucun rôle préalable pour l'inscription initiale à Azure : le souscripteur devient `Owner` (Propriétaire) du compte de facturation créé. Pour créer une Subscription supplémentaire, le rôle `Owner` (Propriétaire), `Contributor` (Contributeur) ou `Azure subscription creator` (Créateur d'abonnement Azure) est requis sur la section de facture, le profil de facturation ou le compte de facturation. Pour enregistrer un fournisseur de ressources et créer un groupe de ressources, le rôle `Owner` ou `Contributor` sur la Subscription est requis.

### 3.1 Pourquoi une Subscription est indispensable

Il est fréquent de confondre trois notions distinctes. Les clarifier évite la majorité des blocages rencontrés dans cette procédure.

| Notion | Ce que c'est | Ce que ce n'est pas |
| :-- | :-- | :-- |
| **Compte Azure** | Une identité, en pratique votre compte `@votresociete.onmicrosoft.com`, autorisée à se connecter au portail Azure. | Ce n'est pas une entité de facturation. |
| **Billing account** (compte de facturation) | L'entité commerciale créée à l'inscription : contrat accepté, adresse, moyen de paiement, profil de facturation. | Ce n'est pas un conteneur de ressources. |
| **Subscription** (abonnement) | Le conteneur dans lequel les ressources sont réellement créées et auquel les coûts sont imputés. | Ce n'est pas un simple identifiant de compte. |

Le `Billing plan` du Power Platform ne se rattache **ni** à un compte Azure, **ni** à un compte de facturation, mais bien à une **Subscription** et à un `Resource group` (groupe de ressources) appartenant à cette Subscription. Sans Subscription active et visible dans le tenant, la liste déroulante `Azure subscription` (Abonnement Azure) de l'assistant du PPAC restera **vide**, et la phase 3 sera impossible à mener.

### 3.2 Deux chemins possibles

Selon votre situation, deux chemins mènent à une Subscription utilisable.

| Situation | Chemin recommandé |
| :-- | :-- |
| Tenant neuf, aucune inscription Azure préalable | Chemin A : inscription à l'offre `Azure free account` (Compte gratuit Azure), qui crée automatiquement une première Subscription. |
| Compte de facturation Azure déjà existant, ou besoin d'une Subscription supplémentaire dédiée | Chemin B : création explicite d'une Subscription depuis le portail Azure. |

Le chemin A est le plus simple pour un tenant neuf. Le chemin B reste indispensable si vous souhaitez isoler la consommation Power Platform dans une Subscription dédiée, ce qui constitue une bonne pratique en contexte professionnel.

### 3.3 Chemin A : créer le compte Azure et la Subscription initiale

**Étape 1.** Ouvrez `https://azure.microsoft.com`.

**Point de vigilance majeur.** Assurez-vous d'être connecté avec le compte `@votresociete.onmicrosoft.com` créé en phase 1, et non avec une identité personnelle. La Subscription doit appartenir **au même tenant** que l'environnement Power Platform. Une Subscription créée dans un autre tenant n'apparaîtra jamais dans l'assistant du PPAC, et cette erreur n'est pas corrigeable simplement.

**Étape 2.** Cliquez sur `Try Azure for free` (Essayer Azure gratuitement) ou `Start free` (Commencer gratuitement).

**Étape 3.** Lisez et acceptez le contrat d'utilisation, puis cliquez sur `Next` (Suivant).

**Étape 4.** Vos informations de profil sont préremplies à partir du compte connecté. Complétez les champs manquants.

**Étape 5.** Procédez à la **vérification d'identité par téléphone**. Un code vous est envoyé par SMS ou par appel vocal.

**Étape 6.** Confirmez le **moyen de paiement**. Une autorisation bancaire de faible montant peut être effectuée à titre de vérification, puis annulée.

**Étape 7.** Cliquez sur `Sign up` (S'inscrire).

À ce stade, Azure crée automatiquement :

- un **Billing account** (compte de facturation) de type Microsoft Customer Agreement ;
- un **Billing profile** (profil de facturation) et une **Invoice section** (section de facture) ;
- une première **Subscription**, généralement nommée `Azure subscription 1` (Abonnement Azure 1) ou `Free Trial` (Version d'évaluation gratuite).

**Étape 8.** Ouvrez le portail Azure à l'adresse `https://portal.azure.com`. Vous devez y voir votre crédit gratuit ainsi que votre Subscription active.

### 3.4 Chemin B : créer explicitement une Subscription

Suivez ce chemin si aucune Subscription n'apparaît, si celle créée automatiquement n'est pas exploitable, ou si vous souhaitez une Subscription dédiée au Power Platform.

#### 3.4.1 Prérequis de rôles

Pour créer une Subscription, votre compte doit détenir l'un des rôles suivants sur le contrat Microsoft Customer Agreement :

| Rôle | Portée |
| :-- | :-- |
| `Owner` (Propriétaire) | Section de facture, profil de facturation ou compte de facturation |
| `Contributor` (Contributeur) | Section de facture, profil de facturation ou compte de facturation |
| `Azure subscription creator` (Créateur d'abonnement Azure) | Section de facture |

En tant que créateur du tenant et titulaire de l'inscription Azure, vous détenez le rôle `Owner` sur le compte de facturation. Aucune action supplémentaire n'est requise.

#### 3.4.2 Identifier votre compte de facturation

**Étape 1.** Dans le portail Azure, recherchez `Cost Management + Billing` (Gestion des coûts et facturation) dans la barre de recherche supérieure.

**Étape 2.** Ouvrez `Billing scopes` (Portées de facturation) ou `Billing accounts` (Comptes de facturation).

**Étape 3.** Notez le **nom** et le **type** de votre compte de facturation. Le type conditionne l'assistant de création affiché à l'étape suivante.

#### 3.4.3 Créer la Subscription

**Étape 1.** Dans le portail Azure, recherchez et ouvrez `Subscriptions` (Abonnements).

**Étape 2.** Cliquez sur `Add` (Ajouter).

**Étape 3.** Sous l'onglet `Basics` (Informations de base), renseignez les champs suivants :

| Champ | Valeur recommandée | Commentaire |
| :-- | :-- | :-- |
| `Subscription name` (Nom de l'abonnement) | `SUB-PowerPlatform-D365FO` | Nom explicite, facilitant l'identification ultérieure dans le PPAC |
| `Billing account` (Compte de facturation) | Le compte identifié en 3.4.2 | Un seul choix possible en règle générale |
| `Billing profile` (Profil de facturation) | Le profil par défaut | Porte le moyen de paiement |
| `Invoice section` (Section de facture) | La section par défaut | Permet la ventilation analytique des coûts |
| `Plan` (Plan) | `Microsoft Azure Plan` (Plan Microsoft Azure) | Retenez `Microsoft Azure Plan for DevTest` (Plan Microsoft Azure pour DevTest) uniquement si votre contrat le prévoit |

**Étape 4.** Sous l'onglet `Advanced` (Avancé), renseignez :

- `Subscription directory` (Répertoire de l'abonnement) : sélectionnez impérativement votre annuaire Microsoft Entra ID, celui du tenant créé en phase 1 ;
- `Management group` (Groupe d'administration) : conservez la valeur par défaut ;
- `Subscription owners` (Propriétaires de l'abonnement) : ajoutez votre compte administrateur.

**Étape 5.** Sous l'onglet `Tags` (Étiquettes), vous pouvez ajouter une paire nom et valeur, par exemple `Projet` et `D365FO-DEV`. Cette étape est facultative mais recommandée pour le suivi des coûts.

**Étape 6.** Cliquez sur `Review + create` (Vérifier et créer), contrôlez la synthèse, puis cliquez sur `Create` (Créer).

**Étape 7.** La Subscription est créée immédiatement. Une notification le confirme.

### 3.5 Enregistrer le fournisseur de ressources Power Platform

**Rôle requis.** `Owner` (Propriétaire) ou `Contributor` (Contributeur) sur la Subscription. Un rôle `Reader` (Lecteur) permet de consulter le statut mais pas de l'enregistrer.

Cette étape technique est souvent omise, alors qu'elle conditionne la réussite de la phase 3. Azure n'autorise la création de ressources d'un service que si le **fournisseur de ressources** correspondant est enregistré sur la Subscription.

**Étape 1.** Dans le portail Azure, ouvrez `Subscriptions` (Abonnements) et sélectionnez votre Subscription.

**Étape 2.** Dans le volet de gauche, cliquez sur `Resource providers` (Fournisseurs de ressources).

**Étape 3.** Recherchez `Microsoft.PowerPlatform`.

**Étape 4.** Si son statut est `NotRegistered` (Non enregistré), sélectionnez la ligne et cliquez sur `Register` (Enregistrer).

**Étape 5.** Patientez une à deux minutes, puis rafraîchissez la page. Le statut doit passer à `Registered` (Enregistré).

### 3.6 Créer le Resource group

**Rôle requis.** `Owner` (Propriétaire) ou `Contributor` (Contributeur) sur la Subscription.

Le `Resource group` (groupe de ressources) est un conteneur logique de ressources Azure. L'assistant du `Billing plan` en exige un.

**Étape 1.** Dans le portail Azure, recherchez `Resource groups` (Groupes de ressources).

**Étape 2.** Cliquez sur `Create` (Créer).

**Étape 3.** Renseignez les champs :

| Champ | Valeur |
| :-- | :-- |
| `Subscription` (Abonnement) | La Subscription créée précédemment |
| `Resource group` (Groupe de ressources) | Un nom explicite, par exemple `rg-d365fo-dev` |
| `Region` (Région) | Une région géographiquement cohérente avec celle de l'environnement Power Platform, par exemple `France Central` ou `West Europe` |

**Étape 4.** Cliquez sur `Review + create` (Vérifier et créer), puis sur `Create` (Créer).

### 3.7 Définir une alerte de budget

**Rôle requis.** `Cost Management Contributor` (Contributeur de gestion des coûts), `Owner` (Propriétaire) ou `Contributor` (Contributeur) sur la Subscription.

Cette étape est facultative sur le plan technique, mais fortement recommandée sur le plan financier.

**Étape 1.** Dans le portail Azure, ouvrez `Cost Management + Billing` (Gestion des coûts et facturation).

**Étape 2.** Sélectionnez votre Subscription, puis cliquez sur `Budgets` (Budgets).

**Étape 3.** Cliquez sur `Add` (Ajouter).

**Étape 4.** Définissez un montant faible, par exemple 10 euros, et une périodicité mensuelle.

**Étape 5.** Configurez une alerte par courrier électronique à 50 %, 80 % et 100 % du budget.

**Étape 6.** Cliquez sur `Create` (Créer).

### 3.8 Checklist de validation de la phase 2

- [ ] Le compte Azure a été créé avec le compte `@votresociete.onmicrosoft.com`.
- [ ] Une Subscription est visible dans `Subscriptions` (Abonnements) du portail Azure.
- [ ] La Subscription est rattachée au **même annuaire Microsoft Entra ID** que le tenant.
- [ ] Le statut de la Subscription est `Active` (Actif).
- [ ] Le fournisseur de ressources `Microsoft.PowerPlatform` est au statut `Registered` (Enregistré).
- [ ] Un `Resource group` existe, dans une région cohérente.
- [ ] Une alerte de budget est configurée.

## 4. Phase 3 : Liaison de la Subscription au Power Platform et gestion de la capacité

**Objectif de la phase.** Lever le plafond de capacité du tenant afin de pouvoir créer un environnement de type `Sandbox`.

**Rôles requis pour cette phase.** Cette phase exige des droits sur **deux plans simultanément**. Côté Power Platform : `Power Platform admin` (Administrateur Power Platform), `Global admin` (Administrateur général), `Dynamics 365 admin` (Administrateur Dynamics 365) ou `Environment admin` (Administrateur d'environnement). Côté Azure, sur la Subscription visée : **`Owner` (Propriétaire) ou `Contributor` (Contributeur)**. L'absence de ce second rôle est la cause la plus fréquente d'une liste `Azure subscription` vide dans l'assistant.

### 4.1 Le mécanisme de capacité du Power Platform

Cette section est la clé de voûte de la procédure. Elle explique pourquoi la phase 2 était indispensable.

Chaque tenant Power Platform dispose d'un **pool de capacité** exprimé en gigaoctets, réparti en trois catégories : `Dataverse Database` (base de données Dataverse), `Dataverse File` (fichiers Dataverse) et `Dataverse Log` (journaux Dataverse). Chaque environnement créé consomme une part de ce pool.

Cette capacité provient des **licences acquises**. Une licence Dynamics 365 payante apporte une dotation confortable. En revanche, une **licence d'essai n'apporte qu'une dotation minimale**, volontairement limitée.

#### 4.1.1 La conséquence directe

Les environnements de type `Sandbox` et `Production` consomment la capacité du pool. Les environnements de type `Trial` (Version d'évaluation) n'y touchent pas, car ils sont temporaires et bridés.

Sur un tenant neuf alimenté uniquement par des essais, le pool de capacité est donc **insuffisant**. Le Power Platform Admin Center refusera la création d'un environnement `Sandbox`, généralement avec un message du type `You don't have enough capacity to create this environment` (Vous ne disposez pas d'une capacité suffisante pour créer cet environnement), ou en grisant purement et simplement le type `Sandbox`.

#### 4.1.2 Pourquoi cela bloque le développement

L'**expérience de développement unifiée**, celle qui permet à Visual Studio de se connecter à l'environnement, de déployer des modèles X++ et de synchroniser la base, n'est disponible **que sur un environnement `Sandbox`**. La `Finance and Operations Provisioning App`, qui installe les outils de développement, n'est elle-même prise en charge que sur les types `Sandbox` et `Trial (subscription-based)` (Version d'évaluation basée sur un abonnement), jamais sur `Production`.

La chaîne de dépendances est la suivante :

1. Une **Subscription Azure** existe dans le tenant.
2. Un **Billing plan** relie un environnement à cette Subscription, ce qui déplafonne la capacité.
3. Un **environnement `Sandbox`** devient créable.
4. La **Provisioning App** devient installable avec les outils de développement.
5. **Visual Studio** devient connectable, et le développement X++ devient possible.

Rompre le premier maillon rend tous les suivants inaccessibles.

#### 4.1.3 Ce que fait exactement le Billing plan

Le `Billing plan` établit un lien entre un ou plusieurs **environnements Power Platform** et une **Subscription Azure**, via un `Resource group`.

Une fois ce lien établi, la consommation de ces environnements qui dépasse la capacité incluse dans vos licences n'est plus **refusée** : elle est **mesurée et facturée à l'usage** sur la Subscription Azure. Le plafond de capacité est ainsi remplacé par un modèle à la consommation.

**Ce que cela implique financièrement.** Vous ne débloquez pas de la capacité gratuite. Vous acceptez d'en payer la consommation. Sur un environnement de développement isolé, utilisé quelques semaines, le montant reste modeste, mais il n'est pas nul et n'est pas systématiquement couvert par le crédit de 200 USD. C'est précisément la raison pour laquelle l'alerte de budget définie en 3.7 n'est pas facultative.

**Exception pour les profils fonctionnels.** Si vous ne réalisez **pas** de développement X++, par exemple en tant que consultant fonctionnel, formateur ou pour une démonstration, vous pouvez ignorer entièrement les phases 2 et 3. Il vous suffira, en phase 4, de choisir le type d'environnement `Trial (subscription-based)` au lieu de `Sandbox`. Vous disposerez alors d'une instance Finance and Operations fonctionnelle, mais sans outils de développement ni connexion Visual Studio.

### 4.2 Prérequis de rôles dans le Power Platform

Pour créer un `Billing plan`, votre compte doit détenir l'un des rôles suivants.

| Rôle | Créer un Billing plan | Modifier | Lier des environnements |
| :-- | :-- | :-- | :-- |
| `Environment admin` (Administrateur d'environnement) | Oui | Ses propres plans uniquement | Ses propres plans et environnements |
| `Power Platform admin` (Administrateur Power Platform) | Oui | Tous | Tous |
| `Global admin` (Administrateur général) | Oui | Tous | Tous |
| `Dynamics 365 admin` (Administrateur Dynamics 365) | Oui | Tous | Tous |

En tant que créateur du tenant, vous détenez le rôle `Global admin`. Aucune action supplémentaire n'est requise.

### 4.3 Créer le Billing plan dans le Power Platform Admin Center

**Rôles requis, sur deux plans.** Côté Power Platform : `Power Platform admin`, `Global admin`, `Dynamics 365 admin` ou `Environment admin`, conformément au tableau de la section 4.2. Côté Azure, sur la Subscription sélectionnée : **`Owner` (Propriétaire) ou `Contributor` (Contributeur)**. Vérifiez ce second point avant de commencer : dans le portail Azure, ouvrez `Subscriptions` (Abonnements) > votre Subscription > `Access control (IAM)` (Contrôle d'accès) > `View my access` (Afficher mon accès).

**Étape 1.** Ouvrez le Power Platform Admin Center à l'adresse `https://admin.powerplatform.microsoft.com`.

**Étape 2.** Dans le volet de navigation, développez `Licensing` (Licences).

**Étape 3.** Accédez à la gestion de la capacité. Selon la version de l'interface déployée sur votre tenant, deux chemins équivalents existent :

- `Licensing` (Licences) > `Pay-as-you-go plans` (Plans de paiement à l'usage), libellé de l'interface actuelle ;
- `Licensing` (Licences) > `Database` (Base de données) > `Manage capacity` (Gérer la capacité), chemin historique encore présent sur certains tenants.

Les deux mènent au même assistant. Si vous empruntez le second, sélectionnez d'abord l'environnement `Default` (Par défaut) créé automatiquement avec le tenant.

**Étape 4.** Cliquez sur `New billing plan` (Nouveau plan de facturation).

**Étape 5.** Une fenêtre s'ouvre. Renseignez les champs suivants :

| Champ | Valeur |
| :-- | :-- |
| Type de plan | `Azure subscription` (Abonnement Azure), et non `Microsoft 365 Copilot Chat` |
| `Name` (Nom) | Un nom explicite, par exemple `BP-D365FO-Dev` |
| `Azure subscription` (Abonnement Azure) | La Subscription créée en phase 2 |
| `Resource group` (Groupe de ressources) | `rg-d365fo-dev`, créé en 3.6 |
| `Power Platform products` (Produits Power Platform) | Les applications couvertes par le plan |

**Point de vigilance.** Si la liste `Azure subscription` est vide, la cause est presque toujours l'une des trois suivantes : la Subscription a été créée dans un autre tenant, le fournisseur de ressources `Microsoft.PowerPlatform` n'est pas enregistré, ou la propagation des droits n'est pas achevée. Reportez-vous à l'annexe A.

**Étape 6.** Cliquez sur `Next` (Suivant).

**Étape 7.** Sélectionnez votre `Region` (Région). La liste des environnements de cette région s'affiche.

**Étape 8.** Sélectionnez l'environnement à rattacher, puis cliquez sur `Save` (Enregistrer).

**Étape 9.** Patientez quelques minutes. Sous `Billing plans` (Plans de facturation), votre Subscription doit apparaître avec le statut `Enabled` (Activé).

**Note sur l'ordre des opérations.** À ce stade, l'environnement `Sandbox` n'existe pas encore. Deux approches sont possibles. La première consiste à rattacher l'environnement `Default`, ce qui suffit à valider le lien Azure. La seconde, plus rigoureuse, consiste à créer d'abord l'environnement `Sandbox` en phase 4, puis à revenir modifier le `Billing plan` pour l'y rattacher. Si la création du `Sandbox` est refusée pour cause de capacité insuffisante, appliquez la première approche.

### 4.4 Checklist de validation de la phase 3

- [ ] Le `Billing plan` est de type `Azure subscription`.
- [ ] La Subscription était bien proposée dans la liste déroulante.
- [ ] Le `Resource group` sélectionné est celui créé en phase 2.
- [ ] Le `Billing plan` affiche le statut `Enabled` (Activé).
- [ ] Le type d'environnement `Sandbox` est désormais sélectionnable dans le PPAC.

## 5. Phase 4 : Environnement Sandbox et applications Finance and Operations

**Objectif de la phase.** Provisionner un environnement `Sandbox` et y installer Dynamics 365 Finance and Operations avec les outils de développement et les données de démonstration.

**Rôles requis pour cette phase.** `Power Platform admin` (Administrateur Power Platform), `Dynamics 365 admin` (Administrateur Dynamics 365) ou `Global admin` (Administrateur général) pour créer l'environnement et installer les applications. À défaut d'un de ces rôles, une licence Dynamics 365 éligible affectée au compte permet également l'installation, sous réserve du délai de propagation évoqué en 1.7.4. Le rôle `System administrator` (Administrateur système) dans l'application Finance and Operations est requis pour l'étape 5.5.

### 5.1 Créer l'environnement Sandbox

**Rôle requis.** `Power Platform admin` (Administrateur Power Platform), `Dynamics 365 admin` (Administrateur Dynamics 365) ou `Global admin` (Administrateur général).

**Étape 1.** Dans le Power Platform Admin Center, développez `Manage` (Gérer), puis cliquez sur `Environments` (Environnements).

**Étape 2.** Cliquez sur `New` (Nouveau).

**Étape 3.** Dans le volet qui s'ouvre, renseignez :

| Champ | Valeur | Commentaire |
| :-- | :-- | :-- |
| `Name` (Nom) | Par exemple `DEV-FO-01` | Nom d'affichage de l'environnement |
| `Type` (Type) | `Sandbox` (Bac à sable) | Obligatoire pour le développement |
| `Region` (Région) | Votre région | Doit rester cohérente avec le `Resource group` |

**Étape 4.** Développez la section `Change default settings` (Modifier les paramètres par défaut) et vérifiez que l'option `Add a database / data store` (Ajouter une base de données ou un magasin de données) est **activée**. Sans base Dataverse, aucune application Dynamics 365 ne pourra être installée.

**Étape 5.** Cliquez sur `Next` (Suivant).

**Étape 6.** Sur l'écran de configuration de la base, renseignez :

| Champ | Valeur | Commentaire |
| :-- | :-- | :-- |
| `Security group` (Groupe de sécurité) | `None` (Aucun) | Aucune restriction d'accès, adapté à un environnement de formation |
| `Language` (Langue) | Votre langue | Non modifiable après création |
| `Currency` (Devise) | La devise adaptée à votre cas d'usage | **Non modifiable après création**, choisissez avec attention |
| `URL` (Adresse) | Un nom de domaine unique | Voir l'avertissement ci-dessous |
| `Enable Dynamics 365 apps` (Activer les applications Dynamics 365) | `Yes` (Oui) | Obligatoire |
| `Automatically deploy these apps` (Déployer automatiquement ces applications) | Ne rien sélectionner | Voir l'avertissement ci-dessous |

**Avertissement 1, longueur de l'adresse.** Le nom d'hôte de l'environnement doit comporter **19 caractères au maximum**. Au-delà, l'installation de la `Finance and Operations Provisioning App` échouera. Privilégiez un nom court, par exemple `devfo01`.

**Avertissement 2, ne pas choisir de modèle applicatif.** Le champ proposant de déployer automatiquement une application telle que `Finance` ou `Supply Chain Management` doit rester **vide**. Passer par ce chemin installe bien Finance and Operations, mais **sans activer les paramètres développeur**, et il n'existe pas de moyen simple de les activer par la suite. Les applications seront installées manuellement à l'étape suivante, ce qui donne accès aux options `Enable developer tools` (Activer les outils de développement) et `Enable demo data` (Activer les données de démonstration).

**Étape 7.** Cliquez sur `Save` (Enregistrer).

**Étape 8.** Patientez quelques minutes. L'état de l'environnement passe de `Preparing` (En cours de préparation) à `Ready` (Prêt).

### 5.2 Installer l'application Platform Tools

**Rôle requis.** `Power Platform admin`, `Dynamics 365 admin` ou `Global admin`. À défaut, une licence Dynamics 365 éligible affectée au compte suffit, sous réserve du délai de propagation décrit en 1.7.4.

Deux applications doivent être installées, **dans cet ordre impératif**. La première est une dépendance de la seconde.

**Étape 1.** Dans la liste `Environments` (Environnements), cliquez sur votre environnement pour l'ouvrir.

**Étape 2.** Dans la section `Resources` (Ressources), cliquez sur `Dynamics 365 apps` (Applications Dynamics 365).

**Étape 3.** Cliquez sur `Install app` (Installer l'application).

**Étape 4.** Dans la barre de recherche, saisissez `Finance and Operations Platform Tools`. Sélectionnez `Dynamics 365 Finance and Operations Platform Tools`, puis cliquez sur `Next` (Suivant).

**Étape 5.** Les informations de l'application s'affichent. Cochez l'acceptation des conditions d'utilisation, `Terms of service` (Conditions d'utilisation), puis cliquez sur `Install` (Installer).

**Étape 6.** L'application apparaît dans la liste avec le statut `Installing` (Installation en cours). Comptez 5 à 10 minutes avant le passage au statut `Installed` (Installé).

**Point de vigilance.** Ne lancez pas l'installation suivante avant que ce statut ne soit atteint.

### 5.3 Installer la Finance and Operations Provisioning App

**Rôle requis.** Identique à la section 5.2.

C'est cette application qui installe réellement Finance and Operations sur l'environnement, avec les outils de développement et les données de démonstration.

**Prérequis rappelés.** L'environnement doit disposer d'au moins 1 Go de capacité `Operations` et `Dataverse` disponible, ne doit pas être lié à Lifecycle Services, et son nom d'hôte doit respecter la limite de 19 caractères.

**Étape 1.** Cliquez de nouveau sur `Install app` (Installer l'application).

**Étape 2.** Saisissez `Finance and Operations Provisioning App` dans la barre de recherche. Sélectionnez `Dynamics 365 Finance and Operations Provisioning App`, puis cliquez sur `Next` (Suivant).

**Étape 3.** Une fenêtre indique que vous allez être redirigé vers une page d'administration dédiée. Cliquez sur `OK`.

**Étape 4.** Sur cette page, configurez les options suivantes :

| Option | Valeur | Rôle |
| :-- | :-- | :-- |
| `Enable developer tools for Finance and Operations` (Activer les outils de développement pour Finance and Operations) | Cochée | Active l'intégration Visual Studio et le développement X++ |
| `Enable demo data for Finance and Operations` (Activer les données de démonstration pour Finance and Operations) | Cochée | Déploie le jeu de données de démonstration Contoso |
| `Application version` (Version de l'application) | Valeur par défaut | Version la plus récente en disponibilité générale |

**Étape critique.** Ces deux cases constituent le cœur de la procédure. Sans `Enable developer tools`, l'environnement fonctionnera, mais Visual Studio ne pourra ni s'y connecter ni y déployer de code. Sans `Enable demo data`, l'application sera vide, ce qui rend tout test réaliste impossible. Ces choix ne sont pas modifiables après installation : une erreur à ce stade impose de recréer l'environnement.

**Étape 5.** Vérifiez l'ensemble des options, puis cliquez sur `Install` (Installer).

**Étape 6.** Patientez. Cette installation est longue : comptez 1 à 2 heures. Le statut passe à `Installed` (Installé) une fois l'opération terminée.

**Conseil.** Mettez ce temps à profit pour dérouler la phase 5, à savoir l'installation de SSMS et de Visual Studio sur votre poste.

### 5.4 Comprendre les deux adresses de l'environnement

Une fois l'installation achevée, ouvrez la page `Overview` (Vue d'ensemble) de l'environnement. Deux adresses distinctes y figurent, et les confondre est une source de confusion fréquente.

| Adresse | Format typique | Usage |
| :-- | :-- | :-- |
| `Environment URL` (Adresse de l'environnement) | `https://<nom>.crm4.dynamics.com` | Adresse Dataverse, servant à **administrer** l'environnement : déploiement des modifications et **connexion depuis Visual Studio** |
| `Finance and Operations URL` (Adresse Finance and Operations) | `https://<nom>.sandbox.operations.dynamics.com` | Adresse de **l'application Finance and Operations elle-même**, à ouvrir dans le navigateur pour utiliser l'ERP |

**À retenir pour la phase 5.** C'est l'`Environment URL`, et non l'adresse Finance and Operations, qui sera saisie dans Visual Studio.

**Vérification.** Ouvrez la `Finance and Operations URL` dans votre navigateur. L'application doit se charger et présenter les données de démonstration Contoso.

### 5.5 Attribuer le rôle System Administrator

**Rôle requis.** `System administrator` (Administrateur système) dans l'environnement Finance and Operations. Le premier administrateur est provisionné automatiquement lors de l'installation de la `Provisioning App` : il s'agit du compte ayant déclenché l'installation.

Ce rôle sera exigé en phase 7 pour l'accès à la base de données.

**Étape 1.** Ouvrez l'application Finance and Operations via son adresse.

**Étape 2.** Naviguez vers `System administration` (Administration système) > `Users` (Utilisateurs).

**Étape 3.** Vérifiez que votre compte figure dans la liste et que le rôle `System administrator` (Administrateur système) lui est attribué.

### 5.6 Checklist de validation de la phase 4

- [ ] L'environnement est de type `Sandbox` et son état est `Ready`.
- [ ] Le nom d'hôte comporte 19 caractères ou moins.
- [ ] L'option `Enable Dynamics 365 apps` était activée à la création.
- [ ] Aucun modèle applicatif n'a été sélectionné à la création.
- [ ] `Dynamics 365 Finance and Operations Platform Tools` affiche le statut `Installed`.
- [ ] `Dynamics 365 Finance and Operations Provisioning App` affiche le statut `Installed`.
- [ ] Les options `Enable developer tools` et `Enable demo data` étaient cochées.
- [ ] Les deux adresses sont visibles et notées.
- [ ] L'application Finance and Operations s'ouvre dans le navigateur avec les données Contoso.
- [ ] Le rôle `System administrator` est attribué à votre compte.

## 6. Phase 5 : Poste de développement local

**Objectif de la phase.** Installer et configurer les outils sur votre poste, puis les connecter à l'environnement `Sandbox`.

**Rôles requis pour cette phase.** Sur le poste de travail : **administrateur local**, indispensable pour installer SSMS, Visual Studio, les extensions et les composants natifs. Sur l'environnement cible : `System administrator` (Administrateur système) dans l'application Finance and Operations, sans lequel la connexion depuis Visual Studio échouera ou n'exposera aucune solution exploitable.

### 6.1 Installer SQL Server Management Studio

**Rôle requis.** Administrateur local du poste de travail.

SQL Server Management Studio, abrégé SSMS, servira en phase 7 à interroger directement la base de données de l'environnement.

**Étape 1.** Rendez-vous sur la page officielle de téléchargement de SQL Server Management Studio. Recherchez `Download SQL Server Management Studio` sur le site `learn.microsoft.com`.

**Étape 2.** Cliquez sur `Download installer` (Télécharger le programme d'installation) ou `Free download` (Téléchargement gratuit), selon la version de la page.

**Étape 3.** Un exécutable de petite taille est téléchargé. Double-cliquez dessus pour lancer l'installation.

**Étape 4.** Cliquez sur `Continue` (Continuer).

**Étape 5.** Les composants de base, `core components` (composants principaux), sont présélectionnés. Cliquez sur `Install` (Installer) sans rien modifier.

**Étape 6.** L'installation démarre. Sa durée dépend de votre connexion Internet.

**Étape 7.** Une fois l'installation terminée, **redémarrez votre poste** pour la finaliser.

### 6.2 Obtenir Visual Studio 2022 Professional

Visual Studio est l'environnement de développement principal. C'est depuis lui que vous vous connecterez au `Sandbox` et que vous réaliserez tous vos développements.

**Étape 1.** Rendez-vous sur `https://my.visualstudio.com`.

**Étape 2.** Connectez-vous avec votre compte `@votresociete.onmicrosoft.com`. Le site vous inscrit automatiquement au programme `Visual Studio Dev Essentials`. Cliquez sur `Confirm` (Confirmer).

**Étape 3.** Dans la section `Downloads` (Téléchargements), sélectionnez `Visual Studio 2022`.

**Étape 4.** Les détails de version s'affichent. Conservez la sélection par défaut et cliquez sur `Download` (Télécharger).

**Étape 5.** Un exécutable d'installation de petite taille, appelé programme d'amorçage, est téléchargé.

### 6.3 Installer Visual Studio avec les composants requis

**Rôle requis.** Administrateur local du poste de travail. L'installation des extensions et l'enregistrement des gestionnaires de protocole déclenchent des demandes d'élévation de privilèges.

**Étape 1.** Double-cliquez sur l'exécutable téléchargé, puis cliquez sur `Continue` (Continuer).

**Étape 2.** Dans l'onglet `Workloads` (Charges de travail), cochez `.NET desktop development` (Développement .NET pour le bureau).

**Étape 3.** Basculez sur l'onglet `Individual components` (Composants individuels).

**Étape 4.** Dans la barre de recherche des composants, saisissez `Model` et cochez `Modeling SDK` (Kit de développement de modélisation).

**Étape 5.** Recherchez ensuite `DGML` et cochez `DGML editor` (Éditeur DGML).

**Note.** Vérifiez également la présence de `Microsoft SQL Server Express LocalDB`, généralement installé par défaut avec la charge de travail .NET. Il héberge la base de références croisées utilisée par les outils Finance and Operations.

**Étape 6.** Contrôlez la synthèse de vos sélections dans le panneau de droite, puis cliquez sur `Install` (Installer).

**Étape 7.** Le téléchargement et l'installation se déroulent automatiquement. Comptez de 30 minutes à plus d'une heure selon votre connexion.

**Étape 8.** À la fin, cliquez sur `Launch` (Lancer).

**Étape 9.** Cliquez sur `Sign in with Microsoft` (Se connecter avec Microsoft) et utilisez le compte `@votresociete.onmicrosoft.com` créé en phase 1. Cette connexion active un essai d'environ 90 jours de Visual Studio Professional via Dev Essentials.

**Étape 10.** Aucun projet n'existant encore, cliquez sur `Continue without code` (Continuer sans code).

### 6.4 Installer les deux extensions requises

#### 6.4.1 Extension 1 : Microsoft Reporting Services Projects

**Étape 1.** Dans la barre de menus, cliquez sur `Extensions` puis sur `Manage Extensions` (Gérer les extensions).

**Étape 2.** Recherchez `Microsoft Reporting Services Projects` et cliquez sur `Install` (Installer).

**Étape 3.** Le fichier d'installation est téléchargé.

**Étape 4.** **Fermez Visual Studio**, puis double-cliquez sur le fichier `.vsix` téléchargé.

**Étape 5.** Cliquez sur `Install` (Installer).

**Étape 6.** Un message confirme la réussite de l'installation.

#### 6.4.2 Extension 2 : Power Platform Tools

**Étape 1.** Rouvrez Visual Studio et retournez dans `Extensions` > `Manage Extensions` (Gérer les extensions).

**Étape 2.** Recherchez `Power Platform Tools` et cliquez sur `Install` (Installer).

**Étape 3.** Une bannière en bas de la fenêtre indique que les modifications sont planifiées. Visual Studio doit être fermé pour que l'installation démarre.

**Étape 4.** Fermez Visual Studio. Un programme d'installation se lance. Cliquez sur `Modify` (Modifier).

**Étape 5.** Après quelques instants, un message de confirmation s'affiche. Les deux extensions sont installées.

**Note.** L'installation du profileur de plug-ins, parfois proposée par l'extension `Power Platform Tools`, n'est pas nécessaire dans le cadre de cette procédure.

### 6.5 Configurer les options de l'extension Power Platform Tools

**Étape 1.** Rouvrez Visual Studio et choisissez `Continue without code` (Continuer sans code).

**Étape 2.** Cliquez sur `Tools` (Outils) dans la barre de menus, puis sur `Options`.

**Étape 3.** Dans la fenêtre `Options`, recherchez `Power Platform` et ouvrez la section correspondante.

**Étape 4.** Réglez les options recommandées :

| Option | Valeur recommandée | Effet |
| :-- | :-- | :-- |
| `Auto setup for Dynamics 365 Finance and Operations` (Configuration automatique pour Dynamics 365 Finance and Operations) | Activée | Extrait automatiquement les métadonnées et crée la configuration, ce qui évite une longue configuration manuelle |
| `Do not display Power Platform Explorer on connect` (Ne pas afficher l'explorateur Power Platform à la connexion) | Activée | Accélère sensiblement la connexion à l'environnement |
| `Download logs` (Télécharger les journaux) | Activée | Génère les journaux de déploiement et de synchronisation de base, très utiles au dépannage |
| `Skip discovery when connecting to Dataverse` (Ignorer la découverte lors de la connexion à Dataverse) | Activée uniquement si votre compte est invité dans un autre tenant | Permet de saisir directement l'adresse Dataverse |

**Étape 5.** Validez par `OK`.

### 6.6 Connecter Visual Studio à l'environnement Sandbox

**Rôle requis.** `System administrator` (Administrateur système) dans l'environnement Finance and Operations, avec une licence Dynamics 365 affectée au compte.

**Étape 1.** Récupérez l'`Environment URL` depuis la page `Overview` de votre environnement dans le Power Platform Admin Center, comme indiqué en 5.4. C'est l'adresse en `*.dynamics.com`, et non celle en `*.operations.dynamics.com`.

**Étape 2.** Dans Visual Studio, ouvrez le menu `Tools` (Outils) et cliquez sur `Connect to Dataverse` (Se connecter à Dataverse). Selon la version de l'extension, ce libellé peut apparaître sous la forme `Connect to Database` (Se connecter à la base de données).

**Étape 3.** Une nouvelle fenêtre s'ouvre. Sélectionnez `Office 365`, puis cochez la **deuxième option**, qui permet de saisir manuellement l'adresse de l'organisation.

**Note sur l'authentification multifacteur.** Si votre compte est protégé par MFA, décochez au contraire toutes les cases de l'écran de connexion. Visual Studio ouvrira alors le navigateur pour un flux d'authentification interactif compatible.

**Étape 4.** Cliquez sur `Login` (Se connecter).

**Étape 5.** Collez l'`Environment URL` dans le champ prévu, puis cliquez sur `OK`.

**Étape 6.** La liste des environnements disponibles s'affiche. Sélectionnez votre environnement `Sandbox` Finance and Operations. Il s'agit généralement du second de la liste, le premier étant l'environnement `Default` du tenant.

**Étape 7.** Cliquez sur `Login` (Se connecter). Visual Studio établit la connexion.

**Étape 8.** Il vous est demandé de sélectionner une solution.

**Point de vigilance.** Ne choisissez pas la solution `Default` (Par défaut). Sélectionnez celle créée spécifiquement pour votre environnement Finance and Operations par la `Provisioning App`. Choisir la solution par défaut conduit à des développements non déployables.

**Étape 9.** Patientez quelques minutes. La connexion se finalise.

### 6.7 Télécharger les assets Dynamics 365

Lors de la toute première connexion, Visual Studio vérifie si les métadonnées de référence sont présentes localement.

**Étape 1.** Si elles ne le sont pas, une fenêtre demande si vous souhaitez les télécharger. Cliquez sur `Yes` (Oui).

**Étape 2.** Le téléchargement démarre. À son terme, un programme d'installation se lance. Cliquez sur `Install` (Installer).

**Étape 3.** Un écran de fin confirme que toutes les étapes d'installation locale sont achevées.

Les fichiers sont déposés dans le dossier suivant :

```
C:\Users\<VotreUtilisateur>\AppData\Local\Microsoft\Dynamics365\<VersionApplication>
```

Ce dossier contient notamment :

| Fichier | Rôle |
| :-- | :-- |
| `PackagesLocalDirectory.zip` | Métadonnées système de l'application standard |
| `Microsoft.Dynamics.FinOps.ToolsVS2022.vsix` | Extension Finance and Operations pour Visual Studio |
| `DYNAMICSXREFDB.bak` | Sauvegarde de la base de références croisées |
| `TraceParser.msi` | Outil d'analyse de traces de performance |

**Étape 4.** Vérification. Une fois l'opération terminée, contrôlez que le dossier des assets contient environ **24 Go** de fichiers. Un volume nettement inférieur signale un téléchargement incomplet. Reportez-vous à l'annexe A.

**Cas particulier.** Si l'option `Auto setup` a été désactivée, vous devrez effectuer manuellement les opérations suivantes : débloquer les fichiers téléchargés par un clic droit puis `Properties` (Propriétés) et `Unblock` (Débloquer) ; extraire `PackagesLocalDirectory.zip` dans un dossier `PackagesLocalDirectory`, l'usage de 7-Zip étant recommandé car l'extracteur natif de Windows échoue fréquemment sur cette archive ; puis installer manuellement `Microsoft.Dynamics.FinOps.ToolsVS2022.vsix`.

### 6.8 Checklist de validation de la phase 5

- [ ] SSMS est installé et le poste a été redémarré.
- [ ] Visual Studio 2022 Professional est installé et activé via Dev Essentials.
- [ ] La charge de travail `.NET desktop development` est installée.
- [ ] Les composants `Modeling SDK` et `DGML editor` sont installés.
- [ ] L'extension `Microsoft Reporting Services Projects` est installée.
- [ ] L'extension `Power Platform Tools` est installée.
- [ ] Les options `Power Platform` sont configurées.
- [ ] Visual Studio est connecté à l'environnement `Sandbox` avec la bonne solution.
- [ ] Le dossier des assets contient environ 24 Go de fichiers.
- [ ] Le menu `Dynamics 365` est visible dans la barre de menus de Visual Studio.

## 7. Phase 6 : Métadonnées, modèle et projet

**Objectif de la phase.** Déclarer où vos personnalisations seront stockées, puis créer votre premier modèle et votre premier projet X++.

**Rôles requis pour cette phase.** Administrateur local du poste pour la configuration des métadonnées et la création de la base de références croisées. `System administrator` (Administrateur système) dans l'environnement pour les actions `Deploy model` (Déployer le modèle) et `Synchronize database` (Synchroniser la base de données).

### 7.1 Configurer l'emplacement des métadonnées

Cette configuration définit deux emplacements distincts sur votre disque :

- le dossier des **métadonnées de référence**, correspondant à l'application standard Microsoft, en lecture seule ;
- le dossier de vos **métadonnées personnalisées**, contenant vos packages et modèles, en écriture.

Les séparer constitue une bonne pratique. Vos développements restent isolés du standard, ce qui facilite les sauvegardes, le versionnement et les mises à jour.

**Étape 1.** Dans Visual Studio, cliquez sur `Dynamics 365` dans la barre de menus, puis sur `Configure Metadata` (Configurer les métadonnées). Selon la version, le chemin peut être `Extensions` > `Dynamics 365` > `Configure Metadata`.

**Étape 2.** Cliquez sur `New` (Nouveau) pour créer une configuration.

**Étape 3.** Renseignez les champs :

| Champ | Valeur | Commentaire |
| :-- | :-- | :-- |
| `Name` (Nom) | Par exemple `Config-DEV-FO-01` | Nom de la configuration |
| `Description` | Texte libre | Utile si vous gérez plusieurs environnements |
| `Cross reference database server` (Serveur de la base de références croisées) | `(localdb)\.` | Ou `localhost` si vous utilisez une instance SQL Server complète |
| `Cross reference database name` (Nom de la base de références croisées) | Par exemple `DYNAMICSXREFDB` | Créée automatiquement si elle est absente |
| `Application version to restore cross reference database from` (Version d'application source de la restauration) | La version téléchargée | Sélectionnable dans la liste |
| `Folders for reference metadata` (Dossiers des métadonnées de référence) | Le dossier `PackagesLocalDirectory` décompressé | Métadonnées standard |
| `Folder for your own custom metadata` (Dossier de vos métadonnées personnalisées) | Un dossier dédié, par exemple `C:\D365\CustomMetadata` | À créer au préalable |

**Étape 4.** Cliquez sur `Save` (Enregistrer).

**Étape 5.** Une fenêtre confirme que tous les fichiers ont été mis à jour avec succès.

**Étape 6.** Vérification. Ouvrez `View` (Affichage) > `Application Explorer` (Explorateur d'applications). L'explorateur doit s'ouvrir et présenter l'arborescence des objets de l'application standard. C'est la preuve que les métadonnées de référence sont correctement chargées.

**Point de vigilance.** Si le bouton `Save` reste grisé, un champ est en erreur. Il apparaît encadré en rouge et une infobulle en précise la cause. La valeur `(localdb)\.` doit être saisie exactement ainsi, point final compris.

### 7.2 Créer un modèle

Un **modèle** est le conteneur logique de vos personnalisations. Il est lui-même hébergé dans un `package` (paquet).

**Étape 1.** Dans le menu `Dynamics 365`, cliquez sur `Model Management` (Gestion des modèles) puis sur `Create model` (Créer un modèle).

**Étape 2.** La fenêtre de création s'ouvre. Renseignez :

| Champ | Valeur | Commentaire |
| :-- | :-- | :-- |
| `Model name` (Nom du modèle) | Par exemple `ArchiaExtensions` | Sans espace ni caractère accentué |
| `Model publisher` (Éditeur du modèle) | Le nom de votre société | Obligatoire |
| `Description` | Texte libre | Recommandé |
| `Version` | Valeur par défaut | Modifiable ultérieurement |

Cliquez sur `Next` (Suivant).

**Étape 3.** Sélectionnez `Create new package` (Créer un package), puis cliquez sur `Next` (Suivant).

**Pourquoi un nouveau package.** Créer un package dédié rend votre modèle indépendant. Il peut être compilé, déployé et désinstallé isolément. Placer un modèle dans un package existant crée une adhérence forte, à réserver à des cas particuliers.

**Étape 4.** Sélectionnez les **packages de référence** dont dépend votre modèle. Dans la grande majorité des cas, les trois packages standard suffisent pour démarrer :

- `ApplicationFoundation`
- `ApplicationPlatform`
- `ApplicationSuite`

Cliquez sur `Next` (Suivant).

**Note.** Si vous devez étendre un module spécifique, tel que la gestion des entrepôts ou Commerce, ajoutez également le package correspondant. Des références peuvent être ajoutées ultérieurement via `Model Management` > `Update model parameters` (Mettre à jour les paramètres du modèle).

**Étape 5.** Un écran de synthèse s'affiche. La case `Create new project` (Créer un projet) étant cochée par défaut, la validation enchaînera automatiquement sur la création du projet.

### 7.3 Créer le projet

**Étape 1.** Saisissez le nom du projet.

**Étape 2.** Indiquez l'emplacement où seront stockés les fichiers de projet et de solution, par exemple `C:\D365\Projects`.

**Étape 3.** Cliquez sur `Create` (Créer).

**Étape 4.** Vérification de la structure de fichiers :

| Élément | Emplacement |
| :-- | :-- |
| Fichiers du **modèle**, métadonnées et éléments X++ | Le dossier de métadonnées personnalisées défini en 7.1 |
| Fichiers de **solution** et de **projet**, extensions `.sln` et `.rnrproj` | L'emplacement indiqué à l'étape 2 |

Votre projet est prêt. Vous pouvez y ajouter des éléments et commencer vos personnalisations.

### 7.4 Compiler et déployer

**Rôle requis.** Administrateur local du poste pour la génération. `System administrator` (Administrateur système) dans l'environnement pour le déploiement et la synchronisation de la base.

Trois actions principales sont désormais disponibles.

| Action | Emplacement | Rôle |
| :-- | :-- | :-- |
| `Build` (Générer) | Menu `Build` ou clic droit sur le projet | Compile votre code X++ localement et signale les erreurs |
| `Deploy model` (Déployer le modèle) | Menu `Dynamics 365` | Pousse votre modèle compilé vers l'environnement `Sandbox` cloud |
| `Synchronize database` (Synchroniser la base de données) | Menu `Dynamics 365` | Applique au schéma de la base les modifications de tables, champs et index de vos modèles |

**Ordre de travail habituel.** Lancez `Build`, corrigez les erreurs éventuelles, exécutez `Synchronize database` si le modèle contient des modifications de structure, puis `Deploy model`. Vérifiez enfin le résultat dans l'application Finance and Operations via son adresse.

### 7.5 Checklist de validation de la phase 6

- [ ] La configuration de métadonnées est enregistrée sans erreur.
- [ ] L'`Application Explorer` s'ouvre et affiche l'arborescence standard.
- [ ] Un modèle est créé, avec un package dédié.
- [ ] Les trois packages de référence standard sont déclarés.
- [ ] Un projet est créé et visible dans le `Solution Explorer` (Explorateur de solutions).
- [ ] La structure de fichiers sur disque correspond à la configuration.
- [ ] Une génération du projet vide se termine sans erreur.

## 8. Phase 7 : Azure DevOps et contrôle de source

**Objectif de la phase.** Disposer d'une organisation Azure DevOps, d'un projet d'équipe doté d'un dépôt configuré, et d'un mapping du contrôle de source opérationnel dans Visual Studio, de sorte que votre modèle et votre projet X++ soient archivés et versionnés.

**Rôles requis pour cette phase.** La création d'une organisation Azure DevOps ne requiert aucun rôle préalable : le créateur en devient `Organization Owner` (Propriétaire de l'organisation). La modification des paramètres d'organisation, notamment l'autorisation des dépôts TFVC, exige l'appartenance au groupe `Project Collection Administrators` (Administrateurs de collection de projets). La création d'un projet d'équipe exige ce même groupe. L'archivage du code exige l'appartenance au groupe `Contributors` (Contributeurs) du projet, avec un niveau d'accès `Basic` (De base).

### 8.1 Pourquoi mettre en place le contrôle de source dès le premier jour

Dans un environnement de développement unifié, votre code X++ n'existe qu'à deux endroits : le dossier de métadonnées personnalisées de votre poste, et l'environnement cloud sur lequel vous déployez. Ni l'un ni l'autre ne constitue une sauvegarde.

Le poste peut être réinstallé. L'environnement `Sandbox` peut être supprimé, réinitialisé, ou perdu à l'expiration de l'essai. Sans contrôle de source, un développement de plusieurs semaines disparaît avec lui.

La documentation Microsoft relative à l'expérience de développement unifiée est explicite sur ce point : le contrôle de source est le seul moyen de garantir la cohérence entre les environnements et de disposer d'un enregistrement fiable de ce qui a été déployé. Il fournit l'historique, les points de contrôle et les points de synchronisation qui rendent le travail reproductible.

Trois bénéfices immédiats, même pour un développeur isolé :

1. **Traçabilité.** Chaque modification est horodatée, attribuée et commentée. Vous pouvez revenir à un état antérieur.
2. **Portabilité.** Vous pouvez reconstruire votre poste, ou en changer, sans perdre votre travail.
3. **Préparation à l'industrialisation.** Les chaînes de génération et de déploiement automatisées s'appuient sur ce dépôt. Le mettre en place maintenant évite une reprise complète plus tard.

### 8.2 Choisir entre TFVC et Git

Deux systèmes de gestion de version coexistent dans Azure DevOps. Le choix conditionne toute la suite de la phase.

| Critère | TFVC | Git |
| :-- | :-- | :-- |
| Nom complet | `Team Foundation Version Control` (Contrôle de version Team Foundation) | Git, gestion distribuée |
| Modèle | Centralisé, un seul espace de travail serveur | Distribué, dépôt local complet |
| Position historique dans l'écosystème Finance and Operations | Option par défaut depuis l'origine, très majoritaire chez les clients existants | Prise en charge officielle, recommandée par Microsoft comme standard moderne |
| Intégration dans Visual Studio | `Team Explorer` (Explorateur d'équipe), avec mapping d'espace de travail | Fenêtre `Git Changes` (Modifications Git) |
| Disponibilité sur une organisation Azure DevOps créée aujourd'hui | **Désactivée par défaut**, doit être réactivée par un paramètre d'organisation | Disponible immédiatement |
| Configuration du dossier de métadonnées | Directe, par mapping de dossier | Nécessite une configuration supplémentaire |
| Environnements de génération liés à Lifecycle Services | Exigent un dépôt TFVC | Nécessitent malgré tout un dépôt TFVC d'amorçage |

**La procédure retenue ci-dessous utilise TFVC**, car c'est le mode qui correspond au mapping de contrôle de source dans `Team Explorer`, le plus répandu dans les projets Finance and Operations existants, et le plus direct à configurer pour un dossier de métadonnées. La variante Git est décrite en 8.11.

**Avertissement important.** Depuis juin 2024, Azure DevOps applique un paramètre nommé `Disable creation of TFVC repositories` (Désactiver la création de dépôts TFVC), **activé par défaut** sur les nouvelles organisations. Créer un projet TFVC sans avoir désactivé ce paramètre est impossible : l'option n'apparaît tout simplement pas dans l'assistant. Microsoft indique par ailleurs qu'à terme, la possibilité de désactiver ce paramètre sera elle-même retirée. Si vous démarrez un projet neuf sans contrainte de compatibilité, Git est le choix qui vous exposera le moins à cette échéance.

### 8.3 Créer l'organisation Azure DevOps

**Rôle requis.** Aucun. Le créateur devient `Organization Owner` (Propriétaire de l'organisation).

**Étape 1.** Ouvrez `https://dev.azure.com` dans le navigateur, en étant connecté avec le compte `@votresociete.onmicrosoft.com` créé en phase 1.

**Point de vigilance.** Comme pour Azure, l'identité utilisée détermine le rattachement. Une organisation créée avec une identité personnelle ne bénéficiera pas de la gouvernance du tenant et compliquera inutilement la gestion des accès.

**Étape 2.** Cliquez sur `Start free` (Commencer gratuitement) ou, si vous êtes déjà connecté, sur `New organization` (Nouvelle organisation).

**Étape 3.** Renseignez :

| Champ | Valeur |
| :-- | :-- |
| `Organization name` (Nom de l'organisation) | Un nom unique, par exemple `archia365-d365fo` |
| `Host location` (Emplacement d'hébergement) | Une région proche, par exemple `West Europe` |

**Étape 4.** Validez le contrôle de sécurité, puis cliquez sur `Continue` (Continuer).

**Note sur le coût.** Le niveau gratuit d'Azure DevOps inclut cinq utilisateurs `Basic` (De base), un nombre illimité de dépôts privés, et un quota mensuel de minutes de génération hébergée. Pour l'usage décrit dans cette procédure, aucun coût n'est engagé.

### 8.4 Autoriser la création de dépôts TFVC

**Rôle requis.** Appartenance au groupe `Project Collection Administrators` (Administrateurs de collection de projets), ou `Organization Owner` (Propriétaire de l'organisation).

Cette étape doit être réalisée **avant** la création du projet. Une fois le projet créé en Git, il n'est pas possible de le convertir en TFVC.

**Étape 1.** En bas à gauche de la page de l'organisation, cliquez sur `Organization settings` (Paramètres de l'organisation).

**Étape 2.** Dans le volet de navigation, ouvrez `Repos` (Dépôts), puis `Settings` (Paramètres).

**Étape 3.** Repérez le paramètre `Disable creation of TFVC repositories` (Désactiver la création de dépôts TFVC).

**Étape 4.** **Désactivez ce paramètre**, c'est-à-dire positionnez-le sur `Off` (Désactivé). Ce double négatif prête à confusion : désactiver le paramètre revient à **autoriser** la création de dépôts TFVC.

**Étape 5.** Enregistrez si l'interface le demande, puis rafraîchissez la page.

**Note.** Ce paramètre existe également au niveau du projet, mais le paramètre d'organisation est prioritaire. Le régler à l'échelle de l'organisation est donc suffisant.

### 8.5 Créer le projet d'équipe avec un dépôt TFVC

**Rôle requis.** `Project Collection Administrators` (Administrateurs de collection de projets).

**Étape 1.** Depuis la page d'accueil de l'organisation, cliquez sur `New project` (Nouveau projet).

**Étape 2.** Renseignez :

| Champ | Valeur | Commentaire |
| :-- | :-- | :-- |
| `Project name` (Nom du projet) | Par exemple `D365FO-DEV` | Sans espace ni caractère accentué, afin d'éviter les problèmes d'encodage dans les chemins de contrôle de source |
| `Description` | Texte libre | Recommandé |
| `Visibility` (Visibilité) | `Private` (Privé) | Obligatoire pour du code client |

**Étape 3.** Développez la section `Advanced` (Avancé).

**Étape 4.** Dans `Version control` (Contrôle de version), sélectionnez **`Team Foundation Version Control`**.

**Point de vigilance.** Si cette option n'apparaît pas, l'étape 8.4 n'a pas été appliquée ou n'a pas encore été propagée. Rafraîchissez la page, déconnectez-vous puis reconnectez-vous, et vérifiez de nouveau le paramètre d'organisation.

**Étape 5.** Dans `Work item process` (Processus des éléments de travail), conservez `Agile` ou choisissez le processus adapté à votre organisation. Ce choix n'a pas d'incidence sur le contrôle de source.

**Étape 6.** Cliquez sur `Create` (Créer).

**Étape 7.** Le projet est créé. Notez son adresse, de la forme `https://dev.azure.com/<organisation>/<projet>`.

### 8.6 Créer l'arborescence de contrôle de source

La convention la plus répandue dans les projets Finance and Operations sépare les métadonnées des fichiers de projet Visual Studio, sous une racine de branche.

Arborescence cible sur le serveur :

```
$/D365FO-DEV
  Trunk
    Main
      Metadata
      Projects
```

| Dossier serveur | Contenu | Dossier local correspondant |
| :-- | :-- | :-- |
| `$/D365FO-DEV/Trunk/Main/Metadata` | Les fichiers XML de vos modèles et packages personnalisés | Le dossier de métadonnées personnalisées défini en 7.1, par exemple `C:\D365\CustomMetadata` |
| `$/D365FO-DEV/Trunk/Main/Projects` | Les fichiers de solution et de projet Visual Studio | Le dossier défini en 7.3, par exemple `C:\D365\Projects` |

**Point de vigilance majeur, propre à l'expérience de développement unifiée.** Ne placez **jamais** le dossier `PackagesLocalDirectory` sous contrôle de source. Il contient les métadonnées de référence de l'application standard Microsoft, soit environ 24 Go de fichiers que vous ne modifiez pas et qui sont retéléchargés à la demande. Les archiver saturerait le dépôt sans aucun bénéfice. Seul votre dossier de métadonnées personnalisées est concerné.

Les dossiers serveur seront créés depuis Visual Studio à l'étape 8.8, une fois la connexion établie.

### 8.7 Connecter Visual Studio à Azure DevOps

**Rôle requis.** Appartenance au projet, avec le niveau d'accès `Basic` (De base) et l'appartenance au groupe `Contributors` (Contributeurs).

**Étape 1.** Ouvrez Visual Studio 2022.

**Étape 2.** Sélectionnez le fournisseur de contrôle de source. Ouvrez `Tools` (Outils) > `Options` > `Source Control` (Contrôle de code source) > `Plug-in Selection` (Sélection du plug-in).

**Étape 3.** Dans la liste `Current source control plug-in` (Plug-in de contrôle de code source actuel), sélectionnez **`Visual Studio Team Foundation Server`**, puis validez par `OK`.

**Point de vigilance.** Cette sélection est indispensable. Tant qu'elle n'est pas faite, les commandes TFVC et la fenêtre `Source Control Explorer` (Explorateur de contrôle de code source) restent inaccessibles.

**Étape 4.** Ouvrez `View` (Affichage) > `Team Explorer` (Explorateur d'équipe).

**Étape 5.** Dans le volet `Team Explorer`, cliquez sur `Manage Connections` (Gérer les connexions), puis sur `Connect to a Project` (Se connecter à un projet).

**Étape 6.** Si votre organisation n'apparaît pas dans la liste, cliquez sur `Add Azure DevOps Server` (Ajouter un serveur Azure DevOps) et saisissez l'adresse `https://dev.azure.com/<organisation>`. Authentifiez-vous avec le compte du tenant.

**Étape 7.** Sélectionnez le projet `D365FO-DEV`, puis cliquez sur `Connect` (Se connecter).

**Étape 8.** Le volet `Team Explorer` affiche désormais les sections `Work Items` (Éléments de travail), `Builds` (Générations), `Source Control Explorer` (Explorateur de contrôle de code source) et `Settings` (Paramètres).

### 8.8 Mapper l'espace de travail

Le mapping, ou association d'espace de travail, établit la correspondance entre un dossier du serveur et un dossier de votre disque. C'est l'opération centrale de cette phase.

**Rôle requis.** `Contributors` (Contributeurs) du projet.

#### 8.8.1 Créer les dossiers sur le serveur

**Étape 1.** Dans `Team Explorer`, ouvrez `Source Control Explorer` (Explorateur de contrôle de code source).

**Étape 2.** Dans l'arborescence de gauche, sélectionnez la racine `$/D365FO-DEV`.

**Étape 3.** Créez le dossier `Trunk` par un clic droit, puis `New Folder` (Nouveau dossier).

**Étape 4.** Répétez l'opération pour créer successivement `Main` sous `Trunk`, puis `Metadata` et `Projects` sous `Main`.

**Étape 5.** Archivez cette arborescence : cliquez sur `Check In` (Archiver), saisissez un commentaire tel que `Initialisation de l'arborescence de contrôle de source`, puis validez.

#### 8.8.2 Définir les deux mappings

**Étape 1.** Dans `Source Control Explorer`, ouvrez la liste `Workspace` (Espace de travail) en haut de la fenêtre, puis sélectionnez `Workspaces` (Espaces de travail).

**Étape 2.** Sélectionnez votre espace de travail, généralement nommé d'après votre poste, puis cliquez sur `Edit` (Modifier).

**Étape 3.** Dans la grille `Working folders` (Dossiers de travail), renseignez deux lignes :

| Statut | Dossier source, sur le serveur | Dossier local |
| :-- | :-- | :-- |
| `Active` (Actif) | `$/D365FO-DEV/Trunk/Main/Metadata` | `C:\D365\CustomMetadata` |
| `Active` (Actif) | `$/D365FO-DEV/Trunk/Main/Projects` | `C:\D365\Projects` |

**Point de vigilance.** Le dossier local des métadonnées doit être **exactement** celui déclaré dans `Configure Metadata` en 7.1, au champ `Folder for your own custom metadata`. Un mapping vers un dossier différent produit une situation trompeuse : le contrôle de source fonctionne, mais il ne versionne pas le code que Visual Studio utilise réellement.

**Étape 4.** Cliquez sur `OK`. Visual Studio propose de récupérer le contenu du serveur : acceptez.

**Étape 5.** Vérification. Dans `Source Control Explorer`, les dossiers `Metadata` et `Projects` ne doivent plus afficher la mention `Not mapped` (Non mappé), mais le chemin local correspondant.

### 8.9 Premier archivage du modèle et du projet

**Rôle requis.** `Contributors` (Contributeurs) du projet.

**Étape 1.** Dans `Source Control Explorer`, sélectionnez le dossier `$/D365FO-DEV/Trunk/Main/Metadata`.

**Étape 2.** Cliquez sur `Add Items to Folder` (Ajouter des éléments au dossier).

**Étape 3.** Sélectionnez le dossier de votre modèle, par exemple `ArchiaExtensions`, situé dans `C:\D365\CustomMetadata`.

**Étape 4.** Dans l'assistant, vérifiez que les éléments suivants sont inclus :

- le **fichier descripteur du modèle**, un fichier XML portant le nom du modèle et situé dans le dossier `Descriptor` du package ;
- l'ensemble des dossiers de métadonnées du modèle, tels que `AxClass`, `AxTable` et `AxForm` ;
- les fichiers `.xpp` correspondants.

**Point de vigilance.** L'oubli du fichier descripteur est l'erreur la plus fréquente de cette étape. Sans lui, un collègue ou votre poste réinstallé récupérera des objets orphelins que Visual Studio ne reconnaîtra pas comme un modèle.

**Étape 5.** Répétez l'opération pour le dossier `Projects`, en y ajoutant les fichiers `.sln` et `.rnrproj`.

**Étape 6.** Ouvrez la vue `Pending Changes` (Modifications en attente) dans `Team Explorer`, saisissez un commentaire explicite, par exemple `Création du modèle ArchiaExtensions et du projet associé`, puis cliquez sur `Check In` (Archiver).

**Étape 7.** Vérification. Dans le portail Azure DevOps, ouvrez `Repos` (Dépôts) > `Files` (Fichiers). L'arborescence et vos fichiers doivent y apparaître, avec l'auteur et l'horodatage de l'archivage.

### 8.10 Opérations courantes

Une fois le mapping en place, le cycle de travail quotidien repose sur quatre commandes.

| Commande | Emplacement | Usage |
| :-- | :-- | :-- |
| `Get Latest Version` (Obtenir la dernière version) | `Source Control Explorer`, clic droit sur un dossier | Synchronise votre dossier local avec la dernière version du serveur, avant de commencer à travailler |
| `Check Out for Edit` (Extraire pour modification) | Automatique lors de la modification d'un objet | Verrouille ou marque l'élément comme modifié |
| `Check In` (Archiver) | `Team Explorer` > `Pending Changes` | Publie vos modifications sur le serveur, avec un commentaire |
| `Refresh models` (Actualiser les modèles) | `Dynamics 365` > `Model Management` (Gestion des modèles) | Indispensable après avoir récupéré des modèles créés par un tiers, afin que Visual Studio les prenne en compte |

**Ordre de travail recommandé.** En début de session : `Get Latest Version`, puis `Refresh models` si de nouveaux modèles sont arrivés. En fin de session ou après chaque évolution fonctionnelle achevée : générer le projet, vérifier l'absence d'erreur, puis `Check In` avec un commentaire décrivant l'intention et non le contenu technique.

**Ce qui ne doit pas être archivé.** Outre `PackagesLocalDirectory`, excluez les dossiers de sortie de génération, les fichiers temporaires de Visual Studio, ainsi que tout fichier contenant des identifiants ou des chaînes de connexion.

### 8.11 Variante Git

Si vous retenez Git plutôt que TFVC, la logique reste identique mais les commandes diffèrent.

**Étape 1.** À l'étape 8.5, laissez `Version control` (Contrôle de version) sur `Git`. L'étape 8.4 devient inutile.

**Étape 2.** Dans Visual Studio, ouvrez `Git` > `Clone Repository` (Cloner un dépôt) et saisissez l'adresse du dépôt.

**Étape 3.** Clonez le dépôt dans un dossier racine, par exemple `C:\D365\Git\D365FO-DEV`.

**Étape 4.** Placez-y vos dossiers `Metadata` et `Projects`, puis faites pointer `Configure Metadata` sur `C:\D365\Git\D365FO-DEV\Metadata`. Contrairement à TFVC, Git ne dispose pas d'un mécanisme de mapping : c'est l'emplacement physique des fichiers qui détermine ce qui est versionné.

**Étape 5.** Ajoutez un fichier `.gitignore` à la racine du dépôt, excluant a minima les dossiers de sortie de génération et les fichiers temporaires de Visual Studio.

**Étape 6.** Utilisez la fenêtre `Git Changes` (Modifications Git) pour valider, `Commit` (Valider), puis publier, `Push` (Envoyer).

**Limite à connaître.** Si vous devez ultérieurement utiliser un environnement de génération rattaché à Lifecycle Services, un dépôt TFVC reste exigé, même s'il n'est pas activement utilisé.

### 8.12 Checklist de validation de la phase 7

- [ ] L'organisation Azure DevOps est créée avec l'identité du tenant.
- [ ] Le paramètre `Disable creation of TFVC repositories` a été désactivé, si la voie TFVC est retenue.
- [ ] Le projet d'équipe est créé, en visibilité `Private`, avec le contrôle de version voulu.
- [ ] L'arborescence `Trunk/Main/Metadata` et `Trunk/Main/Projects` existe sur le serveur.
- [ ] Le plug-in de contrôle de source est réglé sur `Visual Studio Team Foundation Server`.
- [ ] Visual Studio est connecté au projet via `Team Explorer`.
- [ ] Le dossier `Metadata` est mappé sur le dossier de métadonnées personnalisées **déclaré dans `Configure Metadata`**.
- [ ] Le dossier `Projects` est mappé sur le dossier des solutions Visual Studio.
- [ ] `PackagesLocalDirectory` n'est **pas** sous contrôle de source.
- [ ] Le modèle, son fichier descripteur et le projet sont archivés.
- [ ] Les fichiers sont visibles dans `Repos` (Dépôts) du portail Azure DevOps.

## 9. Phase 8 : Accès direct à la base de données

**Objectif de la phase.** Obtenir des identifiants temporaires afin d'interroger la base de données produit depuis SQL Server Management Studio.

**Rôles requis pour cette phase.** `System administrator` (Administrateur système) dans l'environnement Finance and Operations. Ce rôle est strictement exigé : la demande d'identifiants est refusée pour tout autre profil, sans possibilité de dérogation.

### 9.1 Comprendre le mécanisme

Contrairement à une machine virtuelle de développement classique, un environnement `Sandbox` cloud n'expose pas librement sa base de données. L'accès repose sur un mécanisme d'octroi ponctuel, dit `just-in-time` (juste à temps). Vous demandez des identifiants, vous en justifiez le motif, et vous recevez des accès temporaires restreints à votre adresse IP.

Conditions et limites :

- l'accès est réservé aux environnements de développement unifiés ;
- le rôle `System administrator` (Administrateur système) dans l'environnement est requis ;
- les identifiants ont une durée de validité limitée, de l'ordre d'une journée ;
- le pare-feu Azure SQL restreint les connexions à la plage d'adresses IPv4 déclarée ;
- l'octroi de nouveaux identifiants à un même utilisateur invalide les précédents sur le même environnement ;
- plusieurs utilisateurs peuvent détenir simultanément des identifiants sur un même environnement, et un même utilisateur peut en détenir sur plusieurs environnements.

### 9.2 Demander les identifiants SQL

**Rôle requis.** `System administrator` (Administrateur système) dans l'environnement Finance and Operations. Aucun autre rôle n'ouvre cet accès.

**Étape 1.** Dans Visual Studio, ouvrez le menu `Tools` (Outils) et cliquez sur `SQL Credentials for Dynamics 365 FinOps` (Informations d'identification SQL pour Dynamics 365 FinOps).

**Étape 2.** Une fenêtre s'ouvre. Saisissez un motif de demande d'accès. Le texte est libre, mais il doit rester explicite car la demande est tracée. Exemple : `Analyse des données de test, projet ARCHIA365`.

**Étape 3.** Vérifiez la plage d'adresses IPv4 proposée. Elle est préremplie avec l'adresse IP publique de votre poste. Ne l'élargissez pas inutilement.

**Étape 4.** Cliquez sur `Request access` (Demander l'accès) et patientez pendant le traitement.

**Étape 5.** Les identifiants s'affichent : nom du serveur, nom de la base, nom d'utilisateur et mot de passe. Copiez-les immédiatement, ainsi que la date d'expiration indiquée.

### 9.3 Se connecter depuis SSMS

**Étape 1.** Ouvrez SQL Server Management Studio, installé en 6.1.

**Étape 2.** Dans la fenêtre `Connect to Server` (Se connecter au serveur), renseignez :

| Champ | Valeur |
| :-- | :-- |
| `Server type` (Type de serveur) | `Database Engine` (Moteur de base de données) |
| `Server name` (Nom du serveur) | Le nom de serveur fourni par Visual Studio |
| `Authentication` (Authentification) | `SQL Server Authentication` (Authentification SQL Server) |
| `Login` (Connexion) | Le nom d'utilisateur fourni |
| `Password` (Mot de passe) | Le mot de passe fourni |

**Étape 3.** Ouvrez `Options` > `Connection Properties` (Propriétés de connexion) et renseignez le champ `Connect to database` (Se connecter à la base de données) avec le nom de base fourni. Cette précision est souvent nécessaire, l'utilisateur temporaire n'ayant pas de base par défaut.

**Étape 4.** Cliquez sur `Connect` (Se connecter).

**Étape 5.** Vous pouvez désormais exécuter des requêtes et vérifier directement le résultat de vos personnalisations.

**Usage responsable.** Cet accès porte sur la base réelle de l'environnement. Limitez-vous à des opérations de lecture, de type `SELECT`, sauf nécessité impérieuse et maîtrisée. Toute modification directe contourne la logique applicative X++ et peut compromettre la cohérence fonctionnelle de l'environnement.

### 9.4 Checklist de validation de la phase 8

- [ ] Les identifiants SQL ont été obtenus depuis Visual Studio.
- [ ] La date d'expiration est notée.
- [ ] La connexion SSMS aboutit.
- [ ] Une requête `SELECT` simple retourne des données.

## 10. Annexe A : Dépannage

### 10.1 Phase 1, licences

| Symptôme | Cause probable | Résolution |
| :-- | :-- | :-- |
| Message indiquant que l'adresse de messagerie est déjà utilisée | L'adresse est rattachée à un tenant existant | Utilisez une autre adresse, ou créez un alias |
| L'adresse postale n'est pas validée | Format non reconnu par le service de validation | Relisez la saisie, puis cliquez sur `Use this address` |
| Le paiement est refusé | Transactions en ligne désactivées sur la carte | Activez-les auprès de votre banque, ou utilisez une autre carte |
| L'offre `Microsoft 365 E3` n'est pas proposée en essai | Disponibilité régionale ou parcours commercial différent | Passez par le Microsoft 365 Admin Center, `Marketplace`, et recherchez `Microsoft 365 E3` |
| `Dynamics 365 Finance Premium` est absent du `Marketplace` | Filtre de recherche ou disponibilité régionale | Recherchez `Dynamics 365 Finance` sans le mot `Premium`, et vérifiez le pays du tenant |

### 10.2 Phase 2, Azure et Subscription

| Symptôme | Cause probable | Résolution |
| :-- | :-- | :-- |
| Aucune Subscription n'apparaît après l'inscription | L'inscription n'est pas finalisée, ou la vérification d'identité a échoué | Reprenez le parcours d'inscription, ou appliquez le chemin B décrit en 3.4 |
| Le bouton `Add` (Ajouter) est inactif dans `Subscriptions` | Rôle insuffisant sur le compte de facturation | Vérifiez que vous détenez `Owner`, `Contributor` ou `Azure subscription creator` |
| Aucun `Billing account` n'est visible | Le compte connecté n'est pas celui de l'inscription Azure | Reconnectez-vous avec le compte `@votresociete.onmicrosoft.com` |
| La Subscription est créée dans le mauvais annuaire | Champ `Subscription directory` mal renseigné | Recréez la Subscription en sélectionnant l'annuaire du tenant |
| `Microsoft.PowerPlatform` reste `NotRegistered` | Enregistrement non propagé | Patientez 5 minutes et rafraîchissez, puis relancez `Register` |

### 10.3 Phase 3, capacité et Billing plan

| Symptôme | Cause probable | Résolution |
| :-- | :-- | :-- |
| La liste `Azure subscription` est vide | Subscription dans un autre tenant, fournisseur de ressources non enregistré, ou propagation en cours | Vérifiez les points de la section 9.2, puis patientez 15 à 30 minutes |
| La liste `Resource group` est vide | Aucun groupe de ressources, ou aucun dans la région choisie | Créez-en un dans le portail Azure comme indiqué en 3.6 |
| Le `Billing plan` reste bloqué sur `Pending` (En attente) | Fournisseurs de ressources Azure non enregistrés | Enregistrez `Microsoft.PowerPlatform` sur la Subscription |
| L'environnement n'apparaît pas à l'étape de sélection | La région sélectionnée diffère de celle de l'environnement | Sélectionnez la région exacte de l'environnement |
| Le type `Sandbox` reste grisé après création du plan | Propagation non terminée | Patientez 15 à 30 minutes, rafraîchissez le navigateur, puis reconnectez-vous |

### 10.4 Phase 4, environnement et applications

| Symptôme | Cause probable | Résolution |
| :-- | :-- | :-- |
| Message `Not enough capacity` (Capacité insuffisante) à la création | Le `Billing plan` n'est pas actif, ou ne couvre pas la région | Vérifiez le statut `Enabled` du plan et la cohérence de région |
| La `Provisioning App` est introuvable | `Platform Tools` n'est pas installé, ou son statut n'est pas `Installed` | Terminez d'abord l'installation de `Platform Tools` |
| L'installation de la `Provisioning App` échoue | Nom d'hôte de plus de 19 caractères | Recréez l'environnement avec un nom court |
| L'installation dépasse trois heures | Charge de la plateforme, ou blocage réel | Rafraîchissez la page. Au-delà de quatre heures, ouvrez un ticket de support depuis le PPAC |
| L'adresse Finance and Operations n'apparaît pas | Problème connu de synchronisation d'affichage | Modifiez la description de l'environnement et enregistrez, ce qui force la synchronisation |
| Les outils de développement sont absents | Cases non cochées, ou modèle applicatif utilisé à la création | Recréez l'environnement en suivant strictement les sections 5.1 et 5.3 |

### 10.5 Phase 5, poste local

| Symptôme | Cause probable | Résolution |
| :-- | :-- | :-- |
| Visual Studio ne parvient pas à se connecter | Blocage lié à l'authentification multifacteur | Décochez toutes les cases de l'écran de connexion pour déclencher l'authentification interactive par navigateur |
| Aucun environnement dans la liste | Adresse erronée, celle de Finance and Operations au lieu de l'`Environment URL` | Utilisez l'adresse en `*.dynamics.com` |
| Le compte est invité dans un autre tenant | Découverte automatique inopérante | Activez `Skip discovery when connecting to Dataverse`, puis saisissez l'adresse Dataverse |
| Le téléchargement des assets s'interrompt | Coupure réseau, ou espace disque insuffisant | Menu `Tools` > `Download Dynamics 365 assets` (Télécharger les assets Dynamics 365). Le dossier existant est purgé et le téléchargement redémarre intégralement |
| Aucune visibilité sur la progression | Fenêtre de sortie masquée | Ouvrez `View` (Affichage) > `Output` (Sortie). La progression et les erreurs y sont affichées en temps réel |
| Le dossier des assets pèse nettement moins de 24 Go | Téléchargement incomplet | Relancez via `Download Dynamics 365 assets` |
| L'extraction de `PackagesLocalDirectory.zip` échoue | Limites de l'extracteur natif de Windows sur les archives volumineuses | Utilisez 7-Zip |
| Les fichiers téléchargés sont bloqués par Windows | Marquage de provenance Internet | Clic droit, `Properties` (Propriétés), puis cochez `Unblock` (Débloquer) |

### 10.6 Phase 6, métadonnées et modèle

| Symptôme | Cause probable | Résolution |
| :-- | :-- | :-- |
| Le bouton `Save` reste grisé | Un champ est invalide | Repérez le champ encadré en rouge et lisez l'infobulle |
| Erreur de connexion à LocalDB | Instance LocalDB absente | Ouvrez une invite de commandes et exécutez `sqllocaldb create MSSQLLocalDB -s` |
| L'`Application Explorer` reste vide | Le chemin des métadonnées de référence est erroné | Vérifiez qu'il pointe sur le dossier décompressé `PackagesLocalDirectory` |
| Le modèle n'apparaît pas après création | Rafraîchissement nécessaire | Fermez et rouvrez Visual Studio |

### 10.7 Phase 7, Azure DevOps et contrôle de source

| Symptôme | Cause probable | Résolution |
| :-- | :-- | :-- |
| L'option `Team Foundation Version Control` n'apparaît pas à la création du projet | Le paramètre `Disable creation of TFVC repositories` est actif sur l'organisation | Appliquez la section 8.4, rafraîchissez la page, puis reconnectez-vous |
| Le paramètre TFVC est introuvable dans les paramètres d'organisation | Rôle insuffisant | Vérifiez votre appartenance au groupe `Project Collection Administrators` |
| Le menu `Source Control Explorer` est absent de Visual Studio | Le plug-in de contrôle de source n'est pas sélectionné | Ouvrez `Tools` > `Options` > `Source Control` > `Plug-in Selection` et choisissez `Visual Studio Team Foundation Server` |
| `Team Explorer` ne propose pas l'organisation | Organisation non enregistrée dans Visual Studio | Utilisez `Add Azure DevOps Server` et saisissez `https://dev.azure.com/<organisation>` |
| L'authentification échoue en boucle | Session mélangée entre identité personnelle et compte du tenant | Fermez Visual Studio, effacez les comptes enregistrés via `File` > `Account Settings`, puis reconnectez-vous avec le compte du tenant |
| Les dossiers restent marqués `Not mapped` | Espace de travail non modifié, ou mapping enregistré sur un autre espace de travail | Ouvrez `Workspaces` > `Edit` et vérifiez les deux lignes de la grille `Working folders` |
| Le code archivé n'est pas celui utilisé par Visual Studio | Le dossier local mappé diffère du dossier déclaré dans `Configure Metadata` | Comparez les deux chemins et corrigez le mapping, conformément au point de vigilance de la section 8.8.2 |
| Le dépôt grossit anormalement | `PackagesLocalDirectory` a été ajouté au contrôle de source | Supprimez ce mapping et retirez les éléments concernés du dépôt |
| Un modèle récupéré depuis le serveur n'apparaît pas dans Visual Studio | Modèles non actualisés | Exécutez `Dynamics 365` > `Model Management` > `Refresh models` |
| Un collègue récupère des objets orphelins | Le fichier descripteur du modèle n'a pas été archivé | Archivez le fichier XML du dossier `Descriptor` du package |
| L'archivage est refusé | Niveau d'accès `Stakeholder` (Partie prenante), ou absence du groupe `Contributors` | Faites élever votre niveau d'accès à `Basic` et vérifier votre appartenance au groupe `Contributors` |

### 10.8 Phase 8, accès SQL

| Symptôme | Cause probable | Résolution |
| :-- | :-- | :-- |
| L'option `SQL Credentials` est absente du menu `Tools` | Extension Finance and Operations non installée, ou environnement non unifié | Vérifiez la phase 5 et contrôlez le type d'environnement |
| La demande d'accès est refusée | Le rôle `System administrator` n'est pas attribué | Attribuez-le dans l'application Finance and Operations, `System administration` > `Users` |
| SSMS retourne une erreur de pare-feu | Adresse IP publique modifiée depuis la demande | Redemandez des identifiants avec l'adresse IP courante |
| Message `Cannot open database requested by the login` | Base par défaut non définie pour l'utilisateur temporaire | Renseignez `Connect to database` dans `Options` > `Connection Properties` |

## 11. Annexe B : Checklist séquentielle d'exhaustivité, de bout en bout

Cette annexe existe pour répondre à une question précise : **ai-je oublié une étape ?**

Contrairement à la checklist thématique de l'annexe C, qui vérifie des états, celle-ci suit l'**ordre chronologique exact** des actions à réaliser. Chaque ligne correspond à une action concrète, avec le rôle nécessaire pour l'exécuter et la section du document qui la détaille. Parcourez-la de haut en bas : si une case reste vide, l'étape correspondante n'a pas été faite, et les suivantes échoueront probablement.

### 11.1 Préparation

| Fait | Action | Rôle requis | Section |
| :-- | :-- | :-- | :-- |
| [ ] | Vérifier que le poste dispose de 16 Go de mémoire vive et de 60 Go d'espace disque libre | Aucun | 1.5.1 |
| [ ] | Préparer une adresse de messagerie non rattachée à un tenant Microsoft | Aucun | 1.5.2 |
| [ ] | Vérifier que la carte bancaire autorise les transactions en ligne | Aucun | 1.5.2 |
| [ ] | Ouvrir un profil de navigateur dédié ou une fenêtre privée | Aucun | 1.5.3 |
| [ ] | Prendre connaissance de la matrice des rôles | Aucun | 1.7.2 |

### 11.2 Phase 1, licences et tenant

| Fait | Action | Rôle requis | Section |
| :-- | :-- | :-- | :-- |
| [ ] | Ouvrir la page de l'offre Microsoft 365 E3 et lancer l'essai | Aucun | 2.3 |
| [ ] | Saisir l'adresse de messagerie et créer le compte | Aucun | 2.3 |
| [ ] | Renseigner l'identité, l'adresse postale et l'identifiant fiscal | Aucun | 2.3 |
| [ ] | Définir le nom de domaine, le nom d'utilisateur et le mot de passe | Aucun | 2.3 |
| [ ] | **Consigner l'identifiant complet et le mot de passe** | Aucun | 2.3 |
| [ ] | Saisir les coordonnées bancaires et démarrer l'essai | Aucun | 2.3 |
| [ ] | Configurer l'authentification multifacteur | `Authentication administrator` ou `Global admin` | 2.3 |
| [ ] | Se connecter au Microsoft 365 Admin Center pour valider l'accès | `Global admin` | 2.3 |
| [ ] | Ouvrir le `Marketplace` et rechercher Dynamics 365 Finance Premium | `Billing administrator` ou `Global admin` | 2.4 |
| [ ] | Sélectionner le plan d'essai | `Billing administrator` ou `Global admin` | 2.4 |
| [ ] | **Choisir `No, cancel at expiration`** pour éviter le renouvellement payant | `Billing administrator` ou `Global admin` | 2.4 |
| [ ] | Démarrer l'essai et vérifier la présence des 25 licences | `Billing administrator` ou `Global admin` | 2.4 |
| [ ] | Affecter la licence Microsoft 365 E3 à votre compte | `License administrator` ou `Global admin` | 2.5 |
| [ ] | Affecter la licence Dynamics 365 Finance Premium à votre compte | `License administrator` ou `Global admin` | 2.5 |

### 11.3 Phase 2, Azure et Subscription

| Fait | Action | Rôle requis | Section |
| :-- | :-- | :-- | :-- |
| [ ] | **Vérifier que la session en cours utilise le compte du tenant**, et non une identité personnelle | Aucun | 3.3 |
| [ ] | S'inscrire à Azure et accepter le contrat | Aucun | 3.3 |
| [ ] | Réaliser la vérification d'identité par téléphone | Aucun | 3.3 |
| [ ] | Confirmer le moyen de paiement et finaliser l'inscription | Aucun | 3.3 |
| [ ] | Ouvrir le portail Azure et vérifier la présence du crédit | Aucun | 3.3 |
| [ ] | Vérifier qu'une Subscription apparaît dans `Subscriptions` | `Reader` au minimum | 3.3 |
| [ ] | Si nécessaire, identifier le compte de facturation | `Owner` ou `Contributor` sur le compte de facturation | 3.4.2 |
| [ ] | Si nécessaire, créer une Subscription dédiée via `Subscriptions` > `Add` | `Owner`, `Contributor` ou `Azure subscription creator` | 3.4.3 |
| [ ] | **Vérifier que la Subscription est rattachée au bon annuaire Entra ID** | `Owner` ou `Contributor` | 3.4.3 |
| [ ] | Enregistrer le fournisseur de ressources `Microsoft.PowerPlatform` | `Owner` ou `Contributor` sur la Subscription | 3.5 |
| [ ] | Vérifier que son statut est passé à `Registered` | `Reader` au minimum | 3.5 |
| [ ] | Créer le `Resource group` dans une région cohérente | `Owner` ou `Contributor` sur la Subscription | 3.6 |
| [ ] | Créer un budget et configurer les alertes de coût | `Cost Management Contributor`, `Owner` ou `Contributor` | 3.7 |

### 11.4 Phase 3, capacité et plan de facturation

| Fait | Action | Rôle requis | Section |
| :-- | :-- | :-- | :-- |
| [ ] | **Vérifier votre rôle sur la Subscription Azure** via `Access control (IAM)` > `View my access` | `Reader` au minimum pour consulter | 4.3 |
| [ ] | Confirmer que ce rôle est `Owner` ou `Contributor` | Sans quoi la suite est impossible | 4.3 |
| [ ] | Ouvrir le Power Platform Admin Center et la section `Licensing` | `Power Platform admin` ou équivalent | 4.3 |
| [ ] | Créer le `Billing plan` de type `Azure subscription` | `Power Platform admin` côté PPAC, `Owner` ou `Contributor` côté Azure | 4.3 |
| [ ] | Sélectionner la Subscription et le `Resource group` | Idem | 4.3 |
| [ ] | Sélectionner la région et l'environnement à rattacher | Idem | 4.3 |
| [ ] | Vérifier que le plan affiche le statut `Enabled` | `Power Platform admin` | 4.3 |
| [ ] | Vérifier que le type `Sandbox` est devenu sélectionnable | `Power Platform admin` | 4.4 |

### 11.5 Phase 4, environnement et applications

| Fait | Action | Rôle requis | Section |
| :-- | :-- | :-- | :-- |
| [ ] | Créer un environnement de type `Sandbox` | `Power Platform admin`, `Dynamics 365 admin` ou `Global admin` | 5.1 |
| [ ] | **Vérifier que le nom d'hôte ne dépasse pas 19 caractères** | Idem | 5.1 |
| [ ] | Activer `Add a database / data store` | Idem | 5.1 |
| [ ] | Choisir la langue et la devise, non modifiables ensuite | Idem | 5.1 |
| [ ] | Activer `Enable Dynamics 365 apps` | Idem | 5.1 |
| [ ] | **Ne sélectionner aucun modèle applicatif automatique** | Idem | 5.1 |
| [ ] | Attendre l'état `Ready` | Idem | 5.1 |
| [ ] | Installer `Dynamics 365 Finance and Operations Platform Tools` | `Power Platform admin` ou licence éligible | 5.2 |
| [ ] | **Attendre le statut `Installed` avant de continuer** | Idem | 5.2 |
| [ ] | Lancer l'installation de la `Finance and Operations Provisioning App` | Idem | 5.3 |
| [ ] | **Cocher `Enable developer tools for Finance and Operations`** | Idem | 5.3 |
| [ ] | **Cocher `Enable demo data for Finance and Operations`** | Idem | 5.3 |
| [ ] | Attendre la fin de l'installation, de une à deux heures | Idem | 5.3 |
| [ ] | Relever l'`Environment URL` et la `Finance and Operations URL` | Idem | 5.4 |
| [ ] | Ouvrir l'application dans le navigateur et vérifier les données Contoso | Licence Dynamics 365 affectée | 5.4 |
| [ ] | Vérifier l'attribution du rôle `System administrator` | `System administrator` | 5.5 |

### 11.6 Phase 5, poste de développement

| Fait | Action | Rôle requis | Section |
| :-- | :-- | :-- | :-- |
| [ ] | Installer SQL Server Management Studio | Administrateur local | 6.1 |
| [ ] | Redémarrer le poste | Administrateur local | 6.1 |
| [ ] | S'inscrire à Visual Studio Dev Essentials et télécharger Visual Studio 2022 | Aucun | 6.2 |
| [ ] | Installer la charge de travail `.NET desktop development` | Administrateur local | 6.3 |
| [ ] | Ajouter le composant `Modeling SDK` | Administrateur local | 6.3 |
| [ ] | Ajouter le composant `DGML editor` | Administrateur local | 6.3 |
| [ ] | Se connecter à Visual Studio avec le compte du tenant | Aucun | 6.3 |
| [ ] | Installer l'extension `Microsoft Reporting Services Projects` | Administrateur local | 6.4.1 |
| [ ] | Installer l'extension `Power Platform Tools` | Administrateur local | 6.4.2 |
| [ ] | Configurer les options `Power Platform` dans `Tools` > `Options` | Aucun | 6.5 |
| [ ] | Récupérer l'`Environment URL`, et non l'adresse Finance and Operations | `Power Platform admin` pour la consulter | 6.6 |
| [ ] | Se connecter à Dataverse depuis Visual Studio | `System administrator` dans l'environnement | 6.6 |
| [ ] | **Sélectionner la solution de l'environnement F&O, et non `Default`** | Idem | 6.6 |
| [ ] | Lancer le téléchargement des assets Dynamics 365 | Idem | 6.7 |
| [ ] | **Vérifier la présence d'environ 24 Go dans le dossier des assets** | Administrateur local | 6.7 |

### 11.7 Phase 6, modèle et projet

| Fait | Action | Rôle requis | Section |
| :-- | :-- | :-- | :-- |
| [ ] | Créer le dossier destiné aux métadonnées personnalisées | Administrateur local | 7.1 |
| [ ] | Configurer les métadonnées via `Configure Metadata` | Administrateur local | 7.1 |
| [ ] | Renseigner le serveur et le nom de la base de références croisées | Administrateur local | 7.1 |
| [ ] | Pointer les métadonnées de référence sur `PackagesLocalDirectory` décompressé | Administrateur local | 7.1 |
| [ ] | Vérifier l'ouverture de l'`Application Explorer` | Administrateur local | 7.1 |
| [ ] | Créer le modèle avec son éditeur et sa description | Administrateur local | 7.2 |
| [ ] | Choisir `Create new package` | Administrateur local | 7.2 |
| [ ] | Déclarer les packages `ApplicationFoundation`, `ApplicationPlatform` et `ApplicationSuite` | Administrateur local | 7.2 |
| [ ] | Créer le projet et son emplacement | Administrateur local | 7.3 |
| [ ] | Vérifier la structure de fichiers sur disque | Administrateur local | 7.3 |
| [ ] | Lancer une génération du projet et confirmer l'absence d'erreur | Administrateur local | 7.4 |

### 11.8 Phase 7, Azure DevOps et contrôle de source

| Fait | Action | Rôle requis | Section |
| :-- | :-- | :-- | :-- |
| [ ] | Créer l'organisation Azure DevOps avec l'identité du tenant | Aucun, le créateur devient `Organization Owner` | 8.3 |
| [ ] | **Désactiver le paramètre `Disable creation of TFVC repositories`**, si la voie TFVC est retenue | `Project Collection Administrators` | 8.4 |
| [ ] | Créer le projet d'équipe en visibilité `Private` | `Project Collection Administrators` | 8.5 |
| [ ] | Sélectionner `Team Foundation Version Control` dans `Advanced` | `Project Collection Administrators` | 8.5 |
| [ ] | Régler le plug-in de contrôle de source dans `Tools` > `Options` | Administrateur local | 8.7 |
| [ ] | Connecter Visual Studio au projet via `Team Explorer` | `Contributors`, accès `Basic` | 8.7 |
| [ ] | Créer l'arborescence `Trunk/Main/Metadata` et `Trunk/Main/Projects` | `Contributors` | 8.8.1 |
| [ ] | Archiver l'arborescence initiale | `Contributors` | 8.8.1 |
| [ ] | Mapper `Metadata` sur le dossier de métadonnées personnalisées | `Contributors` | 8.8.2 |
| [ ] | **Vérifier que ce dossier est identique à celui de `Configure Metadata`** | `Contributors` | 8.8.2 |
| [ ] | Mapper `Projects` sur le dossier des solutions Visual Studio | `Contributors` | 8.8.2 |
| [ ] | **Vérifier que `PackagesLocalDirectory` n'est pas mappé** | `Contributors` | 8.6 |
| [ ] | Ajouter le modèle au contrôle de source, fichier descripteur inclus | `Contributors` | 8.9 |
| [ ] | Ajouter la solution et le projet Visual Studio | `Contributors` | 8.9 |
| [ ] | Réaliser le premier archivage avec un commentaire explicite | `Contributors` | 8.9 |
| [ ] | Vérifier la présence des fichiers dans `Repos` du portail Azure DevOps | `Readers` au minimum | 8.9 |

### 11.9 Phase 8, accès à la base de données

| Fait | Action | Rôle requis | Section |
| :-- | :-- | :-- | :-- |
| [ ] | Demander les identifiants SQL depuis `Tools` > `SQL Credentials for Dynamics 365 FinOps` | `System administrator` dans l'environnement | 9.2 |
| [ ] | Saisir un motif d'accès explicite | Idem | 9.2 |
| [ ] | Vérifier la plage d'adresses IPv4 proposée | Idem | 9.2 |
| [ ] | Copier les identifiants et noter la date d'expiration | Idem | 9.2 |
| [ ] | Se connecter depuis SSMS en authentification SQL Server | Aucun rôle supplémentaire | 9.3 |
| [ ] | Renseigner `Connect to database` dans les propriétés de connexion | Aucun | 9.3 |
| [ ] | Exécuter une requête de lecture pour valider l'accès | Aucun | 9.3 |

### 11.10 Clôture

| Fait | Action | Rôle requis | Section |
| :-- | :-- | :-- | :-- |
| [ ] | Noter les dates d'expiration des essais dans un agenda | Aucun | 13.1 |
| [ ] | Vérifier que l'alerte de budget Azure est active | `Cost Management Contributor` ou équivalent | 13.2 |
| [ ] | Vérifier qu'un archivage récent existe dans Azure DevOps | `Contributors` | 8.10 |
| [ ] | Dérouler la checklist thématique de l'annexe C | Variable | 12 |
| [ ] | **Signaler tout point de blocage rencontré à contact@archia365.fr** | Aucun | 15 |

## 12. Annexe C : Checklist thématique de validation

Cette checklist regroupe les points de contrôle par domaine. Elle complète la checklist séquentielle de l'annexe B, qui suit l'ordre chronologique des opérations.

**Licences et identité**

- [ ] Tenant créé, domaine `*.onmicrosoft.com` noté
- [ ] Compte administrateur et mot de passe consignés
- [ ] Authentification multifacteur configurée
- [ ] Licence Microsoft 365 E3 affectée au compte
- [ ] Licence Dynamics 365 Finance Premium affectée au compte
- [ ] Non-renouvellement automatique confirmé sur les deux abonnements

**Azure**

- [ ] Compte Azure créé avec l'identité du tenant
- [ ] Subscription active et visible dans le portail Azure
- [ ] Subscription rattachée au bon annuaire Microsoft Entra ID
- [ ] Fournisseur de ressources `Microsoft.PowerPlatform` enregistré
- [ ] `Resource group` créé
- [ ] Alerte de budget configurée

**Power Platform**

- [ ] `Billing plan` créé et au statut `Enabled`
- [ ] Environnement de type `Sandbox` à l'état `Ready`
- [ ] `Platform Tools` au statut `Installed`
- [ ] `Provisioning App` au statut `Installed`, avec outils de développement et données de démonstration
- [ ] Application Finance and Operations accessible dans le navigateur avec les données Contoso
- [ ] Rôle `System administrator` attribué dans l'application

**Poste local**

- [ ] SSMS installé
- [ ] Visual Studio 2022 installé et activé
- [ ] Charge de travail et composants individuels requis présents
- [ ] Deux extensions installées
- [ ] Options `Power Platform` configurées
- [ ] Connexion à l'environnement établie sur la bonne solution
- [ ] Environ 24 Go d'assets téléchargés

**Contrôle de source**

- [ ] Organisation Azure DevOps créée avec l'identité du tenant
- [ ] Projet d'équipe créé en visibilité `Private`
- [ ] Dépôt configuré, TFVC ou Git selon le choix retenu
- [ ] Plug-in de contrôle de source sélectionné dans Visual Studio
- [ ] Connexion établie via `Team Explorer`
- [ ] Mapping du dossier `Metadata` cohérent avec `Configure Metadata`
- [ ] Mapping du dossier `Projects` établi
- [ ] `PackagesLocalDirectory` exclu du contrôle de source
- [ ] Modèle, fichier descripteur et projet archivés
- [ ] Fichiers visibles dans le portail Azure DevOps

**Développement**

- [ ] Configuration de métadonnées enregistrée
- [ ] `Application Explorer` fonctionnel
- [ ] Modèle et package créés
- [ ] Projet créé et compilable
- [ ] Identifiants SQL obtenus et connexion SSMS validée

## 13. Annexe D : Fin d'essai, coûts et nettoyage

### 13.1 Calendrier à anticiper

| Échéance | Élément | Action requise |
| :-- | :-- | :-- |
| J+30 | Microsoft 365 E3 | Vérifier l'annulation, ou la désactiver manuellement |
| J+30 | Dynamics 365 Finance Premium | Annulation automatique si l'option a été retenue |
| J+30 | Crédit Azure | Le crédit expire. La Subscription bascule en paiement à l'usage |
| J+90 | Visual Studio Professional | Acquérir une licence, ou basculer sur Visual Studio Community |

### 13.2 Surveiller les coûts

**Étape 1.** Dans le portail Azure, ouvrez `Cost Management + Billing` (Gestion des coûts et facturation).

**Étape 2.** Consultez `Cost analysis` (Analyse des coûts) pour visualiser la consommation réelle.

**Étape 3.** Vérifiez que le budget défini en 3.7 est actif et que les alertes sont bien envoyées.

La consommation liée au `Billing plan` du Power Platform apparaît sous la Subscription et le `Resource group` déclarés.

### 13.3 Démanteler proprement l'environnement

Lorsque l'environnement n'est plus nécessaire, procédez dans cet ordre :

1. **Supprimer l'environnement** : PPAC > `Manage` > `Environments`, sélection, puis `Delete` (Supprimer). Cette action stoppe la consommation de capacité.
2. **Supprimer le Billing plan** : PPAC > `Licensing` > `Pay-as-you-go plans`, sélection, puis suppression.
3. **Supprimer le Resource group** dans le portail Azure.
4. **Annuler les abonnements** dans le Microsoft 365 Admin Center, `Billing` (Facturation) > `Your products` (Vos produits).
5. **Annuler la Subscription Azure** si elle n'a plus d'usage, via `Subscriptions` > sélection > `Cancel subscription` (Annuler l'abonnement).

Les consommations antérieures à la suppression restent facturables. En revanche, aucun frais nouveau n'est généré ensuite.

### 13.4 Ce qui subsiste

Le tenant ne disparaît pas à l'expiration des abonnements. Vous pouvez y revenir ultérieurement pour souscrire de nouvelles licences. Conservez donc soigneusement le nom de domaine et les identifiants administrateur.

## 14. Annexe E : Références officielles

- [Lifecycle Services project creation freeze, Microsoft Learn](https://learn.microsoft.com/en-us/dynamics365/fin-ops-core/dev-itpro/lifecycle-services/lcs-project-creation-freeze)
- [Migration of the Lifecycle Services support experience to Power Platform admin center, Microsoft Learn](https://learn.microsoft.com/en-us/dynamics365/fin-ops-core/dev-itpro/lifecycle-services/support-migration-to-ppac)
- [Create a Microsoft Customer Agreement subscription, Microsoft Learn](https://learn.microsoft.com/en-us/azure/cost-management-billing/manage/create-subscription)
- [Set up a pay-as-you-go plan, Microsoft Learn](https://learn.microsoft.com/en-us/power-platform/admin/pay-as-you-go-set-up)
- [Pay-as-you-go issues FAQ, Microsoft Learn](https://learn.microsoft.com/en-us/power-platform/admin/pay-as-you-go-issues-faq)
- [Install the Finance and Operations Provisioning App, Microsoft Learn](https://learn.microsoft.com/en-us/power-platform/admin/unified-experience/tutorial-install-finance-operations-provisioning-app)
- [Deploy a new environment with an ERP template, Microsoft Learn](https://learn.microsoft.com/en-us/power-platform/admin/unified-experience/tutorial-deploy-new-environment-with-erp-template)
- [Install and configure development tools, Microsoft Learn](https://learn.microsoft.com/en-us/power-platform/developer/unified-experience/finance-operations-install-config-tools)
- [Request credentials to access the D365 product database, Microsoft Learn](https://learn.microsoft.com/en-us/power-platform/developer/unified-experience/finance-operations-product-db-access)
- [Write, deploy, and debug X++ code, Microsoft Learn](https://learn.microsoft.com/en-us/power-platform/developer/unified-experience/finance-operations-debug)
- [Avoid charges with your Azure free account, Microsoft Learn](https://learn.microsoft.com/en-us/azure/cost-management-billing/manage/avoid-charges-free-account)
- [Version control, metadata search, and navigation, Microsoft Learn](https://learn.microsoft.com/en-us/dynamics365/fin-ops-core/dev-itpro/dev-tools/version-control-metadata-navigation)
- [X++ in Git, Microsoft Learn](https://learn.microsoft.com/en-us/dynamics365/fin-ops-core/dev-itpro/dev-tools/git-intro)
- [Setting to disable creation of TFVC repositories, notes de version Azure DevOps](https://learn.microsoft.com/en-us/azure/devops/release-notes/2024/sprint-240-update)
- [No TFVC in new projects, feuille de route Azure DevOps](https://learn.microsoft.com/en-us/azure/devops/release-notes/roadmap/2024/no-tfvc-in-new-projects)
- [Team Foundation Version Control, documentation Azure DevOps](https://learn.microsoft.com/en-us/azure/devops/repos/tfvc/)
- [Workflow to write, deploy, debug, and troubleshoot X++ code across multiple environments, Microsoft Learn](https://learn.microsoft.com/en-us/power-platform/developer/unified-experience/finance-operations-innerloop)

## 15. À propos, contact et communauté

### 15.1 Auteur et éditeur

Document rédigé par **Rodrigue YENGO** pour **ARCHIA365** et **ARCHIALEARN**, dans le cadre de la série **Dynamics en 365**.

| Ressource | Lien |
| :-- | :-- |
| Profil de l'auteur | [Rodrigue YENGO sur LinkedIn](https://www.linkedin.com/in/rodrigue-yengo/) |
| Communauté | [Data & AI France Study Group](https://data-day.archifridays.com/) |
| Contact | contact@archia365.fr |

### 15.2 Data & AI France Study Group

Le **Data & AI France Study Group** est une communauté ouverte, soutenue par **ARCHIA365** et **ARCHIALEARN**, dont l'ambition est de bâtir la plus grande communauté Data francophone. Elle réunit celles et ceux qui souhaitent apprendre, partager et progresser autour des technologies Data et intelligence artificielle, à travers des sessions de formation, des parcours de préparation aux certifications et des événements réguliers.

Cette procédure s'inscrit dans cette démarche de partage : elle est diffusée pour que chacun puisse monter un environnement de développement Dynamics 365 Finance and Operations complet, sans blocage et sans mauvaise surprise de facturation.

### 15.3 Méthode d'élaboration

Ce document a été rédigé puis réécrit à l'issue de **deux déploiements complets menés de bout en bout**, sur deux tenants distincts. Le premier déploiement a servi à établir la séquence des opérations. Le second a permis de la valider, d'en mesurer les durées réelles et d'identifier les points de blocage qui figurent aujourd'hui dans les avertissements et dans l'annexe A.

Contenu vérifié au regard de la documentation Microsoft en vigueur au 25 août 2026. Les interfaces Microsoft évoluant fréquemment, certains libellés peuvent différer légèrement de ceux constatés à l'écran. La logique des étapes, elle, reste inchangée.

### 15.4 Vos retours

Cette procédure est vivante. Si vous rencontrez un point de blocage, si un libellé a changé, si une étape ne se déroule pas comme décrit, ou si vous souhaitez proposer une amélioration, écrivez-nous à **contact@archia365.fr**.

Pour que votre retour soit exploitable, précisez si possible :

- la **phase** et la **section** concernées, par exemple 4.3 ;
- le **message d'erreur exact**, copié tel quel ;
- le **contexte de votre tenant** : type d'offre Microsoft 365, région, présence ou non d'une Subscription Azure préexistante ;
- votre **rôle** au moment de l'action, si vous le connaissez.

Chaque retour est étudié et alimente directement la version suivante de ce document.
