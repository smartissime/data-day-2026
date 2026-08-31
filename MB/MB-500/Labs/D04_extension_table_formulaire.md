# Démo D04 : Extension de table et de formulaire : le champ ARC visible à l'écran (UDE)

**Formation :** Dynamics 365 F&O, du On-Premises au Cloud (ARCHIA365)
**Séquence :** DJ2, partie 2
**Durée :** 20 minutes
**Alignement MB-500 :** Design and develop AOT elements : create and extend tables ; create and extend forms ; create and use label files
**Environnement :** Visual Studio 2022 (UDE) connecté à l'environnement Sandbox de développement ; modèle ARCDelivery créé en D03.

---

## 1. Objectif

Ajouter au client (CustTable) un champ **Priorité de livraison**, entièrement par extension :

1. Créer l'énumération `ARCDeliveryPriority` et l'EDT `ARCDeliveryPriorityId`.
2. Créer le fichier de labels `ARC` (bonne pratique dès le départ).
3. Étendre la table `CustTable` : champ + field group.
4. Étendre le formulaire `CustTable` : afficher le champ dans l'onglet Général.
5. Builder, **déployer avec synchronisation de base**, vérifier dans le client web, check-in.

## 2. Prérequis et repères d'environnement

| Élément | Détail |
|---|---|
| Visual Studio | Projet `ARCDelivery.FilRouge` ouvert, Model = ARCDelivery |
| Déploiement | Option projet **Deploy changes to online environment** = True, ou menu Deploy models... avec synchronisation |
| Données | Société USMF (Contoso) ; un client de test, par ex. US-004 |

> **Repère UDE :** la synchronisation de la base ne se fait plus sur un SQL local : elle est réalisée côté Cloud lors du déploiement du modèle. Cochez l'option de synchronisation quand le modèle de données change (nouveau champ, nouvelle table).

## 3. Pas à pas

### Étape 1 : Fichier de labels (2 min)

1. Clic droit projet > **Add > New Item > Dynamics 365 Items > Labels And Resources > Label File** : ID `ARC`, langue `fr` (ajouter `en-us` si souhaité).
2. Dans l'éditeur de labels, créer : `DeliveryPriority` = `Priorité de livraison` ; `DeliveryPriorityHelp` = `Priorité de traitement des livraisons du client` ; `Low` = `Basse` ; `Normal` = `Normale` ; `High` = `Haute` ; `Critical` = `Critique` ; `ARCDeliveryGroup` = `Livraison ARC`.

**Contrôle visuel :**
- Solution Explorer : `ARC.fr.label.txt` (et `ARC.en-us.label.txt`).
- L'éditeur de labels affiche une grille Label ID / Text / Description.

### Étape 2 : L'énumération (3 min)

1. **Add > New Item > Data Types > Base Enum** : `ARCDeliveryPriority`.
2. Clic droit sur l'enum > New Element : `Low` (0), `Normal` (1), `High` (2), `Critical` (3), avec les labels `@ARC:Low`... 
3. Propriétés de l'enum : Label `@ARC:DeliveryPriority`, Help `@ARC:DeliveryPriorityHelp`.

**Contrôle visuel :**
- Le concepteur affiche l'enum avec ses quatre éléments et leurs valeurs.
- La fenêtre Properties montre le label résolu (« Priorité de livraison ») sous forme d'info-bulle.

### Étape 3 : L'EDT (2 min)

1. **Add > New Item > Data Types > EDT Base Enum** : `ARCDeliveryPriorityId`.
2. Propriétés : Enum Type `ARCDeliveryPriority`, Label `@ARC:DeliveryPriority`.

**Contrôle visuel :**
- Properties : Enum Type renseigné, Label affiché.

> **Parallèle on-prem :** enum + EDT typé, geste identique à AX 2012. Seule différence : les objets vivent dans votre modèle et vos labels dans votre fichier ARC.

### Étape 4 : L'extension de table (4 min)

