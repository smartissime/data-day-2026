# Démo D02 : LCS et Power Platform admin center : le pilotage ALM

**Formation :** Dynamics 365 F&O, du On-Premises au Cloud (ARCHIA365)
**Demi-journée :** DJ1, Slot 2 (mardi 25/08, matin)
**Durée :** 20 minutes
**Alignement MB-500 :** Implement application lifecycle management : Manage environments by using Lifecycle Services tools ; Issue Search ; asset libraries ; UDE ; Implementation portal

---

## 1. Objectif

1. Naviguer dans un projet LCS : tableau de bord, environnements, Asset Library.
2. Utiliser Issue Search pour rechercher une anomalie plateforme connue.
3. Découvrir la nouvelle génération d'administration : environnements dans le Power Platform admin center (PPAC) et Implementation portal.
4. Comprendre où vivent les deployable packages.

## 2. Prérequis

| Élément | Détail |
|---|---|
| LCS | Un projet LCS accessible (idéalement) : `https://lcs.dynamics.com` |
| PPAC | Accès admin au tenant de démonstration : `https://admin.powerplatform.microsoft.com` |
| Secours | Si aucun projet LCS n'est accessible depuis le tenant d'essai, utiliser les sections marquées **[Capture]** : chaque écran clé est décrit pour être présenté sur diapositive ou en image |

> **Note formateur :** sur un tenant d'essai pur, il n'existe pas toujours de projet LCS d'implémentation. La démo est conçue pour être réalisable au minimum à 60 % en direct (Issue Search + PPAC) ; le reste bascule en captures commentées sans perte pédagogique.

## 3. Pas à pas

### Étape 1 : Le projet LCS (5 min) [Capture si indisponible]

1. Ouvrir `https://lcs.dynamics.com` et se connecter.
2. Ouvrir le projet de démonstration : observer le tableau de bord : nom du projet, méthodologie, tuiles d'outils.
3. Ouvrir la tuile **Environnements** (ou le menu hamburger > Environments) : chaque environnement montre son type (sandbox, production), sa version, son état.
4. **Point de contrôle :** distinguer sur l'écran un environnement sandbox d'une production, et repérer le numéro de version de chacun.

> **Parallèle on-prem :** ce tableau de bord remplace votre classeur Excel « liste des serveurs AX » et les scripts d'inventaire : l'état du paysage est visible en un point, partagé avec Microsoft.

### Étape 2 : Asset Library (4 min) [Capture si indisponible]

1. Depuis le projet, ouvrir **Asset library** (icône de bibliothèque).
2. Parcourir les catégories : **Software deployable package**, **Database backup**, **Data package**, etc.
3. Expliquer le cycle : le pipeline de build dépose ici le package ; le déploiement en sandbox/production consomme ce même actif.
4. **Point de contrôle :** chacun sait dans quelle catégorie chercher un package de code prêt à déployer.

### Étape 3 : Issue Search en direct (5 min)

1. Dans LCS (accessible même sans projet d'implémentation complet, via un projet d'essai), ouvrir **Issue search**.
2. Rechercher un terme fonctionnel, par exemple : `sales order confirmation posting error`.
3. Lire un résultat : statut de l'anomalie (corrigée, planifiée, contournement), version de correction, KB associée.
4. Refaire une recherche avec un objet technique (ex. `SalesFormLetter`) pour montrer la recherche par artefact.
5. **Point de contrôle :** chacun a lancé une recherche et sait lire le statut d'un résultat.

> **Parallèle on-prem :** ce geste remplace des heures de forum, de décompilation et de tickets : le réflexe professionnel Cloud est « Issue Search d'abord, ticket ensuite ».

### Étape 4 : PPAC : les environnements nouvelle génération (5 min)

1. Ouvrir `https://admin.powerplatform.microsoft.com` > **Environnements**.
2. Ouvrir l'environnement de démonstration : lire la page de détail : type, région, état, URL de l'environnement, applications Dynamics 365 installées.
3. Montrer le bouton/section **Ressources > Applications Dynamics 365** : c'est ici que la pile F&O + Dataverse se gère désormais.
4. Évoquer la création d'un environnement de développement UDE : **+ Nouveau** > type d'environnement avec ERP : ne pas créer réellement (durée/licences), décrire le formulaire.
5. **Point de contrôle :** chacun sait où trouver l'URL et l'état d'un environnement dans PPAC.

### Étape 5 : Implementation portal (1 min) [Capture]

1. Mentionner `https://experience.dynamics.com/implementationportal` (ou l'entrée depuis PPAC selon tenant) : le portail qui guide les nouvelles implémentations (projets, environnements, télémétrie).
2. Message : LCS reste la référence des projets existants ; les nouveaux projets basculent progressivement vers PPAC + Implementation portal.

## 4. Récapitulatif des acquis

- LCS : projet, environnements, Asset Library (le magasin des livrables), Issue Search (le réflexe support).
- PPAC : le point d'administration unifié où convergent F&O et Power Platform : gestion des environnements, dont les environnements de développement UDE.
- La transition LCS vers PPAC est engagée : connaître les deux est la compétence 2026.

## 5. Dépannage

| Problème | Solution |
|---|---|
| Aucun projet LCS visible | Utiliser les captures du support ; l'essentiel (Issue Search, PPAC) reste réalisable |
| Issue Search vide | Reformuler en anglais ; élargir les mots-clés |
| PPAC sans droits | Se connecter avec le compte administrateur du tenant de démonstration |
| L'environnement F&O n'apparaît pas dans PPAC | Selon le type de provisioning du tenant d'essai, l'environnement peut être géré différemment : montrer alors la liste des environnements Dataverse et expliquer la convergence |
