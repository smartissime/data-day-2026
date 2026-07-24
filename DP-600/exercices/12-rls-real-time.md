# Exercice 12 - RLS et demarrage avec Real-Time Intelligence
Jour 3 - Module 12 (Securiser, actualiser et mettre en pratique)

## Objectif
Securiser le modele Ventes NordShop par region avec la securite au niveau ligne, puis decouvrir Real-Time Intelligence en simulant un flux d'evenements logistiques NordShop.

## Concepts DP-600 mobilises
- Securite au niveau ligne (RLS) statique et dynamique
- USERPRINCIPALNAME et table de securite
- Sécurité au niveau objet (OLS)
- Eventstream, eventhouse, KQL, Activateur

## Donnees utilisees
- Modele semantique Ventes NordShop (colonne Region issue de clients.csv, propagee via dim.Client)
- Un flux d'evenements simule (scans de colis), a construire pour l'exercice

## Prerequis
- Modele Ventes NordShop avec la colonne Region disponible dans dim.Client
- Un espace de travail avec les capacites Real-Time Intelligence activees (eventstream, eventhouse)

## Etapes detaillees

### Etape 1 - RLS statique
1. Creez un role nomme RegionNord avec un filtre DAX statique :
   ```dax
   [Region] = "Nord"
   ```
2. Testez avec la fonctionnalite Afficher comme ce role, et confirmez que seules les lignes de la region Nord apparaissent.
3. Notez la limite : il faudrait un role par region, ce qui devient difficile a maintenir avec huit regions ou plus.

### Etape 2 - RLS dynamique
1. Ajoutez une table de securite UtilisateursRegion avec deux colonnes : Email et Region, associant chaque compte utilisateur de test a une region.
2. Creez un unique role RLS dynamique utilisant :
   ```dax
   [Region] = LOOKUPVALUE(UtilisateursRegion[Region], UtilisateursRegion[Email], USERPRINCIPALNAME())
   ```
3. Testez avec plusieurs comptes de test associes a des regions differentes et confirmez que chacun voit uniquement sa region, avec un seul role a maintenir.

### Etape 3 - Securite au niveau objet (OLS)
1. Si une colonne sensible existe dans le modele (par exemple Email dans dim.Client), configurez une regle OLS qui masque completement cette colonne pour le role Viewer.
2. Confirmez que la colonne masquee n'apparait ni dans la liste des champs, ni dans les resultats d'une requete Analyser dans Excel pour ce role.

### Etape 4 - Demarrer avec Real-Time Intelligence
1. Creez un eventstream nomme NordShop-Logistique.
2. Simulez une source d'evenements (echantillon de donnees ou generateur integre) representant des scans de colis avec un identifiant de colis, un statut, et un horodatage.
3. Envoyez ce flux vers un eventhouse nomme NordShop-Logistique-Eventhouse.
4. Ecrivez une requete KQL simple qui compte les colis par statut sur la derniere heure :
   ```kql
   ScansColis
   | where Horodatage > ago(1h)
   | summarize Total = count() by Statut
   ```
5. Configurez un Activateur qui envoie une alerte si un colis reste au statut EnTransit plus de deux heures.

## Verification finale
Chaque compte de test RLS dynamique ne voit que sa propre region dans le rapport. La colonne sensible est invisible pour le role Viewer. La requete KQL retourne des resultats sur le flux simule, et l'Activateur declenche une alerte de test lorsque la condition est remplie.

## Pour aller plus loin
La RLS dynamique est un sujet partage avec PL-300. Real-Time Intelligence, plus specifique a Fabric, prefigure des scenarios avances qui rejoignent le perimetre de DP-800 sur l'exploitation de donnees en temps reel pour l'analyse avancee.

---

© ARCHIA365 — Bureau 326, 59 rue de Ponthieu, 75008 Paris
