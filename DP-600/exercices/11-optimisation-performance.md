# Exercice 11 - Diagnostiquer et corriger un rapport lent
Jour 3 - Module 11 (DAX avance et optimisation du modele)

## Objectif
Appliquer une methode reproductible de diagnostic de performance sur un rapport NordShop, puis corriger la ou les causes identifiees.

## Concepts DP-600 mobilises
- Analyseur de performances
- Decomposition du temps de reponse (requete DAX, rendu visuel, autre)
- Optimisation DAX (variables, predicats dans CALCULATE)
- Reduction de la cardinalite
- Agregations

## Donnees utilisees
- Modele semantique Ventes NordShop, avec un rapport contenant plusieurs visuels sur commandes.csv, produits.csv, clients.csv

## Prerequis
- Un rapport Power BI construit sur le modele Ventes NordShop, avec au moins un visuel Top clients ou equivalent utilisant une mesure avec FILTER

## Etapes detaillees

### Etape 1 - Mesurer avec le cache vide
1. Ouvrez le rapport dans Power BI Desktop et lancez l'analyseur de performances.
2. Videz le cache visuel avant de commencer (bouton dedie dans l'analyseur).
3. Interagissez avec le rapport comme le ferait un utilisateur reel : changez un segment, ouvrez une page.

### Etape 2 - Isoler le visuel hors norme
1. Dans les resultats de l'analyseur, reperez le visuel dont le temps total est nettement superieur aux autres (par exemple 4200 ms contre 300 ms pour les autres).
2. Depliez son detail : temps de requete DAX, temps d'affichage visuel, autre.

### Etape 3 - Corriger la mesure DAX
1. Copiez la requete DAX du visuel lent depuis l'analyseur de performances.
2. Si la mesure utilise `FILTER(Ventes, Ventes[Region] = "Nord")`, remplacez-la par un filtre natif plus rapide :
   ```dax
   CALCULATE([ChiffreAffaires], Ventes[Region] = "Nord")
   ```
3. Si une meme expression est calculee plusieurs fois dans la mesure, stockez-la dans une variable VAR au debut de la mesure.

### Etape 4 - Reduire la cardinalite si necessaire
1. Verifiez si une colonne DateHeure existe avec une precision a la seconde inutile pour l'analyse : tronquez-la en Date simple.
2. Supprimez toute colonne chargee dans le modele mais jamais utilisee dans un visuel ou une mesure.

### Etape 5 - Re-mesurer
1. Videz a nouveau le cache et relancez l'analyseur de performances sur le meme visuel.
2. Comparez le nouveau temps total avec celui mesure a l'etape 1.

## Verification finale
Le temps de requete DAX du visuel corrige a diminue de facon mesurable par rapport a la mesure initiale, confirmee par une seconde capture de l'analyseur de performances.

## Pour aller plus loin
La methode de diagnostic (cache vide, isolement du visuel, decomposition du temps) est directement celle enseignee et testee dans PL-300 pour l'optimisation de rapports Power BI en production.

---

© ARCHIA365 — Bureau 326, 59 rue de Ponthieu, 75008 Paris
