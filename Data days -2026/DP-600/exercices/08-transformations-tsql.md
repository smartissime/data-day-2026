# Exercice 8 - Transformer les donnees de preproduction en T-SQL
Jour 2 - Module 8 (Transformations avancees et optimisation)

## Objectif
Construire une chaine de transformation T-SQL complete dans l'entrepot NordShopDB : vue reutilisable, procedure stockee parametree, et chargement de dimension par MERGE, avec un test securise via clone de table.

## Concepts DP-600 mobilises
- Vues et procedures stockees comme objets persistants
- Clones de table (tests sans copie physique, sans risque pour la production)
- Modeles de chargement : actualisation complete, incrementielle, MERGE (upsert)

## Donnees utilisees
- Tables staging.Commandes, staging.Clients, staging.Produits
- Tables cibles dim.Client, dim.Produit, fact.Ventes

## Prerequis
- Exercice 7 termine (schema en etoile en place)
- Droits suffisants pour creer des vues, procedures et clones dans NordShopDB

## Etapes detaillees

### Etape 1 - Creer une vue reutilisable
1. Utilisez ou adaptez la vue fournie dans NordShopDB.sql :
   ```sql
   CREATE VIEW dbo.vw_VentesRegion AS
   SELECT c.Region, p.Categorie, SUM(f.Montant) AS ChiffreAffaires
   FROM fact.Ventes f
   JOIN dim.Client c ON f.ClientKey = c.ClientKey
   JOIN dim.Produit p ON f.ProductKey = p.ProductKey
   GROUP BY c.Region, p.Categorie;
   ```
2. Interrogez cette vue pour obtenir le chiffre d'affaires par region et categorie, sans reecrire la jointure a chaque fois.

### Etape 2 - Creer une procedure stockee parametree
1. Utilisez ou adaptez la procedure ChargerVentes fournie dans NordShopDB.sql, qui accepte un parametre @DateCommande.
2. Executez-la pour une date precise contenue dans commandes.csv :
   ```sql
   EXEC dbo.ChargerVentes @DateCommande = '2024-03-15';
   ```
3. Verifiez dans fact.Ventes que seules les lignes correspondant a cette date ont ete inserees.

### Etape 3 - Cloner pour tester en securite
1. Creez un clone de la table fact.Ventes nomme fact.Ventes_Test (instantane sans copie physique).
2. Testez une modification risquee sur le clone, par exemple une suppression massive de lignes annulees, sans jamais toucher fact.Ventes.
3. Confirmez que fact.Ventes reste intact apres le test sur le clone.

### Etape 4 - Charger une dimension avec MERGE
1. Adaptez l'exemple de MERGE fourni dans NordShopDB.sql pour charger dim.Client depuis staging.Clients :
   ```sql
   MERGE dim.Client AS target
   USING staging.Clients AS source ON target.ClientID = source.ClientID AND target.EstActuel = 1
   WHEN MATCHED AND target.Region <> source.Region THEN
       UPDATE SET EstActuel = 0, DateFinValidite = GETDATE()
   WHEN NOT MATCHED THEN
       INSERT (ClientID, Prenom, Nom, Email, Ville, Region, Segment)
       VALUES (source.ClientID, source.Prenom, source.Nom, source.Email, source.Ville, source.Region, source.Segment);
   ```
2. Executez ce MERGE et verifiez qu'aucun doublon de client actif n'apparait dans dim.Client.

## Verification finale
La vue vw_VentesRegion retourne des resultats coherents. La procedure ChargerVentes s'execute sans erreur pour une date donnee. Le clone de test a permis une modification sans impact sur la table de production. Le MERGE ne cree aucun doublon.

## Pour aller plus loin
Vues, procedures stockees et MERGE relevent aussi du perimetre DP-700 pour la construction de pipelines ETL robustes en T-SQL dans un entrepot d'entreprise.

---

© ARCHIA365 — Bureau 326, 59 rue de Ponthieu, 75008 Paris
