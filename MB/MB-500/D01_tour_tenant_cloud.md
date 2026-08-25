# Démo D01 : Tour du tenant Cloud, applications et DemoHub

**Formation :** Dynamics 365 F&O, du On-Premises au Cloud (ARCHIA365)
**Demi-journée :** DJ1, Slot 1 (mardi 25/08, matin)
**Durée :** 20 minutes
**Alignement MB-500 :** Plan the architecture and solution design : Differentiate between the cloud and on-premises versions of finance and operations apps

---

## 1. Objectif

À la fin de cette démo, chaque participant sait :

1. Se connecter au tenant de démonstration et se repérer dans le lanceur d'applications.
2. Ouvrir l'application Finance and Operations (DemoHub All-in-One) et naviguer dans le client web moderne.
3. Retrouver ses repères AX : modules, sociétés, espaces de travail.
4. Localiser les informations de version (One Version en action) et Feature management.
5. Ouvrir le Power Platform admin center (préparation du Slot 2).

## 2. Prérequis

| Élément | Détail |
|---|---|
| Compte | Un compte utilisateur du tenant de démonstration ARCHIA365 (licences d'essai actives) |
| Applications | Finance and Operations DemoHub All-in-One, Finance, Supply Chain Management |
| Navigateur | Edge ou Chrome, session InPrivate recommandée pour éviter les conflits de comptes |
| Réseau | Accès à https://www.office.com et *.dynamics.com |

> **Note formateur :** vérifiez la veille que les licences d'essai du tenant ne sont pas expirées et que le DemoHub s'ouvre correctement.

## 3. Pas à pas

### Étape 1 : Connexion et lanceur d'applications (3 min)

1. Ouvrir le navigateur en session InPrivate.
2. Aller sur `https://www.office.com` et se connecter avec le compte du tenant de démonstration.
3. Cliquer sur le lanceur d'applications (grille en haut à gauche) puis **Toutes les applications**.
4. **Point de contrôle :** repérer les applications Dynamics 365 disponibles : Finance and Operations DemoHub All-in-One, Finance, Supply Chain Management, et les applications CE (Sales, Customer Service...).

> **Parallèle on-prem :** ce lanceur remplace le raccourci client AX 2012 sur le bureau. Une URL, un compte Entra ID : plus de client lourd à déployer ni de fichier .axc.

### Étape 2 : Ouvrir le DemoHub / Finance and Operations (5 min)

1. Cliquer sur **Finance and Operations DemoHub All-in-One** (ou directement l'application Finance).
2. Attendre le chargement du client web ; noter l'URL de la forme `https://<environnement>.operations.dynamics.com`.
3. Identifier les zones de l'écran :
   - Le **tableau de bord** avec ses tuiles d'espaces de travail.
   - Le **volet de navigation** (hamburger en haut à gauche) : Modules > la liste que vous connaissez (Comptabilité, Clients, Fournisseurs, Gestion des stocks...).
   - Le **sélecteur de société** (en haut à droite) : l'équivalent direct du sélecteur de société AX.
   - La **recherche** (loupe) : recherche de formulaires et de pages par nom.
4. **Point de contrôle :** ouvrir Modules > Clients > Clients : la liste des clients s'affiche : c'est CustTable, votre vieille connaissance.

### Étape 3 : Navigation moderne (5 min)

1. Depuis la liste des clients, cliquer sur un client pour ouvrir la fiche détaillée : observer la structure en onglets (pattern Details Master).
2. Tester le **filtrage** : cliquer sur l'en-tête d'une colonne > filtres.
3. Tester la **personnalisation** utilisateur : clic droit sur un champ > Personnaliser ce formulaire (montrer, sans approfondir).
4. Ouvrir un **espace de travail** (par exemple Gestion du crédit clients ou un workspace visible du tableau de bord) : tuiles, listes, liens : la restitution opérationnelle intégrée.
5. **Point de contrôle :** chaque participant a ouvert la fiche d'un client et appliqué un filtre sur la liste.

### Étape 4 : One Version en évidence (4 min)

1. Cliquer sur la roue dentée (Paramètres) > **À propos de**.
2. Noter le numéro de version de la plateforme et de l'application : expliquer que ce numéro avance automatiquement au rythme des mises à jour One Version.
3. Ouvrir **Administration système > Espaces de travail > Gestion des fonctionnalités** (Feature management).
4. Observer la liste des fonctionnalités livrées, activées ou en attente : c'est ainsi que les nouveautés arrivent en continu.
5. **Point de contrôle :** chacun sait retrouver la version de son environnement.

> **Parallèle on-prem :** en AX, connaître la version = interroger le kernel et la couche applicative (build). Ici, la page À propos donne tout, et Feature management remplace les « hotfix à installer » par des fonctionnalités activables.

### Étape 5 : Aperçu du Power Platform admin center (3 min)

1. Dans un nouvel onglet, ouvrir `https://admin.powerplatform.microsoft.com`.
2. Cliquer sur **Environnements** : observer la liste (l'environnement de démonstration y figure).
3. Ne pas approfondir : annoncer que la démo D02 y revient en détail.
4. **Point de contrôle :** la page s'ouvre et chacun voit la liste des environnements.

## 4. Récapitulatif des acquis

- Le client est 100 % web ; l'authentification est Entra ID ; plus aucun composant client à installer.
- Les concepts métier (sociétés, modules, fiches) sont ceux d'AX : le delta est la plateforme, pas le métier.
- La page À propos et Feature management matérialisent One Version.
- Le Power Platform admin center est le nouveau point d'entrée d'administration.

## 5. Dépannage

| Problème | Solution |
|---|---|
| L'application ne figure pas dans le lanceur | Vérifier l'attribution des licences d'essai à l'utilisateur (admin Microsoft 365) |
| Erreur d'accès à l'environnement F&O | Vérifier que l'utilisateur est bien provisionné dans l'environnement (utilisateurs importés) |
| Page blanche au chargement | Vider le cache / réessayer en InPrivate ; vérifier qu'aucun bloqueur ne filtre *.dynamics.com |
| Tenant d'essai expiré | Prolonger l'essai ou recréer un tenant de démonstration avant la session |
