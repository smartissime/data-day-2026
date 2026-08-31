# Démo D10 : Le flux ARC : alerte Teams à la création d'un client critique (environnement unifié)

**Formation :** Dynamics 365 F&O, du On-Premises au Cloud (ARCHIA365)
**Séquence :** DJ5, partie 2
**Durée :** 20 minutes
**Alignement MB-500 :** Implement business events ; Connect to Microsoft Power Platform services (Power Automate triggers and actions)
**Environnement :** Power Automate (`make.powerautomate.com`) sur l'environnement unifié ; client F&O ; Teams.

---

## 1. Objectif

1. Créer la **solution** Dataverse `ARC Delivery` (réceptacle ALM réutilisé en D11 et D12).
2. Créer le flux : déclenchement à la création / modification d'un client, condition sur la priorité Critique, alerte **Teams** + trace.
3. Tester depuis F&O et lire l'historique d'exécution.

## 2. Prérequis et repères d'environnement

| Élément | Détail |
|---|---|
| Power Automate | Environnement unifié sélectionné ; licence permettant les connecteurs premium (Fin & Ops Apps, Dataverse) |
| Teams | Une équipe et un canal « ARC Delivery » créés à l'avance |
| Chemins de déclenchement | **A** : business event F&O (connecteur Fin & Ops Apps) ; **B** : ligne Dataverse sur la table virtuelle ou sur `Compte` (si dual-write) ; **C** (secours) : déclencheur manuel + liste des clients critiques via le connecteur Fin & Ops Apps |

> **Repère UDE :** l'environnement unifié simplifie le chemin B : la table virtuelle `Customers V3 (mserp)` activée en D09 est directement utilisable comme source dans le flux. Tester la veille le chemin praticable et le suivre en session.

## 3. Pas à pas

### Étape 1 : La solution (3 min)

1. `make.powerautomate.com` > vérifier l'environnement > **Solutions > Nouvelle solution**.
2. Nom `ARC Delivery` ; Éditeur : **Nouvel éditeur** `ARCHIA365`, préfixe `arc` ; Créer.

**Contrôle visuel :**
- La liste des solutions affiche « ARC Delivery » avec Éditeur ARCHIA365, Version 1.0.0.0, Gérée = Non.
- En ouvrant la solution : page vide avec la barre « + Nouveau ».

### Étape 2 : Le déclencheur (5 min)

Dans la solution : **+ Nouveau > Automatisation > Flux de cloud > Automatisé** ; nom `ARC : alerte client critique`.

**Chemin A : business event.**
- Déclencheur **When a business event occurs** (Fin & Ops Apps) ; Instance = URL F&O ; Catégorie / Business event lié aux clients (à activer au préalable côté F&O : Administration système > Configuration > Business events > Catalogue > Activer).

**Chemin B : ligne Dataverse.**
- Déclencheur **When a row is added, modified or deleted** (Dataverse) ; Type = Added or Modified ; Table = `Customers V3 (mserp)` (ou `Comptes` si dual-write) ; Scope = Organization.

**Chemin C : secours universel.**
- Déclencheur **Manually trigger a flow** ; action **Fin & Ops Apps : Lists items present in table** : Instance = URL F&O, Entity = `CustomersV3`, Filter query `ARCDeliveryPriority eq 'Critical'`.

**Contrôle visuel :**
- Le concepteur affiche la carte du déclencheur en haut avec ses paramètres ; pour Fin & Ops Apps, la connexion est marquée « Connecté » (icône verte) après authentification.
- Chemin B : la liste déroulante des tables propose la table virtuelle mserp.

### Étape 3 : Condition et actions (7 min)

1. **Condition** : priorité `est égal à` Critique (payload de l'événement, colonne `mserp_arcdeliverypriority`, ou `ARCDeliveryPriority` selon le chemin ; en chemin C, boucle **Appliquer à chacun** directement sur la liste déjà filtrée).
2. Branche **Oui** : **Publier un message dans un chat ou un canal** (Teams) : Publier en tant que Bot de flux, Publier dans Canal, Équipe / Canal ARC Delivery, message : `ARC : client critique : <Compte> : <Nom> : vérifier le groupe et les conditions de livraison.` (contenu dynamique).
3. Action de trace : **Envoyer un e-mail** (Office 365 Outlook) ou ajout d'une ligne dans une table Dataverse `arc_suivi`.
4. **Enregistrer**.

**Contrôle visuel :**
- Le concepteur montre : déclencheur > Condition (losange) > branches Oui / Non ; la branche Oui contient la carte Teams avec le canal sélectionné et le contenu dynamique surligné.
- Après enregistrement : bandeau « Le flux est prêt à l'emploi » et vérificateur de flux sans erreur.

### Étape 4 : Test de bout en bout (5 min)

1. Chemins A / B : dans F&O, créer ou modifier un client en priorité **Critique** avec groupe renseigné (la règle CoC de D05 veille). Chemin C : **Tester > Manuellement > Exécuter le flux**.
2. Basculer sur Teams : lire l'alerte.
3. Power Automate > flux > **Historique des exécutions** > ouvrir la dernière exécution.

**Contrôle visuel :**
- Teams : message posté par « Flow bot » dans le canal ARC Delivery avec le compte et le nom du client.
- Historique : ligne avec État « Réussi », durée ; en ouvrant l'exécution, chaque carte porte une coche verte, et un clic sur une carte montre Entrées / Sorties (le JSON du client dans la sortie du déclencheur).

## 4. Récapitulatif des acquis

- Solution d'abord, flux ensuite : le réflexe ALM.
- Trois familles de déclenchement F&O : business event (intention métier), Dataverse (donnée modifiée), manuel (démo / outillage).
- En environnement unifié, la table virtuelle est une source de déclenchement directe.
- L'historique d'exécution est le journal d'exploitation du flux.

## 5. Dépannage

| Problème | Solution |
|---|---|
| Connecteur Fin & Ops Apps non autorisé | Licence premium ou politique DLP : basculer chemin B ou C |
| Business event indisponible | L'activer dans le catalogue F&O ; sinon chemin B / C |
| Le flux ne se déclenche pas (chemin B) | Vérifier la table choisie et le Scope ; la table virtuelle doit être activée (D09) |
| Message Teams refusé | Le compte doit être membre de l'équipe ; recréer la connexion Teams |
| Échec d'une action | Ouvrir l'exécution en échec : le détail Entrées / Sorties de la carte rouge donne la cause |
