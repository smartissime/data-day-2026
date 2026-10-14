# Exercice 7 - Concevoir et implementer un schema en etoile
Jour 2 - Module 7 (Modelisation des donnees et conception d'entrepot)

## Objectif
Concevoir un schema en etoile pour NordShop dans un entrepot Fabric, avec un grain explicite, des dimensions denormalisees, et un historique gere via SCD Type 2.

## Concepts DP-600 mobilises
- Choix du magasin de donnees (entrepot vs lakehouse)
- Grain d'une table de faits
- Denormalisation des dimensions
- Dimensions a variation lente (SCD Type 1 et Type 2)

## Donnees utilisees
- Script `NordShopDB.sql` : tables staging.Clients, staging.Produits, staging.Commandes
- Tables cibles dim.Client, dim.Produit, dim.Date, fact.Ventes (definies dans le script)

## Prerequis
- NordShopDB.sql execute integralement (bases, schemas, tables staging et dimensionnelles crees)
- Les trois fichiers CSV charges dans les tables staging correspondantes

## Etapes detaillees

### Etape 1 - Definir le grain
1. Ouvrez la definition de fact.Ventes dans NordShopDB.sql : le grain choisi est une ligne de commande (une ligne = un produit dans une commande).
2. Discutez avec votre binome d'une alternative (un total quotidien par produit) et notez pourquoi le grain fin a ete retenu : il permet de recalculer n'importe quel agregat plus tard sans recharger les donnees source.

### Etape 2 - Charger les dimensions denormalisees
1. Chargez dim.Produit depuis staging.Produits : la hierarchie Categorie / SousCategorie est deja aplatie dans une seule table, evitant une jointure supplementaire a la lecture.
2. Chargez dim.Client depuis staging.Clients avec les colonnes EstActuel = 1 et DateDebutValidite = date du jour pour toutes les lignes initiales.
3. Generez dim.Date pour couvrir la periode 2024-2025 (une ligne par jour, avec Annee, Mois, Trimestre).

### Etape 3 - Charger la table de faits
1. Ecrivez une requete qui insere dans fact.Ventes depuis staging.Commandes, en resolvant ClientKey et ProductKey par jointure sur les cles naturelles ClientID et ProductKey.
2. Verifiez que la colonne calculee Montant se remplit automatiquement (Quantite * PrixUnitaire * (1 - Remise)).

### Etape 4 - Implementer un SCD Type 2
1. Simulez un changement : un client change de region (mettez a jour manuellement staging.Clients pour un ClientID).
2. Ecrivez la logique SCD Type 2 : marquez l'ancienne ligne dans dim.Client avec EstActuel = 0 et DateFinValidite = date du jour, puis inserez une nouvelle ligne avec la nouvelle region et EstActuel = 1.
3. Executez une requete jointe fact.Ventes / dim.Client filtree sur ce client pour verifier que l'historique des deux regions apparait selon la date de la vente.

## Verification finale
Une requete `SELECT COUNT(*) FROM fact.Ventes` doit retourner un nombre de lignes proche du nombre de lignes de commandes.csv. Le client modifie a l'etape 4 possede deux lignes dans dim.Client avec des periodes de validite qui ne se chevauchent pas.

## Pour aller plus loin
Le choix du grain et la denormalisation des dimensions sont des competences directement transferables a PL-300 pour la preparation d'un modele Power BI performant.

---

© ARCHIA365 — Bureau 326, 59 rue de Ponthieu, 75008 Paris
