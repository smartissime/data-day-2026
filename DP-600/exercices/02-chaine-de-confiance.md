# Exercice 2 - Construire une chaine de confiance NordShop
Jour 1 - Module 2 (Securite et gouvernance, partie 2)

## Objectif
Classer les donnees NordShop par sensibilite et construire une chaine de confiance verifiable, de la source jusqu'au rapport, en utilisant les etiquettes de confidentialite et l'approbation Fabric.

## Concepts DP-600 mobilises
- Etiquettes de confidentialite et leur propagation en aval
- Approbation : Promu, Certifie, Donnee de reference
- Catalogue OneLake : lignage, description, tags

## Donnees utilisees
- `commandes.csv` (donnees de vente, sensibilite moderee)
- `produits.csv` (donnees publiques de catalogue)
- `clients.csv` (donnees personnelles, sensibilite elevee)
- Modele semantique Ventes NordShop (construit a partir de ces trois fichiers)

## Prerequis
- Les trois fichiers CSV charges dans NordShop_Lakehouse
- Un modele semantique Ventes NordShop deja cree (relations entre commandes, produits, clients)

## Etapes detaillees

### Etape 1 - Etiqueter selon la sensibilite reelle
1. Dans le lakehouse, selectionnez la table issue de produits.csv. Appliquez l'etiquette de confidentialite Public (catalogue sans donnee personnelle).
2. Selectionnez la table issue de commandes.csv. Appliquez l'etiquette Confidentiel (montants de vente, canal, statut).
3. Selectionnez la table issue de clients.csv. Appliquez l'etiquette Hautement confidentiel (donnees personnelles identifiantes : email, ville).
4. Ouvrez le modele semantique Ventes NordShop et verifiez que l'etiquette la plus restrictive (Hautement confidentiel) s'est propagee au modele.

### Etape 2 - Promouvoir et documenter
1. Dans le modele semantique, ajoutez une description claire a la mesure ChiffreAffaires (si elle existe deja) ou preparez le terrain pour l'exercice 9.
2. Promouvez le modele semantique Ventes NordShop depuis son menu contextuel.
3. Ajoutez une description au niveau du modele expliquant sa source (NordShop_Lakehouse) et son usage prevu (reporting commercial).

### Etape 3 - Faire certifier par un reviseur
1. Demandez a votre voisin de table, qui joue le role de reviseur BI autorise, de revoir votre modele promu.
2. Le reviseur applique le statut Certifie une fois la revue faite (coherence des noms de colonnes, description complete, pas de valeur aberrante visible).

### Etape 4 - Verifier le lignage
1. Ouvrez le catalogue OneLake.
2. Recherchez le modele semantique Ventes NordShop et ouvrez son onglet Lignage.
3. Verifiez que le lignage remonte bien jusqu'a commandes.csv, produits.csv et clients.csv, avec les etiquettes de confidentialite visibles a chaque etape.

## Verification finale
Dans le catalogue OneLake, le modele Ventes NordShop doit apparaitre avec le badge Certifie, une description renseignee, et un lignage complet remontant aux trois fichiers sources.

## Pour aller plus loin
La notion d'approbation (Promu, Certifie) est identique dans PL-300 pour les rapports Power BI. Un rapport certifie est prioritaire dans les resultats de recherche et pour les suggestions Copilot.

---

© ARCHIA365 — Bureau 326, 59 rue de Ponthieu, 75008 Paris
