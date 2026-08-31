# Démo D12 : AI Builder, Copilot et la solution ARC packagée (clôture, environnement unifié)

**Formation :** Dynamics 365 F&O, du On-Premises au Cloud (ARCHIA365)
**Séquence :** DJ6, partie 2
**Durée :** 15 minutes
**Alignement :** Extend Copilot in finance and operations apps ; AI Builder ; ALM Power Platform (solutions managed / unmanaged)
**Environnement :** Maker portal (AI Builder, Solutions) sur l'environnement unifié ; client F&O (Copilot) ; Power BI (D11).

---

## 1. Objectif

1. Tester un modèle **AI Builder** de traitement de facture.
2. Explorer **Copilot** dans F&O (volet latéral) et situer les leviers d'extension pour le développeur (AI tools vs client plugins).
3. Geste ALM final : vérifier la **solution ARC Delivery** (app + flux + table éventuelle), l'**exporter en managed** : le livrable jumeau du package X++.

## 2. Prérequis et repères d'environnement

| Élément | Détail |
|---|---|
| AI Builder | Crédits d'essai activés (bandeau « Démarrer l'essai » dans le maker portal > IA) |
| Copilot F&O | Activation selon tenant / région ; version d'application 10.0.40 ou supérieure pour l'extension par client plugins ; captures de secours prévues |
| Document | `facture_demo_arc.pdf` (ressource fournie) |
| Solution | `ARC Delivery` contenant le flux (D10) et l'app (D11) |

> **Repère UDE :** en ALM unifié, une solution Dataverse peut embarquer à la fois des artefacts Power Platform et des packages X++ ; les pipelines Power Platform déploient l'ensemble de dev vers test puis prod. Dans cette démo, on exporte la partie low-code ; la partie X++ suit la chaîne Azure DevOps vue en DJ2.

## 3. Pas à pas

### Étape 1 : AI Builder : lire une facture (5 min)

1. Maker portal > **IA (AI Hub)** > **Modèles prédéfinis** > **Traitement de facture** > **Essayer**.
2. Glisser `facture_demo_arc.pdf`.

**Contrôle visuel :**
- La page du modèle affiche l'aperçu de la facture à gauche et, à droite, les champs extraits (Fournisseur, Date, Total, Lignes) avec un pourcentage de confiance par champ.
- En bas : « Utiliser dans un flux » / « Utiliser dans une application » : l'IA est une action de plus dans un flux.

### Étape 2 : Copilot (5 min, selon tenant)

1. Client F&O > icône **Copilot** (volet latéral) > poser une question sur la fiche ou la liste ouverte (par ex. résumé du client courant).
2. Rappeler les leviers d'extension : guidance, questions sur les données, **client actions** et **AI plugins** branchés sur la logique X++ ; Copilot Studio pour les agents.
3. Décision d'architecture (job aid officiel) : **AI tool** pour un scénario transverse et simple sans UI ; **client plugin** pour un scénario spécifique F&O avec interaction de formulaire.

**Contrôle visuel :**
- Le volet Copilot s'ouvre à droite avec la zone de saisie et des suggestions de questions ; la réponse cite la page en cours.
- [Captures] si Copilot n'est pas activé sur le tenant.

> Message de clôture : « Copilot, quels clients critiques n'ont pas de groupe renseigné ? » : derrière cette phrase, votre entité, votre champ, votre règle, votre sécurité.

### Étape 3 : La solution ARC : vérifier et exporter (5 min)

1. Maker portal > **Solutions > ARC Delivery** : parcourir les composants ; onglet **Dépendances** (menu ... > Afficher les dépendances).
2. **Publier toutes les personnalisations**.
3. **Exporter la solution** > Suivant > Version proposée (1.0.0.1) > **Non gérée** > Exporter ; recommencer en **Gérée**.
4. Ouvrir le dossier Téléchargements : deux fichiers .zip.

**Contrôle visuel :**
- La solution liste : `ARC : alerte client critique` (Flux de cloud), `ARC Priorités` (Application canvas), éventuellement `arc_clients` (Table) et les références de connexion.
- Le volet d'export propose le choix Gérée / Non gérée et incrémente la version.
- Téléchargements : `ARCDelivery_1_0_0_1.zip` et `ARCDelivery_1_0_0_1_managed.zip`.

Mettre côte à côte, au tableau : le .zip managed (livrable low-code) et le deployable package X++ (livrable pro-code) : les deux trains de livraison du projet moderne ; mentionner les pipelines Power Platform comme équivalent du pipeline de package.

## 4. Récapitulatif des acquis : et bilan du fil rouge

- AI Builder : l'IA prête à brancher, chiffrable (crédits), démontrable.
- Copilot : utiliser aujourd'hui, étendre demain (client actions, AI plugins) ; suivre les release waves ; gouvernance et IA responsable.
- Solution managed = livrable low-code ; le duo d'ALM est complet.

| Séquence | Brique construite |
|---|---|
| DJ2 | Modèle ARCDelivery, labels, enum, EDT, champ sur CustTable, formulaire (UDE : build + déploiement + sync) |
| DJ3 | Règle CoC, event handler, tests SysTest, entité étendue, API OData |
| DJ4 | Privilèges, devoir, extension de rôle ; trace en environnement unifié, set-based |
| DJ5 | Table virtuelle activée, flux d'alerte Teams |
| DJ6 | App mobile, aperçu analytique, IA, solution exportée |

## 5. Dépannage

| Problème | Solution |
|---|---|
| AI Builder demande des crédits | Activer l'essai depuis le maker portal (bandeau) |
| Copilot absent de F&O | Non activé sur le tenant / région : captures ; expliquer l'activation par environnement |
| Export bloqué par des dépendances | Onglet Dépendances : ajouter l'objet manquant à la solution (table, référence de connexion) |
| Connexions personnelles dans le flux exporté | Point pédagogique : utiliser des références de connexion dans la solution (check-list de mise en production) |
