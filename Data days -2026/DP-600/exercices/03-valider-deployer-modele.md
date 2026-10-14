# Exercice 3 - Valider et deployer un modele semantique
Jour 1 - Module 3 (Lifecycle Management)

## Objectif
Mettre en place un cycle de vie professionnel pour le modele semantique Ventes NordShop : versionnement Git, validation automatisee avec SemPy, puis promotion via un pipeline de deploiement.

## Concepts DP-600 mobilises
- Format .pbip et fichiers TMDL pour Git
- Validation programmatique avec SemPy (notebook Python)
- Pipelines de deploiement Fabric (Dev, Test, Production)
- Regles de deploiement (changement de source de donnees par etape)

## Donnees utilisees
- Modele semantique Ventes NordShop, connecte a NordShop_Lakehouse
- Table fact.Ventes et dimensions dim.Client, dim.Produit issues de NordShopDB.sql

## Prerequis
- Power BI Desktop avec l'option de fichiers .pbip activee
- Un depot Git relie a votre espace de travail Fabric (Azure DevOps ou GitHub)
- Le modele semantique Ventes NordShop enregistre au format .pbip

## Etapes detaillees

### Etape 1 - Versionner avec Git
1. Dans Power BI Desktop, enregistrez le modele Ventes NordShop au format Projet Power BI (.pbip). Vous obtenez des fichiers texte TMDL (model.tmdl, relationships.tmdl).
2. Connectez votre espace de travail Fabric au depot Git (Parametres de l'espace de travail > Integration Git).
3. Committez la version initiale sur une branche nommee feature/ajout-mesure-marge.
4. Modifiez une mesure existante puis committez a nouveau : observez le diff lisible dans les fichiers TMDL.

### Etape 2 - Valider avec SemPy
1. Creez un notebook nomme validate_model.ipynb dans NordShop-Analytics.
2. Installez et importez la librairie SemPy (semantic-link) :
   ```python
   import sempy.fabric as fabric
   ```
3. Recuperez la liste des relations et detectez les cles orphelines :
   ```python
   fabric.list_relationship_violations("Ventes NordShop")
   ```
4. Testez une mesure cle en comparant sa valeur a un total calcule manuellement a partir de fact.Ventes dans NordShopDB.

### Etape 3 - Creer un pipeline de deploiement
1. Creez un pipeline de deploiement nomme NordShop-Pipeline avec trois etapes : Dev, Test, Production.
2. Affectez l'espace de travail NordShop-Analytics a l'etape Dev.
3. Deployez vers Test. Configurez une regle de deploiement qui pointe l'etape Test vers une copie distincte de NordShop_Lakehouse (par exemple NordShop_Lakehouse_Test).
4. Comparez les deux etapes dans l'ecran du pipeline avant de valider la promotion.

### Etape 4 - Planifier et superviser
1. Configurez l'actualisation planifiee quotidienne du modele en etape Production.
2. Ajoutez une alerte par e-mail en cas d'echec d'actualisation.

## Verification finale
Le depot Git contient au moins deux commits distincts sur le modele. Le notebook SemPy s'execute sans erreur et confirme l'absence de cle orpheline. Le pipeline affiche les trois etapes avec le contenu promu de Dev vers Test.

## Pour aller plus loin
La gestion de version avec Git recoupe PL-300 (deploiement de rapports Power BI en entreprise) et DP-700 (orchestration de pipelines de donnees avec des environnements Dev/Test/Prod).

---

© ARCHIA365 — Bureau 326, 59 rue de Ponthieu, 75008 Paris
