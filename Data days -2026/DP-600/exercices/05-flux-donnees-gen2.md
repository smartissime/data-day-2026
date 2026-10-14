# Exercice 5 - Transformer les donnees clients avec un flux Gen2
Jour 2 - Module 5 (Chargement et transformation, partie 1)

## Objectif
Construire un flux de donnees Gen2 sans code qui nettoie et enrichit clients.csv avant de le charger dans le lakehouse.

## Concepts DP-600 mobilises
- Connexion a une source de donnees (fichier plat)
- Transformations Power Query (colonnes personnalisees, filtres)
- Destination et methode de mise a jour
- Query Folding

## Donnees utilisees
- `clients.csv` (colonnes ClientID, Prenom, Nom, Email, Ville, Region, Segment, DateInscription)

## Prerequis
- clients.csv disponible dans NordShop_Lakehouse (dossier /Files) ou televerse directement dans le flux
- Droits Contributor sur l'espace de travail NordShop-Analytics

## Etapes detaillees

### Etape 1 - Se connecter et explorer
1. Creez un flux de donnees Gen2 nomme DF_Clients_NordShop.
2. Connectez-vous a clients.csv comme source.
3. Verifiez les types de colonnes detectes automatiquement (DateInscription doit etre de type Date, pas texte).

### Etape 2 - Appliquer des colonnes personnalisees
1. Ajoutez une colonne personnalisee Anciennete qui calcule le nombre d'annees depuis DateInscription jusqu'a aujourd'hui.
2. Ajoutez une colonne personnalisee SegmentPriorite qui traduit Segment en une valeur numerique (Grand compte = 3, Professionnel = 2, Particulier = 1), utile pour un tri ulterieur.
3. Filtrez les lignes ou Email est vide, si il en existe.

### Etape 3 - Configurer la destination
1. Configurez NordShop_Lakehouse comme destination, dans une nouvelle table nommee clients_enrichis.
2. Choisissez la methode de mise a jour Remplacer (jeu de donnees complet, pas d'historique a conserver a ce stade).

### Etape 4 - Publier et verifier
1. Publiez le flux de donnees.
2. Attendez la fin de l'execution puis ouvrez l'explorateur du lakehouse.
3. Verifiez que la table clients_enrichis contient bien les colonnes Anciennete et SegmentPriorite.

## Verification finale
La table clients_enrichis existe dans NordShop_Lakehouse avec 200 lignes, les deux colonnes personnalisees calculees, et aucune ligne avec un Email vide.

## Pour aller plus loin
Les flux de donnees Gen2 et leurs methodes de mise a jour figurent aussi dans le referentiel DP-700, avec un accent plus fort sur l'orchestration et la supervision de ces flux en production.

---

© ARCHIA365 — Bureau 326, 59 rue de Ponthieu, 75008 Paris
