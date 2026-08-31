# Démo D07 : Sécuriser le champ ARC + tour d'Electronic Reporting (UDE)

**Formation :** Dynamics 365 F&O, du On-Premises au Cloud (ARCHIA365)
**Séquence :** DJ4, partie 1
**Durée :** 20 minutes (volet sécurité prioritaire ; volet ER écourtable)
**Alignement MB-500 :** Implement security : create and extend duties and roles, create privileges ; Implement reporting : Electronic Reporting
**Environnement :** Visual Studio 2022 (UDE) pour les artefacts de sécurité ; client web pour la configuration, Security diagnostics et ER.

---

## 1. Objectif

**Volet A : sécurité.** Encadrer l'accès en maintenance au formulaire client enrichi :
1. Deux privilèges (lecture / maintenance) sur le point d'entrée du formulaire client.
2. Un devoir `ARCDeliveryPriorityManage`, rattaché à un rôle par extension.
3. Vérification avec **Security diagnostics** et avec un utilisateur de test.

**Volet B : Electronic Reporting.** Explorer le référentiel de configurations ER.

> Remarque de périmètre : la sécurisation d'un champ unique passe normalement par des politiques dédiées ou une séparation d'écrans. Pour rester dans le temps imparti, la démo illustre la chaîne privilège > devoir > rôle sur le point d'entrée du formulaire. Approfondissements en section 6.

## 2. Prérequis et repères d'environnement

| Élément | Détail |
|---|---|
| Visual Studio | Projet ARCDelivery.FilRouge, déploiement incrémental actif |
| Client web | Accès Administration système ; un second utilisateur de test si disponible (Administration système > Utilisateurs) |
| ER | Application Finance ; accès à l'espace de travail États électroniques |

> **Repère UDE :** les artefacts de sécurité (privilèges, devoirs, extensions de rôles) sont des éléments AOT du modèle ARC : ils sont déployés avec le code par le build, puis visibles dans la configuration de la sécurité côté client web.

## 3. Pas à pas : Volet A : sécurité (14 min)

### Étape 1 : Les privilèges (4 min)

1. **Add > New Item > Dynamics 365 Items > Security > Security Privilege** : `ARCDeliveryPriorityView`, Label `@ARC:PrivView` (créer le label « ARC : consulter la priorité de livraison »).
2. Clic droit **Entry Points > New Entry Point** : Object Type `Menu Item Display`, Object Name `CustTable`, Access Level `Read`.
3. Second privilège `ARCDeliveryPriorityMaintain`, même entry point, Access Level `Update`.

**Contrôle visuel :**
- Le concepteur de privilège affiche le noeud Entry Points avec `CustTable` et, dans Properties, Access Level = Read (puis Update).
- Solution Explorer : deux éléments de type Security Privilege.

### Étape 2 : Le devoir et l'extension de rôle (4 min)

1. **Add > New Item > Security > Security Duty** : `ARCDeliveryPriorityManage`, label « ARC : gérer les priorités de livraison ».
2. Dans le devoir : **Privileges > New** > `ARCDeliveryPriorityMaintain`.
3. Application Explorer > Security > Roles > `SalesManager` > clic droit > **Create extension**.
4. Dans `SalesManager.ARCDelivery` : **Duties > New** > `ARCDeliveryPriorityManage`.
5. Ctrl+Shift+B (build + déploiement).

**Contrôle visuel :**
- Le concepteur du devoir liste le privilège sous Privileges.
- L'extension de rôle apparaît dans Solution Explorer avec l'icône d'extension ; son noeud Duties contient `ARCDeliveryPriorityManage`.
- Output : déploiement `Succeeded`.

> **Parallèle on-prem :** le modèle rôle / devoir / privilège est né en AX 2012. Nouveautés : artefacts versionnés et livrés avec le code ; on étend un rôle standard, on ne le modifie pas.

### Étape 3 : Vérification côté client (6 min)

1. Client web > **Administration système > Sécurité > Configuration de la sécurité** > onglet Rôles > rechercher `Sales manager` > Devoirs.
2. Ouvrir la fiche d'un client > **Options > Sécurité du formulaire** (Security diagnostics).
3. Test avec un utilisateur : **Administration système > Utilisateurs** > utilisateur de test > Affecter le rôle Sales manager ; se connecter avec ce compte (InPrivate) et modifier la priorité ; retirer le rôle et constater la restriction.

**Contrôle visuel :**
- Configuration de la sécurité : la liste des devoirs du rôle inclut « ARC : gérer les priorités de livraison » ; en le dépliant, le privilège Maintain et le point d'entrée CustTable.
- Security diagnostics : une grille listant Rôle / Devoir / Privilège / Niveau d'accès pour le formulaire ; vos artefacts ARC y figurent.
- Utilisateur de test avec le rôle : champ Priorité modifiable ; sans le rôle (et sans autre rôle donnant l'écriture) : fiche en lecture seule ou accès refusé.

## 4. Pas à pas : Volet B : Electronic Reporting (6 min, écourtable)

1. **Administration d'organisation > Espaces de travail > États électroniques**.
2. Fournisseurs de configuration : définir Microsoft comme actif si nécessaire.
3. **Référentiels** du fournisseur Microsoft > ouvrir > parcourir l'arborescence ; ouvrir un format de paiement (par ex. ISO 20022 Credit transfer).
4. Ouvrir le concepteur de format en lecture.

**Contrôle visuel :**
- L'espace de travail affiche des tuiles Fournisseurs de configuration, Configurations d'états, et le fournisseur actif marqué.
- Le référentiel montre un arbre : modèle de données > mappage > format, avec versions et statuts (Brouillon / Terminé / Partagé).
- Le concepteur de format affiche à gauche la structure du fichier (éléments XML), à droite le mappage vers le modèle de données.

> Si le référentiel global n'est pas accessible depuis le tenant, utiliser les captures fournies : l'espace de travail ER reste toujours visible.

## 5. Récapitulatif des acquis

- Sécurité : artefacts AOT versionnés, déployés par le build UDE, visibles dans la configuration de la sécurité.
- On étend un rôle standard, on ne l'édite pas : cohérence avec le paradigme d'extension.
- Security diagnostics répond à « qui a accès à cet écran ? ».
- ER : documents légaux et bancaires maintenus en configuration.

## 6. Pour aller plus loin

- Sécurité par champ (politiques au niveau champ) pour masquer la priorité à certains rôles.
- XDS : politique restreignant les clients visibles par groupe de clients.
- ER : dériver une configuration Microsoft (héritage de versions), ajouter une source de données personnalisée.

## 7. Dépannage

| Problème | Solution |
|---|---|
| Entry point introuvable | Vérifier le nom exact du menu item display `CustTable` dans Application Explorer |
| Devoir absent du rôle côté client | Déploiement non fait ; ou extension créée dans un autre modèle : vérifier le modèle du projet |
| Security diagnostics introuvable | Chemin : Options > Page options > Sécurité du formulaire (varie selon version) |
| Utilisateur de test sans changement visible | Le compte a d'autres rôles donnant l'écriture ; retirer temporairement ces rôles ou utiliser un compte dédié |
| Référentiel ER inaccessible | Captures ; expliquer le principe du référentiel Microsoft de configurations localisées |
