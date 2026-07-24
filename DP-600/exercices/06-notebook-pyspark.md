# Exercice 6 - Nettoyer et enrichir les ventes avec PySpark
Jour 2 - Module 6 (Chargement et transformation, partie 2)

## Objectif
Utiliser un notebook Fabric pour nettoyer les donnees de ventes brutes issues de commandes.csv, les enrichir par jointure, et ecrire le resultat en table Delta optimisee.

## Concepts DP-600 mobilises
- Notebooks Fabric, execution cellule par cellule sur Spark
- PySpark et Spark SQL dans le meme notebook (%%sql)
- Fonctions de fenetre
- Ecriture Delta et commandes OPTIMIZE / VACUUM

## Donnees utilisees
- `commandes.csv` (grain ligne de commande) charge en table raw_commandes
- `clients.csv` charge en table clients
- `produits.csv` charge en table produits

## Prerequis
- Les trois fichiers charges en tables dans NordShop_Lakehouse (via l'explorateur de fichiers ou l'exercice 5)
- Un notebook Fabric attache a NordShop_Lakehouse

## Etapes detaillees

### Etape 1 - Charger et nettoyer
1. Dans une premiere cellule PySpark :
   ```python
   df = spark.table("raw_commandes")
   df = df.dropDuplicates(["OrderID", "LineNumber"])
   df = df.fillna({"Remise": 0})
   ```
2. Filtrez les lignes dont le Statut est Annulee (elles ne doivent pas compter dans le chiffre d'affaires).

### Etape 2 - Joindre avec clients et produits
1. Joignez df avec la table clients sur ClientID.
2. Joignez le resultat avec la table produits sur ProductKey.
3. Calculez une colonne MontantLigne = Quantite * PrixUnitaire * (1 - Remise).

### Etape 3 - Fonction de fenetre
1. Calculez un total cumule des ventes par client, trie par DateCommande, avec une fonction de fenetre (Window + sum).
2. Basculez dans une nouvelle cellule en Spark SQL avec %%sql pour verifier le total par region avec un GROUP BY.

### Etape 4 - Ecrire et optimiser
1. Ecrivez le dataframe final dans une table Delta nommee ventes_enrichies (mode overwrite).
2. Executez la commande OPTIMIZE ventes_enrichies pour compacter les fichiers.
3. Executez VACUUM ventes_enrichies RETAIN 168 HOURS pour nettoyer les anciens fichiers.

## Verification finale
La table ventes_enrichies existe, ne contient aucune commande annulee, et la colonne de total cumule croit de facon monotone pour chaque client.

## Pour aller plus loin
PySpark et les commandes Delta (OPTIMIZE, VACUUM) sont au coeur de DP-700, avec davantage d'accent sur l'automatisation via des pipelines planifies plutot que sur l'execution manuelle en notebook.

---

© ARCHIA365 — Bureau 326, 59 rue de Ponthieu, 75008 Paris