1. **Application Explorer** > Data Model > Tables > `CustTable` > clic droit > **Create extension**.
2. Ouvrir `CustTable.ARCDelivery` (l'extension) dans le projet.
3. **Fields** > clic droit > New > **Enum** : nom `ARCDeliveryPriority`, Extended Data Type `ARCDeliveryPriorityId`.
4. **Field Groups** > New Field Group : nom `ARCDelivery`, Label `@ARC:ARCDeliveryGroup` ; glisser le champ dedans.

**Contrôle visuel :**
- Solution Explorer : `CustTable.ARCDelivery` avec l'icône d'extension (petite flèche).
- Dans le concepteur de l'extension, le noeud Fields ne montre que VOS champs ; les champs standard sont visibles en lecture dans Application Explorer, pas dans l'extension.
- Application Explorer > CustTable : un noeud « Extensions » liste `CustTable.ARCDelivery`.

### Étape 5 : L'extension de formulaire (4 min)

1. Application Explorer > User Interface > Forms > `CustTable` > clic droit > **Create extension**.
2. Ouvrir `CustTable.ARCDelivery` (form extension).
3. Dans le design, localiser l'onglet **General** (utiliser le filtre du concepteur : taper `General`).
4. Volet **Data Sources** > `CustTable` > Fields > `ARCDeliveryPriority` : glisser-déposer dans un groupe de l'onglet General (ou créer un groupe `ARCDeliveryGroup` avec Data Source = CustTable et Data Group = ARCDelivery).

**Contrôle visuel :**
- Le concepteur affiche à gauche l'arbre Design / Data Sources / Methods, à droite l'aperçu (Preview) du formulaire ; le nouveau contrôle apparaît dans l'aperçu avec le libellé « Priorité de livraison ».
- Properties du contrôle : Data Source `CustTable`, Data Field `ARCDeliveryPriority`.

### Étape 6 : Build, déploiement avec synchronisation, vérification (4 min)

1. Projet > Properties : **Synchronize database on build** = True (ou utiliser Deploy models... avec l'option de synchronisation cochée).
2. Ctrl+Shift+B.
3. Client web > **Clients > Tous les clients** > ouvrir US-004 > onglet **Général**.
4. Choisir `Critique`, Enregistrer, actualiser la page.

**Contrôle visuel :**
- Output : build OK, déploiement OK, puis les lignes de synchronisation de base (`Database synchronization` ... `succeeded`).
- Formulaire client : dans l'onglet Général, un groupe « Livraison ARC » contenant la liste déroulante « Priorité de livraison » avec Basse / Normale / Haute / Critique.
- Après actualisation, la valeur `Critique` est toujours affichée : le champ est bien en base.

### Étape 7 : Check-in (1 min)

Git Changes / Pending Changes : labels, enum, EDT, extension de table, extension de formulaire. Message : `D04 : champ ARCDeliveryPriority (labels+enum+EDT+table ext+form ext)`. Commit + Push.

**Contrôle visuel :**
- Git Changes liste 5 à 7 fichiers dans le dossier ARCDelivery ; après push, « Successfully pushed ».

## 4. Récapitulatif des acquis

- Chaîne complète d'un champ personnalisé en UDE : labels > enum > EDT > extension de table > extension de formulaire > build + déploiement + sync.
- Aucun objet standard modifié : Application Explorer le prouve (noeud Extensions).
- Le glisser-déposer depuis la data source fait 90 % du travail d'UI.

## 5. Dépannage

| Problème | Solution |
|---|---|
| Le champ n'apparaît pas dans le client | Vérifier que le déploiement a bien eu lieu (Output) ; Ctrl+F5 dans le navigateur ; vérifier l'onglet ciblé |
| Erreur de synchronisation | Lire l'Output ; cas courant : nom de champ en collision : vérifier le préfixe ARC |
| Label affiché `@ARC:...` | Le fichier de labels n'est pas déployé : rebuilder et redéployer le modèle complet |
| « Create extension » grisé | Extension déjà présente dans le projet, ou projet rattaché à un autre modèle |
| Valeur non persistée | Synchronisation non exécutée : relancer Deploy models... avec l'option de synchronisation |
