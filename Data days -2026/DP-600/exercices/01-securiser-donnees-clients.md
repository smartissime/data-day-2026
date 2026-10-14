# Exercice 1 - Securiser les donnees clients NordShop
Jour 1 - Module 1 (Securite et gouvernance, partie 1)

## Objectif
Appliquer les quatre couches de securite Fabric sur un cas reel : proteger les donnees personnelles des clients NordShop tout en gardant le lakehouse exploitable par les equipes qui en ont besoin.

## Concepts DP-600 mobilises
- Roles d'espace de travail (Admin, Member, Contributor, Viewer)
- Permissions au niveau element (partage cible d'un lakehouse)
- Securite T-SQL granulaire (GRANT, DENY au niveau colonne)
- Roles d'acces OneLake (RBAC au niveau dossier)

## Donnees utilisees
- `clients.csv` (200 lignes) - colonnes : ClientID, Prenom, Nom, Email, Ville, Region, Segment, DateInscription
- `NordShopDB.sql` - table `staging.Clients` et son point de terminaison SQL

## Prerequis
- Un espace de travail Fabric nomme NordShop-Analytics (capacite Fabric ou essai)
- clients.csv importe dans un lakehouse NordShop_Lakehouse (dossier /Files)
- NordShopDB.sql execute sur une instance SQL Server ou Azure SQL, avec staging.Clients charge depuis clients.csv

## Etapes detaillees

### Etape 1 - Roles d'espace de travail
1. Dans NordShop-Analytics, ouvrez Parametres de l'espace de travail puis Acces.
2. Ajoutez votre binome avec le role Contributor (il doit pouvoir construire et modifier le contenu).
3. Ajoutez le reste du groupe avec le role Viewer (consultation uniquement).
4. Verifiez que seul l'administrateur (vous) garde le role Admin pour gerer les acces futurs.

### Etape 2 - Permission d'element cible
1. Dans le lakehouse NordShop_Lakehouse, ouvrez le menu Partager.
2. Partagez uniquement ce lakehouse (pas tout l'espace de travail) avec un compte de test jouant le role du service marketing.
3. Cochez uniquement la permission de lecture, sans autoriser le partage en cascade.

### Etape 3 - Securite T-SQL au niveau colonne
1. Ouvrez le point de terminaison SQL de NordShop_Lakehouse (ou connectez-vous a staging.Clients dans NordShopDB).
2. Creez un role SQL nomme Equipe_Marketing :
   ```sql
   CREATE ROLE Equipe_Marketing;
   ```
3. Refusez explicitement l'acces a la colonne Email pour ce role :
   ```sql
   DENY SELECT ON staging.Clients(Email) TO Equipe_Marketing;
   ```
4. Ajoutez votre compte de test au role et verifiez qu'une requete `SELECT Email FROM staging.Clients` echoue pour ce compte, alors qu'un `SELECT ClientID, Ville FROM staging.Clients` fonctionne.

### Etape 4 - Role d'acces OneLake
1. Dans NordShop_Lakehouse, creez un sous-dossier /Files/Import destine a un prestataire externe de saisie de donnees.
2. Dans Parametres > Roles d'acces OneLake, creez un role limite a ce dossier uniquement.
3. Affectez ce role au compte du prestataire externe et confirmez qu'il ne voit pas les autres dossiers du lakehouse.

## Verification finale
Connectez-vous avec le compte de test Viewer : il doit voir les rapports mais ne rien pouvoir modifier. Connectez-vous avec le compte marketing : il doit voir la table Clients sans la colonne Email.

## Pour aller plus loin
Ce modele en couches se retrouve presque a l'identique dans DP-700 (ingenierie de donnees), notamment pour la securite des lakehouses et entrepots partages entre equipes.

---

© ARCHIA365 — Bureau 326, 59 rue de Ponthieu, 75008 Paris
