# Démo D06 : Test unitaire SysTest et exposition OData du champ ARC (UDE)

**Formation :** Dynamics 365 F&O, du On-Premises au Cloud (ARCHIA365)
**Séquence :** DJ3, partie 2
**Durée :** 20 minutes
**Alignement MB-500 :** Develop and test code : create unit tests using SysTest ; Integrate and manage data solutions : OData, extend data entities
**Environnement :** Visual Studio 2022 (UDE), modèle ARCDelivery à l'état D05 ; client web ; navigateur ou client REST.

---

## 1. Objectif

1. Écrire un test **SysTest** validant la règle de priorité (2 cas) et l'exécuter dans **Test Explorer** contre l'environnement en ligne.
2. Étendre l'entité **CustCustomerV3Entity** avec le champ `ARCDeliveryPriority` ; déployer avec synchronisation.
3. Vérifier la présence du champ dans la **Gestion des données**.
4. Requêter l'entité en **OData** avec un filtre sur la priorité ; constater que la règle CoC protège aussi l'API.

## 2. Prérequis et repères d'environnement

| Élément | Détail |
|---|---|
| Visual Studio | Projet ARCDelivery.FilRouge ; Test Explorer (Test > Test Explorer) |
| Environnement | Sandbox UDE ; URL `https://<env>.operations.dynamics.com` |
| OData | Niveau B (recommandé) : requêtes GET dans le navigateur authentifié. Niveau A : app registration Entra ID + jeton OAuth2 (annexe) |

> **Repère UDE :** les tests SysTest s'exécutent depuis Test Explorer, mais le code testé tourne dans l'environnement Cloud : le modèle doit être déployé avant l'exécution des tests. Chaque modification de la classe de test implique donc build + déploiement.

## 3. Pas à pas

### Étape 1 : La classe de test (6 min)

1. **Add > New Item > Code > Class** : `ARCDeliveryPriorityTest`.

```xpp
[SysTestTarget(classStr(ARC_CustTable_Extension))]
final class ARCDeliveryPriorityTest extends SysTestCase
{
    [SysTestMethod]
    public void criticalWithoutGroup_fails()
    {
        CustTable custTable;

        ttsbegin;
        custTable.initValue();
        custTable.AccountNum          = 'ARC-T001';
        custTable.ARCDeliveryPriority = ARCDeliveryPriority::Critical;
        custTable.CustGroup           = '';

        this.assertFalse(custTable.validateWrite(), 'Critique sans groupe doit echouer.');
        ttsabort;
    }

    [SysTestMethod]
    public void criticalWithGroup_succeeds()
    {
        CustTable custTable;

        ttsbegin;
        custTable.initValue();
        custTable.AccountNum          = 'ARC-T002';
        custTable.ARCDeliveryPriority = ARCDeliveryPriority::Critical;
        custTable.CustGroup           = '10';

        this.assertTrue(custTable.validateWrite(), 'Critique avec groupe doit reussir.');
        ttsabort;
    }
}
```

2. Ctrl+Shift+B (build + déploiement).

**Contrôle visuel :**
- Output : build et déploiement `Succeeded`.
- **Test Explorer** : après le build, le noeud `ARCDeliveryPriorityTest` apparaît avec ses deux méthodes (icônes grises « non exécuté »).

### Étape 2 : Exécution des tests (3 min)

1. Test Explorer > **Run All**.
2. Optionnel : casser volontairement la règle (inverser la condition), rebuild, Run All, observer le rouge, puis restaurer.

**Contrôle visuel :**
- Les deux tests passent au vert (coche verte) ; la durée d'exécution s'affiche à côté de chaque test.
- En cas d'échec provoqué : icône rouge, et le message d'assert (« Critique sans groupe doit echouer. ») dans le volet de détail.

> **Parallèle on-prem :** le framework de test existait en germe dans AX, quasi inutilisé. Sous One Version, c'est l'assurance de non-régression à chaque mise à jour.

### Étape 3 : Étendre l'entité CustCustomerV3 (5 min)

1. Application Explorer > Data Model > Data Entities > `CustCustomerV3Entity` > clic droit > **Create extension**.
2. Ouvrir l'extension ; volet Data Sources > `CustTable` > Fields > `ARCDeliveryPriority` : glisser dans **Fields** de l'entité.
3. Projet > Properties > Synchronize database on build = True ; Ctrl+Shift+B.

