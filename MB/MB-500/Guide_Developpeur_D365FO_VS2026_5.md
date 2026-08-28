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
| Version du document | 1.6 |
| Date | 25 août 2026 |
| Contact | contact@archia365.fr |

**Genèse du document.** Cette procédure a été rédigée à l'issue de deux mises en place complètes réalisées de bout en bout. Chaque étape a été exécutée, vérifiée, et corrigée à la lumière des blocages rencontrés.

**Appel à contribution.** Les portails Microsoft évoluent vite et les configurations de tenant varient. Si vous rencontrez un point de blocage, un libellé qui a changé, ou si vous identifiez une amélioration, faites-le nous remonter à l'adresse **contact@archia365.fr**. Précisez la phase concernée, le message d'erreur exact et le contexte de votre environnement.

**Convention de lecture.** Les libellés de l'interface Microsoft sont indiqués en anglais, en `police à chasse fixe`, suivis de leur équivalent français entre parenthèses. Les chemins de menu utilisent le signe `>` comme séparateur de niveau. Chaque phase est précédée de la mention des rôles requis.

## Sommaire

1. À lire avant de commencer
2. L'environnement de développement unifié
3. Phase 1 : Visual Studio 2026 Professional, installation et extensions
4. Phase 2 : Azure DevOps, organisation, projet et dépôt Git
5. Phase 3 : Modèle, package et projet
6. Phase 4 : Développement du composant
7. Phase 5 : Configuration du Power Platform pour l'automatisation
8. Phase 6 : Chaîne d'intégration continue et de déploiement
9. Phase 7 : Livraison du composant par le pipeline
10. Annexe A : Dépannage
11. Annexe B : Checklist séquentielle d'exhaustivité
12. Annexe C : Conventions de nommage et bonnes pratiques
13. Annexe D : Provisionnement d'un environnement par script
14. Annexe E : Références officielles
15. À propos, contact et communauté

## 1. À lire avant de commencer

### 1.1 Objectif et livrable

Ce guide part d'un poste vierge et se termine par un composant X++ fonctionnel, versionné, compilé automatiquement et déployé sur un environnement cloud par un pipeline.

À l'issue de la procédure, vous disposerez :

- d'un poste équipé de **Visual Studio 2026 Professional**, de ses charges de travail, de ses composants individuels et de ses extensions Dynamics 365 ;
- d'une **organisation Azure DevOps** avec un projet et un dépôt Git structuré ;
- d'un **modèle**, d'un **package** et d'un **projet** X++ opérationnels ;
- d'un **composant fonctionnel complet** : un champ métier ajouté au client, affiché sur le formulaire standard et protégé par une règle de validation écrite en X++ ;
- d'une **chaîne d'intégration continue et de déploiement** qui compile ce composant et l'installe automatiquement sur votre environnement.

### 1.2 Point de départ et articulation avec les autres documents

**Ce guide ne suppose pas qu'un environnement existe déjà.** Le chapitre 2 définit ce qu'est un environnement de développement unifié, le situe par rapport aux modèles qui l'ont précédé, et montre comment en provisionner un. Si vous partez de rien, commencez donc par ce chapitre 2.

En revanche, ce guide **suppose qu'un tenant Microsoft 365 existe**, doté d'une licence Dynamics 365 et, sur une licence d'essai, d'une Subscription Azure permettant de lever le plafond de capacité. La constitution de ce socle, depuis la création du tenant jusqu'au plan de facturation à l'usage, fait l'objet d'un document distinct de la même série, intitulé *Mise en place d'un environnement de développement complet Dynamics 365 Finance and Operations sur un nouveau tenant*.

**Répartition des rôles entre les deux documents :**

| Sujet | Document de mise en place d'environnement | Le présent guide |
| :-- | :-- | :-- |
| Création du tenant et des licences | Traité en détail | Supposé acquis |
| Subscription Azure, capacité et plan de facturation | Traité en détail | Supposé acquis, rappelé en 2.5.1 |
| Définition et choix du modèle de développement | Non traité | **Chapitre 2** |
| Provisionnement de l'environnement de développement | Traité en détail | **Chapitre 2**, vue d'ensemble opérationnelle |
| Poste de développement et extensions | Traité | **Chapitre 3**, plus détaillé |
| Développement d'un composant X++ | Non traité | **Chapitre 6**, cœur du guide |
| Chaîne d'intégration continue et de déploiement | Traité | **Chapitre 8**, orienté développeur |

**Ce dont vous devez disposer pour aborder le chapitre 2 :**

| Élément | Pourquoi |
| :-- | :-- |
| Un tenant Microsoft 365 | Il porte les identités, les licences et les environnements |
| Une licence Dynamics 365 affectée à votre compte | Sans licence, l'accès à l'application est refusé |
| Un rôle d'administration sur le Power Platform | `Power Platform admin`, `Dynamics 365 admin` ou `Global admin`, pour créer l'environnement |
| De la capacité disponible | Sur une licence d'essai, cela suppose une Subscription Azure rattachée par un plan de facturation à l'usage |
| Une Subscription Azure dans le tenant | Elle porte la capacité, puis le Managed DevOps Pool de la phase 6 |

**Si vous disposez déjà d'un environnement**, le chapitre 2 reste utile : sa section 2.6 fournit la grille de contrôle permettant de vérifier qu'il est réellement exploitable pour le développement, et sa section 2.7 lève l'ambiguïté sur les deux adresses de l'environnement.

### 1.3 Ce que vous allez construire

Le composant retenu est volontairement simple sur le plan fonctionnel, mais il traverse **les quatre techniques d'extensibilité les plus utilisées au quotidien**. Un développeur qui les maîtrise couvre l'essentiel des demandes courantes.

**Besoin fonctionnel.** Le service crédit souhaite consigner, pour chaque client, la **date de la prochaine revue de son encours**. Cette date doit apparaître sur la fiche client, et le système doit refuser l'enregistrement d'une date antérieure à la date du jour, une revue ne pouvant être planifiée dans le passé.

**Traduction technique.**

| Objet à créer | Type | Technique | Section |
| :-- | :-- | :-- | :-- |
| `ArcLabels` | Fichier de libellés | Création | 6.2 |
| `ArcCreditReviewDate` | Type de données étendu | Création | 6.3 |
| `CustTable.ArcExtension` | Extension de table | Extension de données | 6.4 |
| `CustTable.ArcExtension` | Extension de formulaire | Extension d'interface | 6.5 |
| `ArcCustTable_Extension` | Classe d'extension | Chain of Command | 6.6 |

À ces cinq objets X++ s'ajoute la **solution Dataverse** créée en 3.5, qui sert de contexte à la connexion entre Visual Studio et l'environnement, et de conteneur à tout composant Power Platform qui viendrait compléter le dispositif.

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

La colonne de gauche renvoie au **chapitre** du document, et non au numéro de phase.

