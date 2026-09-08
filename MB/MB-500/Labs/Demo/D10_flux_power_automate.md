# Démo D10 : Le flux ARC : alerte Teams à la création d'un client critique

**Formation :** Dynamics 365 F&O, du On-Premises au Cloud (ARCHIA365)
**Demi-journée :** DJ5, Slot 2 (jeudi 27/08, matin)
**Durée :** 20 minutes
**Alignement MB-500 :** Implement business events ; Connect to Microsoft Power Platform services (Power Automate, triggers and actions)

---

## 1. Objectif

Construire de bout en bout le flux du fil rouge :

1. Créer une **solution** Dataverse `ARC Delivery` (le réceptacle ALM : réutilisé en D12).
2. Créer le flux : déclencheur sur création/modification d'un client, condition sur la priorité **Critique**, alerte **Teams** + trace.
3. Tester en réel depuis F&O et lire l'historique d'exécution.

## 2. Prérequis

| Élément | Détail |
|---|---|
| Tenant | Tenant de démonstration (Power Automate + Teams actifs) |
| Données | Accès aux clients F&O via Dataverse (virtual table ou dual-write : état vérifié en D09) |
| Canal Teams | Une équipe/canal de démo (ex. « ARC Delivery ») créé à l'avance |
| Chemins de déclenchement | **Chemin A : business event F&O** (si le connecteur et l'événement sont activables sur le tenant) ; **Chemin B : ligne Dataverse** (si dual-write actif sur les clients) ; **Chemin C (secours universel) : déclencheur manuel + lecture des clients critiques** : fonctionne sur tout tenant |

> **Note formateur :** testez la veille le chemin praticable sur VOTRE tenant et suivez-le en session ; les trois sont détaillés ci-dessous.

## 3. Pas à pas

### Étape 1 : La solution (3 min)

1. `https://make.powerautomate.com` (vérifier l'environnement en haut à droite).
2. **Solutions > Nouvelle solution** : Nom `ARC Delivery` ; **éditeur** : créer un éditeur `ARCHIA365` avec préfixe `arc` ; enregistrer.
3. Message : tout artefact du fil rouge low-code (flux, app) naît DANS cette solution : c'est le geste ALM (repris en D12) : jamais dans « Mes flux ».

### Étape 2 : Le flux : déclencheur (5 min)

**Chemin A : business event.**
1. Dans la solution : **Nouveau > Automatisation > Flux de cloud > Automatisé**.
2. Chercher le déclencheur **When a business event occurs** (connecteur Fin & Ops Apps).
3. Renseigner : Instance (l'URL F&O), Catégorie/Business event : un événement lié aux clients si disponible sur le tenant (le catalogue F&O : Administration système > Configuration > Business events : y activer l'événement au préalable côté F&O).

**Chemin B : ligne Dataverse.**
1. Déclencheur **When a row is added, modified or deleted** (Dataverse).
2. Change type : `Added or Modified` ; Table : `Comptes` (accounts, alimentée par dual-write) ; Scope : `Organization`.

**Chemin C : secours universel.**
1. Déclencheur **Manually trigger a flow**, puis action **Fin & Ops Apps : Lister les éléments présents dans une entité** (`CustomersV3`, filtre OData `ARCDeliveryPriority eq 'Critical'`).
2. Le reste du flux est identique : seule l'origine du déclenchement change (bouton au lieu d'événement) : parfait pour garantir une démo qui fonctionne.

### Étape 3 : Condition et actions (7 min)

1. **Condition** : la valeur de priorité `est égale à` Critique :
   - Chemin A : champ issu du payload de l'événement ;
   - Chemin B : colonne `arc_deliverypriority` (si mappée) ou test simplifié sur un autre champ pour la démonstration ;
   - Chemin C : la liste est déjà filtrée : boucle **Appliquer à chacun** directement.
2. Branche **Oui** : action **Publier un message dans un canal Teams** (Post message in a chat or channel) :
   - Équipe/canal de démo ;
   - Message avec contenu dynamique : `ARC : client critique : <Compte> : <Nom> : vérifier le groupe et les conditions de livraison.`
3. Action de trace (au choix) : ajouter une ligne dans une liste (Dataverse table `arc_suivi` créée à la volée, ou simple envoi de mail) : montrer le principe du double effet notification + journalisation.
4. **Enregistrer** le flux ; le nommer `ARC : alerte client critique`.

### Étape 4 : Test de bout en bout (5 min)

1. Chemins A/B : dans F&O, créer ou modifier un client en priorité **Critique** (avec groupe renseigné : la règle CoC de D05 veille). Chemin C : cliquer **Tester > Manuellement**.
2. Basculer sur Teams : l'alerte tombe dans le canal (compter les secondes à voix haute : l'effet est garanti).
3. Retour Power Automate : ouvrir l'**historique d'exécution** du flux : dérouler chaque action, montrer entrées/sorties : c'est le journal d'exploitation.

> **Point de contrôle :** la boucle ERP > événement > flux > collaboration s'est exécutée sous les yeux de la salle : aucun équivalent AX n'a jamais existé.

## 4. Récapitulatif des acquis

- Solution d'abord, flux ensuite : le réflexe ALM.
- Trois familles de déclenchement F&O : business event (intention métier), Dataverse (donnée modifiée), manuel (démo/outillage).
- Contenu dynamique : le pipeline de données entre actions.
- Historique d'exécution : le journal des traitements par lots du 21e siècle.

## 5. Dépannage

| Problème | Solution |
|---|---|
| Connecteur Fin & Ops absent / non autorisé | Vérifier la licence et les politiques DLP de l'environnement ; basculer chemin B ou C |
| Business event indisponible | L'activer côté F&O (catalogue des business events) ; à défaut chemin B/C |
| Le flux ne se déclenche pas (chemin B) | Dual-write inactif sur les comptes : basculer chemin C |
| Message Teams refusé | Le compte doit être membre de l'équipe cible ; recréer la connexion Teams |
| Échec d'action dans l'historique | Ouvrir l'exécution en échec : le détail entrée/sortie de l'action fautive donne la cause exacte |