**Contrôle visuel :**
- Solution Explorer : `CustCustomerV3Entity.ARCDelivery`.
- Le concepteur d'entité montre le nouveau champ dans Fields avec Data Source `CustTable` et Data Field `ARCDeliveryPriority` ; les champs standard restent en lecture.
- Output : synchronisation exécutée (la table de staging `CustCustomerV3Staging` est régénérée).

### Étape 4 : Vérification dans la Gestion des données (2 min)

1. Client web > **Administration système > Espaces de travail > Gestion des données** > tuile **Paramètres du framework** ou **Entités de données**.
2. Rechercher `Customers V3` > ouvrir > **Modifier le mappage cible**.

**Contrôle visuel :**
- La liste des entités affiche « Customers V3 » ; l'écran de mappage montre la colonne `ARCDELIVERYPRIORITY` reliée entre staging et cible.
- Si le champ n'apparaît pas : bouton **Actualiser la liste des entités** puis réouvrir.

### Étape 5 : Requêter en OData (4 min)

**Niveau B (navigateur authentifié) :**

1. `https://<env>.operations.dynamics.com/data` : liste des entités exposées ; chercher `CustomersV3`.
2. `https://<env>.operations.dynamics.com/data/CustomersV3?$top=3&$select=CustomerAccount,SalesCurrencyCode`
3. `https://<env>.operations.dynamics.com/data/CustomersV3?$select=CustomerAccount,ARCDeliveryPriority&$filter=ARCDeliveryPriority eq Microsoft.Dynamics.DataEntities.ARCDeliveryPriority'Critical'&$top=10`

**Contrôle visuel :**
- `/data` renvoie un JSON avec un tableau `value` d'objets `{ "name": "CustomersV3", "kind": "EntitySet", "url": "CustomersV3" }`.
- La requête filtrée renvoie un JSON dont chaque objet contient `"ARCDeliveryPriority": "Critical"` : votre champ d'extension est dans l'API sans plomberie supplémentaire.

**Niveau A (client REST + OAuth2, annexe) :** POST d'un client Critique sans groupe > la réponse HTTP 400 contient le message de la règle ARC : le CoC protège aussi le canal API.

### Étape 6 : Check-in (moins d'1 min)

Commit + Push : `D06 : tests SysTest + extension entite CustCustomerV3 (ARCDeliveryPriority)`.

## 4. Récapitulatif des acquis

- SysTest : cas nominal + cas d'erreur, `ttsabort`, Test Explorer ; en UDE, déployer avant d'exécuter.
- Étendre une entité = glisser le champ + build avec synchronisation.
- OData expose entités et extensions automatiquement ; la règle CoC s'applique à tous les canaux.

## 5. Dépannage

| Problème | Solution |
|---|---|
| Tests absents de Test Explorer | Rebuild ; vérifier `extends SysTestCase` et `[SysTestMethod]` ; fermer/rouvrir Test Explorer |
| Tests en échec « cannot connect » | Le modèle n'est pas déployé, ou l'environnement est indisponible : vérifier l'Output et PPAC |
| Échec du test 2 | Le groupe `10` n'existe pas : utiliser un groupe existant de USMF |
| Champ absent de l'entité en OData | Synchronisation non faite ; vérifier IsPublic = Yes sur l'entité (CustomersV3 est publique) |
| 401 sur /data | Session expirée : se reconnecter au client F&O puis rejouer l'URL |
| Erreur de syntaxe du filtre enum | Utiliser la forme complète `Microsoft.Dynamics.DataEntities.<Enum>'<Valeur>'` |

## Annexe A : App registration Entra ID (niveau A)

1. Portail Azure > Microsoft Entra ID > App registrations > New registration (`ARC-OData-Demo`) ; noter Client ID et Tenant ID ; créer un secret.
2. F&O : **Administration système > Configuration > Applications Microsoft Entra ID** : nouvelle ligne Client ID + utilisateur associé.
3. Jeton : POST `https://login.microsoftonline.com/<tenant>/oauth2/v2.0/token` avec `grant_type=client_credentials`, `client_id`, `client_secret`, `scope=https://<env>.operations.dynamics.com/.default`.
4. Appels avec l'en-tête `Authorization: Bearer <token>`.

**Contrôle visuel :** la réponse du token contient `"token_type": "Bearer"` et `"access_token"` ; la première requête GET renvoie HTTP 200 et le JSON attendu.