| Chapitre | Action | Rôle minimal requis | Plan concerné |
| :-- | :-- | :-- | :-- |
| 2 | Créer un environnement `Sandbox` | `Power Platform admin` (Administrateur Power Platform), `Dynamics 365 admin` (Administrateur Dynamics 365) ou `Global admin` (Administrateur général) | Power Platform |
| 2 | Installer `Platform Tools` et la `Provisioning App` | Mêmes rôles, ou une licence Dynamics 365 éligible affectée au compte | Power Platform |
| 2 | Attribuer le rôle `System administrator` dans l'application | `System administrator` (Administrateur système) dans l'environnement | Dynamics 365 |
| 3 | Installer Visual Studio, les composants et les extensions | Administrateur local du poste | Poste local |
| 3 | Créer un éditeur et une solution dans le Power Platform | `System customizer` (Personnalisateur système) ou `System administrator` (Administrateur système) dans l'environnement | Power Platform |
| 3 | Se connecter à l'environnement depuis Visual Studio | `System administrator` (Administrateur système) dans l'environnement | Dynamics 365 |
| 3 | Créer une organisation Azure DevOps | Aucun rôle préalable, le créateur devient `Organization Owner` (Propriétaire de l'organisation) | Azure DevOps |
| 3 | Créer un projet d'équipe | `Project Collection Administrators` (Administrateurs de collection de projets) | Azure DevOps |
| 3 | Cloner, valider et publier du code | `Contributors` (Contributeurs), niveau d'accès `Basic` (De base) | Azure DevOps |
| 4 | Créer un modèle, un package et un projet | Administrateur local du poste | Poste local |
| 5 | Déployer un modèle et synchroniser la base | `System administrator` (Administrateur système) dans l'environnement | Dynamics 365 |
| 6 | Créer un principal de service | `System administrator` dans l'environnement, et droit de créer une inscription d'application dans Microsoft Entra ID | Les deux |
| 6 | Créer une connexion de service | `Project Administrators` (Administrateurs de projet) | Azure DevOps |
| 7 | Installer les extensions de l'organisation | `Project Collection Administrators` | Azure DevOps |
| 7 | Créer un flux Azure Artifacts | `Project Collection Administrators` | Azure DevOps |
| 7 | Enregistrer les fournisseurs de ressources Azure | `Owner` (Propriétaire) ou `Contributor` (Contributeur) sur la Subscription | Azure |
| 7 | Créer un `Managed DevOps Pool` (pool DevOps managé) | `DevOps Infrastructure Contributor` (Contributeur d'infrastructure DevOps) au minimum | Azure |
| 7 | Utiliser un pool d'agents dans un projet | Permission `Administrator` (Administrateur) ou `Creator` (Créateur) sur les pools d'agents | Azure DevOps |
| 8 | Créer et exécuter un pipeline | `Contributors` (Contributeurs) du projet | Azure DevOps |

### 1.7 Le paramètre DevToolsEnabled, condition sine qua non

Cette section traite le prérequis le plus déterminant de tout le guide, et celui dont l'oubli coûte le plus cher.

#### 1.7.1 De quoi il s'agit

Lorsqu'un environnement Finance and Operations est provisionné, la `Finance and Operations Provisioning App` (application de provisionnement) reçoit une chaîne de paramètres qui pilote ce qu'elle installe. Deux d'entre eux nous concernent :

```
DevToolsEnabled=true|DemoDataEnabled=true
```

Dans le Power Platform Admin Center, ces deux paramètres correspondent aux cases `Enable developer tools for Finance and Operations` (Activer les outils de développement) et `Enable demo data for Finance and Operations` (Activer les données de démonstration), cochées au moment de l'installation de l'application. Lorsque l'environnement est créé par script ou par appel direct à l'interface de programmation, ils sont transmis explicitement, comme le montre l'annexe D.

#### 1.7.2 Ce que ce paramètre commande réellement

`DevToolsEnabled` n'est pas un simple confort. Il conditionne l'installation, sur l'environnement, de l'ensemble du dispositif de développement côté serveur.

| Sans `DevToolsEnabled=true` | Avec `DevToolsEnabled=true` |
| :-- | :-- |
| Visual Studio ne peut pas se connecter à l'environnement | La connexion aboutit et expose les solutions |
| Aucun téléchargement de métadonnées de référence n'est proposé | Les métadonnées et l'extension Finance and Operations sont téléchargeables |
| Le déploiement d'un modèle est impossible | `Deploy model` (Déployer le modèle) fonctionne |
| La synchronisation de la base est impossible | `Synchronize database` (Synchroniser la base de données) fonctionne |
| Le débogage X++ est impossible | Le débogueur s'attache à l'environnement |
| La demande d'identifiants SQL est refusée | `SQL Credentials for Dynamics 365 FinOps` fonctionne |
| L'environnement reste une instance applicative utilisable, mais fermée au développement | L'environnement est un environnement de développement unifié à part entière |

Autrement dit, sans ce paramètre, la totalité des phases 1, 4 et 7 de ce guide est inapplicable. L'environnement fonctionne parfaitement pour un usage fonctionnel, ce qui rend l'erreur d'autant plus perfide : rien ne signale le problème tant que l'on ne tente pas de se connecter depuis Visual Studio.

#### 1.7.3 Pourquoi le sujet est critique sur une licence d'essai

Sur une souscription d'essai Finance and Operations, trois contraintes se cumulent.

1. **Seuls certains types d'environnement acceptent les outils de développement.** La `Provisioning App` n'est prise en charge que sur un environnement de type `Sandbox` (bac à sable) ou `Trial (subscription-based)` (version d'évaluation basée sur un abonnement). Un environnement de type `Production` est exclu.
2. **Le type `Sandbox` exige de la capacité.** Une licence d'essai n'en fournit qu'une dotation minimale, ce qui impose de rattacher l'environnement à une Subscription Azure par un plan de facturation à l'usage. Ce point est traité dans le document d'installation d'environnement de la même série.
3. **Le paramètre se fixe à la création, et à la création seulement.** Il n'existe pas de commutateur permettant d'activer les outils de développement sur un environnement déjà provisionné sans eux. La voie sûre consiste à **supprimer l'environnement et à le recréer**, ce qui, compte tenu des une à deux heures de provisionnement de l'application, représente une demi-journée perdue.

**La règle à retenir.** Sur une licence d'essai, vous disposez d'un nombre limité d'environnements et d'un temps limité. Vérifiez `DevToolsEnabled` avant toute chose, et non au moment où Visual Studio refuse de se connecter.

#### 1.7.4 Vérifier l'état de votre environnement

Trois contrôles, du plus rapide au plus formel.

**Contrôle 1, le plus rapide.** Dans le Power Platform Admin Center, ouvrez votre environnement, puis `Resources` (Ressources) > `Dynamics 365 apps` (Applications Dynamics 365). L'application de provisionnement doit être au statut `Installed` (Installé). Ouvrez ses détails : les options retenues à l'installation y figurent.

**Contrôle 2, décisif.** Tentez la connexion depuis Visual Studio, décrite en 3.6. Si l'environnement apparaît dans la liste et propose des solutions, les outils de développement sont actifs. S'il n'apparaît pas, ou si aucune solution n'est proposée, c'est le premier soupçon.

**Contrôle 3, par script.** Le script de l'annexe D transmet explicitement `DevToolsEnabled=true`. Un environnement créé avec ce script porte le paramètre par construction, ce qui supprime toute ambiguïté.

#### 1.7.5 Que faire si le paramètre est absent

| Situation | Action |
| :-- | :-- |
| L'environnement vient d'être créé, aucun travail n'y est stocké | Supprimez-le et recréez-le avec le paramètre, par le portail ou par le script de l'annexe D |
| L'environnement contient déjà des données de configuration | Créez un second environnement dédié au développement, et conservez le premier pour l'usage fonctionnel |
| La capacité ne permet pas un second environnement | Rattachez une Subscription Azure par un plan de facturation à l'usage, ce qui lève le plafond de capacité |
| Vous n'êtes pas certain de l'état actuel | Appliquez les trois contrôles de la section 1.7.4 avant de supprimer quoi que ce soit |

## 2. L'environnement de développement unifié

Ce chapitre définit ce qu'est un environnement de développement unifié, le situe par rapport aux modèles qui l'ont précédé, et montre comment en provisionner un. Il constitue le prérequis de tout ce qui suit : les chapitres suivants supposent qu'un tel environnement est disponible.

### 2.1 Définition

L'**environnement de développement unifié**, désigné par l'abréviation **UDE** pour `Unified Developer Experience` (Expérience de développement unifiée), est le modèle de développement actuel de Dynamics 365 Finance and Operations.

Il repose sur une séparation nette entre deux mondes :

| Composant | Où il se trouve | Ce qu'il porte |
| :-- | :-- | :-- |
| **Le poste de développement** | Votre machine, physique ou virtuelle | Visual Studio, les extensions, les métadonnées de référence en lecture, vos métadonnées personnalisées, le compilateur |
| **L'environnement Finance and Operations** | Le cloud Microsoft, provisionné dans le Power Platform | Le serveur d'application, la base de données, les données de démonstration, le moteur d'exécution du X++ déployé |

Le poste **écrit et compile**. L'environnement **exécute**. Entre les deux, un canal de déploiement piloté depuis Visual Studio transporte les modèles compilés vers le cloud, et un canal de débogage permet de suivre l'exécution distante depuis le poste.

**Ce que l'UDE conserve du modèle antérieur.** Le langage **X++**, la notion de **modèle** et de **package**, l'`Application Explorer` (Explorateur d'applications), le compilateur, les mécanismes d'extensibilité que sont les extensions de table, de formulaire et la Chain of Command. Un développeur venant du modèle précédent retrouve ses outils et ses réflexes.

**Ce que l'UDE change.** L'environnement d'exécution n'est plus sur la machine du développeur. Il n'y a plus de serveur d'application local, plus de base de données locale à administrer, plus d'image de machine virtuelle à maintenir. Le poste devient léger, l'environnement devient partagé et administré par la plateforme.

### 2.2 Le chemin parcouru depuis AX 2012

Comprendre d'où vient l'UDE éclaire ses choix de conception, et évite de chercher des mécanismes qui n'existent plus.

#### 2.2.1 Génération 1, AX 2012 et MorphX

Dynamics AX 2012 disposait de son propre environnement de développement, **MorphX**, intégré au client lourd. Le développeur travaillait directement dans l'**AOT**, `Application Object Tree` (Arborescence d'objets applicatifs), une arborescence unique où cohabitaient le code Microsoft et les personnalisations du client.

| Caractéristique | Conséquence |
| :-- | :-- |
| Développement dans le client applicatif lui-même | Aucun outil externe à installer, mais aucun outillage moderne non plus |
| Modification directe des objets standard, par système de couches | Toute mise à jour Microsoft imposait un travail de réconciliation manuel, parfois considérable |
| Code et données dans la même base | Le développement et l'exécution étaient indissociables |
| Contrôle de source par intégration à l'AOT | Fonctionnel, mais éloigné des pratiques de l'industrie |

Le point de rupture de ce modèle est la **modification du standard**. Un client ayant surchargé une centaine d'objets Microsoft payait cette dette à chaque mise à jour.

#### 2.2.2 Génération 2, Dynamics 365 F&O et les machines virtuelles OneBox

Avec le passage au cloud, Microsoft a abandonné MorphX au profit de **Visual Studio**, et a rendu le standard **non modifiable**. L'extensibilité est devenue la seule voie possible.

Le développement s'effectuait alors sur une **machine virtuelle OneBox**, ainsi nommée parce qu'elle contenait tout dans une seule boîte : serveur d'application, base de données SQL Server, services de restitution, Visual Studio et les métadonnées. Deux variantes coexistaient : une machine hébergée dans le cloud, provisionnée depuis Lifecycle Services, et une image **VHD** téléchargeable pour un usage local.

| Caractéristique | Conséquence |
| :-- | :-- |
| Tout est local à la machine virtuelle | Le développeur est autonome, y compris hors ligne pour le VHD |
| Machine de grande taille, de l'ordre de 32 Go de mémoire et plusieurs centaines de gigaoctets de disque | Coût d'hébergement continu, ou poste très puissant |
| Une machine par développeur | Multiplication des environnements à maintenir et à mettre à jour |
| Mise à jour manuelle de chaque machine | Décalage fréquent entre les versions des développeurs et celle de la production |
| Provisionnement depuis Lifecycle Services | Dépendance à un portail que Microsoft retire progressivement |

Ce modèle a bien fonctionné pendant des années. Ses limites sont d'ordre économique et opérationnel : le coût de possession des machines, et la dérive des versions entre développeurs.

#### 2.2.3 Génération 3, l'environnement de développement unifié

L'UDE conserve Visual Studio et le X++, mais déplace l'exécution vers un environnement cloud partagé et administré par la plateforme.

| Caractéristique | Conséquence |
| :-- | :-- |
| Le poste ne porte que les outils et les métadonnées | Un poste de 16 Go de mémoire suffit |
| L'environnement est provisionné et mis à jour par la plateforme | Fin de la dérive de versions, fin de la maintenance des machines |
| L'environnement est un environnement Power Platform | Accès natif à Dataverse, aux solutions, aux applications pilotées par modèle |
| Provisionnement depuis le Power Platform Admin Center | Alignement avec le retrait de Lifecycle Services |
| Plusieurs développeurs peuvent viser le même environnement | Économie, mais coordination nécessaire, notamment lors du débogage |

### 2.3 Anatomie d'un environnement de développement unifié

Savoir ce qui vit de chaque côté évite les erreurs de diagnostic les plus fréquentes.

| Élément | Poste local | Environnement cloud |
| :-- | :-- | :-- |
| Visual Studio et ses extensions | Oui | Non |
| Métadonnées de référence, environ 24 Go | Oui, en lecture | Non, elles existent sous une autre forme |
| Vos métadonnées personnalisées, modèles et packages | Oui, source de vérité | Copie déployée |
| Base de références croisées, pour la navigation | Oui, dans LocalDB | Non |
| Compilateur X++ | Oui | Non |
| Serveur d'application | Non | Oui |
| Base de données applicative | Non | Oui |
| Données de démonstration Contoso | Non | Oui |
| Exécution du code, et donc le débogage | Non | Oui, le débogueur s'y attache à distance |

**Trois conséquences pratiques.**

1. **Une compilation réussie ne prouve pas qu'un composant fonctionne.** Elle prouve seulement qu'il est syntaxiquement correct. Tant qu'il n'est pas déployé, il n'existe pas pour l'environnement.
2. **Une modification de structure de données exige une synchronisation.** Le schéma de la base vit dans le cloud, pas sur votre poste.
3. **Le débogage suspend le serveur d'application distant.** Sur un environnement partagé, cela affecte les autres utilisateurs. Ce point est développé en 6.9.

### 2.4 Comparaison des options de développement disponibles

Trois options subsistent aujourd'hui. Ce tableau aide à choisir en connaissance de cause.

| Critère | **UDE**, environnement unifié | **VHD local** téléchargeable | Machine virtuelle cloud héritée |
| :-- | :-- | :-- | :-- |
| Statut chez Microsoft | Modèle courant et recommandé | Toujours disponible, usage d'apprentissage | En voie de retrait, lié à Lifecycle Services |
| Provisionnement | Power Platform Admin Center, ou script | Téléchargement d'une image, plusieurs centaines de gigaoctets | Lifecycle Services, dont la création de projets est gelée pour les nouveaux clients |
| Poste requis | 16 Go de mémoire, 60 Go de disque | 32 Go de mémoire recommandés, plusieurs centaines de gigaoctets de disque | Poste léger, la machine est distante |
| Coût | Capacité Power Platform, souvent adossée à une Subscription Azure | Nul, hors le poste lui-même | Hébergement continu de la machine virtuelle |
| Fonctionne hors ligne | Non | Oui | Non |
| Accès à Dataverse et au Power Platform | Oui, natif | Non | Partiel |
| Intégrations, services externes, flux | Oui | Non | Oui |
| Données de démonstration | Oui, à l'installation | Oui, incluses | Oui |
| Mise à jour | Assurée par la plateforme | Manuelle, par retéléchargement | Manuelle |
| Adapté à | Projet réel, formation avec accès cloud, chaîne de livraison automatisée | Apprentissage du X++ sans budget cloud | Existant à faire durer |

**Comment choisir.**

| Votre situation | Option à retenir |
| :-- | :-- |
| Vous montez un projet, ou vous formez avec un tenant d'essai | **UDE**. C'est le sujet de ce guide |
| Vous voulez apprendre le X++ sans budget ni tenant | **VHD local**. Vous perdrez l'accès au cloud, aux intégrations et à la chaîne de livraison |
| Vous héritez d'un projet sur machine virtuelle héritée | Conservez l'existant, et planifiez la bascule vers l'UDE. La création de nouveaux projets dans Lifecycle Services est gelée pour les nouveaux clients |

### 2.5 Provisionner un environnement de développement unifié

Cette section montre comment obtenir l'environnement que le reste du guide utilise. Elle en donne la vue d'ensemble ; le document d'installation d'environnement de la même série en détaille chaque écran, notamment la question de la capacité.

#### 2.5.1 Prérequis

| Prérequis | Détail |
| :-- | :-- |
| Un tenant Microsoft 365 | Avec une licence Dynamics 365 Finance ou équivalent, y compris en version d'essai |
| Une licence affectée à votre compte | Sans licence affectée, l'accès à l'application est refusé |
| Un rôle d'administration | `Power Platform admin` (Administrateur Power Platform), `Dynamics 365 admin` (Administrateur Dynamics 365) ou `Global admin` (Administrateur général) |
| De la capacité disponible | Au moins 1 Go de capacité `Operations` et `Dataverse`. Sur une licence d'essai, cela suppose en pratique une Subscription Azure rattachée par un plan de facturation à l'usage |

**Sur la capacité.** C'est le point de blocage le plus fréquent. Une licence d'essai ne fournit qu'une dotation minimale, insuffisante pour créer un environnement de type `Sandbox` (bac à sable). Le rattachement d'une Subscription Azure par un plan de facturation à l'usage lève ce plafond. Le document d'installation d'environnement de la même série traite ce mécanisme en détail.

#### 2.5.2 Les deux voies possibles

| Voie | Quand la retenir |
| :-- | :-- |
| **Portail**, Power Platform Admin Center | Un environnement isolé, création ponctuelle, découverte de la plateforme |
| **Script**, appel direct à l'interface de programmation | Plusieurs environnements à créer à l'identique, ou volonté de garantir par construction la présence de `DevToolsEnabled=true`. Voir l'annexe D |

#### 2.5.3 Voie du portail, étape par étape

**Étape 1.** Ouvrez le Power Platform Admin Center à l'adresse `https://admin.powerplatform.microsoft.com`.

**Étape 2.** Développez `Manage` (Gérer), cliquez sur `Environments` (Environnements), puis sur `New` (Nouveau).

**Étape 3.** Renseignez l'identité de l'environnement :

| Champ | Valeur | Commentaire |
| :-- | :-- | :-- |
| `Name` (Nom) | Par exemple `ARCFODEV09` | Nom d'affichage |
| `Type` (Type) | **`Sandbox`** (Bac à sable) | Obligatoire pour le développement X++. `Production` est exclu |
| `Region` (Région) | Votre région | À garder cohérente avec vos autres ressources |

**Étape 4.** Développez `Change default settings` (Modifier les paramètres par défaut) et vérifiez que `Add a database / data store` (Ajouter une base de données) est activé. Sans base Dataverse, aucune application ne pourra être installée.

**Étape 5.** Sur l'écran de configuration de la base :

| Champ | Valeur | Commentaire |
| :-- | :-- | :-- |
| `Security group` (Groupe de sécurité) | `None` (Aucun) | Convient à un environnement de formation |
| `Language` (Langue) | Votre langue | **Non modifiable après création** |
| `Currency` (Devise) | Votre devise | **Non modifiable après création** |
| `URL` (Adresse) | Un nom court et unique | **19 caractères au maximum** |
| `Enable Dynamics 365 apps` (Activer les applications Dynamics 365) | `Yes` (Oui) | Obligatoire |
| `Automatically deploy these apps` (Déployer automatiquement ces applications) | **Ne rien sélectionner** | Voir l'avertissement ci-dessous |

**Avertissement, longueur de l'adresse.** Le nom d'hôte doit comporter 19 caractères au maximum. Au-delà, l'installation de la `Finance and Operations Provisioning App` échoue.

**Avertissement, ne pas choisir de modèle applicatif.** Laisser ce champ vide est essentiel. Passer par un modèle installe bien Finance and Operations, mais **sans activer les paramètres développeur**, et il n'existe pas de moyen simple de les activer ensuite. Les applications seront installées manuellement à l'étape suivante, ce qui donne accès aux options qui comptent.

**Étape 6.** Enregistrez, puis patientez jusqu'à ce que l'état passe de `Preparing` (En cours de préparation) à `Ready` (Prêt).

**Étape 7.** Ouvrez l'environnement, puis `Resources` (Ressources) > `Dynamics 365 apps` (Applications Dynamics 365) > `Install app` (Installer l'application).

**Étape 8.** Installez d'abord **`Dynamics 365 Finance and Operations Platform Tools`**. Comptez 5 à 10 minutes. **Attendez le statut `Installed` (Installé) avant de poursuivre** : cette application est une dépendance de la suivante.

**Étape 9.** Installez ensuite **`Dynamics 365 Finance and Operations Provisioning App`**. Une page d'administration dédiée s'ouvre.

**Étape 10.** Sur cette page, cochez impérativement les deux options suivantes :

| Option | Effet |
| :-- | :-- |
| `Enable developer tools for Finance and Operations` (Activer les outils de développement) | Transmet `DevToolsEnabled=true`. **Sans cette option, aucun développement n'est possible sur l'environnement.** Voir le chapitre 1, section 1.7 |
| `Enable demo data for Finance and Operations` (Activer les données de démonstration) | Déploie le jeu de données Contoso, indispensable pour tester |

**Étape 11.** Lancez l'installation et patientez. Comptez **une à deux heures**. Mettez ce temps à profit pour dérouler le chapitre 3, qui installe Visual Studio.

#### 2.5.4 Voie du script

Le script `New-ArcFnoDevEnvironment.ps1`, documenté en annexe D, crée le même environnement par appel direct à l'interface de programmation, en transmettant explicitement `DevToolsEnabled=true|DemoDataEnabled=true`.

Son intérêt principal n'est pas la rapidité, mais la **certitude** : le paramètre déterminant est visible dans le corps de requête, et peut être contrôlé avant exécution grâce au mode `-DryRun`. Sur une licence d'essai, où recréer un environnement coûte une demi-journée, cette vérification a de la valeur.

### 2.6 Vérifier qu'un environnement est bien un environnement de développement unifié

Avant d'investir du temps dans l'installation du poste, contrôlez que l'environnement dont vous disposez est exploitable.

| Contrôle | Où | Résultat attendu |
| :-- | :-- | :-- |
| Type d'environnement | Power Platform Admin Center, liste des environnements | `Sandbox`, ou `Trial (subscription-based)` |
| État | Même écran | `Ready` (Prêt) |
| Applications installées | `Resources` > `Dynamics 365 apps` | `Platform Tools` et `Provisioning App`, toutes deux au statut `Installed` |
| Options de provisionnement | Détail de la `Provisioning App` | Outils de développement et données de démonstration activés |
| Adresses | Page `Overview` (Vue d'ensemble) | Deux adresses distinctes, l'une Dataverse, l'autre Finance and Operations |
| Accès applicatif | Navigateur, adresse Finance and Operations | L'application se charge avec les données Contoso |
| Rôle applicatif | Application, `System administration` > `Users` | Votre compte porte le rôle `System administrator` |
| Preuve définitive | Visual Studio, `Connect to Dataverse` | L'environnement apparaît et propose des solutions |

**Le dernier contrôle est le seul décisif.** Tous les autres peuvent être satisfaits alors que les outils de développement sont absents. Si la connexion depuis Visual Studio n'aboutit pas et que la cause n'est pas l'authentification, reportez-vous au chapitre 1, section 1.7.

### 2.7 Les deux adresses de l'environnement

Une fois l'environnement prêt, sa page `Overview` (Vue d'ensemble) présente deux adresses. Les confondre est la source de confusion la plus fréquente de tout le guide.

| Adresse | Format | Usage |
| :-- | :-- | :-- |
| `Environment URL` (Adresse de l'environnement) | `https://<nom>.crm4.dynamics.com` | Adresse **Dataverse**. Sert à administrer l'environnement et à **connecter Visual Studio** |
| `Finance and Operations URL` | `https://<nom>.sandbox.operations.dynamics.com` | Adresse de **l'application**. S'ouvre dans le navigateur pour utiliser l'ERP |

**Retenez cette règle.** Visual Studio veut l'adresse **Dataverse**. Saisir l'adresse de l'application produit une liste d'environnements vide, sans aucun message explicatif.

### 2.8 Checklist du chapitre

- [ ] La distinction entre poste local et environnement cloud est comprise.
- [ ] L'option de développement retenue est l'UDE, en connaissance des alternatives.
- [ ] Un tenant avec une licence Dynamics 365 est disponible.
- [ ] La capacité permet la création d'un environnement `Sandbox`.
- [ ] L'environnement est de type `Sandbox` et à l'état `Ready`.
- [ ] Son nom d'hôte ne dépasse pas 19 caractères.
- [ ] Aucun modèle applicatif n'a été sélectionné à la création.
- [ ] `Platform Tools` est au statut `Installed`.
- [ ] `Provisioning App` est au statut `Installed`.
- [ ] Les outils de développement et les données de démonstration étaient activés.
- [ ] L'application se charge dans le navigateur avec les données Contoso.
- [ ] Le rôle `System administrator` est attribué à votre compte.
- [ ] Les deux adresses sont relevées et distinguées.

## 3. Phase 1 : Visual Studio 2026 Professional, installation et extensions

**Objectif de la phase.** Disposer d'un poste capable de lire les métadonnées de l'application standard, de compiler du X++ et de dialoguer avec l'environnement cloud.

**Rôles requis.** Administrateur local du poste pour toutes les installations. `System administrator` (Administrateur système) dans l'environnement Finance and Operations pour la connexion.

### 3.1 Obtenir Visual Studio 2026 Professional

**Étape 1.** Rendez-vous sur `https://my.visualstudio.com`.

**Étape 2.** Connectez-vous avec le compte du tenant, de la forme `votreutilisateur@votresociete.onmicrosoft.com`. Le site vous inscrit au programme `Visual Studio Dev Essentials`. Cliquez sur `Confirm` (Confirmer).

**Étape 3.** Dans la section `Downloads` (Téléchargements), sélectionnez `Visual Studio 2026`, édition `Professional`.

**Étape 4.** Cliquez sur `Download` (Télécharger). Un programme d'amorçage de petite taille est téléchargé.

**Note sur la licence.** La connexion avec un compte Dev Essentials active un essai d'environ 90 jours de l'édition Professional. Au-delà, une licence est requise. L'édition `Community` est une alternative gratuite pour les usages qui y sont éligibles, mais vérifiez les conditions de licence avant de la retenir en contexte professionnel.

### 3.2 Installer les charges de travail et les composants individuels

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

### 3.3 Installer les extensions requises

Deux extensions issues de la place de marché sont nécessaires, en plus de l'extension Finance and Operations qui sera installée automatiquement en 3.5.

#### 3.3.1 Microsoft Reporting Services Projects

Cette extension fournit le concepteur d'états. Elle est requise dès lors qu'un modèle contient un état, ce qui arrive rapidement.

**Étape 1.** Dans la barre de menus, cliquez sur `Extensions` puis sur `Manage Extensions` (Gérer les extensions).

**Étape 2.** Recherchez `Microsoft Reporting Services Projects` et cliquez sur `Install` (Installer).

**Étape 3.** **Fermez Visual Studio**, puis double-cliquez sur le fichier `.vsix` téléchargé si l'installation ne démarre pas d'elle-même.

**Étape 4.** Cliquez sur `Install` (Installer) et attendez le message de confirmation.

**Note.** L'extension `Microsoft RDLC Report Designer` (Concepteur d'états RDLC) est également requise pour le développement d'états. Installez-la selon la même méthode si votre périmètre inclut la restitution.

#### 3.3.2 Power Platform Tools

Cette extension est **le pivot de l'expérience de développement unifiée**. C'est elle qui établit la connexion avec l'environnement cloud, télécharge les métadonnées de référence et installe l'extension Finance and Operations.

**Étape 1.** Rouvrez Visual Studio et retournez dans `Extensions` > `Manage Extensions` (Gérer les extensions).

**Étape 2.** Recherchez `Power Platform Tools` et cliquez sur `Install` (Installer).

**Étape 3.** Une bannière indique que les modifications sont planifiées et que Visual Studio doit être fermé.

**Étape 4.** Fermez Visual Studio. Un programme d'installation se lance. Cliquez sur `Modify` (Modifier).

**Étape 5.** Attendez le message de confirmation.

**Note.** L'installation du profileur de plug-ins, parfois proposée par cette extension, n'est pas nécessaire pour le développement X++.

### 3.4 Configurer les options Power Platform Tools

Cette page d'options est le tableau de bord de l'extension. Mal réglée, elle produit des connexions lentes, des journaux inexploitables et des commandes absentes des menus. Bien réglée, elle rend le reste du guide fluide.

**Étape 1.** Rouvrez Visual Studio et choisissez `Continue without code` (Continuer sans code).

**Étape 2.** Ouvrez `Tools` (Outils) > `Options`, puis recherchez `Power Platform` dans la fenêtre. La page `Power Platform Tools` s'affiche.

#### 3.4.1 Tableau de configuration recommandée

Le tableau ci-dessous couvre l'intégralité des options de la page, avec la valeur à retenir sur un **poste de développement X++ connecté à un environnement de développement unifié**, qui est le contexte de ce guide.

| Option | Valeur en environnement de développement | Ce qu'elle fait, et pourquoi ce réglage |
| :-- | :-- | :-- |
| `Filter out Plugin Assemblies from Microsoft` (Filtrer les assemblys de plug-ins Microsoft) | **Activée** | Masque, dans l'explorateur Power Platform, les assemblys de plug-ins livrés par Microsoft. Ceux-ci se comptent par centaines et noient les vôtres. Activée, vous ne voyez que ce que votre organisation a déployé. Sans effet sur le développement X++, mais sans inconvénient non plus. |
| `Display Detailed Log Data` (Afficher les données de journal détaillées) | **Activée** | Bascule la sortie de l'extension en mode verbeux dans `View` > `Output` (Sortie). Sur un poste de développement, c'est ce qui permet de comprendre pourquoi un déploiement a échoué au lieu de constater qu'il a échoué. Le surcoût en performance est négligeable. Désactivez-la seulement si la fenêtre de sortie devient illisible. |
| `Capture Detailed Dataverse Communications Log` (Capturer le journal détaillé des communications Dataverse) | **Désactivée par défaut, activée ponctuellement** | Enregistre le détail des échanges réseau avec Dataverse, requêtes et réponses comprises. Très volumineux, et susceptible de contenir des données sensibles. C'est un outil de diagnostic à activer le temps d'une investigation de connectivité, puis à désactiver. Ne le laissez jamais actif en permanence. |
| `Skip Discovery when connecting to Dataverse` (Ignorer la découverte lors de la connexion à Dataverse) | **Désactivée**, sauf compte invité | Court-circuite le service de découverte qui énumère les environnements accessibles, et vous fait saisir directement l'adresse de l'organisation. Indispensable lorsque votre compte est **invité dans un autre locataire** que celui de l'environnement, cas où la découverte ne retourne rien. Dans le cas nominal du présent guide, laissez-la désactivée : la liste des environnements est plus confortable qu'une saisie manuelle. |
| `Use nuget package for deploying Plugins to Dataverse` (Utiliser un package NuGet pour déployer les plug-ins vers Dataverse) | **Activée** si vous développez des plug-ins Dataverse, sinon indifférente | Empaquette l'assembly de plug-in et ses dépendances sous forme de package NuGet avant déploiement, ce qui résout proprement les dépendances tierces. Sans objet pour du X++ pur. Si votre périmètre inclut des plug-ins Dataverse, activez-la : le déploiement d'un assembly à dépendances sans cette option est une source classique d'erreurs de chargement de type. |
| `Download logs for operations if using Unified environment` (Télécharger les journaux des opérations en environnement unifié) | **Activée** | Rapatrie depuis le cloud les journaux des opérations de déploiement de modèle et de synchronisation de base. C'est la seule façon de savoir ce qui s'est réellement passé côté serveur quand un déploiement échoue. Sur un environnement de développement, cette option n'est pas négociable. |
| `Enable auto setup for Dynamics 365 when using the Unified environment` (Activer la configuration automatique pour Dynamics 365 en environnement unifié) | **Activée** | Après le téléchargement des assets, extrait automatiquement les métadonnées de référence et crée la configuration de métadonnées décrite en 3.7. Désactivée, il faut débloquer les fichiers, décompresser une archive de 24 Go et renseigner la configuration à la main. Le gain de temps est de l'ordre de l'heure. |
| `Download Dynamics 365 FinOps NuGets for CI/CD` (Télécharger les NuGets Dynamics 365 FinOps pour CI/CD) | **Activée** | Fait apparaître dans le menu `Tools` (Outils) la commande de téléchargement des cinq packages NuGet de compilation, utilisée en 8.3. Sans cette option, la commande est absente du menu, ce qui donne l'impression trompeuse que la fonctionnalité n'existe pas. |
| `Enable Download Dynamics 365 FinOps VHD` (Activer le téléchargement du VHD Dynamics 365 FinOps) | **Désactivée** | Fait apparaître la commande de téléchargement de l'image de machine virtuelle locale, héritée du modèle de développement antérieur à l'expérience unifiée. Le fichier se compte en centaines de gigaoctets et n'a aucune utilité dans le contexte de ce guide. Ne l'activez que si vous devez délibérément monter un poste de développement local hors ligne. |
| `Do not display Power Platform Explorer on connecting to Dataverse` (Ne pas afficher l'explorateur Power Platform à la connexion) | **Activée** | Supprime l'ouverture automatique de l'explorateur Power Platform à chaque connexion. Cet explorateur interroge Dataverse pour construire son arborescence, ce qui ralentit sensiblement la connexion. Pour du développement X++, il n'apporte rien : votre outil de navigation est l'`Application Explorer`, qui est un objet distinct. |

**Étape 3.** Validez par `OK`.

#### 3.4.2 Lecture d'ensemble de ces réglages

Les dix options se rangent en quatre familles, et cette lecture aide à décider en cas de doute sur une version qui en proposerait d'autres.

| Famille | Options concernées | Principe de décision |
| :-- | :-- | :-- |
| **Confort de navigation** | `Filter out Plugin Assemblies from Microsoft`, `Do not display Power Platform Explorer on connecting to Dataverse` | Retirer de la vue ce que vous n'utilisez pas. Gain de lisibilité et de temps de connexion. |
| **Diagnostic** | `Display Detailed Log Data`, `Download logs for operations if using Unified environment`, `Capture Detailed Dataverse Communications Log` | Les deux premières restent actives en permanence sur un poste de développement. La troisième s'active le temps d'une investigation, puis se désactive. |
| **Automatisation de la mise en place** | `Enable auto setup for Dynamics 365 when using the Unified environment` | Toujours active. Elle remplace une heure de manipulation manuelle. |
| **Disponibilité de commandes** | `Download Dynamics 365 FinOps NuGets for CI/CD`, `Enable Download Dynamics 365 FinOps VHD`, `Use nuget package for deploying Plugins to Dataverse`, `Skip Discovery when connecting to Dataverse` | Ces options font apparaître ou disparaître des commandes et des comportements. Activez celles dont votre périmètre a besoin, laissez les autres inactives pour ne pas encombrer les menus. |

**Trois conséquences concrètes à retenir.**

1. **Une commande absente d'un menu n'est pas une commande inexistante.** Si `Download Dynamics 365 FinOps NuGets for CI/CD` ne figure pas dans le menu `Tools`, c'est l'option correspondante qui est inactive, et non l'extension qui serait défaillante.
2. **Une connexion lente s'explique souvent par une option.** L'ouverture automatique de l'explorateur Power Platform est la première cause de lenteur à la connexion.
3. **Un déploiement qui échoue sans explication s'explique souvent par une option.** Sans `Download logs for operations`, le journal serveur n'est jamais rapatrié, et il ne reste qu'un message générique.

#### 3.4.3 Note sur la documentation de ces options

Ces options ne font pas l'objet d'une page de référence exhaustive dans la documentation Microsoft, qui n'en documente que quelques-unes au fil des articles d'installation et de configuration. Le tableau ci-dessus en donne la lecture opérationnelle, établie par la pratique. Si votre version de l'extension en propose de nouvelles, appliquez la grille de lecture de la section 3.4.2 : identifiez la famille à laquelle l'option appartient, et décidez en conséquence.

### 3.5 Créer la solution et son éditeur dans le Power Platform

La connexion de Visual Studio à l'environnement, décrite à la section suivante, vous demandera de **choisir une solution**. Cette section crée celle que vous choisirez. La faire maintenant évite de se retrouver, au moment de la connexion, devant une liste où seule la solution `Default` (Par défaut) est proposée.

**Rôle requis.** `System customizer` (Personnalisateur système) ou `System administrator` (Administrateur système) dans l'environnement.

#### 3.5.1 Ce qu'est une solution, et pourquoi elle compte

Une **solution** est le conteneur de personnalisation du Power Platform. Elle regroupe les composants que vous créez ou modifiez dans un environnement, et constitue l'unité de transport entre environnements : c'est elle que l'on exporte d'un environnement de développement pour l'importer dans un environnement de recette puis de production.

Chaque solution est rattachée à un **éditeur**, ou `publisher`, qui porte un **préfixe**. Ce préfixe est automatiquement apposé au nom technique de tout composant Dataverse créé dans la solution, ce qui garantit qu'aucune collision de nom ne peut survenir entre votre travail, celui de Microsoft et celui d'un éditeur tiers.

**Ce que la solution fait et ne fait pas dans notre cas.** Le composant construit en phase 4 est un composant **X++**, et à ce titre il est porté par le **modèle** créé en phase 3, non par la solution Dataverse. La solution joue ici deux rôles :

1. Elle constitue le **contexte de travail de la connexion** entre Visual Studio et l'environnement. C'est ce contexte que l'assistant de connexion vous demande de désigner.
2. Elle devient le conteneur réel dès que votre périmètre déborde du X++ pur : table Dataverse, table virtuelle, application pilotée par modèle, flux, rôle de sécurité. Ce cas se présente très vite en projet.

**Pourquoi ne jamais retenir la solution `Default`.** La solution par défaut de l'environnement présente trois défauts rédhibitoires. Elle utilise l'éditeur par défaut de Dataverse, dont le préfixe est une chaîne aléatoire de la forme `cr8a3`, illisible et non maîtrisée. Elle ne peut pas être exportée proprement, ce qui interdit tout transport vers un autre environnement. Enfin, elle mélange les composants de toutes provenances, ce qui rend impossible de savoir ce qui appartient à votre projet. Y déposer des composants est une erreur difficile à réparer par la suite.

#### 3.5.2 Créer l'éditeur

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

#### 3.5.3 Créer la solution

**Étape 1.** Renseignez le formulaire de la solution :

| Champ | Valeur | Commentaire |
| :-- | :-- | :-- |
| `Display name` (Nom d'affichage) | `ARC Revue de credit client` | Nom lisible, modifiable ultérieurement |
| `Name` (Nom) | `ARCRevueCreditClient` | Nom technique, lettres, chiffres et tirets bas uniquement. **Non modifiable après enregistrement** |
| `Publisher` (Éditeur) | `ARCHIA365`, créé en 3.5.2 | |
| `Version` | `1.0.0.0` | Figure dans le nom du fichier lors d'un export |
| `Set as your preferred solution` (Définir comme solution préférée) | Coché | Les composants créés hors contexte de solution atterrissent alors ici plutôt que dans `Default` |

**Point de vigilance.** Le champ `Name` ne peut plus être modifié après enregistrement, contrairement au `Display name`. Prenez le temps de le formuler correctement.

**Étape 2.** Dépliez `More options` (Plus d'options) et renseignez la `Description`, par exemple : `Ajout de la date de revue du credit sur la fiche client. Auteur ARCHIA365.`

**Étape 3.** Cliquez sur `Create` (Créer).

**Étape 4.** La solution apparaît dans la liste des solutions de l'environnement. Ouvrez-la : elle est vide, ce qui est normal à ce stade.

#### 3.5.4 Ce que contiendra cette solution

Le périmètre retenu pour ce guide est volontairement minimal, conformément au principe énoncé en 1.3 : **ajouter un champ à une table existante et simple**, en l'occurrence la table des clients.

| Élément | Où il vit réellement | Pourquoi |
| :-- | :-- | :-- |
| Le champ `ArcCreditReviewDate` sur la table client | Modèle X++ `ArchiaExtensions`, via une extension de table | Il s'agit d'une extension de la table `CustTable` de Finance and Operations, portée par le modèle et livrée par le package |
| Le type de données étendu, les libellés, l'extension de formulaire, la classe de validation | Modèle X++ `ArchiaExtensions` | Objets X++ purs |
| La solution `ARC Revue de credit client` | Dataverse | Contexte de la connexion, et conteneur de tout composant Dataverse qui viendrait compléter le dispositif |

**À quoi ressemblerait un débordement vers Dataverse.** Si, dans un second temps, vous souhaitiez exposer cette date de revue à une application pilotée par modèle, à un flux d'alerte, ou à un tableau de bord, les composants correspondants seraient créés dans cette solution. C'est précisément pour cette raison que la créer proprement dès le départ, plutôt que de s'appuyer sur `Default`, évite une reprise ultérieure.

#### 3.5.5 Checklist de la section

- [ ] L'environnement sélectionné dans le portail des créateurs est le bon.
- [ ] L'éditeur `ARCHIA365` est créé, avec un préfixe maîtrisé.
- [ ] La solution est créée et rattachée à cet éditeur.
- [ ] Le nom technique de la solution est correct, sachant qu'il n'est plus modifiable.
- [ ] La solution est définie comme solution préférée.
- [ ] La solution apparaît dans la liste des solutions de l'environnement.

### 3.6 Se connecter à l'environnement et télécharger les métadonnées

**Rôle requis.** `System administrator` (Administrateur système) dans l'environnement.

**Étape 1.** Munissez-vous de l'**`Environment URL`** de votre environnement, relevée dans le Power Platform Admin Center sur la page `Overview` (Vue d'ensemble) de l'environnement.

**Point de vigilance.** Deux adresses figurent sur cette page. Celle qui vous intéresse est l'adresse **Dataverse**, de la forme `https://<nom>.crm4.dynamics.com`, et non l'adresse de l'application, de la forme `https://<nom>.sandbox.operations.dynamics.com`. Utiliser la seconde produit une liste d'environnements vide, sans message explicite.

**Étape 2.** Dans Visual Studio, ouvrez `Tools` (Outils) > `Connect to Dataverse` (Se connecter à Dataverse). Selon la version de l'extension, ce libellé peut apparaître sous la forme `Connect to Database` (Se connecter à la base de données).

**Étape 3.** Sélectionnez `Office 365`, puis cochez l'option permettant de saisir manuellement l'adresse de l'organisation.

**Point de vigilance immédiat.** Si votre compte est soumis à l'authentification multifacteur, ce qui est le cas par défaut sur un tenant récent, **ne cochez aucune case à cet écran**, pas même celle-ci. Lisez l'avertissement ci-dessous avant de poursuivre : cocher une case à ce stade produit l'erreur `AADSTS50076` et fait perdre un temps considérable.

**Avertissement sur l'authentification multifacteur et l'extension Power Platform Tools.** Ce point mérite un développement, car il concerne aujourd'hui la quasi-totalité des tenants, et parce que l'erreur produite par l'extension n'oriente pas vers sa cause.

**L'erreur que vous allez très probablement rencontrer.** La boîte de dialogue `Connect to Dataverse` (Se connecter à Dataverse) échoue et renvoie un rapport d'exception dont le cœur est le suivant :

```
Error : {"error":"interaction_required",
"error_description":"AADSTS50076: Due to a configuration change made by your
administrator, or because you moved to a new location, you must use
multi-factor authentication to access
'00000007-0000-0000-c000-000000000000'.",
"error_codes":[50076],
"suberror":"basic_action"}: Unknown error
```

**Décryptage de ce message, terme par terme.**

| Élément du message | Signification |
| :-- | :-- |
| `AADSTS50076` | Le service d'authentification exige un second facteur pour délivrer le jeton demandé |
| `00000007-0000-0000-c000-000000000000` | Identifiant d'application bien connu de **Dataverse**. C'est donc le jeton d'accès à Dataverse qui est refusé, et non la connexion à Visual Studio |
| `interaction_required` | Le service ne peut pas satisfaire la demande sans interaction de l'utilisateur |
| `suberror: basic_action` | Le flux d'authentification employé est un flux **de base**, incapable de présenter un second facteur |
| `Unknown error` en fin de ligne | Message générique de l'extension, qui ne sait pas interpréter la réponse du service. C'est lui qui égare le lecteur |

**La cause réelle.** Lorsque des cases sont cochées dans l'écran de connexion de l'extension, celle-ci tente d'obtenir le jeton Dataverse par un **flux d'authentification par identifiant et mot de passe**, hérité, qui ne comporte aucun mécanisme pour présenter un second facteur. Le service Entra ID refuse alors le jeton et renvoie `AADSTS50076`. Le problème ne vient donc ni de vos identifiants, ni de vos droits sur l'environnement, ni de l'environnement lui-même : il vient du **flux d'authentification retenu par l'extension**.

**La correction, en trois gestes.**

1. **Décochez toutes les cases** de l'écran de connexion de l'extension, sans exception, y compris celle qui vous ferait saisir manuellement l'adresse de l'organisation. C'est le seul réglage qui force l'extension à ouvrir le navigateur et à déléguer l'authentification, second facteur compris.
2. **Relancez la connexion.** Le navigateur s'ouvre, vous présente le formulaire d'authentification complet, puis rend la main à Visual Studio.
3. **Saisissez l'adresse de l'organisation ensuite**, si elle vous est demandée, plutôt qu'avant l'authentification.

**Si l'erreur persiste après ce réglage.**

| Vérification | Comment procéder |
| :-- | :-- |
| Un jeton en cache pollue la tentative | Fermez Visual Studio, ouvrez `File` (Fichier) > `Account Settings` (Paramètres du compte), retirez les comptes enregistrés, puis relancez |
| Le navigateur est connecté avec une autre identité | Ouvrez une fenêtre de navigation privée, ou déconnectez-vous de la session en cours avant de relancer |
| L'inscription à l'authentification multifacteur n'est pas achevée | Connectez-vous une fois au portail `https://aka.ms/mfasetup` avec le compte concerné et terminez l'inscription |
| Le compte lui-même est en cause | Testez-le indépendamment de Visual Studio avec `pac auth create --environment <adresse>`, qui ouvre le navigateur de lui-même. Si cette commande aboutit, le compte est sain et le problème est bien dans le réglage de l'extension |

**Pourquoi vous êtes très probablement concerné.** Les `Security defaults` (Paramètres de sécurité par défaut) de Microsoft Entra ID sont **activés par défaut sur tout tenant créé depuis le 22 octobre 2019**, avec un délai de grâce de vingt-quatre heures avant application. Microsoft les active en outre automatiquement sur les tenants existants qui ne disposent ni de stratégies d'accès conditionnel, ni de licences Entra ID premium. Un tenant d'essai monté pour ce guide entre donc dans le périmètre, sans qu'aucune action de votre part ne soit nécessaire.

**Ce que ces paramètres imposent, et qui vous concerne directement :**

| Contrôle appliqué | Conséquence pour cette procédure |
| :-- | :-- |
| Inscription obligatoire de tous les utilisateurs à l'authentification multifacteur | Votre compte de développement est soumis à la MFA |
| Authentification multifacteur systématique pour les rôles d'administration | Le compte `Global admin` (Administrateur général) utilisé au long de ce guide est concerné à chaque connexion |
| Blocage des protocoles d'authentification hérités | Les modes de connexion anciens, sans prise en charge de la MFA, échouent |
| Protection des activités privilégiées, dont Azure PowerShell et Azure CLI | Les commandes du script de l'annexe D déclenchent une demande d'authentification forte |
| **Blocage du flux d'authentification par code d'appareil** | Le repli `-UseDeviceCode` de l'annexe D peut lui-même être refusé |

**Symptômes typiques, et ce qu'ils veulent dire.** Aucun de ces messages ne mentionne la MFA, ce qui explique le temps perdu à chercher ailleurs.

| Symptôme observé | Cause réelle |
| :-- | :-- |
| La boîte de dialogue de connexion boucle sans jamais aboutir | Le formulaire de connexion intégré ne sait pas présenter le second facteur |
| La liste des environnements revient vide alors que l'environnement existe | L'authentification a échoué silencieusement en amont |
| Message de la forme `AADSTS50076`, mentionnant une exigence d'authentification forte | Demande de second facteur non satisfaite par le flux utilisé |
| Message `User interaction is required` lors d'un appel PowerShell | Consentement interactif requis pour cette audience |
| Message `A window handle must be configured` | Le courtier d'authentification Windows réclame une fenêtre parente, indisponible en console |

**La conduite à tenir ailleurs dans la procédure.** La correction décrite plus haut vaut pour l'extension Power Platform Tools. Les autres points de la procédure qui s'authentifient auprès de Microsoft appellent leurs propres réglages.

| Contexte | Conduite à tenir |
| :-- | :-- |
| Interface en ligne de commande `pac`, section 7.2 | `pac auth create` ouvre le navigateur de lui-même, aucune adaptation n'est nécessaire |
| Connexion de service Azure DevOps, section 7.3 | Préférez `Workload Identity Federation` (Fédération d'identité de charge de travail) au secret client : elle supprime à la fois le secret et sa date d'expiration |
| Script de provisionnement, annexe D | Utilisez `Connect-AzAccount -AuthScope "https://api.bap.microsoft.com/"` avant l'exécution. Si le flux par code d'appareil est refusé par les paramètres de sécurité, passez par `-AccessToken` avec un jeton récupéré depuis la console du navigateur |

**Ce qu'il ne faut pas faire.** La tentation de désactiver les `Security defaults` pour se simplifier la vie est réelle, et l'interface le permet en trois clics depuis `Entra ID` > `Overview` (Vue d'ensemble) > `Properties` (Propriétés) > `Manage security defaults` (Gérer les paramètres de sécurité par défaut). C'est une mauvaise réponse à un problème réel, pour trois raisons : elle expose l'ensemble du tenant, y compris les comptes d'administration ; Microsoft signale explicitement ce choix comme non recommandé ; et elle ne résout rien, les flux d'authentification interactifs fonctionnant parfaitement une fois la bonne option retenue. Si votre organisation a un besoin légitime d'assouplissement pour une identité applicative, la voie correcte est une stratégie d'**accès conditionnel** ciblée, qui suppose une licence Entra ID premium, et non la désactivation globale d'un garde-fou.

**Étape 4.** Cliquez sur `Login` (Se connecter), collez l'`Environment URL`, puis validez par `OK`.

**Étape 5.** Sélectionnez votre environnement dans la liste, puis cliquez sur `Login` (Se connecter).

**Étape 6.** Une solution vous est demandée. Sélectionnez **`ARC Revue de credit client`**, créée en 3.5.

**Point de vigilance.** **Ne choisissez jamais la solution `Default`** (Par défaut), pour les trois raisons exposées en 3.5.1 : préfixe aléatoire, impossibilité d'export propre, et mélange des composants de toutes provenances. Si votre solution n'apparaît pas dans la liste, c'est presque toujours qu'elle a été créée dans un autre environnement que celui auquel Visual Studio est connecté. Retournez sur `https://make.powerapps.com`, vérifiez le sélecteur d'environnement en haut à droite, et recréez la solution dans le bon environnement.

**Étape 7.** À la première connexion, Visual Studio détecte l'absence des métadonnées de référence et propose de les télécharger. Cliquez sur `Yes` (Oui).

**Étape 8.** Le téléchargement démarre. Suivez sa progression dans `View` (Affichage) > `Output` (Sortie), en sélectionnant la source `FinOps Cloud Runtime` dans la liste déroulante.

**Étape 9.** À la fin du téléchargement, un programme d'installation se lance et installe l'extension Finance and Operations correspondant à la version de plateforme de votre environnement. Cliquez sur `Install` (Installer).

**Étape 10.** Redémarrez Visual Studio. À la première ouverture, acceptez les demandes d'élévation de privilèges relatives à l'enregistrement du gestionnaire de protocole, à la mise en place des cibles de génération et à l'extraction des fichiers du compilateur.

**Étape 11.** Vérification. Le dossier suivant doit contenir environ 24 Go de fichiers :

```
C:\Users\<VotreUtilisateur>\AppData\Local\Microsoft\Dynamics365\<VersionApplication>
```

Un volume nettement inférieur signale un téléchargement incomplet. Dans ce cas, exécutez `Tools` (Outils) > `Download Dynamics 365 assets` (Télécharger les assets Dynamics 365), qui purge le dossier et relance le téléchargement intégralement.

### 3.7 Vérifier la configuration des métadonnées

L'option `Auto setup` ayant été activée en 3.4, la configuration a normalement été créée automatiquement. Cette section vérifie qu'elle est correcte, et explique comment la créer à la main si nécessaire.

**Étape 1.** Ouvrez `Extensions` > `Dynamics 365` > `Configure Metadata` (Configurer les métadonnées).

**Étape 2.** Une configuration doit exister. Vérifiez ses champs :

| Champ | Valeur attendue |
| :-- | :-- |
| `Cross reference database server` (Serveur de la base de références croisées) | `(localdb)\.` |
| `Cross reference database name` (Nom de la base de références croisées) | `DYNAMICSXREFDB` |
| `Application version to restore cross reference database from` (Version d'application source) | La version téléchargée en 3.6 |
| `Folders for reference metadata` (Dossiers des métadonnées de référence) | Le dossier `PackagesLocalDirectory` décompressé |
| `Folder for your own custom metadata` (Dossier de vos métadonnées personnalisées) | Un dossier dédié, que vous repointerez en phase 2 vers l'intérieur du dépôt Git |

**Étape 3.** Vérification déterminante. Ouvrez `View` (Affichage) > `Application Explorer` (Explorateur d'applications). L'arborescence complète des objets de l'application standard doit s'afficher. C'est la preuve que les métadonnées de référence sont correctement chargées et indexées.

**Si le bouton `Save` reste grisé**, un champ est invalide. Il apparaît encadré en rouge et une infobulle en précise la cause. La valeur `(localdb)\.` doit être saisie exactement ainsi, point final compris. Si la connexion à LocalDB échoue, ouvrez une invite de commandes et exécutez :

```
sqllocaldb create MSSQLLocalDB -s
```

### 3.8 Checklist de validation de la phase 1

- [ ] L'environnement cible a été provisionné avec `DevToolsEnabled=true`.
- [ ] Visual Studio 2026 Professional est installé et activé.
- [ ] La charge de travail `.NET desktop development` est présente.
- [ ] Les composants `Modeling SDK` et `DGML editor` sont présents.
- [ ] `Microsoft SQL Server Express LocalDB` est installé.
- [ ] L'extension `Microsoft Reporting Services Projects` est installée.
- [ ] L'extension `Power Platform Tools` est installée.
- [ ] Les dix options `Power Platform Tools` sont réglées conformément au tableau 3.4.1.
- [ ] `Enable auto setup` et `Download logs for operations` sont actives.
- [ ] `Download Dynamics 365 FinOps NuGets for CI/CD` est active.
- [ ] `Enable Download Dynamics 365 FinOps VHD` est inactive.
- [ ] `Capture Detailed Dataverse Communications Log` est inactive.
- [ ] L'éditeur `ARCHIA365` est créé, avec un préfixe maîtrisé.
- [ ] La solution est créée dans le bon environnement, rattachée à cet éditeur.
- [ ] La solution est définie comme solution préférée.
- [ ] La connexion à l'environnement aboutit, sur **votre** solution et non sur `Default`.
- [ ] Le dossier des assets contient environ 24 Go de fichiers.
- [ ] L'extension Finance and Operations est installée.
- [ ] Le menu `Dynamics 365` est visible dans Visual Studio.
- [ ] L'`Application Explorer` s'ouvre et affiche l'arborescence standard.

## 4. Phase 2 : Azure DevOps, organisation, projet et dépôt Git

**Objectif de la phase.** Disposer d'un dépôt Git structuré de telle sorte que le pipeline de la phase 6 puisse le compiler sans adaptation.

**Rôles requis.** Aucun pour créer l'organisation. `Project Collection Administrators` (Administrateurs de collection de projets) pour créer le projet. `Contributors` (Contributeurs) avec un niveau d'accès `Basic` (De base) pour publier du code.

### 4.1 Pourquoi le dépôt avant le code

Il est tentant de développer d'abord et de versionner ensuite. C'est une erreur de séquence, pour une raison simple : dans l'expérience de développement unifiée, **l'emplacement physique de vos métadonnées détermine ce qui est versionné**. Git ne dispose pas du mécanisme de mapping qui existait dans les systèmes centralisés. Vos modèles doivent donc résider à l'intérieur du dépôt cloné, ce qui suppose que le dépôt existe avant qu'ils ne soient créés.

Créer le dépôt en second oblige à déplacer les fichiers, à repointer la configuration des métadonnées et à actualiser les modèles. C'est faisable, mais c'est une source d'erreurs évitable.

### 4.2 Créer l'organisation Azure DevOps

**Étape 1.** Ouvrez `https://dev.azure.com`, connecté avec le compte du tenant.

**Point de vigilance.** L'organisation doit être **connectée à l'annuaire Microsoft Entra ID du tenant**. C'est une condition obligatoire du Managed DevOps Pool mis en place en phase 6. Une organisation créée avec une identité personnelle ne satisfait pas cette condition et devra être recréée.

**Étape 2.** Cliquez sur `Start free` (Commencer gratuitement) ou `New organization` (Nouvelle organisation).

**Étape 3.** Renseignez le nom, par exemple `archia365-d365fo`, et l'emplacement d'hébergement, par exemple `West Europe`.

**Étape 4.** Vérification. Ouvrez `Organization settings` (Paramètres de l'organisation) > `Microsoft Entra`. L'annuaire de votre tenant doit y figurer.

### 4.3 Créer le projet d'équipe

**Étape 1.** Cliquez sur `New project` (Nouveau projet).

**Étape 2.** Renseignez :

| Champ | Valeur |
| :-- | :-- |
| `Project name` (Nom du projet) | `D365FO-DEV`, sans espace ni accent |
| `Visibility` (Visibilité) | `Private` (Privé) |
| `Version control` (Contrôle de version), sous `Advanced` | `Git`, valeur par défaut |
| `Work item process` (Processus des éléments de travail) | `Agile`, sans incidence technique |

**Étape 3.** Cliquez sur `Create` (Créer), puis notez l'adresse du dépôt, de la forme `https://dev.azure.com/<organisation>/<projet>/_git/<projet>`.

### 4.4 La structure de dépôt attendue

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

### 4.5 Cloner le dépôt et repointer la configuration

**Étape 1.** Dans Visual Studio, ouvrez `Git` > `Clone Repository` (Cloner un dépôt).

**Étape 2.** Saisissez l'adresse relevée en 4.3 et choisissez un dossier local **court**, par exemple `C:\D365\Repos\D365FO-DEV`.

**Point de vigilance.** Les chemins X++ sont longs. Un dossier de clonage profond expose à la limite de longueur de chemin de Windows, avec des erreurs de compilation difficiles à diagnostiquer. Restez proche de la racine du disque.

**Étape 3.** Cliquez sur `Clone` (Cloner).

**Étape 4.** Créez à la main les quatre dossiers de la structure décrite en 4.4, à la racine du dépôt cloné.

**Étape 5.** Ouvrez `Extensions` > `Dynamics 365` > `Configure Metadata` (Configurer les métadonnées) et modifiez le champ `Folder for your own custom metadata` (Dossier de vos métadonnées personnalisées) pour le faire pointer sur :

```
C:\D365\Repos\D365FO-DEV\XppMetadata
```

**Étape 6.** Enregistrez, puis redémarrez Visual Studio.

**Vérification déterminante.** Le chemin déclaré dans `Configure Metadata` et le chemin réel de vos modèles doivent être identiques. Une divergence produit une situation trompeuse : le dépôt se remplit normalement, mais il ne contient pas le code que Visual Studio compile, et le pipeline compilera une version obsolète.

### 4.6 Créer le fichier .gitignore

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

### 4.7 Checklist de validation de la phase 2

- [ ] L'organisation Azure DevOps est créée avec l'identité du tenant.
- [ ] L'organisation est connectée à Microsoft Entra ID.
- [ ] Le projet est créé en visibilité `Private`, avec un dépôt `Git`.
- [ ] Le dépôt est cloné dans un chemin court.
- [ ] Les quatre dossiers de la structure existent.
- [ ] `Configure Metadata` pointe sur `XppMetadata` à l'intérieur du dépôt.
- [ ] Le fichier `.gitignore` est en place.

## 5. Phase 3 : Modèle, package et projet

**Objectif de la phase.** Créer les conteneurs qui accueilleront votre code.

**Rôles requis.** Administrateur local du poste.

### 5.1 Comprendre la hiérarchie des conteneurs

Trois niveaux d'emboîtement structurent tout développement X++. Les confondre est la source de confusion la plus fréquente chez les débutants.

| Niveau | Nature | Rôle |
| :-- | :-- | :-- |
| **Package** | Unité de déploiement | Ce qui est compilé, livré et installé sur un environnement. C'est le grain de la livraison. |
| **Modèle** (`model`) | Unité logique de personnalisation | Regroupe des objets appartenant à un même périmètre fonctionnel. Un package peut contenir plusieurs modèles. |
| **Projet** (`project`) | Unité de travail Visual Studio | Vue de travail sur un sous-ensemble d'objets. Il n'a aucune existence à l'exécution. |

**Analogie utile.** Le package est le carton d'expédition, le modèle est le produit qu'il contient, le projet est la liste de courses du développeur. Supprimer un projet ne supprime aucun objet ; supprimer un modèle supprime tous les objets qu'il contient.

### 5.2 Créer le modèle et son package

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

### 5.3 Créer le projet

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

### 5.4 Premier commit

**Étape 1.** Ouvrez `View` (Affichage) > `Git Changes` (Modifications Git).

**Étape 2.** Vérifiez la liste des fichiers détectés. Contrôlez que `PackagesLocalDirectory` n'y figure pas, et que le dossier `Descriptor` y figure bien.

**Étape 3.** Saisissez un message de commit, par exemple `Initialisation du modele ArchiaExtensions et de la solution`.

**Étape 4.** Cliquez sur `Commit All` (Valider tout), puis sur `Push` (Envoyer).

**Étape 5.** Vérification dans le portail Azure DevOps, sous `Repos` (Dépôts) > `Files` (Fichiers).

### 5.5 Checklist de validation de la phase 3

- [ ] Le modèle `ArchiaExtensions` est créé, avec un package dédié.
- [ ] Les trois packages de référence sont déclarés.
- [ ] Le projet est créé dans `VS_Solutions`, à l'intérieur du dépôt.
- [ ] Les métadonnées du modèle sont dans `XppMetadata`, à l'intérieur du dépôt.
- [ ] Le fichier descripteur existe et est versionné.
- [ ] Le premier commit est publié et visible dans le portail.

## 6. Phase 4 : Développement du composant

**Objectif de la phase.** Construire, dans l'ordre, les cinq objets du composant décrit en 1.3, puis le déployer et le tester.

**Rôles requis.** Administrateur local du poste pour le développement. `System administrator` (Administrateur système) dans l'environnement pour le déploiement et la synchronisation de la base.

### 6.1 Spécification et ordre de construction

**Rappel du besoin.** Consigner sur chaque client la date de la prochaine revue de son encours, l'afficher sur la fiche client, et refuser une date antérieure à la date du jour.

**Ordre de construction, et pourquoi cet ordre.** Les objets X++ s'appuient les uns sur les autres. Les construire dans le désordre oblige à revenir en arrière.

| Ordre | Objet | Dépend de |
| :-- | :-- | :-- |
| 1 | Fichier de libellés `ArcLabels` | Rien |
| 3 | Type de données étendu `ArcCreditReviewDate` | Le fichier de libellés |
| 4 | Extension de table `CustTable` | Le type de données étendu |
| 5 | Extension de formulaire `CustTable` | L'extension de table |
| 6 | Classe d'extension `ArcCustTable_Extension` | L'extension de table |

### 6.2 Étape 1 : le fichier de libellés

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

### 6.3 Étape 2 : le type de données étendu

#### 6.3.1 Ce qu'est un type de données étendu et pourquoi il est obligatoire ici

Un **type de données étendu**, ou EDT pour `Extended Data Type`, est un type nommé bâti sur un type primitif. Il porte son libellé, son texte d'aide, son format d'affichage, sa longueur, son alignement, et le cas échéant sa relation vers une table de référence.

Trois raisons imposent de passer par un EDT plutôt que par un type primitif.

1. **Le libellé est défini une seule fois.** Le champ de table, le contrôle de formulaire, la colonne d'un état et la cellule d'une entité de données héritent tous du même libellé. Le modifier à un seul endroit le modifie partout.
2. **Le comportement d'affichage est cohérent.** Deux dates issues du même EDT s'affichent avec le même format, s'alignent de la même manière et proposent le même sélecteur de calendrier.
3. **C'est la convention attendue.** Un champ typé directement en `date` plutôt que par un EDT est systématiquement relevé en revue de code, et les outils d'analyse de qualité le signalent.

#### 6.3.2 Créer l'objet

**Étape 1.** Dans le `Solution Explorer` (Explorateur de solutions), faites un clic droit sur le projet, puis `Add` (Ajouter) > `New Item` (Nouvel élément).

**Étape 2.** Dans le volet de gauche de l'assistant, dépliez `Dynamics 365 Items` (Éléments Dynamics 365) puis sélectionnez la catégorie `Data Types` (Types de données).

**Étape 3.** Dans la liste centrale, sélectionnez **`Extended Data Type Date`** (Type de données étendu Date).

**Point de vigilance.** L'assistant propose un type d'élément distinct par type primitif : `Extended Data Type String`, `Extended Data Type Int`, `Extended Data Type Real`, `Extended Data Type Date`, `Extended Data Type UtcDateTime`, `Extended Data Type Enum`. Le type primitif choisi ici est **définitif** : il ne peut pas être changé ensuite. Pour une date sans heure, retenez `Date`. Pour un horodatage avec heure et fuseau, il faudrait retenir `UtcDateTime`.

**Étape 4.** Saisissez le nom `ArcCreditReviewDate` et cliquez sur `Add` (Ajouter).

**Rappel de nommage.** Le préfixe `Arc` identifie ARCHIA365 et rend impossible toute collision avec un objet Microsoft ou d'un éditeur tiers. La convention complète figure en annexe C.

#### 6.3.3 Renseigner les propriétés

L'objet s'ouvre dans le concepteur et la fenêtre `Properties` (Propriétés) affiche ses caractéristiques. Renseignez les suivantes.

| Propriété | Valeur | Rôle |
| :-- | :-- | :-- |
| `Name` (Nom) | `ArcCreditReviewDate` | Déjà renseigné par l'assistant |
| `Extends` (Étend) | `TransDate` | EDT parent dont on hérite le comportement |
| `Label` (Libellé) | `@ArcLabels:CreditReviewDate` | Texte affiché comme intitulé du champ |
| `Help Text` (Texte d'aide) | `@ArcLabels:CreditReviewDateHelp` | Bulle d'aide affichée au survol |
| `Country Region Codes` (Codes pays et région) | Vide | À renseigner uniquement pour une fonctionnalité propre à un pays |
| `Configuration Key` (Clé de configuration) | Vide | À renseigner pour conditionner l'existence du champ à l'activation d'une fonctionnalité |

**Pourquoi étendre `TransDate`.** `TransDate` est l'EDT standard des dates de transaction dans Finance and Operations. En l'étendant, votre type hérite du format d'affichage, de l'alignement et du comportement de saisie attendus par les utilisateurs, sans que vous ayez à les redéfinir. Si Microsoft fait évoluer ce comportement, votre EDT suit automatiquement.

**Comment choisir l'EDT parent.** Interrogez-vous sur la nature métier de la donnée, et non sur son type technique. Une date de transaction étend `TransDate`. Une date de début ou de fin de validité étend `FromDate` ou `ToDate`. Un montant en devise de transaction étend `AmountCur`. Un identifiant de client étend `CustAccount`. En cas de doute, cherchez dans l'`Application Explorer` un champ standard portant une donnée de même nature et regardez quel EDT il utilise.

**Point de vigilance sur l'héritage.** Les propriétés héritées de l'EDT parent apparaissent en grisé dans la fenêtre des propriétés. Les redéfinir localement est possible mais rompt l'héritage : la propriété redéfinie ne suivra plus les évolutions du parent. Ne le faites que si vous en avez un besoin explicite.

**Étape.** Enregistrez par `Ctrl+S`.

#### 6.3.4 Vérifier

**Étape 1.** Ouvrez `View` (Affichage) > `Application Explorer` (Explorateur d'applications).

**Étape 2.** Dépliez `Data Types` (Types de données) > `Extended Data Types` (Types de données étendus) et recherchez `ArcCreditReviewDate`.

**Étape 3.** Faites un clic droit dessus, puis `Open designer` (Ouvrir le concepteur). Le concepteur doit afficher votre EDT avec `TransDate` comme parent.

**Ce qui a été produit sur le disque.** Un fichier XML a été créé dans votre dossier de métadonnées, au chemin suivant :

```
XppMetadata\ArchiaExtensions\ArchiaExtensions\AxEdtDate\ArcCreditReviewDate.xml
```

C'est ce fichier, et non une entrée dans une base de données, qui constitue la définition de votre EDT. C'est lui que Git versionne et que le compilateur lit.

### 6.4 Étape 3 : l'extension de table et la création du champ

Cette section est le cœur du composant. Elle est détaillée pas à pas, car la création d'un champ par extension concentre l'essentiel des réflexes à acquérir.

#### 6.4.1 Ce qu'est une extension de table

Une **extension de table** est un objet qui vous appartient et qui vient se greffer sur une table standard, sans la modifier. À la compilation, la plateforme fusionne la table d'origine et toutes ses extensions, quelles qu'en soient les provenances, pour produire la table effective.

**Ce qu'une extension de table permet d'ajouter :**

| Élément | Ajout possible |
| :-- | :-- |
| Champs | Oui |
| Groupes de champs | Oui, ainsi que l'ajout de champs dans un groupe standard |
| Index | Oui |
| Relations | Oui |
| Actions de suppression, `Delete actions` | Oui |
| Mappages de table, `Mappings` | Oui |
| Gestionnaires d'événements sur les méthodes de la table | Oui, par une classe séparée |

**Ce qu'une extension de table ne permet pas :**

| Opération | Possible |
| :-- | :-- |
| Supprimer un champ standard | Non |
| Renommer un champ standard | Non |
| Modifier les propriétés d'un champ standard | Non, sauf pour les rares propriétés explicitement rendues extensibles par Microsoft |
| Modifier le code d'une méthode standard | Non, il faut passer par la Chain of Command de la section 6.6 |

**Pourquoi ces restrictions.** Elles garantissent que les mises à jour Microsoft, appliquées automatiquement plusieurs fois par an, ne casseront pas votre travail. Une personnalisation qui modifierait la table d'origine devrait être réexaminée à chaque mise à jour. Une extension, non.

#### 6.4.2 Localiser la table client dans l'Application Explorer

La table qui porte les clients dans Finance and Operations se nomme **`CustTable`**. C'est une table simple d'accès, très largement utilisée, et donc un bon terrain d'apprentissage.

**Étape 1.** Ouvrez `View` (Affichage) > `Application Explorer` (Explorateur d'applications).

**Étape 2.** Dépliez `AOT` > `Data Model` (Modèle de données) > `Tables` (Tables).

**Étape 3.** L'arborescence contient plusieurs milliers de tables. N'y naviguez pas à la main : utilisez la **barre de recherche** située en haut de l'explorateur et saisissez `CustTable`.

**Point de méthode.** La recherche de l'`Application Explorer` s'appuie sur la base de références croisées construite lors de la configuration des métadonnées en 3.7. Si la recherche ne retourne rien alors que la table existe, c'est le signe que cette base n'a pas été correctement générée. Reportez-vous à l'annexe A.

**Étape 4, facultative mais formatrice.** Avant de créer l'extension, faites un clic droit sur `CustTable` puis `Open designer` (Ouvrir le concepteur) pour inspecter la table d'origine. Observez :

| Nœud | Ce qu'il contient | Intérêt pour vous |
| :-- | :-- | :-- |
| `Fields` (Champs) | Les champs standard, dont `AccountNum`, `CreditMax`, `CreditRating` | Vérifier qu'aucun champ existant ne couvre déjà votre besoin |
| `Field Groups` (Groupes de champs) | Les regroupements logiques utilisés par les formulaires | Repérer le groupe dans lequel votre champ a sa place |
| `Indexes` (Index) | Les index, dont `AccountIdx` sur `AccountNum` | Comprendre les clés d'accès |
| `Relations` (Relations) | Les liens vers les autres tables | Comprendre le modèle de données |

**Vérification préalable indispensable.** Recherchez dans les champs existants un champ qui répondrait déjà au besoin. Ajouter un champ redondant est l'une des dettes techniques les plus fréquentes et les plus coûteuses en projet. Ici, aucun champ standard ne porte une date de revue du crédit, l'ajout est donc justifié.

**Étape 5.** Refermez le concepteur de la table standard sans rien modifier. Vous ne pourriez d'ailleurs pas l'enregistrer : elle est en lecture seule.

#### 6.4.3 Créer l'extension de table

**Étape 1.** Dans l'`Application Explorer`, faites un clic droit sur `CustTable`.

**Étape 2.** Choisissez **`Create extension in the current project`** (Créer une extension dans le projet courant).

**Point de méthode.** Deux entrées voisines existent dans ce menu contextuel.

| Entrée | Effet |
| :-- | :-- |
| `Create extension` (Créer une extension) | Crée l'extension dans le modèle, mais **ne l'ajoute pas au projet** |
| `Create extension in the current project` (Créer une extension dans le projet courant) | Crée l'extension **et l'ajoute au projet ouvert** |

Retenez systématiquement la seconde. Oublier d'ajouter un objet au projet est sans conséquence sur la compilation, l'objet appartenant au modèle, mais il devient invisible dans votre vue de travail et vous risquez de le perdre de vue.

**Étape 3.** L'extension est créée et s'ouvre dans le concepteur. Observez son nom, attribué automatiquement :

```
CustTable.ArchiaExtensions
```

**Comment lire ce nom.** Il se compose du nom de la table étendue, d'un point, puis du nom de votre modèle. Ce motif garantit qu'aucune collision ne peut survenir : si trois éditeurs étendent `CustTable`, chacun produit `CustTable.<SonModèle>`, et les trois coexistent sans conflit. Ce nom n'est pas modifiable, et il ne doit pas l'être.

**Étape 4.** Vérifiez que le nœud `CustTable.ArchiaExtensions` apparaît bien dans le `Solution Explorer`, sous votre projet.

#### 6.4.4 Ajouter le champ

**Étape 1.** Dans le concepteur d'extension, faites un clic droit sur le nœud **`Fields`** (Champs).

**Étape 2.** Choisissez `New` (Nouveau), puis le type primitif du champ. La liste propose notamment :

| Type proposé | Usage |
| :-- | :-- |
| `String` (Chaîne) | Texte |
| `Integer` (Entier) | Nombre entier |
| `Real` (Réel) | Nombre décimal, montants |
| **`Date`** | Date sans heure |
| `UtcDateTime` (Date et heure UTC) | Horodatage avec heure et fuseau |
| `Enum` (Énumération) | Liste de valeurs fixes |
| `Container` (Conteneur) | Structure composite, à éviter sauf besoin précis |
| `Guid` (Identifiant global) | Identifiant technique |

Sélectionnez **`Date`**.

**Point de vigilance.** Le type primitif du champ doit correspondre à celui de l'EDT qui lui sera affecté. Un champ créé en `String` n'acceptera pas un EDT de type `Date`, et la propriété restera vide sans message d'erreur explicite. Si vous vous trompez, supprimez le champ et recréez-le avec le bon type : c'est plus rapide que de chercher pourquoi l'EDT ne s'applique pas.

**Étape 3.** Le champ est créé sous un nom générique, du type `Date1`. Sélectionnez-le.

#### 6.4.5 Renseigner les propriétés du champ

La fenêtre `Properties` (Propriétés) affiche une trentaine de propriétés. La majorité reste à sa valeur par défaut. Le tableau ci-dessous détaille celles qui comptent.

| Propriété | Valeur à retenir | Explication |
| :-- | :-- | :-- |
| `Name` (Nom) | `ArcCreditReviewDate` | Nom technique du champ. Préfixé, sans espace, sans accent, en notation Pascal. Il devient le nom de la colonne en base de données. |
| `Extended Data Type` (Type de données étendu) | `ArcCreditReviewDate` | L'EDT créé en 6.3. C'est de lui que le champ hérite libellé, aide et format. |
| `Label` (Libellé) | **Laisser vide** | Hérité de l'EDT. Le renseigner ici romprait l'héritage. |
| `Help Text` (Texte d'aide) | **Laisser vide** | Hérité de l'EDT, même raisonnement. |
| `Mandatory` (Obligatoire) | `No` (Non) | La date de revue n'est pas obligatoire à la création d'un client. Passer à `Yes` bloquerait la création de tout nouveau client sans cette date, y compris par les processus automatisés. |
| `Allow Edit` (Autoriser la modification) | `Yes` (Oui) | Le champ est modifiable après création. |
| `Allow Edit On Create` (Autoriser la modification à la création) | `Yes` (Oui) | Le champ est saisissable dès la création du client. |
| `Visible` (Visible) | `Yes` (Oui) | Le champ peut être affiché. Le passer à `No` le rendrait techniquement présent mais jamais affichable. |
| `Configuration Key` (Clé de configuration) | Vide | À renseigner pour conditionner l'existence physique du champ à l'activation d'une fonctionnalité. Un champ dont la clé est désactivée n'est pas créé en base. |
| `Country Region Codes` (Codes pays et région) | Vide | À renseigner uniquement pour une fonctionnalité propre à un ou plusieurs pays. |
| `Save Contents` (Enregistrer le contenu) | `Yes` (Oui) | Le contenu est persisté en base. `No` produirait un champ calculé non stocké. |
| `Ignore EDT Relation` (Ignorer la relation de l'EDT) | Sans objet | N'a de sens que pour un EDT porteur d'une relation vers une table de référence, ce qui n'est pas le cas d'un EDT de type date. |

**Ce que vous ne renseignez pas, et pourquoi.** Le champ possède un **identifiant numérique**, `Field ID`, attribué automatiquement par la plateforme dans la plage réservée aux extensions. Vous n'y touchez jamais. C'est une différence majeure avec les anciennes versions d'AX, où le développeur gérait les identifiants à la main, avec les conflits que l'on imagine.

**Étape.** Enregistrez par `Ctrl+S`.

#### 6.4.6 Ajouter le champ à un groupe de champs

Un **groupe de champs** est un regroupement logique nommé, défini sur la table et réutilisé par les formulaires et les états. Placer votre champ dans un groupe standard présente un avantage décisif : tous les formulaires qui affichent ce groupe afficheront automatiquement votre champ, sans aucune modification supplémentaire de leur part.

**Étape 1.** Dans le concepteur d'extension, dépliez le nœud `Field Groups` (Groupes de champs). Vous y voyez les groupes de la table standard.

**Étape 2.** Repérez le groupe pertinent. Pour une donnée de gestion du crédit, le groupe consacré au crédit est le candidat naturel. Son nom exact dépend de la version de l'application ; recherchez un groupe dont le nom contient `Credit`.

**Étape 3.** Faites glisser votre champ `ArcCreditReviewDate`, depuis le nœud `Fields`, vers ce groupe.

**Étape 4.** Enregistrez.

**Ce que cela produit.** Le groupe de champs standard est étendu par votre extension. La table effective, après fusion, présente un groupe contenant les champs Microsoft suivis du vôtre.

**Alternative si l'opération se révèle délicate.** Certaines versions restreignent l'extension de certains groupes standard. Deux replis existent :

1. **Créer votre propre groupe de champs** dans l'extension, par un clic droit sur `Field Groups` > `New Group` (Nouveau groupe), puis y placer votre champ. Le formulaire devra alors référencer ce groupe explicitement.
2. **Poser directement le contrôle sur le formulaire** en 6.5, sans passer par un groupe. Le résultat visible pour l'utilisateur est identique.

L'ordre de préférence est celui donné ici : le groupe standard d'abord, votre propre groupe ensuite, le contrôle isolé en dernier recours. Plus le champ est déclaré haut dans la chaîne, moins il faudra d'interventions ultérieures pour l'afficher ailleurs.

#### 6.4.7 Ce qui a été produit sur le disque

Votre extension de table est un fichier XML, créé dans votre dossier de métadonnées :

```
XppMetadata\ArchiaExtensions\ArchiaExtensions\AxTableExtension\CustTable.ArchiaExtensions.xml
```

Son contenu ressemble, dans sa forme la plus simple, à ceci :

```xml
<?xml version="1.0" encoding="utf-8"?>
<AxTableExtension xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
  <Name>CustTable.ArchiaExtensions</Name>
  <Fields>
    <AxTableField i:type="AxTableFieldDate">
      <Name>ArcCreditReviewDate</Name>
      <ExtendedDataType>ArcCreditReviewDate</ExtendedDataType>
    </AxTableField>
  </Fields>
  <FieldGroups />
  <Indexes />
  <Mappings />
  <Relations />
</AxTableExtension>
```

**Trois enseignements pratiques.**

1. **C'est ce fichier que Git versionne.** Une modification dans le concepteur produit une modification de ce fichier, que vous verrez apparaître dans la fenêtre `Git Changes` (Modifications Git).
2. **C'est ce fichier que le compilateur lit.** L'agent de build de la phase 6 ne connaît pas votre poste : il ne voit que ces fichiers XML, récupérés depuis le dépôt.
3. **Ne le modifiez jamais à la main.** Le concepteur garantit la cohérence du schéma. Une édition manuelle produit facilement un fichier que Visual Studio refusera d'ouvrir.

#### 6.4.8 Ce qui se passe lors de la synchronisation de la base

L'ajout d'un champ modifie le **schéma de données**. Tant que la base n'est pas synchronisée, la colonne n'existe pas physiquement et toute tentative d'ouverture du formulaire produit une erreur.

La synchronisation, déclenchée en 6.7, exécute une commande d'ajout de colonne sur la table `CUSTTABLE` de la base de données.

| Aspect | Comportement |
| :-- | :-- |
| Type de colonne créé | Une colonne de type date et heure, le type `date` de X++ étant stocké sous cette forme |
| Valeur des lignes existantes | La **date nulle**, correspondant au 1er janvier 1900. Ce n'est pas une valeur vide au sens SQL du terme |
| Impact sur les données existantes | Aucun. L'ajout d'une colonne est une opération non destructive |
| Durée | De quelques secondes à quelques minutes selon le volume de la table |
| Réversibilité | La suppression d'un champ est en revanche destructive et doit être traitée avec précaution |

**Conséquence directe sur votre code X++.** La date nulle vaut `false` lorsqu'elle est évaluée comme un booléen. C'est précisément ce qui rend correcte l'écriture utilisée en 6.6 :

```xpp
if (ret && this.ArcCreditReviewDate)
```

Cette condition est fausse lorsque le champ n'a jamais été renseigné, ce qui est le comportement souhaité : un client sans date de revue ne doit déclencher aucun contrôle. Écrire `if (this.ArcCreditReviewDate != dateNull())` serait équivalent, mais moins idiomatique.

**Une spécificité à connaître sur cette table.** `CustTable` est une table **propre à chaque société**, au sens où ses données sont cloisonnées par entité juridique. Votre champ hérite de ce comportement : un même client, présent dans deux entités juridiques, pourra porter deux dates de revue distinctes. C'est le comportement attendu ici, mais il faut en avoir conscience avant d'étendre une table.

#### 6.4.9 Pièges fréquents à ce stade

| Piège | Conséquence | Prévention |
| :-- | :-- | :-- |
| Champ créé sans préfixe | Risque de collision avec un autre éditeur, refus en revue de code | Appliquez le préfixe dès la création |
| Type primitif du champ différent de celui de l'EDT | L'EDT ne s'applique pas, sans message clair | Vérifiez le type au moment du clic droit `New` |
| Libellé renseigné à la fois sur l'EDT et sur le champ | Double maintenance, incohérences d'affichage | Laissez le libellé du champ vide |
| Propriété `Mandatory` passée à `Yes` sans analyse | Blocage de la création de clients, y compris par les intégrations | Ne rendez obligatoire que sur demande fonctionnelle explicite |
| Extension créée hors du projet | Objet invisible dans la vue de travail | Utilisez toujours `Create extension in the current project` |
| Champ ajouté mais base non synchronisée | Erreur à l'ouverture du formulaire | Synchronisez après toute modification de structure |
| Champ redondant avec un champ standard | Dette technique durable | Inspectez la table standard avant d'ajouter |
| Modification manuelle du fichier XML | Objet illisible par Visual Studio | Passez exclusivement par le concepteur |

#### 6.4.10 Vérifier avant de poursuivre

- [ ] L'extension `CustTable.ArchiaExtensions` figure dans le `Solution Explorer`.
- [ ] Le champ `ArcCreditReviewDate` apparaît sous le nœud `Fields` de l'extension.
- [ ] Sa propriété `Extended Data Type` vaut `ArcCreditReviewDate`.
- [ ] Ses propriétés `Label` et `Help Text` sont vides.
- [ ] La propriété `Mandatory` vaut `No`.
- [ ] Le champ figure dans un groupe de champs, standard ou propre.
- [ ] Le fichier `CustTable.ArchiaExtensions.xml` existe dans le dossier `AxTableExtension`.
- [ ] La fenêtre `Git Changes` détecte ce nouveau fichier.

### 6.5 Étape 4 : l'extension du formulaire CustTable

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

### 6.6 Étape 5 : la logique de validation en Chain of Command

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
| `this.ArcCreditReviewDate` | Accède au champ ajouté en 6.4. Le mot-clé `this` désigne l'enregistrement courant de `CustTable`. |
| `if (ret && this.ArcCreditReviewDate)` | Ne valide que si le standard a déjà accepté l'enregistrement, et que si le champ est renseigné. Une date vide est une valeur légitime. |
| `systemDateGet()` | Retourne la date de session de l'utilisateur, et non la date du serveur. C'est la fonction correcte pour toute comparaison métier avec la date du jour. |
| `checkFailed("@ArcLabels:...")` | Affiche le message d'erreur à l'utilisateur et **retourne toujours `false`**, ce qui bloque l'enregistrement. Le libellé est référencé, jamais écrit en dur. |

**Trois règles à retenir de cet exemple.**

1. **Appelez toujours `next`.** Une extension qui omet cet appel supprime le comportement standard et celui des autres extensions. C'est la première cause de régression en environnement multi-éditeurs.
2. **Vérifiez le retour du standard avant d'ajouter vos contrôles.** Si le standard a déjà refusé l'enregistrement, il est inutile d'empiler un second message d'erreur.
3. **Ne jamais écrire de texte en dur.** `checkFailed("La date est invalide")` compile parfaitement, mais rend la traduction impossible et sera refusé en revue de code.

**Étape 5.** Enregistrez.

### 6.7 Étape 6 : générer et déployer

**Étape 1.** Faites un clic droit sur le projet, puis `Build` (Générer).

**Étape 2.** Ouvrez `View` (Affichage) > `Error List` (Liste d'erreurs) et corrigez les éventuelles erreurs jusqu'à obtenir une génération sans erreur.

**Erreurs les plus fréquentes à ce stade :**

| Message | Cause | Correction |
| :-- | :-- | :-- |
| Type `CustTable` introuvable | Le package `ApplicationSuite` n'est pas référencé | `Model Management` > `Update model parameters`, ajoutez la référence |
| Le champ `ArcCreditReviewDate` n'existe pas | Extension de table non enregistrée, ou nom différent | Vérifiez le nom exact dans le concepteur d'extension de table |
| Attribut `ExtensionOf` non valide | Suffixe `_Extension` manquant sur le nom de la classe | Renommez la classe |
| Libellé affiché littéralement | Identifiant du fichier de libellés erroné | Comparez avec le nom du fichier créé en 6.2 |

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

### 6.8 Étape 7 : tester dans l'application

**Étape 1.** Ouvrez l'application Finance and Operations dans le navigateur, à l'adresse de la forme `https://<nom>.sandbox.operations.dynamics.com`.

**Étape 2.** Naviguez vers `Accounts receivable` (Comptabilité client) > `Customers` (Clients) > `All customers` (Tous les clients).

**Étape 3.** Ouvrez un client existant, par exemple un client de démonstration Contoso.

**Étape 4.** Ouvrez l'onglet consacré au crédit et aux relances. Votre champ `Credit review date` (Date de revue du crédit) doit y figurer.

**Étape 5.** Test du chemin nominal. Saisissez une date future, par exemple dans trois mois, puis enregistrez. L'enregistrement doit aboutir sans message.

**Étape 6.** Test du chemin d'erreur. Saisissez une date passée, par exemple celle de la veille, puis enregistrez. Le message `La date de revue du crédit ne peut pas être antérieure à la date du jour.` doit apparaître, et l'enregistrement doit être refusé.

**Étape 7.** Test de la valeur vide. Videz le champ et enregistrez. L'enregistrement doit aboutir : une date non renseignée est une valeur légitime, conformément à la condition posée en 6.6.

**Ces trois tests forment le jeu minimal.** Un composant validé uniquement sur son chemin nominal n'est pas validé. Le chemin d'erreur et le cas limite de la valeur vide révèlent la majorité des défauts de logique.

### 6.9 Déboguer le composant

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

### 6.10 Checklist de validation de la phase 4

- [ ] Le fichier de libellés `ArcLabels` contient les trois libellés.
- [ ] L'EDT `ArcCreditReviewDate` est de type `Date` et étend `TransDate`.
- [ ] L'EDT porte le libellé et le texte d'aide.
- [ ] La table standard a été inspectée pour écarter un champ redondant.
- [ ] L'extension `CustTable.ArchiaExtensions` est créée dans le projet.
- [ ] Le champ `ArcCreditReviewDate` est de type primitif `Date`.
- [ ] Sa propriété `Extended Data Type` pointe sur l'EDT.
- [ ] Ses propriétés `Label` et `Help Text` sont vides.
- [ ] Sa propriété `Mandatory` vaut `No`.
- [ ] Le champ figure dans un groupe de champs.
- [ ] Le fichier `CustTable.ArchiaExtensions.xml` est détecté par Git.
- [ ] L'extension de formulaire affiche le champ, lié à la bonne source de données.
- [ ] La classe d'extension porte le suffixe `_Extension` et l'attribut `ExtensionOf`.
- [ ] L'appel à `next` est présent dans la méthode.
- [ ] Aucun texte n'est écrit en dur dans le code.
- [ ] La génération se termine sans erreur.
- [ ] Le modèle est déployé et la base synchronisée.
- [ ] Le test du chemin nominal aboutit.
- [ ] Le test du chemin d'erreur affiche le message et bloque l'enregistrement.
- [ ] Le test de la valeur vide aboutit.

## 7. Phase 5 : Configuration du Power Platform pour l'automatisation

**Objectif de la phase.** Doter le pipeline d'une identité propre, capable de déployer sur l'environnement sans intervention humaine.

**Rôles requis.** `System administrator` (Administrateur système) dans l'environnement, et droit de créer une inscription d'application dans Microsoft Entra ID. `Project Administrators` (Administrateurs de projet) dans Azure DevOps pour créer la connexion de service.

### 7.1 Pourquoi un principal de service

Un pipeline s'exécute sans utilisateur devant l'écran. Il ne peut donc ni saisir un mot de passe, ni valider une authentification multifacteur. Il lui faut une **identité applicative**, appelée principal de service, dotée de ses propres droits sur l'environnement.

Cette identité présente trois avantages sur un compte nominatif : elle n'est pas soumise à l'expiration de mot de passe des comptes utilisateurs, elle ne consomme pas de licence utilisateur, et son départ n'est pas lié à celui d'une personne de l'équipe.

### 7.2 Créer le principal de service

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

### 7.3 Créer la connexion de service dans Azure DevOps

**Étape 1.** Ouvrez `Project settings` (Paramètres du projet) > `Service connections` (Connexions de service) > `New service connection` (Nouvelle connexion de service).

**Étape 2.** Sélectionnez `Power Platform`, puis `Next` (Suivant).

**Étape 3.** Renseignez :

| Champ | Valeur |
| :-- | :-- |
| `Authentication method` (Méthode d'authentification) | `Service Principal and Client Secret` (Principal de service et secret client) |
| `Server URL` (Adresse du serveur) | L'`Environment URL` de votre environnement |
| `Tenant ID` (Identifiant du locataire) | La valeur relevée en 7.2 |
| `Application ID` (Identifiant de l'application) | La valeur relevée en 7.2 |
| `Client secret` (Secret client) | La valeur relevée en 7.2 |
| `Service connection name` (Nom de la connexion de service) | `PPAC-Sandbox-DEV` |

**Étape 4.** Cochez `Grant access permission to all pipelines` (Accorder l'autorisation d'accès à tous les pipelines), puis `Save` (Enregistrer).

**Note sur l'authentification fédérée.** Si votre organisation impose l'authentification multifacteur pour les identités applicatives, préférez la méthode `Workload Identity Federation` (Fédération d'identité de charge de travail), qui supprime la gestion d'un secret et donc son expiration.

### 7.4 Créer le groupe de variables

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

### 7.5 Checklist de validation de la phase 5

- [ ] L'interface `pac` est installée et authentifiée.
- [ ] Le principal de service est créé.
- [ ] Les trois valeurs retournées sont consignées.
- [ ] La date d'expiration du secret est notée.
- [ ] La connexion de service `PPAC-Sandbox-DEV` est créée et accessible aux pipelines.
- [ ] Le groupe de variables est créé, le secret marqué comme secret.

## 8. Phase 6 : Chaîne d'intégration continue et de déploiement

**Objectif de la phase.** Mettre en place le pipeline qui compilera votre composant à chaque publication et le déploiera sur l'environnement.

**Rôles requis.** `Project Collection Administrators` pour les extensions et le flux d'artefacts. `Owner` ou `Contributor` sur la Subscription Azure pour les fournisseurs de ressources. `DevOps Infrastructure Contributor` au minimum pour le pool. `Contributors` pour créer le pipeline.

### 8.1 Vue d'ensemble de la chaîne

| Étage | Ce qu'il fait | Résultat |
| :-- | :-- | :-- |
| `Build` (Génération) | Restaure les packages NuGet de compilation, compile le X++, produit le package unifié Power Platform | Un artefact `UnifiedPackage.zip` |
| `Deploy` (Déploiement) | Authentifie le principal de service, installe le package sur l'environnement | Le composant est installé |

**Ce que cette chaîne remplace.** Dans le modèle antérieur, la compilation exigeait une machine virtuelle de build dédiée, provisionnée, maintenue et facturée en permanence. Elle s'effectue désormais sur des agents éphémères, à partir de packages NuGet, sans aucune machine à maintenir.

### 8.2 Installer les extensions Azure DevOps

**Étape 1.** Cliquez sur l'icône de sac de courses en haut à droite, puis `Browse marketplace` (Parcourir la place de marché).

**Étape 2.** Installez `Dynamics 365 Finance and Operations Tools`, qui fournit la tâche de création du package déployable.

**Étape 3.** Installez `Power Platform Build Tools`, qui fournit l'outillage `pac` et les tâches de déploiement.

**Étape 4.** Vérification dans `Organization settings` (Paramètres de l'organisation) > `Extensions`.

### 8.3 Récupérer les packages NuGet de compilation

L'agent ne dispose ni de l'application standard, ni du compilateur X++. Il les obtient sous forme de cinq packages NuGet.

| Package | Contenu |
| :-- | :-- |
| `Microsoft.Dynamics.AX.Platform.CompilerPackage` | Le compilateur X++ et les tâches de génération |
| `Microsoft.Dynamics.AX.Platform.DevALM.BuildXpp` | Les références compilées du module Platform |
| `Microsoft.Dynamics.AX.Application1.DevALM.BuildXpp` | Les références du module Application, première partie |
| `Microsoft.Dynamics.AX.Application2.DevALM.BuildXpp` | Les références du module Application, seconde partie |
| `Microsoft.Dynamics.AX.ApplicationSuite.DevALM.BuildXpp` | Les références du module Application Suite |

**Point important sur la provenance.** Ces packages étaient historiquement téléchargés depuis la bibliothèque d'actifs partagés de Lifecycle Services. Cette voie n'est plus adaptée aux nouveaux projets. **Visual Studio les met à disposition directement**, ce qui garantit en outre la cohérence entre la version de votre environnement et celle des packages de compilation.

**Étape 1.** Dans Visual Studio, ouvrez `Tools` (Outils) > `Download Dynamics 365 FnO NuGets for CI/CD` (Télécharger les NuGets Dynamics 365 FnO pour CI/CD). Cette commande est disponible car l'option correspondante a été activée en 3.4.

**Étape 2.** Patientez. Les cinq fichiers `.nupkg` sont déposés dans un dossier local dont le chemin est indiqué à la fin de l'opération.

**Étape 3.** Relevez les **numéros de version exacts**, visibles dans le nom des fichiers : la version **plateforme**, au format `7.0.XXXX.XX`, et la version **application**, au format `10.0.XXXX.XX`.

**Point de vigilance.** Ces deux valeurs seront reprises telles quelles dans `packages.config` et dans les variables du pipeline. Une divergence entre les quatre emplacements est la cause d'échec la plus fréquente de cette phase.

### 8.4 Publier les packages dans un flux Azure Artifacts

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

### 8.5 Déclarer nuget.config et packages.config

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

**Étape 2.** Créez `BuildPipeline/packages.config`, en reportant les versions relevées en 8.3 :

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

### 8.6 Créer le Managed DevOps Pool

Un `Managed DevOps Pool` (pool DevOps managé) fournit des agents éphémères hébergés dans **votre** souscription Azure, provisionnés à la demande et détruits en fin d'exécution, sans aucune maintenance de votre part.

#### 8.6.1 Prérequis

**Étape 1.** Enregistrez les fournisseurs de ressources. Portail Azure > `Subscriptions` (Abonnements) > votre souscription > `Resource providers` (Fournisseurs de ressources). Enregistrez `Microsoft.DevOpsInfrastructure` puis `Microsoft.DevCenter`.

**Étape 2.** Patientez deux à trois minutes et vérifiez que les deux statuts affichent `Registered` (Enregistré).

**Étape 3.** Vérifiez vos permissions sur les pools d'agents. Azure DevOps > `Project settings` (Paramètres du projet) > `Agent pools` (Pools d'agents) > `Security` (Sécurité). Vous devez y figurer comme `Administrator` (Administrateur) ou `Creator` (Créateur).

**Sur le quota.** La taille d'agent par défaut, `Standard D2ads v5`, consomme deux cœurs. Le quota par défaut de cinq cœurs par famille et par région autorise donc deux agents simultanés, ce qui suffit ici.

#### 8.6.2 Créer le pool

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

#### 8.6.3 Coût et repli

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

### 8.7 Créer le fichier de pipeline

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
    value: '7.0.7367.146'       # A ADAPTER : version plateforme relevee en 8.3
  - name: ApplicationVersion
    value: '10.0.1935.21'       # A ADAPTER : version application relevee en 8.3
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

### 8.8 Créer et exécuter le pipeline

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

### 8.9 Checklist de validation de la phase 6

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

## 9. Phase 7 : Livraison du composant par le pipeline

**Objectif de la phase.** Vérifier que la chaîne fonctionne de bout en bout, en modifiant le composant et en observant sa livraison automatique.

**Rôles requis.** `Contributors` (Contributeurs) du projet.

### 9.1 Publier le composant

**Étape 1.** Dans Visual Studio, ouvrez `View` (Affichage) > `Git Changes` (Modifications Git).

**Étape 2.** Vérifiez la liste des fichiers modifiés. Elle doit contenir les cinq objets créés en phase 4, ainsi que le fichier descripteur du modèle.

**Étape 3.** Saisissez un message de commit décrivant **l'intention**, et non le contenu technique. Par exemple :

```
Ajout de la date de revue du credit sur le client, avec controle de coherence
```

**Étape 4.** Cliquez sur `Commit All` (Valider tout), puis sur `Push` (Envoyer).

### 9.2 Observer le déclenchement automatique

**Étape 1.** Ouvrez `Pipelines` dans Azure DevOps. Une exécution doit avoir démarré dans la minute suivant la publication.

**Étape 2.** Ouvrez l'exécution. Le nom du commit et son auteur y figurent, ce qui établit la traçabilité entre le code publié et le déploiement.

**Étape 3.** Suivez la progression étage par étage.

**Si l'étage de compilation échoue**, le journal indique la ligne fautive. Corrigez dans Visual Studio, validez et publiez de nouveau : une nouvelle exécution démarre automatiquement.

### 9.3 Vérifier le résultat

**Étape 1.** Dans le Power Platform Admin Center, ouvrez votre environnement. L'opération de déploiement doit apparaître dans l'historique des opérations.

**Étape 2.** Ouvrez l'application Finance and Operations et vérifiez que votre champ est présent et que la règle de validation s'applique, en rejouant les trois tests de la section 6.8.

**Étape 3.** Vérification de la traçabilité complète. Vous devez pouvoir remonter, sans ambiguïté, du champ affiché à l'écran jusqu'au commit qui l'a produit, en passant par l'exécution du pipeline. C'est la finalité de toute la chaîne mise en place.

### 9.4 Le cycle de travail au quotidien

| Moment | Action | Commande |
| :-- | :-- | :-- |
| Début de session | Récupérer les modifications de l'équipe | `Git` > `Pull` (Extraire) |
| Après un `Pull` apportant des modèles | Actualiser les modèles | `Dynamics 365` > `Model Management` > `Refresh models` |
| Pendant le développement | Générer localement et corriger | Clic droit sur le projet > `Build` (Générer) |
| Après une modification de structure | Synchroniser la base locale | `Dynamics 365` > `Synchronize database` |
| Pour tester avant publication | Déployer sur l'environnement | `Dynamics 365` > `Deploy` (Déployer) |
| Évolution achevée | Publier et déclencher la chaîne | `Git Changes` > `Commit All` puis `Push` |

**Bonne pratique de branche.** Dès que vous travaillez à plusieurs, protégez la branche `main` par une stratégie exigeant une pull request et une compilation réussie avant fusion. Azure DevOps > `Repos` > `Branches` > menu de la branche > `Branch policies` (Stratégies de branche).

### 9.5 Checklist de validation de la phase 7

- [ ] La publication déclenche automatiquement le pipeline.
- [ ] L'exécution porte le nom du commit et son auteur.
- [ ] Les deux étages se terminent avec succès.
- [ ] L'opération de déploiement apparaît dans le Power Platform Admin Center.
- [ ] Le composant est fonctionnel dans l'application après déploiement automatique.
- [ ] Les trois tests de la section 6.8 passent toujours.

## 10. Annexe A : Dépannage

### 10.1 Chapitre 2, provisionnement de l'environnement

| Symptôme | Cause probable | Résolution |
| :-- | :-- | :-- |
| Le type `Sandbox` n'est pas sélectionnable | Capacité insuffisante | Rattachez une Subscription Azure par un plan de facturation à l'usage, voir 2.5.1 |
| L'installation de la `Provisioning App` échoue | Nom d'hôte de plus de 19 caractères | Recréez l'environnement avec un nom court |
| La `Provisioning App` est introuvable | `Platform Tools` non installé, ou statut différent de `Installed` | Terminez d'abord l'installation de `Platform Tools` |
| L'installation dépasse trois heures | Charge de la plateforme, ou blocage réel | Rafraîchissez la page. Au-delà de quatre heures, ouvrez un ticket de support depuis le portail |
| L'adresse Finance and Operations n'apparaît pas | Problème connu de synchronisation d'affichage | Modifiez la description de l'environnement et enregistrez, ce qui force la synchronisation |
| Les outils de développement sont absents | Cases non cochées, ou modèle applicatif retenu à la création | Recréez l'environnement en suivant strictement 2.5.3 |

### 10.2 Chapitre 3, Visual Studio et connexion

| Symptôme | Cause probable | Résolution |
| :-- | :-- | :-- |
| Le menu `Dynamics 365` est absent | L'extension Finance and Operations n'est pas installée | Relancez la connexion à l'environnement, qui déclenche son installation |
| L'environnement n'accepte aucune connexion depuis Visual Studio, aucun message clair | L'environnement a été provisionné **sans** `DevToolsEnabled=true` | Appliquez les trois contrôles de la section 1.7.4, puis recréez l'environnement selon l'annexe D |
| La commande de téléchargement des NuGets est absente du menu `Tools` | Option `Download Dynamics 365 FinOps NuGets for CI/CD` inactive | Activez-la dans `Tools` > `Options` > `Power Platform Tools` |
| La connexion à Dataverse est anormalement lente | L'explorateur Power Platform s'ouvre automatiquement | Activez `Do not display Power Platform Explorer on connecting to Dataverse` |
| Un déploiement échoue sans détail exploitable | Option `Download logs for operations if using Unified environment` inactive | Activez-la, puis relancez l'opération |
| Aucun environnement n'est proposé alors que le compte est invité dans un autre locataire | Le service de découverte ne retourne rien pour un compte invité | Activez `Skip Discovery when connecting to Dataverse` et saisissez l'adresse manuellement |
| La liste des environnements est vide | L'adresse de l'application a été saisie au lieu de l'`Environment URL` | Utilisez l'adresse Dataverse en `*.dynamics.com` |
| L'authentification échoue en boucle | Blocage lié à l'authentification multifacteur, `Security defaults` actifs par défaut | Décochez **toutes** les cases de l'écran de connexion pour déclencher le flux navigateur. Voir l'avertissement de la section 3.6 |
| Message `AADSTS50076` avec `suberror: basic_action` sur la ressource `00000007-0000-0000-c000-000000000000` | L'extension Power Platform Tools a tenté d'obtenir le jeton **Dataverse** par un flux hérité, incapable de présenter un second facteur | Décochez **toutes** les cases de l'écran de connexion de l'extension, puis relancez. Voir le décryptage complet en 3.6 |
| L'erreur `AADSTS50076` persiste malgré les cases décochées | Jeton en cache, ou navigateur connecté avec une autre identité | Retirez les comptes dans `File` > `Account Settings`, puis relancez depuis une session de navigation privée |
| Doute sur la santé du compte lui-même | Le problème peut venir du compte et non de l'extension | Testez avec `pac auth create --environment <adresse>`, qui ouvre le navigateur de lui-même |
| Message `A window handle must be configured` en PowerShell | Le courtier d'authentification Windows réclame une fenêtre parente | Le script de l'annexe D désactive le courtier et bascule seul, forcez au besoin avec `-UseDeviceCode` |
| Le flux par code d'appareil est refusé | Les `Security defaults` bloquent ce flux | Utilisez `Connect-AzAccount -AuthScope` ou fournissez un jeton avec `-AccessToken` |
| Seule la solution `Default` est proposée à la connexion | Aucune solution créée, ou solution créée dans un autre environnement | Vérifiez le sélecteur d'environnement sur `make.powerapps.com` et recréez la solution selon la section 3.5 |
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

### 10.3 Phase 2 et phase 3, dépôt, modèle et projet

| Symptôme | Cause probable | Résolution |
| :-- | :-- | :-- |
| Erreur de chemin trop long à la compilation | Dossier de clonage trop profond | Reclonez dans un chemin proche de la racine du disque |
| Le dépôt se remplit mais le pipeline compile une version obsolète | `Configure Metadata` pointe hors du dépôt | Comparez le chemin déclaré et le chemin réel, corrigez selon la section 4.5 |
| Le dépôt grossit anormalement | `PackagesLocalDirectory` a été ajouté | Retirez-le du suivi et vérifiez le fichier `.gitignore` |
| Un collègue récupère des objets orphelins | Le fichier descripteur du modèle n'est pas versionné | Ajoutez le fichier XML du dossier `Descriptor` |
| Le modèle n'apparaît pas après création | Rafraîchissement nécessaire | Fermez et rouvrez Visual Studio, puis `Refresh models` |
| Le `Push` est refusé | Niveau d'accès `Stakeholder` (Partie prenante) | Faites élever votre accès à `Basic` et vérifier le groupe `Contributors` |

### 10.4 Phase 4, développement du composant

| Symptôme | Cause probable | Résolution |
| :-- | :-- | :-- |
| Type `CustTable` introuvable à la compilation | Le package `ApplicationSuite` n'est pas référencé | `Model Management` > `Update model parameters`, ajoutez la référence |
| Attribut `ExtensionOf` refusé | Suffixe `_Extension` manquant sur le nom de la classe | Renommez la classe |
| Le champ n'existe pas selon le compilateur | Extension de table non enregistrée, ou nom différent | Vérifiez le nom exact dans le concepteur |
| L'EDT ne s'applique pas au champ, propriété vide | Type primitif du champ différent de celui de l'EDT | Supprimez le champ et recréez-le avec le bon type |
| L'`Application Explorer` ne trouve pas `CustTable` | Base de références croisées non générée | Reprenez la section 3.7, et régénérez si nécessaire |
| L'extension n'apparaît pas dans le projet | Entrée `Create extension` retenue au lieu de `Create extension in the current project` | Ajoutez l'objet au projet par un clic droit sur le projet, `Add` puis `Add existing item` |
| Impossible d'enregistrer la table standard | La table d'origine est en lecture seule | C'est le comportement attendu, passez par une extension |
| La création d'un client échoue depuis une intégration | Propriété `Mandatory` du nouveau champ passée à `Yes` | Repassez-la à `No`, sauf demande fonctionnelle explicite |
| Visual Studio refuse d'ouvrir un objet | Fichier XML modifié à la main | Restaurez la version précédente depuis Git |
| Le champ n'apparaît dans aucun formulaire | Champ absent de tout groupe de champs | Ajoutez-le à un groupe, ou posez le contrôle explicitement |
| Le libellé s'affiche littéralement à l'écran | Identifiant du fichier de libellés erroné | Comparez avec le nom saisi à la création du fichier |
| Le formulaire produit une erreur à l'ouverture | Base non synchronisée après ajout du champ | Exécutez `Dynamics 365` > `Synchronize database` |
| Le champ n'apparaît pas sur le formulaire | Contrôle non lié à la source de données | Vérifiez les propriétés `Data Source` et `Data Field` du contrôle |
| La validation ne se déclenche jamais | Modèle non déployé sur l'environnement | Déployez le modèle, la validation s'exécute côté serveur |
| La validation standard ne fonctionne plus | Appel à `next` omis dans la méthode d'extension | Rétablissez `boolean ret = next validateWrite();` |
| Le message d'erreur s'affiche deux fois | Contrôle ajouté sans vérifier le retour du standard | Encadrez votre contrôle par `if (ret && ...)` |
| Le point d'arrêt n'est jamais atteint | Symboles non chargés, ou modèle non déployé | Activez le chargement des symboles, puis redéployez |
| L'environnement redémarre après le débogage | Utilisation de `Stop` au lieu de `Detach` | Utilisez systématiquement `Detach` (Détacher) |

### 10.5 Phase 5 et phase 6, automatisation

| Symptôme | Cause probable | Résolution |
| :-- | :-- | :-- |
| La restauration NuGet retourne une erreur 401 | Le compte de service de build n'a pas accès au flux | `Artifacts` > `Feed settings` > `Permissions`, ajoutez le compte de service en `Reader` (Lecteur) |
| La restauration ne trouve pas les packages | Adresse de flux erronée, ou versions absentes | Comparez avec l'adresse de `Connect to feed` et les versions publiées |
| Le pipeline reste en attente sans démarrer | Aucun agent disponible, quota atteint | Vérifiez le pool et le quota, ou basculez sur `vmImage: 'windows-latest'` |
| La compilation échoue immédiatement | Image Linux sélectionnée pour le pool | Recréez le pool avec une image Windows incluant Visual Studio |
| Erreur de versionnement sémantique à l'empaquetage | NuGet postérieur à la version 3.3.0 | Vérifiez la présence de `NuGetToolInstaller@1` avec `versionSpec: '3.3.0'` |
| Message `fnomoduledefinition.json not found` | Chemins de la tâche d'empaquetage erronés | Contrôlez `CloudPackageOutputLocation` et `XppToolsPath` |
| Versions du package unifié incohérentes | Variables désynchronisées de `packages.config` | Alignez les quatre valeurs sur celles relevées en 8.3 |
| Erreur de syntaxe sur le bloc `variables` | Formes abrégée et en liste mélangées | Écrivez toutes les variables sous forme de paires `name` et `value` |
| La tâche `PowerPlatformWhoAmi` échoue | Principal de service sans droits, ou secret expiré | Réexécutez `pac admin create-service-principal` et mettez à jour la connexion |
| Le déploiement échoue sans message explicite | Environnement indisponible ou opération concurrente | Vérifiez l'état de l'environnement et relancez |
| Autorisation demandée à chaque exécution | Accès aux ressources non accordé durablement | Ouvrez l'exécution, `View` puis `Permit`, en cochant l'accès permanent |

## 11. Annexe B : Checklist séquentielle d'exhaustivité

Cette annexe répond à une question précise : ai-je oublié une étape ? Elle suit l'ordre chronologique exact des actions.

### 11.1 Préparation du socle

| Fait | Action | Rôle requis | Section |
| :-- | :-- | :-- | :-- |
| [ ] | Vérifier l'existence d'un tenant Microsoft 365 | Aucun | 1.2 |
| [ ] | Vérifier l'affectation d'une licence Dynamics 365 au compte | `License administrator` | 1.2 |
| [ ] | Vérifier le rôle d'administration sur le Power Platform | `Global admin` | 1.2 |
| [ ] | Vérifier la capacité disponible, ou le plan de facturation à l'usage | `Power Platform admin` | 2.5.1 |
| [ ] | Vérifier les 60 Go d'espace disque libre sur le poste | Aucun | 1.4 |

### 11.2 Chapitre 2, environnement de développement unifié

**Si l'environnement reste à créer :**

| Fait | Action | Rôle requis | Section |
| :-- | :-- | :-- | :-- |
| [ ] | Créer un environnement de type **`Sandbox`** | `Power Platform admin` | 2.5.3 |
| [ ] | **Vérifier que le nom d'hôte ne dépasse pas 19 caractères** | `Power Platform admin` | 2.5.3 |
| [ ] | Choisir la langue et la devise, non modifiables ensuite | `Power Platform admin` | 2.5.3 |
| [ ] | Activer `Enable Dynamics 365 apps` | `Power Platform admin` | 2.5.3 |
| [ ] | **Ne sélectionner aucun modèle applicatif automatique** | `Power Platform admin` | 2.5.3 |
| [ ] | Installer `Platform Tools` et attendre le statut `Installed` | `Power Platform admin` | 2.5.3 |
| [ ] | Installer la `Provisioning App` | `Power Platform admin` | 2.5.3 |
| [ ] | **Cocher `Enable developer tools for Finance and Operations`** | `Power Platform admin` | 2.5.3 |
| [ ] | Cocher `Enable demo data for Finance and Operations` | `Power Platform admin` | 2.5.3 |

**Dans tous les cas, y compris si l'environnement existait déjà :**

| Fait | Action | Rôle requis | Section |
| :-- | :-- | :-- | :-- |
| [ ] | Vérifier le type `Sandbox` et l'état `Ready` | `Power Platform admin` | 2.6 |
| [ ] | Vérifier le statut `Installed` des deux applications | `Power Platform admin` | 2.6 |
| [ ] | **Vérifier que les outils de développement sont activés** | `Power Platform admin` | 2.6 |
| [ ] | Ouvrir l'application et vérifier les données Contoso | Licence Dynamics 365 | 2.6 |
| [ ] | Vérifier le rôle `System administrator` dans l'application | `System administrator` | 2.6 |
| [ ] | **Relever les deux adresses et les distinguer** | `Power Platform admin` | 2.7 |

### 11.3 Phase 1, Visual Studio

| Fait | Action | Rôle requis | Section |
| :-- | :-- | :-- | :-- |
| [ ] | Télécharger Visual Studio 2026 Professional via Dev Essentials | Aucun | 3.1 |
| [ ] | Installer la charge de travail `.NET desktop development` | Administrateur local | 3.2 |
| [ ] | Ajouter le composant `Modeling SDK` | Administrateur local | 3.2 |
| [ ] | Ajouter le composant `DGML editor` | Administrateur local | 3.2 |
| [ ] | Vérifier la présence de `SQL Server Express LocalDB` | Administrateur local | 3.2 |
| [ ] | Se connecter à Visual Studio avec le compte du tenant | Aucun | 3.2 |
| [ ] | Installer `Microsoft Reporting Services Projects` | Administrateur local | 3.3.1 |
| [ ] | Installer `Power Platform Tools` | Administrateur local | 3.3.2 |
| [ ] | Régler les dix options `Power Platform Tools` selon le tableau | Aucun | 3.4.1 |
| [ ] | **Vérifier `Enable auto setup` et `Download logs for operations`** | Aucun | 3.4.1 |
| [ ] | Laisser `Enable Download Dynamics 365 FinOps VHD` inactive | Aucun | 3.4.1 |
| [ ] | Ouvrir `make.powerapps.com` et **vérifier le sélecteur d'environnement** | Aucun | 3.5.2 |
| [ ] | Créer l'éditeur avec un préfixe maîtrisé | `System customizer` | 3.5.2 |
| [ ] | Créer la solution rattachée à cet éditeur | `System customizer` | 3.5.3 |
| [ ] | **Vérifier le nom technique, non modifiable ensuite** | `System customizer` | 3.5.3 |
| [ ] | Cocher `Set as your preferred solution` | `System customizer` | 3.5.3 |
| [ ] | **En cas de MFA, décocher toutes les cases de l'écran de connexion** | `System administrator` | 3.6 |
| [ ] | **Se connecter avec l'`Environment URL`, et non l'adresse de l'application** | `System administrator` | 3.6 |
| [ ] | **Sélectionner votre solution, et non `Default`** | `System administrator` | 3.6 |
| [ ] | Télécharger les métadonnées de référence | `System administrator` | 3.6 |
| [ ] | Installer l'extension Finance and Operations | Administrateur local | 3.6 |
| [ ] | Vérifier les 24 Go du dossier des assets | Aucun | 3.6 |
| [ ] | Vérifier l'ouverture de l'`Application Explorer` | Aucun | 3.7 |

### 11.4 Phase 2, Azure DevOps et dépôt

| Fait | Action | Rôle requis | Section |
| :-- | :-- | :-- | :-- |
| [ ] | Créer l'organisation avec l'identité du tenant | Aucun | 4.2 |
| [ ] | **Vérifier le rattachement à Microsoft Entra ID** | `Organization Owner` | 4.2 |
| [ ] | Créer le projet en visibilité `Private`, contrôle de version `Git` | `Project Collection Administrators` | 4.3 |
| [ ] | Cloner le dépôt dans un chemin court | `Contributors` | 4.5 |
| [ ] | Créer les quatre dossiers de la structure | `Contributors` | 4.5 |
| [ ] | **Repointer `Configure Metadata` sur `XppMetadata` dans le dépôt** | Administrateur local | 4.5 |
| [ ] | Créer le fichier `.gitignore` | `Contributors` | 4.6 |

### 11.5 Phase 3, modèle et projet

| Fait | Action | Rôle requis | Section |
| :-- | :-- | :-- | :-- |
| [ ] | Créer le modèle avec son éditeur et sa couche | Administrateur local | 5.2 |
| [ ] | Choisir `Create new package` | Administrateur local | 5.2 |
| [ ] | Déclarer les trois packages de référence | Administrateur local | 5.2 |
| [ ] | Créer le projet dans `VS_Solutions` | Administrateur local | 5.3 |
| [ ] | **Vérifier la présence du fichier descripteur** | Administrateur local | 5.3 |
| [ ] | Réaliser et publier le premier commit | `Contributors` | 5.4 |

### 11.6 Phase 4, développement

| Fait | Action | Rôle requis | Section |
| :-- | :-- | :-- | :-- |
| [ ] | Créer le fichier de libellés `ArcLabels` | Administrateur local | 6.2 |
| [ ] | Saisir les trois libellés | Administrateur local | 6.2 |
| [ ] | Créer l'EDT de type `Date`, le type primitif étant définitif | Administrateur local | 6.3.2 |
| [ ] | Renseigner `Extends`, le libellé et le texte d'aide | Administrateur local | 6.3.3 |
| [ ] | Vérifier l'EDT dans l'`Application Explorer` | Administrateur local | 6.3.4 |
| [ ] | Localiser `CustTable` par la barre de recherche | Administrateur local | 6.4.2 |
| [ ] | **Inspecter la table standard pour écarter un champ redondant** | Administrateur local | 6.4.2 |
| [ ] | Créer l'extension par `Create extension in the current project` | Administrateur local | 6.4.3 |
| [ ] | Ajouter un champ de type primitif `Date` | Administrateur local | 6.4.4 |
| [ ] | Nommer le champ avec le préfixe | Administrateur local | 6.4.5 |
| [ ] | Affecter l'EDT au champ | Administrateur local | 6.4.5 |
| [ ] | **Laisser `Label` et `Help Text` vides** | Administrateur local | 6.4.5 |
| [ ] | **Laisser `Mandatory` à `No`** | Administrateur local | 6.4.5 |
| [ ] | Ajouter le champ à un groupe de champs | Administrateur local | 6.4.6 |
| [ ] | Vérifier la présence du fichier XML d'extension | Administrateur local | 6.4.7 |
| [ ] | Créer l'extension de formulaire `CustTable` | Administrateur local | 6.5 |
| [ ] | Ajouter le contrôle et le lier à la source de données | Administrateur local | 6.5 |
| [ ] | Créer la classe `ArcCustTable_Extension` | Administrateur local | 6.6 |
| [ ] | **Vérifier la présence de l'appel à `next`** | Administrateur local | 6.6 |
| [ ] | **Vérifier qu'aucun texte n'est écrit en dur** | Administrateur local | 6.6 |
| [ ] | Générer le projet sans erreur | Administrateur local | 6.7 |
| [ ] | Déployer le modèle avec synchronisation de la base | `System administrator` | 6.7 |
| [ ] | Tester le chemin nominal, date future | Licence Dynamics 365 | 6.8 |
| [ ] | Tester le chemin d'erreur, date passée | Licence Dynamics 365 | 6.8 |
| [ ] | Tester la valeur vide | Licence Dynamics 365 | 6.8 |

### 11.7 Phase 5, Power Platform

| Fait | Action | Rôle requis | Section |
| :-- | :-- | :-- | :-- |
| [ ] | Installer l'interface `pac` | Administrateur local | 7.2 |
| [ ] | Créer le principal de service | `System administrator` | 7.2 |
| [ ] | **Consigner les trois valeurs retournées** | Aucun | 7.2 |
| [ ] | Noter la date d'expiration du secret | Aucun | 7.2 |
| [ ] | Créer la connexion de service `Power Platform` | `Project Administrators` | 7.3 |
| [ ] | Créer le groupe de variables | `Contributors` | 7.4 |
| [ ] | **Marquer le secret client comme secret** | `Contributors` | 7.4 |

### 11.8 Phase 6, chaîne CI/CD

| Fait | Action | Rôle requis | Section |
| :-- | :-- | :-- | :-- |
| [ ] | Installer `Dynamics 365 Finance and Operations Tools` | `Project Collection Administrators` | 8.2 |
| [ ] | Installer `Power Platform Build Tools` | `Project Collection Administrators` | 8.2 |
| [ ] | Télécharger les cinq packages NuGet depuis Visual Studio | Administrateur local | 8.3 |
| [ ] | **Relever les versions plateforme et application** | Aucun | 8.3 |
| [ ] | Créer le flux `FinOpsNuGet` | `Project Collection Administrators` | 8.4 |
| [ ] | Publier les cinq packages | `Contributors` du flux | 8.4 |
| [ ] | Créer `nuget.config` | `Contributors` | 8.5 |
| [ ] | Créer `packages.config` avec les versions relevées | `Contributors` | 8.5 |
| [ ] | Enregistrer `Microsoft.DevOpsInfrastructure` | `Owner` ou `Contributor` Azure | 8.6.1 |
| [ ] | Enregistrer `Microsoft.DevCenter` | `Owner` ou `Contributor` Azure | 8.6.1 |
| [ ] | Vérifier la permission sur les pools d'agents | `Project Administrators` | 8.6.1 |
| [ ] | Créer le Managed DevOps Pool | `DevOps Infrastructure Contributor` | 8.6.2 |
| [ ] | **Sélectionner une image Windows incluant Visual Studio** | Idem | 8.6.2 |
| [ ] | Vérifier l'apparition du pool dans `Agent pools` | `Project Administrators` | 8.6.2 |
| [ ] | Configurer une alerte de budget Azure | `Cost Management Contributor` | 8.6.3 |
| [ ] | Créer `ci-build.yml` et adapter les valeurs signalées | `Contributors` | 8.7 |
| [ ] | Créer le pipeline à partir du fichier existant | `Contributors` | 8.8 |
| [ ] | Autoriser l'accès aux ressources | `Contributors` | 8.8 |
| [ ] | Obtenir une exécution complète réussie | `Contributors` | 8.8 |

### 11.9 Phase 7, livraison

| Fait | Action | Rôle requis | Section |
| :-- | :-- | :-- | :-- |
| [ ] | Publier le composant avec un message d'intention | `Contributors` | 9.1 |
| [ ] | Vérifier le déclenchement automatique du pipeline | `Contributors` | 9.2 |
| [ ] | Vérifier la réussite des deux étages | `Contributors` | 9.2 |
| [ ] | Vérifier l'opération dans le Power Platform Admin Center | `Power Platform admin` | 9.3 |
| [ ] | Rejouer les trois tests fonctionnels | Licence Dynamics 365 | 9.3 |
| [ ] | Mettre en place une stratégie de branche sur `main` | `Project Administrators` | 9.4 |
| [ ] | **Signaler tout point de blocage à contact@archia365.fr** | Aucun | 15 |

## 12. Annexe C : Conventions de nommage et bonnes pratiques

### 12.1 Conventions de nommage

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

### 12.2 Règles d'extensibilité

1. **Ne modifiez jamais un objet standard.** C'est techniquement impossible depuis la version 10, et toute tentative de contournement produit du code non maintenable.
2. **Appelez toujours `next` dans une Chain of Command.** Omettre cet appel neutralise le comportement standard et celui des autres extensions.
3. **Préférez une extension à un gestionnaire d'événements lorsque les deux sont possibles.** La Chain of Command est vérifiée à la compilation, ce qui n'est pas le cas des gestionnaires liés par délégué.
4. **Ne stockez jamais de texte visible en dur.** Tout passe par un libellé.
5. **Une extension par objet et par modèle.** Multiplier les extensions du même objet dans un même modèle rend le comportement difficile à suivre.
6. **Vérifiez le retour du standard avant d'ajouter vos propres contrôles.** Cela évite l'empilement de messages d'erreur.

### 12.3 Règles de contrôle de source

1. **Ne versionnez jamais `PackagesLocalDirectory`.** Environ 24 Go de métadonnées Microsoft que le poste retélécharge à la demande.
2. **Versionnez toujours le fichier descripteur du modèle.** Sans lui, le modèle n'existe pas pour le compilateur.
3. **Publiez souvent, avec des messages d'intention.** Un message décrivant le besoin métier vaut mieux qu'une liste d'objets modifiés.
4. **Générez localement avant de publier.** Un pipeline qui échoue sur une faute de frappe fait perdre du temps à toute l'équipe.
5. **Protégez la branche principale dès que vous êtes plusieurs.**

### 12.4 Règles de déploiement

1. **Synchronisez la base après toute modification de structure.** Ajout de champ, de table, d'index ou de relation.
2. **Utilisez `Detach` et non `Stop` pour terminer une session de débogage.**
3. **Prévenez avant de déboguer sur un environnement partagé.** Le débogage suspend le serveur d'application.
4. **Alignez systématiquement les versions.** Celles des packages NuGet, celles de `packages.config` et celles des variables du pipeline doivent être identiques.

## 13. Annexe D : Provisionnement d'un environnement par script

Cette annexe fournit un script PowerShell qui crée un environnement `Sandbox` Dynamics 365 Finance and Operations **avec `DevToolsEnabled=true`**, sans passer par l'interface du Power Platform Admin Center.

**Quand l'utiliser.** Le portail convient parfaitement pour un environnement isolé. Le script devient préférable dans trois cas : lorsque vous provisionnez plusieurs environnements et voulez garantir qu'ils sont identiques ; lorsque vous voulez la certitude que `DevToolsEnabled` est bien transmis, plutôt que de dépendre d'une case à cocher ; et lorsque vous documentez une procédure destinée à être rejouée.

### 13.1 Ce que fait le script

| Étape | Action |
| :-- | :-- |
| 1 | Obtient un jeton d'accès pour l'interface de programmation Business Application Platform, par trois voies possibles |
| 3 | Construit le corps de la requête de création d'environnement, au format JSON |
| 4 | Transmet à la `Provisioning App` la chaîne `DevToolsEnabled=true|DemoDataEnabled=true` |
| 5 | Négocie avec le service la forme exacte du corps de requête, en essayant plusieurs emplacements pour les champs de localisation |
| 6 | Affiche un récapitulatif et demande confirmation avant toute création |
| 7 | Suit l'opération de provisionnement jusqu'à son état final |

**Pourquoi un appel direct à l'interface de programmation.** Le module PowerShell d'administration Power Platform n'expose pas le paramètre de macro région exigé par le service depuis le déploiement du provisionnement par macro région. Un appel direct est donc nécessaire pour obtenir un environnement correctement localisé.

### 13.2 Prérequis

| Prérequis | Détail |
| :-- | :-- |
| Version de PowerShell | Windows PowerShell 5.1, dans une fenêtre neuve |
| Module | `Az.Accounts`, installé automatiquement si absent |
| Rôle | `Power Platform admin` (Administrateur Power Platform), `Dynamics 365 admin` (Administrateur Dynamics 365) ou `Global admin` (Administrateur général) |
| Capacité | Suffisante pour un environnement `Sandbox`, ce qui suppose en pratique une Subscription Azure rattachée par un plan de facturation à l'usage |
| Licence | Une licence Dynamics 365 affectée au compte exécutant le script |

### 13.3 Paramètres

Toute la configuration est portée par le bloc `param()`. Le script s'utilise sans être modifié.

| Paramètre | Valeur par défaut | Commentaire |
| :-- | :-- | :-- |
| `-DisplayName` | `ARCFODEV09` | Nom d'affichage de l'environnement |
| `-DomainName` | `arcfodev09` | Nom de domaine, **unique à l'échelle mondiale**, en minuscules, **19 caractères au maximum** |
| `-MacroRegion` | `the-americas` | Macro région de provisionnement. Énumérez les valeurs valides avec `-ListMacroRegions` |
| `-Location` | `canada` | Localisation, transmise uniquement si aucune macro région n'est renseignée |
| `-AzureRegion` | `canadacentral` | Indication de centre de données, transmise comme `azureRegionHint` |
| `-Sku` | `Sandbox` | Type d'environnement. `Sandbox` est requis pour le développement X++ |
| `-Template` | `D365_FinOps_Finance` | Modèle applicatif déployé |
| `-BaseLanguage` | `1033` | **Irréversible.** `1033` pour l'anglais, `1036` pour le français |
| `-Currency` | `USD` | **Irréversible.** Devise de base de la comptabilité |
| `-DevTools` | `$true` | Transmet `DevToolsEnabled=true`. **Ne le passez à `$false` sous aucun prétexte** pour un environnement de développement |
| `-DemoData` | `$true` | Transmet `DemoDataEnabled=true`, qui déploie le jeu de données Contoso |

**Modes d'exécution.**

| Commutateur | Effet |
| :-- | :-- |
| `-ListMacroRegions` | Envoie une sonde de validation volontairement invalide, et affiche la liste des macro régions acceptées par le service. Ne crée rien |
| `-DryRun` | Affiche le corps de requête qui serait envoyé, sans rien créer |
| `-UsePowerAppsSession` | Réutilise une session Power Apps déjà ouverte, au lieu de passer par `Az.Accounts` |
| `-UseDeviceCode` | Force le flux d'authentification par code d'appareil, utile lorsque le navigateur ou le courtier Windows est indisponible |
| `-AccessToken` | Utilise un jeton fourni à la main |

### 13.4 Séquence d'utilisation recommandée

**Étape 1.** Ouvrez une **nouvelle** fenêtre Windows PowerShell 5.1. Une fenêtre ayant déjà servi peut porter des réglages résiduels.

**Étape 2.** Énumérez les macro régions valides pour votre locataire :

```powershell
.\New-ArcFnoDevEnvironment.ps1 -ListMacroRegions
```

**Étape 3.** Vérifiez le corps de requête sans rien créer, en substituant vos propres valeurs :

```powershell
.\New-ArcFnoDevEnvironment.ps1 `
    -DisplayName 'ARCFODEV09' `
    -DomainName  'arcfodev09' `
    -MacroRegion 'europe' `
    -BaseLanguage 1036 `
    -Currency 'EUR' `
    -DryRun
```

**Étape 4.** Contrôlez dans la sortie que la chaîne suivante figure bien dans le corps de requête :

```
"parameters": "DevToolsEnabled=true|DemoDataEnabled=true"
```

**Point de vigilance.** Cette vérification est le cœur de l'annexe. Si cette chaîne est absente ou incomplète, n'exécutez pas la création : vous obtiendriez un environnement inutilisable pour le développement, et il faudrait tout recommencer.

**Étape 5.** Lancez la création réelle, en retirant `-DryRun`. Le script affiche un récapitulatif, signale les valeurs irréversibles et demande confirmation.

**Étape 6.** Le script suit l'opération jusqu'à son état final. L'acceptation de la requête ne signifie pas que l'environnement est prêt : **l'application Finance and Operations continue de se déployer une à trois heures en arrière-plan**. Suivez cette seconde phase dans le Power Platform Admin Center, sous `Resources` (Ressources) > `Dynamics 365 apps` (Applications Dynamics 365).

### 13.5 Points d'attention

| Point | Conséquence |
| :-- | :-- |
| `-BaseLanguage` et `-Currency` | Non modifiables après création. Une erreur impose de recréer l'environnement |
| `-DomainName` | Unique à l'échelle mondiale. Un nom déjà pris produit un rejet. Limitez-vous à 19 caractères |
| `-MacroRegion` et `-Location` | Mutuellement exclusifs. Le script gère cette exclusivité automatiquement |
| Authentification multifacteur | Si la connexion échoue, utilisez `-UseDeviceCode` ou fournissez un jeton avec `-AccessToken` |
| `Security defaults` actifs sur le tenant | Ces paramètres **bloquent le flux par code d'appareil**. Le repli `-UseDeviceCode` peut donc être refusé. Passez alors par `Connect-AzAccount -AuthScope "https://api.bap.microsoft.com/"` avant l'exécution, ou par `-AccessToken`. Voir l'avertissement de la section 3.6 |
| Capacité insuffisante | La création d'un environnement `Sandbox` est refusée. Rattachez une Subscription Azure par un plan de facturation à l'usage |

### 13.6 Le script

Le fichier est fourni séparément sous le nom `New-ArcFnoDevEnvironment.ps1`. Son contenu est reproduit ci-dessous.

```powershell
<#
  New-ArcFnoDevEnvironment.ps1
  Environnement de developpement unifie (UDE) Dynamics 365 Finance and Operations
  Creation via appel direct de l'API BAP, avec propriete "macroRegion".

  Serie Dynamics en 365 - ARCHIA365 / ARCHIALEARN - contact@archia365.fr

  Toutes les valeurs de configuration sont exposees en parametres : le script
  s'utilise sans etre modifie. Les valeurs par defaut correspondent a un
  environnement de formation.
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  Pourquoi REST et pas PowerShell : le module Microsoft.PowerApps.Administration
  .PowerShell est fige en 2.0.217 (30/03/2026), anterieur au deploiement mondial
  du provisionnement par macro region. Il n'expose aucun parametre -MacroRegion
  et ne peut donc pas satisfaire l'API -> 400 MacroRegionRequired.

  Configuration retenue, copiee de l'environnement test-th (fonctionnel) :
    location = canada | macroRegion = the-americas | azureRegion = canadacentral

  USAGE
    1) .\New-ArcFnoDevEnvironment.ps1 -ListMacroRegions
         enumere les valeurs de macro region valides pour ce tenant
    2) .\New-ArcFnoDevEnvironment.ps1 -DisplayName 'ARCFODEV09' -DomainName 'arcfodev09' -DryRun
         affiche le JSON qui serait envoye, sans rien creer
    3) .\New-ArcFnoDevEnvironment.ps1 -DisplayName 'ARCFODEV09' -DomainName 'arcfodev09'
         creation reelle, apres confirmation interactive

  SI L'AUTHENTIFICATION AZ ECHOUE (MFA / acces conditionnel) :
    Connect-AzAccount -AuthScope "https://api.bap.microsoft.com/"
    ... ou contourner Az completement :
    .\New-ArcFnoDevEnvironment.ps1 -UsePowerAppsSession -ListMacroRegions
    .\New-ArcFnoDevEnvironment.ps1 -AccessToken "eyJ0..." -ListMacroRegions

  SI WAM ECHOUE ("A window handle must be configured") :
    le script desactive le broker et bascule seul en device code ;
    forcer explicitement avec -UseDeviceCode.

  A executer dans une NOUVELLE fenetre PowerShell 5.1 (la precedente porte
  encore un Set-StrictMode residuel).
#>

[CmdletBinding()]
param(
    # --- Identite de l'environnement ---
    [string]$DisplayName = 'ARCFODEV09',
    # Nom de domaine, unique a l'echelle mondiale, en minuscules.
    # 19 caracteres au maximum : au-dela, la Provisioning App echoue.
    [string]$DomainName = 'arcfodev09',

    # --- Localisation ---
    [string]$MacroRegion = 'the-americas',
    [string]$Location = 'canada',
    [string]$AzureRegion = 'canadacentral',

    # --- Nature de l'environnement ---
    [ValidateSet('Sandbox', 'Trial', 'Production')]
    [string]$Sku = 'Sandbox',
    [string]$Template = 'D365_FinOps_Finance',

    # --- Parametres IRREVERSIBLES apres creation ---
    [int]$BaseLanguage = 1033,
    [string]$Currency = 'USD',

    # --- Options de provisionnement de l'application F&O ---
    # DevToolsEnabled conditionne toute la chaine de developpement X++.
    [bool]$DevTools = $true,
    [bool]$DemoData = $true,

    # --- Modes d'execution ---
    [switch]$ListMacroRegions,
    [switch]$DryRun,
    [switch]$UsePowerAppsSession,
    [switch]$UseDeviceCode,
    [string]$AccessToken
)

$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# --- Constantes techniques ----------------------------------------------------
# Toute la configuration fonctionnelle est desormais portee par le bloc param().
#
# /!\ macroRegion et location sont EXCLUSIFS ("AmbiguousLocationSpecification").
#     Tant que -MacroRegion est renseigne, -Location n'est PAS envoye : la
#     plateforme choisit le datacenter dans la macro region, guidee par le hint
#     -AzureRegion, transmis comme properties.azureRegionHint.
#
# /!\ IRREVERSIBLE apres creation : -BaseLanguage (1033 anglais, 1036 francais)
#     et -Currency. Ces deux valeurs ne peuvent plus etre modifiees ensuite.
#
# /!\ -DevTools controle le parametre DevToolsEnabled transmis a la Provisioning
#     App. A false, l'environnement ne pourra jamais accueillir de developpement
#     X++ : ni connexion Visual Studio, ni deploiement de modele, ni acces SQL.
#     Cette option n'est pas modifiable apres coup ; il faut recreer.

$ApiVersion = '2021-04-01'
$BapRoot = 'https://api.bap.microsoft.com'
$Resource = 'https://api.bap.microsoft.com/'

# --- Jeton d'acces ------------------------------------------------------------
# Trois sources possibles, par ordre de preference :
#   1. -AccessToken '...'      : jeton colle a la main (F12 dans le PPAC)
#   2. -UsePowerAppsSession    : reutilise la session Add-PowerAppsAccount
#   3. defaut                  : Az.Accounts, avec -AuthScope si MFA/acces conditionnel

function ConvertTo-PlainToken {
    param($Value)
    if ($Value -is [System.Security.SecureString]) {
        return [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Value))
    }
    return [string]$Value
}

function Get-TokenFromAz {
    param([string]$ResourceUrl)

    if (-not (Get-Module -ListAvailable -Name Az.Accounts)) {
        Write-Host 'Installation de Az.Accounts...' -ForegroundColor Yellow
        Install-Module -Name Az.Accounts -Scope CurrentUser -Force -AllowClobber
    }
    Import-Module Az.Accounts -ErrorAction Stop

    # -AsPlainText n'existe qu'a partir d'Az.Accounts 2.17 : on teste, on ne devine pas.
    $supportsPlain = (Get-Command Get-AzAccessToken).Parameters.ContainsKey('AsPlainText')

    $fetch = {
        if ($supportsPlain) { Get-AzAccessToken -ResourceUrl $ResourceUrl -AsPlainText }
        else { ConvertTo-PlainToken ((Get-AzAccessToken -ResourceUrl $ResourceUrl).Token) }
    }

    # WAM (broker Windows) exige un handle de fenetre, indisponible dans une
    # console PowerShell 5.1 -> on le desactive pour ce processus.
    try {
        Update-AzConfig -EnableLoginByWam $false -Scope Process -WarningAction SilentlyContinue | Out-Null
    }
    catch {
        Write-Verbose 'Update-AzConfig -EnableLoginByWam indisponible sur cette version d Az.Accounts.'
    }

    function Invoke-AzLogin {
        param([string]$Scope, [switch]$DeviceCode)
        if ($DeviceCode) {
            Connect-AzAccount -AuthScope $Scope -UseDeviceAuthentication | Out-Null
        }
        else {
            try {
                Connect-AzAccount -AuthScope $Scope | Out-Null
            }
            catch {
                # 'A window handle must be configured' = WAM sans fenetre parente.
                if ($_.Exception.Message -match 'window handle|WAM|broker|InteractiveBrowserCredential') {
                    Write-Warning 'Navigateur/broker indisponible, bascule sur le flux device code.'
                    Connect-AzAccount -AuthScope $Scope -UseDeviceAuthentication | Out-Null
                }
                else { throw }
            }
        }
    }

    # Un contexte peut exister tout en pointant vers un cache vide (echec de
    # connexion precedent) : on verifie qu'un compte y est reellement associe.
    $ctx = Get-AzContext
    if (-not $ctx -or -not $ctx.Account) {
        Write-Warning 'Contexte Az absent ou invalide, nettoyage puis reconnexion.'
        Disconnect-AzAccount -ErrorAction SilentlyContinue | Out-Null
        Clear-AzContext -Force -ErrorAction SilentlyContinue | Out-Null
        Invoke-AzLogin -Scope $ResourceUrl -DeviceCode:$UseDeviceCode
    }

    try {
        return & $fetch
    }
    catch {
        # Cas classique : MFA / acces conditionnel -> il faut un consentement
        # interactif pour CETTE audience precise.
        $m = $_.Exception.Message
        $needsLogin = $m -match 'User interaction is required|interactive|conditional access|multi-factor' `
            -or $m -match 'CredentialUnavailable|SharedTokenCache|No accounts were found|not found in the cache'
        if ($needsLogin) {
            Write-Warning "Jeton indisponible pour $ResourceUrl - nettoyage du cache et reconnexion."
            Disconnect-AzAccount -ErrorAction SilentlyContinue | Out-Null
            Clear-AzContext -Force -ErrorAction SilentlyContinue | Out-Null
            Invoke-AzLogin -Scope $ResourceUrl -DeviceCode:$UseDeviceCode
            return & $fetch
        }
        throw   # toute autre erreur remonte telle quelle, sans masquage
    }
}

function Get-TokenFromPowerAppsSession {
    Import-Module Microsoft.PowerApps.Administration.PowerShell -ErrorAction Stop -WarningAction SilentlyContinue
    if (-not $global:currentSession -or -not $global:currentSession.loggedIn) {
        Add-PowerAppsAccount -Endpoint prod | Out-Null
    }
    $tokens = $global:currentSession.resourceTokens
    if (-not $tokens) { throw 'Session PowerApps sans resourceTokens. Utilise -AccessToken.' }

    Write-Host 'Audiences disponibles dans la session PowerApps :' -ForegroundColor Cyan
    $tokens.Keys | ForEach-Object { Write-Host "  $_" }

    $key = $tokens.Keys | Where-Object { $_ -match 'bap' } | Select-Object -First 1
    if (-not $key) { $key = $tokens.Keys | Where-Object { $_ -match 'powerapps' } | Select-Object -First 1 }
    if (-not $key) { throw 'Aucune audience BAP exploitable. Utilise -AccessToken.' }

    Write-Host "Audience retenue : $key" -ForegroundColor Green
    return ConvertTo-PlainToken $tokens[$key].accessToken
}

if ($AccessToken) {
    $token = $AccessToken -replace '^Bearer\s+', ''
    Write-Host 'Jeton fourni manuellement.' -ForegroundColor Green
}
elseif ($UsePowerAppsSession) {
    $token = Get-TokenFromPowerAppsSession
}
else {
    $token = Get-TokenFromAz -ResourceUrl $Resource
}

$headers = @{ Authorization = "Bearer $token"; 'Content-Type' = 'application/json' }

# --- Construction du payload --------------------------------------------------
# Ce que le service nous a appris, erreur apres erreur :
#   * objet racine      = EnvironmentDefinition -> accepte macroRegion
#   * objet imbrique    = EnvironmentProperties -> refuse macroRegion
#   * 'azureRegion' n'existe sur aucun des deux ; le nom reel est
#     vraisemblablement 'azureRegionHint', dans properties.
#
# On ne devine plus : chaque champ optionnel dispose d'une liste de candidats
# (emplacement + nom), essayes dans l'ordre jusqu'a acceptation, avec abandon
# propre du champ si aucun ne passe. macroRegion, lui, est obligatoire.

# Champs neutralises en cours de route par les regles d'exclusivite du service.
$Suppressed = New-Object System.Collections.Generic.HashSet[string]

$Fields = [ordered]@{
    macroRegion = @{
        value      = $MacroRegion
        candidates = @(
            @{ path = 'root'; name = 'macroRegion' },
            @{ path = 'properties'; name = 'macroRegion' }
        )
        index      = 0
    }
    azureRegion = @{
        value      = $AzureRegion
        candidates = @(
            @{ path = 'properties'; name = 'azureRegionHint' },
            @{ path = 'root'; name = 'azureRegionHint' },
            @{ path = 'properties'; name = 'azureRegion' },
            @{ path = 'omit'; name = 'azureRegion' }
        )
        index      = 0
    }
}

function New-EnvironmentBody {
    param([string]$MacroOverride)

    $parameters = @()
    if ($DevTools) { $parameters += 'DevToolsEnabled=true' }
    if ($DemoData) { $parameters += 'DemoDataEnabled=true' }

    $props = [ordered]@{
        displayName    = $DisplayName
        environmentSku = $Sku
        databaseType   = 'CommonDataService'
    }
    $root = [ordered]@{}

    # Exclusivite : location n'est envoye QUE si aucune macro region n'est definie.
    $macroActive = -not [string]::IsNullOrWhiteSpace($MacroRegion) -or -not [string]::IsNullOrWhiteSpace($MacroOverride)
    if (-not $macroActive -and -not $Suppressed.Contains('location') -and $Location) {
        $root['location'] = $Location
    }

    foreach ($key in @($Fields.Keys)) {
        $f = $Fields[$key]
        $val = if ($key -eq 'macroRegion' -and $MacroOverride) { $MacroOverride } else { $f.value }
        if ([string]::IsNullOrWhiteSpace($val)) { continue }

        $c = $f.candidates[$f.index]
        if ($Suppressed.Contains($c.name)) { continue }
        switch ($c.path) {
            'root' { $root[$c.name] = $val }
            'properties' { $props[$c.name] = $val }
            'omit' { }
        }
    }

    $props['linkedEnvironmentMetadata'] = [ordered]@{
        baseLanguage     = $BaseLanguage
        currency         = @{ code = $Currency }
        domainName       = $DomainName
        templates        = @($Template)
        templateMetadata = @{
            PostProvisioningPackages = @(
                [ordered]@{
                    applicationUniqueName = 'msdyn_FinanceAndOperationsProvisioningAppAnchor'
                    parameters            = ($parameters -join '|')
                }
            )
        }
    }

    $root['properties'] = $props
    return ($root | ConvertTo-Json -Depth 12)
}

# PowerShell 5.1 consomme lui-meme le flux de reponse pour composer son message
# d'erreur : le corps JSON se lit dans ErrorDetails, pas dans GetResponseStream().
function Read-ErrorBody {
    param($ErrorRecord)

    if ($ErrorRecord.ErrorDetails -and $ErrorRecord.ErrorDetails.Message) {
        return $ErrorRecord.ErrorDetails.Message
    }
    try {
        $stream = $ErrorRecord.Exception.Response.GetResponseStream()
        if ($stream -and $stream.CanRead) {
            $stream.Position = 0
            return (New-Object IO.StreamReader($stream)).ReadToEnd()
        }
    }
    catch { }
    return $ErrorRecord.Exception.Message
}

# Fait avancer le champ portant ce nom vers son candidat suivant.
# Retourne $true si une nouvelle tentative est possible.
function Step-Field {
    param([string]$MemberName)

    foreach ($key in @($Fields.Keys)) {
        $f = $Fields[$key]
        if ($f.candidates[$f.index].name -ne $MemberName) { continue }

        if ($f.index -ge $f.candidates.Count - 1) {
            Write-Warning "'$MemberName' : plus aucun candidat disponible."
            return $false
        }
        $f.index++
        $next = $f.candidates[$f.index]
        if ($next.path -eq 'omit') {
            Write-Warning "'$MemberName' refuse partout : le champ est retire du payload."
        }
        else {
            Write-Warning "'$MemberName' refuse -> nouvel essai en '$($next.path).$($next.name)'."
        }
        return $true
    }
    return $false
}

$uri = "$BapRoot/providers/Microsoft.BusinessAppPlatform/environments?api-version=$ApiVersion"

# --- Mode 1 : enumeration des macro regions valides ---------------------------
if ($ListMacroRegions) {
    Write-Host 'Sonde de validation (aucun environnement ne sera cree)...' -ForegroundColor Cyan
    try {
        Invoke-RestMethod -Method Post -Uri $uri -Headers $headers `
            -Body (New-EnvironmentBody -MacroOverride 'zzz-invalide') | Out-Null
        Write-Warning "Aucune erreur retournee - la sonde n'a pas fonctionne."
    }
    catch {
        Write-Host '--- Reponse du service ---' -ForegroundColor Yellow
        Write-Host (Read-ErrorBody $_)
    }
    return
}

# --- Mode 2 : creation --------------------------------------------------------
if ([string]::IsNullOrWhiteSpace($MacroRegion)) { throw 'Renseigne $MacroRegion.' }

Write-Host '--- Payload initial ---' -ForegroundColor Cyan
Write-Host (New-EnvironmentBody)

if ($DryRun) { Write-Host 'DryRun : rien envoye.' -ForegroundColor Yellow; return }

Write-Host ''
Write-Host '=== Recapitulatif (les 3 premieres lignes sont DEFINITIVES) ===' -ForegroundColor Yellow
Write-Host "  Macro region : $MacroRegion"
Write-Host "  Region       : $Location / $AzureRegion"
Write-Host "  Devise       : $Currency"
Write-Host "  Nom          : $DisplayName  ($DomainName)"
Write-Host "  Langue       : $BaseLanguage"
Write-Host "  Template     : $Template"
Write-Host ''
if ((Read-Host 'Lancer la creation ? (o/N)') -notin @('o', 'O', 'y', 'Y')) { return }

$response = $null
$json = $null

for ($attempt = 1; $attempt -le 8; $attempt++) {

    $json = New-EnvironmentBody

    try {
        $response = Invoke-WebRequest -Method Post -Uri $uri -Headers $headers `
            -Body $json -UseBasicParsing
        break
    }
    catch {
        $detail = Read-ErrorBody $_

        if ($detail -match "Could not find member '([^']+)' on object of type '([^']+)'") {
            $member = $matches[1]
            Write-Host "[tentative $attempt] $member rejete par $($matches[2])" -ForegroundColor DarkYellow
            if (Step-Field -MemberName $member) { continue }
        }

        # Exclusivite mutuelle : "Cannot specify both X and Y".
        # macroRegion est le mode de provisionnement retenu : on garde macroRegion
        # et on neutralise l'autre champ.
        if ($detail -match 'Cannot specify both (\w+) and (\w+)') {
            $a = $matches[1]; $b = $matches[2]
            $victim = if ($a -eq 'macroRegion') { $b } else { $a }
            if (-not $Suppressed.Contains($victim)) {
                Write-Warning "[tentative $attempt] '$a' et '$b' sont exclusifs -> '$victim' retire du payload."
                [void]$Suppressed.Add($victim)
                continue
            }
        }

        Write-Host '--- Erreur ---' -ForegroundColor Red
        Write-Host $detail
        Write-Host '--- Payload envoye ---' -ForegroundColor DarkGray
        Write-Host $json
        throw "Creation refusee par le service (voir ci-dessus)."
    }
}

if (-not $response) { throw 'Aucune forme de payload acceptee apres 8 tentatives.' }

Write-Host ''
Write-Host "HTTP $($response.StatusCode) - requete acceptee" -ForegroundColor Green
Write-Host '--- Payload accepte ---' -ForegroundColor DarkGray
Write-Host $json

$opUri = $response.Headers['Location']
if (-not $opUri) { $opUri = $response.Headers['Operation-Location'] }

# --- Suivi --------------------------------------------------------------------
if (-not $opUri) {
    Write-Warning "Pas d'URL de suivi retournee ; verifie l'etat dans le PPAC."
    return
}

Write-Host "Suivi : $opUri"
$state = ''
do {
    Start-Sleep -Seconds 60
    try {
        $op = Invoke-RestMethod -Method Get -Uri $opUri -Headers $headers
        $state = $op.properties.provisioningState
    }
    catch {
        Write-Warning "Lecture de l'etat impossible : $($_.Exception.Message)"
        break
    }
    Write-Host ("[{0:HH:mm}] Etat : {1}" -f (Get-Date), $state)
} while ($state -notin @('Succeeded', 'Failed'))

Write-Host "Etat final : $state" -ForegroundColor $(if ($state -eq 'Succeeded') { 'Green' } else { 'Red' })
Write-Host "L'application F&O continue de se deployer 1 a 3 h en arriere-plan."
Write-Host "Suis la progression dans le PPAC : Ressources > Applications Dynamics 365."
```

### 13.7 Checklist de l'annexe

- [ ] Le script est exécuté depuis une fenêtre Windows PowerShell 5.1 neuve.
- [ ] Les macro régions valides ont été énumérées avec `-ListMacroRegions`.
- [ ] Le nom de domaine est unique, en minuscules, et ne dépasse pas 19 caractères.
- [ ] La langue et la devise ont été choisies en connaissance de leur caractère irréversible.
- [ ] Un `-DryRun` a été exécuté et inspecté.
- [ ] **La chaîne `DevToolsEnabled=true` est présente dans le corps de requête.**
- [ ] La création a été confirmée après lecture du récapitulatif.
- [ ] Le suivi de l'installation de l'application a été poursuivi dans le Power Platform Admin Center.

## 14. Annexe E : Références officielles

- [Unified developer experience for finance and operations apps, Microsoft Learn](https://learn.microsoft.com/en-us/power-platform/developer/unified-experience/finance-operations-dev-overview)
- [Create a solution in Power Apps, Microsoft Learn](https://learn.microsoft.com/en-us/power-apps/maker/data-platform/create-solution)
- [Configure Security Defaults for Microsoft Entra ID, Microsoft Learn](https://learn.microsoft.com/en-us/entra/fundamentals/security-defaults)
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

### 15.3 Documents liés de la même série

| Document | Objet |
| :-- | :-- |
| *Mise en place d'un environnement de développement complet Dynamics 365 Finance and Operations sur un nouveau tenant* | Création du tenant, licences, Subscription Azure, capacité, environnement Sandbox, poste local, dépôt et chaîne CI/CD |
| *Du poste de développement au premier composant X++ livré* | Le présent document, centré sur l'outillage du développeur et la construction d'un composant |
| `New-ArcFnoDevEnvironment.ps1` | Script de provisionnement d'un environnement `Sandbox` avec `DevToolsEnabled=true`, documenté en annexe D |

### 15.4 Méthode d'élaboration

Ce document a été rédigé à l'issue de mises en place complètes menées de bout en bout. Les avertissements et les tableaux de dépannage correspondent à des difficultés réellement rencontrées.

Contenu vérifié au regard de la documentation Microsoft en vigueur au 25 août 2026. Les interfaces Microsoft évoluant fréquemment, certains libellés peuvent différer légèrement de ceux constatés à l'écran. La transition de Visual Studio 2022 vers Visual Studio 2026 étant en cours au moment de la rédaction, vérifiez la page de prérequis des outils de développement citée en annexe D si vous constatez un écart.

### 15.5 Vos retours

Cette procédure est vivante. Si vous rencontrez un point de blocage, si un libellé a changé, si une étape ne se déroule pas comme décrit, ou si vous souhaitez proposer une amélioration, écrivez-nous à **contact@archia365.fr**.

Pour que votre retour soit exploitable, précisez si possible :

- la **phase** et la **section** concernées, par exemple 5.6 ;
- le **message d'erreur exact**, copié tel quel ;
- la **version de plateforme** de votre environnement et celle de Visual Studio ;
- votre **rôle** au moment de l'action.

Chaque retour est étudié et alimente directement la version suivante de ce document.
