# Démo D01 : Tour du tenant Cloud, applications et environnement unifié

**Formation :** Dynamics 365 F&O, du On-Premises au Cloud (ARCHIA365)
**Séquence :** DJ1, partie 1
**Durée :** 20 minutes
**Alignement MB-500 :** Plan the architecture and solution design : Differentiate between the cloud and on-premises versions ; extend into the Microsoft ecosystem
**Environnement :** Tenant de démonstration (DemoHub All-in-One, Finance, SCM) + Power Platform admin center. Aucun outil de développement requis.

---

## 1. Objectif

À la fin de cette démo, le participant sait :

1. Se connecter au tenant et se repérer dans le lanceur d'applications Microsoft 365.
2. Ouvrir une application finance and operations et naviguer dans le client web moderne.
3. Retrouver ses repères AX : modules, sociétés, fiches, espaces de travail.
4. Lire la version de l'application (One Version) et la gestion des fonctionnalités.
5. Comprendre qu'en expérience unifiée, l'environnement F&O et son environnement Dataverse forment un couple visible dans le Power Platform admin center (PPAC).

## 2. Prérequis et repères d'environnement

| Élément | Détail |
|---|---|
| Compte | Compte utilisateur du tenant ARCHIA365 avec licence d'essai active |
| Navigateur | Edge ou Chrome, fenêtre InPrivate recommandée (évite les conflits de comptes) |
| URLs | `https://www.office.com` ; `https://admin.powerplatform.microsoft.com` |
| Réseau | Accès à *.dynamics.com et *.powerplatform.microsoft.com |

> **Repère UDE :** dans l'expérience unifiée, un environnement finance and operations est un environnement Dataverse sur lequel les applications F&O sont installées. Il n'y a plus d'un côté « l'environnement F&O dans LCS » et de l'autre « l'environnement Dataverse » : c'est un seul objet, administré dans PPAC.

## 3. Pas à pas

### Étape 1 : Connexion et lanceur d'applications (3 min)

1. Ouvrir une fenêtre InPrivate, aller sur `https://www.office.com`, se connecter.
2. Cliquer sur le lanceur d'applications (grille en haut à gauche) > **Toutes les applications**.
3. Repérer les applications Dynamics 365 : Finance and Operations DemoHub All-in-One, Finance, Supply Chain Management, et les applications CE (Sales, Customer Service...).

**Contrôle visuel :**
- Le lanceur affiche les tuiles Dynamics 365 ; la tuile « Finance and Operations » (ou DemoHub) est présente.
- En haut à droite, l'avatar du compte connecté correspond bien au compte du tenant de démonstration.

> **Parallèle on-prem :** ce lanceur remplace le raccourci client AX 2012 et le fichier de configuration .axc. Une URL, un compte Entra ID, aucun client lourd.

### Étape 2 : Ouvrir l'application finance and operations (5 min)

1. Cliquer sur **Finance and Operations DemoHub All-in-One** (ou Finance).
2. Attendre le chargement ; observer l'URL : `https://<nom-environnement>.operations.dynamics.com`.
3. Identifier les zones : tableau de bord et tuiles d'espaces de travail ; volet de navigation (icône hamburger) ; sélecteur de société (en haut à droite) ; recherche de pages (loupe).
4. Ouvrir **Modules > Clients > Clients > Tous les clients**.

**Contrôle visuel :**
- Le tableau de bord affiche des tuiles (espaces de travail) et la société courante (par ex. USMF) en haut à droite.
- Le volet de navigation liste les modules dans l'ordre familier : Comptabilité, Clients, Fournisseurs, Gestion des stocks...
- La liste des clients s'affiche en grille avec les colonnes Compte, Nom, Groupe de clients : c'est CustTable.

### Étape 3 : Navigation moderne (5 min)

1. Cliquer sur un client pour ouvrir la fiche : structure en onglets (pattern Details Master).
2. Sur la liste : cliquer sur l'en-tête d'une colonne > filtrer sur une valeur.
3. Clic droit sur un champ de la fiche > **Personnaliser ce formulaire** (montrer, ne pas approfondir).
4. Ouvrir un espace de travail depuis le tableau de bord (par ex. Gestion du crédit clients).

**Contrôle visuel :**
- La fiche client montre un bandeau d'actions en haut (Nouveau, Supprimer, Options...) et des onglets à gauche (Général, Adresses, Contact...).
- Après le filtre, la grille ne montre que les lignes correspondantes et le filtre actif apparaît sous l'en-tête de colonne.
- L'espace de travail affiche des tuiles chiffrées et des listes : la restitution opérationnelle intégrée.

### Étape 4 : One Version en évidence (4 min)

1. Roue dentée (Paramètres) > **À propos de**.
2. Lire la version de la plateforme et de l'application.
3. **Administration système > Espaces de travail > Gestion des fonctionnalités**.

**Contrôle visuel :**
- La boîte À propos affiche « Version de l'application » (ex. 10.0.xx) et « Version de la plateforme » (Update xx) : noter ces valeurs.
- Gestion des fonctionnalités : une liste avec les colonnes Nom de la fonctionnalité, Module, État, Date d'activation ; des onglets Nouveautés, Pas activé, Toutes.

> **Parallèle on-prem :** en AX, la version se lisait dans le kernel et le build de la couche applicative ; les correctifs s'installaient un par un. Ici, la version avance seule et les nouveautés s'activent par bascule.

### Étape 5 : Le couple environnement F&O / Dataverse dans PPAC (3 min)

1. Nouvel onglet : `https://admin.powerplatform.microsoft.com` > **Gérer > Environnements**.
2. Cliquer sur l'environnement de démonstration.

**Contrôle visuel :**
- La liste montre les environnements avec Type (Sandbox, Trial, Production, Développeur), Région, État.
- La page de détail affiche deux URLs distinctes : l'URL Dataverse (…crm.dynamics.com) et l'URL Finance and Operations (…operations.dynamics.com), preuve du couplage.
- La carte **Ressources** propose « Applications Dynamics 365 », « Solutions », « Flux connectés ».

> Ne pas approfondir : la démo D02 revient sur PPAC en détail.

## 4. Récapitulatif des acquis

- Client 100 % web, authentification Entra ID, aucun composant à installer.
- Concepts métier inchangés : le delta est la plateforme, pas le métier.
- À propos et Gestion des fonctionnalités matérialisent One Version.
- En expérience unifiée, F&O et Dataverse forment un seul environnement administré dans PPAC.

## 5. Dépannage

| Problème | Solution |
|---|---|
| Application absente du lanceur | Vérifier l'attribution des licences à l'utilisateur (centre d'administration Microsoft 365) |
| Erreur d'accès à l'application F&O | L'utilisateur n'est pas provisionné dans l'environnement : l'importer (Administration système > Utilisateurs) |
| Page blanche au chargement | Vider le cache, réessayer en InPrivate, vérifier l'absence de bloqueur sur *.dynamics.com |
| Environnement absent dans PPAC | Vérifier le rôle (Power Platform Admin ou Dynamics 365 Admin ; cache de 12 h après attribution) |
