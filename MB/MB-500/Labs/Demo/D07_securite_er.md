# Démo D07 : Sécuriser le champ ARC + tour d'Electronic Reporting

**Formation :** Dynamics 365 F&O, du On-Premises au Cloud (ARCHIA365)
**Demi-journée :** DJ4, Slot 1 (mercredi 26/08, après-midi)
**Durée :** 20 minutes (volet sécurité prioritaire ; volet ER écourtable)
**Alignement MB-500 :** Implement security : create and extend duties and roles ; create privileges : Implement reporting : Electronic Reporting

---

## 1. Objectif

**Volet A : sécurité (prioritaire).** Encadrer le champ Priorité de livraison :

1. Créer deux privilèges (lecture / maintenance) sur l'accès au formulaire client enrichi.
2. Créer un devoir `ARCDeliveryPriorityManage` et l'intégrer à un rôle par extension.
3. Vérifier l'effet avec **Security diagnostics**.

**Volet B : Electronic Reporting (découverte).** Explorer le référentiel de configurations ER du tenant.

## 2. Prérequis

- Tier-1 à l'état D06 (volet A).
- Tenant de démonstration, application Finance (volet B).
- Remarque : la sécurité au niveau du CHAMP unique passe normalement par des politiques dédiées ou la séparation d'écrans ; pour rester dans le temps imparti, la démo sécurise l'accès en maintenance au formulaire enrichi via un menu item dédié, ce qui illustre la chaîne complète privilège > devoir > rôle. L'approfondissement (sécurité par champ, XDS) est en section 6.

## 3. Pas à pas : Volet A : sécurité (14 min)

### Étape 1 : Les privilèges (5 min)

1. Dans le projet, **Add > New Item > Security > Security Privilege**. Nom : `ARCDeliveryPriorityView`.
   - Propriété **Label** : `ARC : consulter la priorité de livraison`.
   - Clic droit **Entry Points > New Entry Point** : Object Type `Menu Item Display`, Object `CustTable` (le point d'entrée du formulaire client), **Access Level : Read**.
2. Recommencer : privilège `ARCDeliveryPriorityMaintain` ; même entry point, **Access Level : Update**.

> **Parallèle on-prem :** structure identique au modèle AX 2012 (le modèle par rôles y est né) : la différence : ces artefacts sont dans VOTRE modèle, versionnés, livrés par package : plus de sécurité recréée à la main en production.

### Étape 2 : Le devoir et le rôle (4 min)

1. **Add > New Item > Security > Security Duty**. Nom : `ARCDeliveryPriorityManage` ; label `ARC : gérer les priorités de livraison`.
2. Dans le devoir : clic droit **Privileges > New** > référencer `ARCDeliveryPriorityMaintain`.
3. Étendre un rôle standard : Application Explorer > Security > Roles > rechercher `SalesManager` (Responsable des ventes) > clic droit > **Create extension**.
4. Dans l'extension de rôle : **Duties > New** > référencer `ARCDeliveryPriorityManage`.
5. **Build** du projet.

### Étape 3 : Vérification (5 min)

1. Client web > **Administration système > Sécurité > Configuration de la sécurité** : rechercher le rôle Sales Manager : vérifier la présence du devoir ARC (la vue fusionnée AOT + configuration).
2. **Security diagnostics** : ouvrir la fiche client > Options > **Sécurité du formulaire** (Security diagnostics) : la liste des rôles ayant accès s'affiche : repérer l'effet de vos artefacts.
3. Test utilisateur (si un second compte est disponible) : affecter à un utilisateur de test le rôle Sales Manager > il peut modifier ; retirer le rôle (ou affecter un rôle de consultation seule) > accès réduit.

> **Point de contrôle :** la chaîne privilège > devoir > rôle est visible dans la configuration de la sécurité et dans Security diagnostics.

## 4. Pas à pas : Volet B : Electronic Reporting (6 min : écourtable)

1. Client web > **Administration d'organisation > Espaces de travail > États électroniques** (Electronic reporting).
2. Observer les **fournisseurs de configuration** (Microsoft en tête) ; définir Microsoft comme actif si demandé.
3. Ouvrir **Référentiels** du fournisseur Microsoft (Dataverse ou Global repository selon tenant) > parcourir l'arborescence des configurations : modèles de données, mappings, formats (chercher un format de paiement, ex. ISO 20022 / SEPA).
4. Ouvrir une configuration de format : montrer l'arbre du format (éléments, mappings) SANS le modifier.
5. Message : la retouche d'un format (ajout d'une colonne, changement d'un libellé bancaire) se fait ICI, en configuration versionnée, sans build ni déploiement de code.

> **[Capture]** : si le référentiel global n'est pas accessible depuis le tenant d'essai, utiliser les captures du support (l'espace de travail ER lui-même est toujours visible).

## 5. Récapitulatif des acquis

- Sécurité : artefacts AOT (privilège, devoir, extension de rôle) versionnés et livrés avec le code.
- On n'édite jamais un rôle standard : on l'étend : cohérence totale avec le paradigme d'extension.
- Security diagnostics : l'outil de réponse à « qui a accès à cet écran ? ».
- ER : les documents légaux et bancaires se maintiennent en configuration : le développeur sort de la boucle des retouches.

## 6. Pour aller plus loin

- **Sécurité par champ / valeurs sensibles :** politiques de sécurité au niveau champ pour masquer la priorité à certains rôles.
- **XDS :** créer une politique restreignant les clients visibles (par ex. par groupe de clients) : le successeur industrialisé du Record Level Security.
- **ER avancé :** dériver une configuration Microsoft (héritage de versions), ajouter une source de données custom.

## 7. Dépannage

| Problème | Solution |
|---|---|
| L'entry point n'est pas trouvé | Vérifier le nom exact du menu item display (CustTable) dans Application Explorer |
| Le devoir n'apparaît pas sur le rôle | Build non fait, ou extension créée dans un autre modèle : vérifier le modèle du projet |
| Security diagnostics introuvable | Chemin : Options (bandeau) > Page options > Sécurité du formulaire, selon version |
| Référentiel ER inaccessible | Utiliser les captures ; expliquer le principe : le référentiel Microsoft distribue les configurations localisées |
