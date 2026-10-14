# Exercice 4 - Preparer NordShop pour Copilot
Jour 1 - Module 4 (Manage Analytics Solution)

## Objectif
Preparer le modele semantique Ventes NordShop pour une utilisation fiable par les agents IA de Fabric (Copilot) et generer une ontologie Fabric IQ a partir de ce modele.

## Concepts DP-600 mobilises
- Schema de donnees IA (masquage de champs techniques)
- Instructions IA et reponses verifiees
- Ontologie Fabric IQ : types d'entite, proprietes, relations

## Donnees utilisees
- Modele semantique Ventes NordShop (issu de commandes.csv, produits.csv, clients.csv)

## Prerequis
- Le modele semantique Ventes NordShop deja construit et fonctionnel
- Le volet Copilot active dans l'espace de travail NordShop-Analytics

## Etapes detaillees

### Etape 1 - Simplifier le schema de donnees IA
1. Ouvrez le modele Ventes NordShop, puis le panneau Schema de donnees IA.
2. Masquez les colonnes techniques qui ne doivent pas etre visibles par l'IA : cles techniques (ClientKey, ProductKey), colonnes de remise brute non retraitee.
3. Conservez visibles les colonnes porteuses de sens metier : Region, Categorie, Montant, DateCommande.

### Etape 2 - Ecrire des instructions IA
1. Dans le meme panneau, ajoutez des instructions IA donnant le contexte NordShop : unites monetaires en euros, definition du terme client actif, terminologie interne (par exemple Segment signifie type de client : Particulier, Professionnel, Grand compte).
2. Precisez la periode de reference par defaut (annee civile en cours) si le modele contient plusieurs annees.

### Etape 3 - Creer une reponse verifiee
1. Identifiez une question frequente : quel est le chiffre d'affaires du mois ?
2. Creez une reponse verifiee associant cette question a la bonne mesure et au bon visuel de reference.
3. Testez la question dans le volet Copilot et confirmez que la reponse verifiee est utilisee en priorite.

### Etape 4 - Generer une ontologie Fabric IQ
1. Depuis le modele semantique Ventes NordShop, lancez la generation automatique d'une ontologie.
2. Verifiez les types d'entite generes automatiquement : Client, Produit, Commande.
3. Renommez les proprietes ambigues si necessaire et validez le graphe de relations Client vers Commande vers Produit.

## Verification finale
Le panneau Schema de donnees IA ne montre plus aucune colonne technique. La question test dans Copilot renvoie la reponse verifiee. L'ontologie generee affiche au moins trois types d'entite relies entre eux.

## Pour aller plus loin
La preparation IA et les ontologies partagees anticipent des sujets qui recoupent DP-700 (gouvernance de plateforme de donnees pour l'IA) et prefigurent le perimetre avance de DP-800 sur l'exploitation de donnees par des agents.

---

© ARCHIA365 — Bureau 326, 59 rue de Ponthieu, 75008 Paris
