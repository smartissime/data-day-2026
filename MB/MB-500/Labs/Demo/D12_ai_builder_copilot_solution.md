# Démo D12 : AI Builder, Copilot et la solution ARC packagée (clôture)

**Formation :** Dynamics 365 F&O, du On-Premises au Cloud (ARCHIA365)
**Demi-journée :** DJ6, Slot 2 (jeudi 27/08, après-midi)
**Durée :** 15 minutes
**Alignement :** Extension de Copilot dans les finance and operations apps ; AI Builder ; ALM Power Platform (solutions managed/unmanaged)

---

## 1. Objectif

1. Tester un modèle **AI Builder** de traitement de documents.
2. Explorer **Copilot** : dans F&O (sidecar) et/ou dans Power BI, selon l'activation du tenant.
3. Geste ALM final : vérifier la **solution ARC Delivery** (app + flux) et l'**exporter en managed** : le livrable jumeau du deployable package.

## 2. Prérequis

| Élément | Détail |
|---|---|
| AI Builder | Crédits d'essai actifs sur l'environnement (activables depuis le maker portal) |
| Copilot F&O | Dépend de l'activation sur le tenant/région : prévoir les captures de secours du support |
| Document de test | Une facture PDF d'exemple (fournie dans les ressources : `facture_demo_arc.pdf`) |
| Solution | `ARC Delivery` contenant le flux (D10) et l'app (D11) |

> **Note formateur :** hiérarchie de robustesse : la partie **solution** (étapes 3) fonctionne sur tout tenant : c'est le geste à préserver absolument. AI Builder en essai fonctionne généralement ; Copilot est le plus dépendant du tenant : montrez ce qui est disponible, les captures suppléent le reste.

## 3. Pas à pas

### Étape 1 : AI Builder : lire une facture (5 min)

1. Maker portal > **IA (AI Hub / AI Builder) > Modèles prédéfinis > Traitement de facture** (Invoice processing).
2. Cliquer **Essayer** : glisser `facture_demo_arc.pdf`.
3. Observer l'extraction : fournisseur, date, montants, lignes : avec le score de confiance par champ.
4. Message : cette extraction est une **action de flux** : dans le scénario du support (facture entrante intelligente), elle s'insère entre le mail reçu et la création de la facture en attente dans F&O via le connecteur : l'IA est UNE ACTION DE PLUS, pas un monde à part.

### Étape 2 : Copilot (5 min : selon tenant)

**Dans F&O (si activé) :**
1. Client F&O : ouvrir le volet **Copilot** (icône dédiée).
2. Poser une question sur les données visibles (ex. résumé de la fiche client ouverte, ou question sur une liste).
3. Relier aux quatre leviers d'extension du support : guidance, questions sur les données, client actions, AI plugins (logique X++ branchée) : et à Copilot Studio pour les agents personnalisés.

**Dans Power BI (si le rapport D11 est ouvert et Copilot disponible) :**
1. Volet Copilot du rapport : demander une synthèse ou un visuel en langage naturel.

**[Capture]** si aucun des deux n'est actif sur le tenant : dérouler les captures du support en commentant le geste.

> **Message de clôture conceptuel :** « Copilot, quels clients critiques n'ont pas de groupe renseigné ? » : derrière cette phrase se trouvent VOTRE entité (DJ2), VOTRE champ (DJ2), VOTRE règle (DJ3), VOTRE sécurité (DJ4) : l'IA rend interrogeable le travail bien fait ; elle ne le remplace pas.

### Étape 3 : La solution ARC : vérifier et exporter (5 min)

1. Maker portal > **Solutions > ARC Delivery** : vérifier le contenu : le flux `ARC : alerte client critique`, l'app `ARC Priorités`, la table `arc_clients` le cas échéant, et les **dépendances** (onglet des dépendances : montrer).
2. **Publier toutes les personnalisations**.
3. **Exporter la solution** :
   - une première fois en **unmanaged** (archive de développement) ;
   - une seconde fois en **managed** (le livrable de déploiement) ; noter l'incrément de version proposé.
4. Télécharger le .zip managed et le montrer côte à côte (fenêtre d'explorateur) avec l'idée du **deployable package** F&O : **les deux trains de livraison** du projet moderne, matérialisés.
5. Mentionner les **pipelines Power Platform** (déploiement outillé dev > test > prod) comme l'équivalent du pipeline LCS.

> **Point de contrôle final :** la salle peut nommer les deux artefacts de livraison d'un projet F&O moderne et leur chaîne respective (package + LCS/DevOps ; solution managed + pipelines PP).

## 4. Récapitulatif des acquis : et bilan du fil rouge

- AI Builder : l'IA prête à brancher dans les flux et les apps : chiffrable (crédits) et démontrable.
- Copilot : utiliser aujourd'hui, étendre demain (client actions, AI plugins) : suivre les release waves.
- Solution managed = le livrable low-code ; le duo d'ALM est complet.

**Le fil rouge ARC Delivery, de bout en bout (3 jours) :**

| Jour | Brique construite |
|---|---|
| DJ2 | Modèle ARCDelivery, enum, EDT, champ sur CustTable, formulaire |
| DJ3 | Règle métier (CoC), journalisation (event handler), tests SysTest, API OData |
| DJ4 | Sécurité (privilèges, devoir, rôle), performance (trace avant/après) |
| DJ5 | Exploration du pont Dataverse, flux d'alerte Teams |
| DJ6 | App mobile, aperçu analytique, IA, solution packagée |

Un besoin client simple, traité avec TOUTE la pile 2026 : c'est exactement le métier qui vous attend.

## 5. Dépannage

| Problème | Solution |
|---|---|
| AI Builder demande des crédits | Activer l'essai AI Builder depuis le maker portal (bouton d'essai gratuit) |
| Copilot absent de F&O | Non activé sur le tenant/région : captures du support ; expliquer l'activation par environnement (gouvernance) |
| Export de solution bloqué par des dépendances | Ouvrir l'onglet dépendances : ajouter à la solution l'objet manquant (table, connexion référencée) |
| Le flux exporté référence des connexions personnelles | Point pédagogique : en production, utiliser des références de connexion dans la solution : la check-list de mise en production du support s'applique |
