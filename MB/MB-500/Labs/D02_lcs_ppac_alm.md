# Démo D02 : Piloter les environnements en expérience unifiée (PPAC) et LCS

**Formation :** Dynamics 365 F&O, du On-Premises au Cloud (ARCHIA365)
**Séquence :** DJ1, partie 2
**Durée :** 20 minutes
**Alignement MB-500 :** Implement ALM : manage UDE developer environments in PPAC ; Implementation portal ; LCS (Issue Search, asset libraries, package deployments)
**Environnement :** Power Platform admin center (accès administrateur) ; LCS pour Issue Search ; Implementation portal.

---

## 1. Objectif

1. Lire la page de détail d'un environnement finance and operations unifié dans PPAC : version, état du service, capacité, URLs, applications.
2. Comprendre comment on provisionne un environnement de développement UDE (deux options) et ce que cela remplace côté LCS.
3. Utiliser **Issue Search** (LCS) pour rechercher une anomalie plateforme connue.
4. Situer l'Implementation portal et le nouveau modèle ALM (solutions + pipelines).

## 2. Prérequis et repères d'environnement

| Élément | Détail |
|---|---|
| PPAC | `https://admin.powerplatform.microsoft.com`, rôle Power Platform Admin ou Dynamics 365 Admin |
| LCS | `https://lcs.dynamics.com` : Issue Search est accessible même sans projet d'implémentation complet |
| Implementation portal | `https://experience.dynamics.com/implementationportal` (selon tenant) |
| Capacité | Pour créer un environnement UDE : au moins 1 Go de capacité Operations et Dataverse disponible |

> **Repère UDE, à retenir absolument :** un environnement de type **Trial** ne supporte pas le développement Visual Studio. Pour les démos D03 à D08, il faut un environnement de type **Sandbox** avec l'application « Finance and Operations Provisioning App » installée avec les options **Enable Developer Tools** et **Enable Demo Data** (Contoso). Comptez environ 1 heure par installation : à provisionner la veille.

## 3. Pas à pas

### Étape 1 : La page de détail d'un environnement unifié (5 min)

1. PPAC > **Gérer > Environnements** > cliquer sur l'environnement de démonstration.
2. Parcourir la page de haut en bas.

**Contrôle visuel :**
- Bloc **Détails** : Nom, Type, Région, URL de l'environnement (Dataverse), **URL Finance and Operations**, Date de création, Version.
- Section **Finance and Operations (UDE)** : version de l'application, état du service, utilisation de la capacité base de données, liens de surveillance et diagnostics.
- Carte **Ressources** : Applications Dynamics 365, Solutions, Flux connectés.
- Carte **Accès** : administrateurs d'environnement, rôles de sécurité, accès utilisateurs.
- Barre de commandes en haut : Copier, Sauvegarder + Restaurer, Convertir en production, Supprimer, Paramètres.

> **Parallèle on-prem :** cette page remplace le classeur « inventaire des serveurs AX » et les scripts maison : type, version, capacité et actions d'exploitation en un seul écran, partagé avec Microsoft.

### Étape 2 : Provisionner un environnement de développement UDE : les deux options (5 min, démonstration sans validation finale)

**Option A : nouvel environnement avec modèle ERP**
1. **Gérer > Environnements > Nouveau**.
2. Nom (unique, 20 caractères max), Région, Type **Sandbox**, « Ajouter un magasin de données Dataverse » = Oui > Suivant.
3. « Activer les applications Dynamics 365 » = Oui > modèle **Finance** (ou Supply Chain Management) > Enregistrer.

**Option B : environnement Sandbox existant**
1. Page de l'environnement > **Ressources > Applications Dynamics 365 > Installer une application**.
2. Installer d'abord **Dynamics 365 Finance and Operations Platform Tools**, puis **Dynamics 365 Finance and Operations Provisioning App**.
3. Dans la configuration : cocher **Enable Developer Tools**, cocher **Enable Demo Data**, choisir la version > Installer.

**Contrôle visuel :**
- Option A : le formulaire de création montre la bascule « Activer les applications Dynamics 365 » et la liste déroulante des modèles (Finance, Supply Chain Management, Commerce, Project Operations).
- Option B : la liste « Applications Dynamics 365 » affiche les deux applications avec leur état (Installé / En cours) ; la page de configuration montre les cases Developer Tools et Demo Data.
- Après installation : l'URL Finance and Operations apparaît sur la page de détail (si elle manque, modifier la description de l'environnement pour forcer la synchronisation).

> Ne pas lancer réellement l'installation en session (environ 1 heure). Montrer les écrans et arrêter avant validation.

### Étape 3 : Issue Search dans LCS (5 min)

1. `https://lcs.dynamics.com` > ouvrir un projet (même un projet d'essai) > **Issue search**.
2. Rechercher `sales order confirmation posting error`, puis un objet technique, par ex. `SalesFormLetter`.

**Contrôle visuel :**
- La liste de résultats affiche pour chaque anomalie : titre, statut (Released / Planned / By design...), version de correction, lien KB.
- Un clic sur un résultat ouvre le détail avec les symptômes et le contournement éventuel.

> **Parallèle on-prem :** ce geste remplace des heures de forums et de décompilation. Réflexe Cloud : Issue Search d'abord, ticket ensuite.

### Étape 4 : ALM unifié et Implementation portal (5 min)

1. Sur la page de l'environnement, ouvrir **Ressources > Solutions** : c'est ici que vivront les solutions Dataverse contenant les artefacts Power Platform et, en ALM unifié, les packages X++.
2. Mentionner les **pipelines Power Platform** (dev > test > prod) comme remplaçant progressif du déploiement de packages LCS pour les environnements unifiés.
3. Ouvrir l'Implementation portal : liste des projets d'implémentation et de leurs environnements.

**Contrôle visuel :**
- La page Solutions liste les solutions gérées / non gérées avec Éditeur, Version, Date d'installation.
- L'Implementation portal affiche des projets avec leurs environnements et leur état de santé.

## 4. Récapitulatif des acquis

- En UDE, PPAC est le poste de pilotage : détail d'environnement, provisioning, copie, sauvegarde, conversion.
- Deux façons de créer un environnement de développement : modèle ERP à la création, ou Provisioning App sur un Sandbox existant (Developer Tools + Demo Data).
- Trial = pas de développement Visual Studio ; Sandbox requis.
- Issue Search reste le réflexe support ; LCS demeure pour les projets historiques.
- L'ALM converge vers solutions + pipelines Power Platform.

## 5. Dépannage

| Problème | Solution |
|---|---|
| « You don't have required licenses » | Vérifier licences et rôle admin ; attendre le cache de 12 h après attribution du rôle |
| URL Finance and Operations absente après installation | Modifier le champ Description de l'environnement pour déclencher la synchronisation |
| Nom d'hôte refusé | Le nom d'hôte doit faire 19 caractères maximum avant installation de la Provisioning App |
| Échec de provisioning | Vérifier la capacité (1 Go minimum) ; sinon ticket Microsoft avec nom d'environnement et ID de tenant |
| Aucun projet LCS | Issue Search reste accessible via un projet d'essai ; le reste de LCS n'est pas nécessaire en UDE |
