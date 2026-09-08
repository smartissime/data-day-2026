# Démo D04 : Extension de table et de formulaire : le champ ARC visible à l'écran

**Formation :** Dynamics 365 F&O, du On-Premises au Cloud (ARCHIA365)
**Demi-journée :** DJ2, Slot 2 (mardi 25/08, après-midi)
**Durée :** 20 minutes
**Alignement MB-500 :** Design and develop AOT elements : Create and extend tables ; create and extend forms ; create and use label files

---

## 1. Objectif

Ajouter au client (CustTable) un champ **Priorité de livraison** entièrement par extension :

1. Créer l'énumération `ARCDeliveryPriority` et l'EDT `ARCDeliveryPriorityId`.
2. Étendre la table `CustTable` : champ + field group.
3. Étendre le formulaire `CustTable` : afficher le champ dans l'onglet Général.
4. Builder, synchroniser, vérifier dans le client web, faire le check-in.

## 2. Prérequis

- Tier-1 de développement avec le modèle **ARCDelivery** et le projet créés en D03.
- Société de démonstration USMF avec données Contoso.

## 3. Pas à pas

### Étape 1 : L'énumération (4 min)

1. Dans le projet, **Add > New Item > Data Types > Base Enum**. Nom : `ARCDeliveryPriority`.
2. Dans le concepteur, clic droit sur l'enum > **New Element**, créer 4 valeurs :

| Name | Label (à saisir) | Valeur |
|---|---|---|
| Low | Basse | 0 |
| Normal | Normale | 1 |
| High | Haute | 2 |
| Critical | Critique | 3 |

3. Propriétés de l'enum : **Label** : `Priorité de livraison` ; **Help** : `Priorité de traitement des livraisons du client`.

> **Bonne pratique :** créez dès maintenant un fichier de labels (Add > New Item > Labels And Resources > Label File, ID `ARC`, langue fr) et remplacez les libellés en dur par des labels `@ARC:...`. Le guide utilise les libellés directs pour la lisibilité de la démo ; le fichier de labels est l'exercice de perfectionnement n°1.

### Étape 2 : L'EDT (2 min)

1. **Add > New Item > Data Types > EDT Base Enum**. Nom : `ARCDeliveryPriorityId`.
2. Propriétés : **Enum Type** : `ARCDeliveryPriority` ; **Label** : `Priorité de livraison`.

> **Parallèle on-prem :** geste identique à AX 2012 : enum + EDT typé : votre expertise s'applique telle quelle. La seule différence : ces objets vivent dans VOTRE modèle.

### Étape 3 : L'extension de table (5 min)

1. Dans **Application Explorer** (View > Application Explorer), rechercher `CustTable` (AOT > Data Model > Tables).
2. Clic droit sur `CustTable` > **Create extension**. Un élément `CustTable.ARCDelivery` apparaît dans le projet.
3. Double-cliquer sur l'extension pour l'ouvrir :
   - Déplier **Fields** > clic droit > **New > Enum field**.
   - Nom du champ : `ARCDeliveryPriority` ; propriété **Extended Data Type** : `ARCDeliveryPriorityId` (l'enum type suit automatiquement).
4. Créer le field group : clic droit sur **Field Groups** > **New Field Group** ; nom `ARCDelivery` ; label `Livraison ARC` ; glisser le champ `ARCDeliveryPriority` dedans.

> **Point de contrôle :** dans Application Explorer, CustTable (standard) n'a PAS bougé ; votre projet contient `CustTable.ARCDelivery`. C'est toute la différence avec la couche USR de 2012 : le standard reste intact.

### Étape 4 : L'extension de formulaire (5 min)

1. Application Explorer : rechercher le **formulaire** `CustTable` (AOT > User Interface > Forms).
2. Clic droit > **Create extension** : l'élément `CustTable.ARCDelivery` (form extension) rejoint le projet.
3. Ouvrir l'extension de formulaire dans le concepteur :
   - Déplier le **Design** jusqu'à l'onglet **General** de la fiche client (TabPageDetails > ... ; utiliser la recherche du concepteur avec `General`).
   - Clic droit sur le groupe cible > **New > Group** ; nom `ARCDeliveryGroup` ; propriété **Data Source** : `CustTable`, ou plus simple :
   - Depuis le volet **Data Sources** de l'extension, déplier `CustTable` > Fields, localiser `ARCDeliveryPriority`, et le **glisser-déposer** dans le groupe choisi du design.
4. Vérifier la propriété **Label** du contrôle (héritée de l'EDT : Priorité de livraison).

### Étape 5 : Build, sync, vérification (3 min)

1. Clic droit projet > **Properties** > **Synchronize database on build** : `True` (le modèle de données a changé).
2. **Build** le projet. Attendre la fin (build + DB sync).
3. Ctrl+F5 (ou ouvrir le client web) : **Clients > Tous les clients** > ouvrir une fiche > onglet **Général** : le champ **Priorité de livraison** est là, avec ses 4 valeurs.
4. Choisir `Critique` sur un client de test (par ex. US-004) et **enregistrer**.

> **Point de contrôle :** la valeur persiste après actualisation : le champ est bien en base, créé par la synchronisation.

### Étape 6 : Check-in (1 min)

1. Team Explorer > Pending Changes : enum, EDT, extension de table, extension de formulaire.
2. Commentaire : `D04 : champ ARCDeliveryPriority (enum+EDT+table ext+form ext)`.
3. **Check In**.

## 4. Récapitulatif des acquis

- La chaîne complète d'un champ personnalisé en Cloud : enum > EDT > extension de table > extension de formulaire > build + sync.
- Aucun objet standard modifié : mise à jour One Version sans risque.
- Le glisser-déposer depuis la data source du formulaire fait 90 % du travail d'UI.

## 5. Dépannage

| Problème | Solution |
|---|---|
| Le champ n'apparaît pas dans le client | Vider le cache du navigateur / Ctrl+F5 ; vérifier que le build incluait la form extension ; vérifier l'onglet ciblé |
| Erreur de synchronisation | Fenêtre Output : lire l'erreur ; cas courant : conflit de nom de champ : vérifier le préfixe ARC |
| « Create extension » grisé | L'élément est peut-être déjà étendu dans le projet ; ou le projet n'est pas le projet actif du bon modèle |
| Le label affiche @ARC:xxx | Le fichier de labels n'est pas buildé : rebuilder le projet complet |

## 6. Pour aller plus loin (après la formation)

- Remplacer les libellés en dur par le fichier de labels ARC (fr + en).
- Ajouter le champ à la **liste** des clients (grille) via la même form extension.
- Créer un index sur le champ si des recherches fréquentes par priorité sont prévues (vu en DJ4, performance).
