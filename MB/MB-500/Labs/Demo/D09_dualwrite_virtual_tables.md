# Démo D09 : Explorer le pont F&O / Dataverse : dual-write et virtual tables

**Formation :** Dynamics 365 F&O, du On-Premises au Cloud (ARCHIA365)
**Demi-journée :** DJ5, Slot 1 (jeudi 27/08, matin)
**Durée :** 20 minutes
**Alignement MB-500 :** Integrate and manage data solutions : integrate Dataverse using dual-write ; integrate Dataverse using virtual entities

---

## 1. Objectif

1. Repérer, dans le tenant, l'environnement Dataverse lié à F&O.
2. Explorer l'espace **dual-write** : table maps, état, historique d'exécution.
3. Examiner les **virtual tables** F&O côté Dataverse (tables mserp_/mssft_).
4. Identifier où le champ `ARCDeliveryPriority` s'insérerait dans le mapping client.

## 2. Prérequis

| Élément | Détail |
|---|---|
| Tenant | Tenant de démonstration ARCHIA365 (DemoHub All-in-One + Dataverse) |
| Accès | Compte administrateur du tenant |
| Portails | PPAC (`admin.powerplatform.microsoft.com`), maker portal (`make.powerapps.com`), client F&O |
| Réalité des tenants d'essai | Le lien dual-write n'est **pas toujours pré-provisionné**. La démo est hiérarchisée : étapes 1, 3, 4 quasi toujours réalisables ; étape 2 en direct si dual-write est actif, sinon **[Capture]** |

## 3. Pas à pas

### Étape 1 : Repérer le couple F&O / Dataverse (4 min)

1. PPAC > **Environnements** : ouvrir l'environnement de démonstration.
2. Lire la page : URL de l'environnement Dataverse, et la présence des applications Dynamics 365 (dont F&O le cas échéant : sur un DemoHub All-in-One, F&O et Dataverse cohabitent nativement).
3. Message : chaque F&O moderne a (ou peut avoir) son environnement Dataverse jumeau : c'est ce couple qui rend possible apps, flux et Copilot sur les données de l'ERP.

### Étape 2 : L'espace dual-write (6 min) [Capture si non provisionné]

1. Client F&O > **Gestion des données** (Data management) > tuile **Dual-write** ; ou l'application de gestion dual-write selon tenant.
2. Observer la liste des **table maps** : `Customers V3 : (accounts)`, `Vendors V2 : ...`, etc. : le catalogue des mappings prêts à l'emploi.
3. Ouvrir le mapping clients : colonnes source/destination, sens de synchronisation, transformations.
4. Regarder l'**état** (Running / Not running) et l'onglet d'historique / journal d'erreurs : c'est ici que vit l'exploitation quotidienne de dual-write.
5. **Fil rouge :** montrer où s'ajouterait `ARCDeliveryPriority` : dans le mapping clients, ajout d'une ligne de correspondance vers une colonne personnalisée créée côté Dataverse (`arc_deliverypriority`) : ne pas le réaliser en session (création de colonne + re-mapping dépasse le temps imparti) : le chemin est documenté en section 6.

> **Parallèle on-prem :** comparez ce catalogue de mappings supervisés à vos synchronisations AX/CRM artisanales (SSIS nocturne, fichiers plats) : ce que vous codiez en semaines est ici de la configuration.

### Étape 3 : Les virtual tables côté maker portal (6 min)

1. Ouvrir `https://make.powerapps.com` : vérifier l'environnement sélectionné (en haut à droite).
2. **Tables** : filtrer/rechercher `mserp` (les tables virtuelles F&O portent le préfixe d'éditeur mserp_).
3. Ouvrir une table virtuelle (si visible) : observer qu'elle n'a **pas de données stockées localement** : chaque lecture part vers l'entité F&O.
4. Selon l'état du tenant, l'activation d'une entité virtuelle supplémentaire se fait via la table `Entités disponibles` (Available Finance and Operations entities) : montrer le principe (cocher Visible) sans attendre la génération complète.
5. Message : dual-write COPIE (les deux mondes possèdent), la virtual table DÉLÈGUE (un monde voit l'autre) : le tableau comparatif du support s'incarne ici.

### Étape 4 : Synthèse fil rouge (4 min)

1. Au tableau, dérouler le choix pour ARC Delivery :
   - L'app mobile de consultation des priorités (démo D11) a besoin de VOIR les clients : **virtual table suffit** ;
   - Si demain le CRM doit posséder le client enrichi (offline, processus) : **dual-write + extension du mapping**.
2. Chaque participant formule le choix et sa justification en une phrase (tour rapide).

> **Point de contrôle :** la règle « posséder = dual-write, voir = virtual table » est restituée par la salle.

## 4. Récapitulatif des acquis

- Le couple F&O / Dataverse est l'infrastructure de tout le low-code sur données ERP.
- Dual-write : catalogue de table maps, supervision, extension possible avec vos champs.
- Virtual tables : visibilité sans copie, activation par entité.
- Le choix entre les deux est un choix d'architecture, désormais argumentable par la salle.

## 5. Dépannage

| Problème | Solution |
|---|---|
| Aucune tuile dual-write | Non provisionné sur ce tenant d'essai : passer en mode captures (fournies au support) ; l'étape 3 reste réalisable |
| Tables mserp_ absentes du maker portal | Vérifier l'environnement sélectionné ; activer une entité virtuelle via Available F&O entities et patienter |
| Erreur de lecture sur une virtual table | Droits insuffisants côté F&O pour le compte : la sécurité F&O s'applique aussi à ce canal (point pédagogique) |

## 6. Pour aller plus loin : étendre le mapping dual-write avec le champ ARC

1. Maker portal > Tables > `Account` (compte) > **Colonnes** > Nouvelle colonne `arc_deliverypriority` (choix : Choice alignée sur les 4 valeurs).
2. Espace dual-write > mapping `Customers V3 : (accounts)` > arrêter le mapping > ajouter la ligne `ARCDELIVERYPRIORITY` > `arc_deliverypriority` (transformations de valeurs enum si nécessaire) > redémarrer avec synchronisation initiale ciblée.
3. Tester : modifier la priorité côté F&O > vérifier la colonne côté Dataverse (et inversement).
