# Exercice 9 - Creer des calculs DAX pour NordShop
Jour 3 - Module 9 (Conception du modele semantique, partie 1)

## Objectif
Construire une serie de calculs DAX sur le modele semantique Ventes NordShop, des tables calculees simples jusqu'aux mesures composees avec des fonctions d'iterateur.

## Concepts DP-600 mobilises
- Tables, colonnes et mesures calculees
- Contexte de ligne et contexte de filtre
- Mesures explicites vs implicites
- Fonctions d'iterateur (SUMX)

## Donnees utilisees
- Modele semantique Ventes NordShop, base sur fact.Ventes, dim.Client, dim.Produit (issues de l'exercice 7)

## Prerequis
- Le modele semantique Ventes NordShop importe ou connecte en Direct Lake a NordShopDB / NordShop_Lakehouse
- Power BI Desktop ou l'editeur de modele Fabric

## Etapes detaillees

### Etape 1 - Table calculee pour les dimensions de jeu de role
1. Creez une table calculee DateLivraison qui duplique la table Date, destinee a analyser les livraisons independamment des commandes :
   ```dax
   DateLivraison = Date
   ```
2. Renommez ses colonnes pour eviter toute ambiguite avec la table Date d'origine (par exemple AnneeLivraison, MoisLivraison).

### Etape 2 - Colonne calculee avec RELATED
1. Dans la table de faits Ventes, ajoutez une colonne calculee CategorieProduit qui recupere la categorie depuis la dimension Produit :
   ```dax
   CategorieProduit = RELATED(Produit[Categorie])
   ```

### Etape 3 - Mesure simple puis mesure composee
1. Creez une mesure simple explicite :
   ```dax
   ChiffreAffaires = SUM(Ventes[Montant])
   ```
2. Creez une mesure de cout total en vous appuyant sur la colonne CoutUnitaire de dim.Produit :
   ```dax
   CoutTotal = SUMX(Ventes, Ventes[Quantite] * RELATED(Produit[CoutUnitaire]))
   ```
3. Composez une mesure de marge a partir des deux precedentes :
   ```dax
   Marge = [ChiffreAffaires] - [CoutTotal]
   ```

### Etape 4 - Verifier le comportement contextuel
1. Placez la mesure Marge dans un tableau croise avec Region en ligne.
2. Ajoutez un segment sur Categorie et verifiez que la marge se recalcule automatiquement dans le contexte de filtre courant.
3. Comparez avec une colonne calculee equivalente (si vous en creez une) pour observer qu'elle, elle, ne reagit pas aux segments de la meme facon.

## Verification finale
La mesure Marge retourne des valeurs coherentes par region et categorie, et varie correctement quand un segment est applique. La colonne CategorieProduit affiche la bonne categorie pour chaque ligne de vente.

## Pour aller plus loin
Ce module recoupe presque integralement l'examen PL-300 : la distinction mesure explicite/implicite et les iterateurs comme SUMX y sont testes de la meme maniere.

---

© ARCHIA365 — Bureau 326, 59 rue de Ponthieu, 75008 Paris
