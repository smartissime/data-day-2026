# Exercice 10 - Concevoir un modele semantique evolutif
Jour 3 - Module 10 (Conception du modele semantique, partie 2)

## Objectif
Faire passer le modele Ventes NordShop a l'echelle : mode de stockage Direct Lake, relations propres avec integrite referentielle, et un groupe de calcul Time Intelligence reutilisable par toutes les mesures.

## Concepts DP-600 mobilises
- Modes de stockage (Direct Lake, Import, DirectQuery, Composite)
- Integrite referentielle entre faits et dimensions
- Groupes de calcul
- Acces en lecture/ecriture XMLA

## Donnees utilisees
- NordShop_Lakehouse (tables Delta fact.Ventes, dim.Client, dim.Produit, dim.Date)

## Prerequis
- Les tables issues de l'exercice 7 ecrites en format Delta dans NordShop_Lakehouse (ou une copie equivalente)
- Droits d'administration sur le modele semantique pour activer XMLA

## Etapes detaillees

### Etape 1 - Se connecter en Direct Lake
1. Creez un nouveau modele semantique connecte directement a NordShop_Lakehouse en mode Direct Lake (pas d'import, pas de copie).
2. Verifiez dans les proprietes du modele que le mode de stockage affiche bien Direct Lake pour chaque table.

### Etape 2 - Construire le schema en etoile
1. Ajoutez les tables Fact_Ventes, Dim_Client, Dim_Produit, Dim_Date au modele.
2. Creez les relations entre Fact_Ventes et chaque dimension, en activant l'option qui force l'integrite referentielle (aucune ligne de fait orpheline sans dimension correspondante).

### Etape 3 - Creer un groupe de calcul Time Intelligence
1. Creez un groupe de calcul nomme Intelligence Temporelle.
2. Ajoutez un premier element de calcul :
   ```dax
   YTD = CALCULATE(SELECTEDMEASURE(), DATESYTD('Dim_Date'[Date]))
   ```
3. Ajoutez un second element pour la comparaison annuelle :
   ```dax
   AnneeGlissante = CALCULATE(SELECTEDMEASURE(), SAMEPERIODLASTYEAR('Dim_Date'[Date]))
   ```
4. Verifiez dans un visuel que ce groupe de calcul s'applique automatiquement a la mesure ChiffreAffaires sans avoir eu besoin de creer ChiffreAffaires_YTD manuellement.

### Etape 4 - Activer XMLA
1. Dans les parametres de la capacite Fabric, activez la lecture/ecriture XMLA.
2. Connectez-vous au modele depuis un outil externe (par exemple Tabular Editor ou DAX Studio) pour confirmer l'acces.

## Verification finale
Le modele n'affiche aucune erreur d'integrite referentielle. Le groupe de calcul Intelligence Temporelle applique YTD et AnneeGlissante a la mesure ChiffreAffaires sans duplication de mesure. La connexion XMLA externe reussit.

## Pour aller plus loin
Direct Lake est une notion propre a Fabric, mais la logique de groupes de calcul et d'integrite referentielle est directement transferable a un modele Power BI classique evalue dans PL-300.

---

© ARCHIA365 — Bureau 326, 59 rue de Ponthieu, 75008 Paris
