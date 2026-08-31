# Démo D09 : Le pont F&O / Dataverse en environnement unifié : dual-write et virtual tables

**Formation :** Dynamics 365 F&O, du On-Premises au Cloud (ARCHIA365)
**Séquence :** DJ5, partie 1
**Durée :** 20 minutes
**Alignement MB-500 :** Integrate and manage data solutions : integrate Dataverse using dual-write ; integrate Dataverse using virtual entities
**Environnement :** PPAC, maker portal Power Apps (`make.powerapps.com`), client web F&O de l'environnement unifié.

---

## 1. Objectif

1. Constater, dans PPAC, qu'un environnement unifié est un seul environnement Dataverse + F&O.
2. Explorer les **virtual tables** F&O côté Dataverse et en activer une.
3. Explorer l'espace **dual-write** : table maps, état, historique (si provisionné).
4. Choisir, pour le fil rouge, entre virtual table et dual-write.

## 2. Prérequis et repères d'environnement

| Élément | Détail |
|---|---|
| PPAC | Accès administrateur ; environnement unifié (Sandbox de développement) |
| Maker portal | `https://make.powerapps.com`, environnement sélectionné = l'environnement unifié |
| Client F&O | URL Finance and Operations de l'environnement |
| Dual-write | Peut ne pas être configuré : l'étape 3 bascule alors en captures ; les étapes 1, 2 et 4 sont toujours réalisables |

> **Repère UDE :** en environnement unifié, il n'y a pas de « liaison » à établir entre F&O et Dataverse : ils partagent le même environnement. Les tables virtuelles F&O sont donc disponibles immédiatement dans le maker portal, sans configuration d'application Entra ID.

## 3. Pas à pas

### Étape 1 : Un seul environnement, deux visages (3 min)

1. PPAC > Environnements > ouvrir l'environnement unifié.
2. Lire les deux URLs : Dataverse (…crm.dynamics.com) et Finance and Operations (…operations.dynamics.com).
3. **Ressources > Applications Dynamics 365** : repérer Finance and Operations Platform Tools, Provisioning App, et les applications Dataverse installées.

**Contrôle visuel :**
- Page de détail : les deux URLs côte à côte ; section Finance and Operations (UDE) avec version et état.
- Liste des applications Dynamics 365 : lignes « Dynamics 365 Finance and Operations Platform Tools » et « ... Provisioning App » à l'état Installé.

### Étape 2 : Les virtual tables F&O dans le maker portal (7 min)

1. `make.powerapps.com` > vérifier l'environnement (en haut à droite).
2. **Tables** > filtre « Toutes » > rechercher `mserp`.
3. Ouvrir la table virtuelle `Available Finance and Operations entities` (mserp_financeandoperationsentity) ou, à défaut, une table `mserp_` déjà visible.
4. Pour activer une entité : dans la table des entités disponibles, rechercher `CustCustomerV3Entity` > éditer la ligne > **Visible** = Oui > enregistrer ; patienter quelques minutes.
5. Rouvrir la liste des tables : la table virtuelle du client apparaît ; ouvrir **Données** pour voir les lignes lues en direct depuis F&O.

**Contrôle visuel :**
- Le sélecteur d'environnement affiche le nom de l'environnement unifié.
- La liste des tables montre des lignes préfixées `mserp_` avec le type « Virtuel ».
- Après activation : la table `Customers V3 (mserp)` apparaît ; l'onglet Données affiche les clients Contoso (US-001, US-002...) : ce sont les données F&O lues à la demande, sans copie.
- Si le champ ARC a été exposé dans l'entité (D06), la colonne `mserp_arcdeliverypriority` figure dans la table virtuelle.

> **Parallèle on-prem :** c'est la vue SQL vers la base AX que l'on exposait aux applications tierces, mais contractualisée par l'entité et donc insensible aux changements de schéma physique.

### Étape 3 : L'espace dual-write (5 min) [Captures si non provisionné]

1. Client F&O > **Gestion des données** > tuile **Dual-write** (ou application Dual-write).
2. Observer les **table maps** (Customers V3 : accounts, Vendors V2 : ...), leur état, l'historique d'exécution.
3. Ouvrir le mapping clients : colonnes source / destination, sens, transformations.
4. Montrer où s'ajouterait `ARCDELIVERYPRIORITY` (voir section 6).

**Contrôle visuel :**
- Liste des table maps avec colonnes Nom, État (Running / Not running), Version.
- Détail du mapping : deux colonnes Finance and operations / Dataverse, avec le sens de synchronisation ; onglet Historique d'exécution avec réussites / erreurs.

### Étape 4 : Décision pour le fil rouge (5 min)

1. Énoncer la règle : posséder la donnée des deux côtés = dual-write ; voir la donnée = virtual table.
2. Appliquer : l'app mobile de consultation (D11) a besoin de voir les clients > virtual table suffit.
3. Le participant formule le choix et sa justification en une phrase.

**Contrôle visuel :**
- Au tableau : deux colonnes « Posséder » / « Voir » avec les cas d'usage placés.

## 4. Récapitulatif des acquis

- Environnement unifié = Dataverse + F&O ensemble ; les virtual tables sont disponibles sans liaison à configurer.
- Virtual table : voir sans copier, activation par entité (Visible = Oui).
- Dual-write : copie synchronisée, catalogue de table maps, supervision, extension possible.
- Le choix entre les deux est un choix d'architecture argumentable.

## 5. Dépannage

| Problème | Solution |
|---|---|
| Aucune table `mserp_` | Mauvais environnement sélectionné dans le maker portal ; ou applications F&O non installées sur cet environnement |
| L'entité activée n'apparaît pas | Patienter (génération asynchrone), rafraîchir la liste des tables |
| Erreur de lecture de la table virtuelle | Droits F&O insuffisants pour le compte : la sécurité F&O s'applique à ce canal (point pédagogique) |
| Tuile dual-write absente | Non provisionné : passer en captures ; le principe est le même |

## 6. Pour aller plus loin : étendre le mapping dual-write avec le champ ARC

1. Maker portal > Tables > `Compte` (account) > Colonnes > Nouvelle colonne `arc_deliverypriority` (Choix : Basse / Normale / Haute / Critique).
2. Espace dual-write > mapping `Customers V3 : (accounts)` > arrêter > ajouter la ligne `ARCDELIVERYPRIORITY` > `arc_deliverypriority` (transformation de valeurs) > redémarrer avec synchronisation initiale.
3. Tester dans les deux sens.
