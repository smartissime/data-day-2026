# Démo D06 : Test unitaire SysTest et exposition OData du champ ARC

**Formation :** Dynamics 365 F&O, du On-Premises au Cloud (ARCHIA365)
**Demi-journée :** DJ3, Slot 2 (mercredi 26/08, matin)
**Durée :** 20 minutes
**Alignement MB-500 :** Develop and test code : Create unit tests using SysTest ; Integrate and manage data solutions : OData, extend data entities

---

## 1. Objectif

1. Écrire un test unitaire **SysTest** validant la règle de priorité (2 cas), l'exécuter dans **Test Explorer**.
2. Étendre l'entité **CustCustomerV3** avec le champ `ARCDeliveryPriority`.
3. Requêter l'entité en **OData** avec un filtre sur la priorité, et constater que la règle CoC s'applique aussi via l'API.

## 2. Prérequis

- Tier-1 à l'état D05 (règle CoC active).
- Pour la partie OData : l'URL de l'environnement F&O ; un client REST (navigateur suffisant pour la lecture ; un outil REST pour l'écriture).
- **Deux niveaux prévus :**
  - **Niveau A (complet)** : app registration Microsoft Entra ID + jeton OAuth2 (annexe A) ;
  - **Niveau B (simplifié, recommandé en session)** : requêtes GET directement dans le navigateur authentifié par la session : suffisant pour démontrer la lecture filtrée.

## 3. Pas à pas

### Étape 1 : La classe de test (7 min)

1. **Add > New Item > Code > Class**. Nom : `ARCDeliveryPriorityTest`.

```xpp
[SysTestTarget(classStr(ARC_CustTable_Extension))]
final class ARCDeliveryPriorityTest extends SysTestCase
{
    /// <summary>Client Critique sans groupe : la sauvegarde doit echouer.</summary>
    [SysTestMethod]
    public void criticalWithoutGroup_fails()
    {
        CustTable custTable;

        ttsbegin;
        custTable.initValue();
        custTable.AccountNum          = 'ARC-T001';
        custTable.ARCDeliveryPriority = ARCDeliveryPriority::Critical;
        custTable.CustGroup           = '';

        this.assertFalse(custTable.validateWrite(),
            'Un client Critique sans groupe ne doit pas etre valide.');
        ttsabort;
    }

    /// <summary>Client Critique avec groupe : la sauvegarde doit reussir.</summary>
    [SysTestMethod]
    public void criticalWithGroup_succeeds()
    {
        CustTable custTable;

        ttsbegin;
        custTable.initValue();
        custTable.AccountNum          = 'ARC-T002';
        custTable.ARCDeliveryPriority = ARCDeliveryPriority::Critical;
        custTable.CustGroup           = '10';   // groupe existant du jeu USMF

        this.assertTrue(custTable.validateWrite(),
            'Un client Critique avec groupe doit etre valide.');
        ttsabort;
    }
}
```

2. Points à commenter : `extends SysTestCase`, attributs `[SysTestMethod]`, asserts, et le `ttsabort` qui garantit qu'aucune donnée de test ne persiste.

### Étape 2 : Exécution dans Test Explorer (3 min)

1. **Build** du projet.
2. **Test > Test Explorer** : les 2 tests apparaissent.
3. **Run All** : viser 2 verts.
4. (Théâtral, optionnel) Modifier temporairement la règle CoC pour la casser, relancer : 1 rouge : puis restaurer et repasser au vert : le cycle rouge/vert visualisé.

> **Parallèle on-prem :** le SysTest framework existait en germe dans AX, quasi inutilisé. Sous One Version, ce réflexe devient la garantie de non-régression à chaque mise à jour mensuelle.

### Étape 3 : Étendre l'entité CustCustomerV3 (5 min)

1. Application Explorer : rechercher l'entité **CustCustomerV3Entity** (Data Model > Data Entities).
2. Clic droit > **Create extension** > l'extension rejoint le projet.
3. Ouvrir l'extension : depuis le volet Data Sources, déplier la source `CustTable`, localiser `ARCDeliveryPriority` et le **glisser** dans les **Fields** de l'entité.
4. Projet : vérifier **Synchronize database on build = True** ; **Build** (la table de staging est régénérée).
5. Vérification côté application : **Administration système > Espaces de travail > Gestion des données** > Entités > vérifier la présence du champ dans l'entité clients (ou lancer un export de l'entité et vérifier la colonne).

> **Point de contrôle :** le champ ARC est désormais dans le pipeline de données : DMF ET OData.

### Étape 4 : Requêter en OData (5 min)

**Niveau B (navigateur, recommandé en session) :**

1. Dans le navigateur déjà authentifié sur l'environnement, ouvrir :
   - `https://<env>.operations.dynamics.com/data` : la liste des entités exposées (chercher `CustomersV3`) ;
   - `https://<env>.operations.dynamics.com/data/CustomersV3?$top=3&$select=CustomerAccount,SalesCurrencyCode` : lecture simple ;
   - `https://<env>.operations.dynamics.com/data/CustomersV3?$select=CustomerAccount,ARCDeliveryPriority&$filter=ARCDeliveryPriority eq Microsoft.Dynamics.DataEntities.ARCDeliveryPriority'Critical'&$top=10` : le filtre sur VOTRE champ (syntaxe enum complète ; en cas d'erreur, tester d'abord sans le filtre et montrer le champ dans la réponse JSON).
2. Lire la réponse JSON : le champ d'extension est là, sans une ligne de plomberie d'API.

**Niveau A (client REST + OAuth2, annexe) :** réaliser en plus un POST de création d'un client Critique **sans groupe** > constater l'erreur renvoyée par l'API : **la règle CoC de D05 protège aussi ce canal** : la démonstration ultime du « règle dans la table ».

> **Point de contrôle :** JSON affiché avec ARCDeliveryPriority ; la salle a compris que l'entité EST l'API.

## 4. Récapitulatif des acquis

- SysTest : cas nominal + cas d'erreur, ttsabort, Test Explorer : le minimum vital est simple à écrire.
- Étendre une entité = glisser le champ + build : le staging suit.
- OData expose automatiquement les entités et VOS extensions ; la règle métier posée en CoC s'applique à tous les canaux.

## 5. Dépannage

| Problème | Solution |
|---|---|
| Tests absents de Test Explorer | Rebuild ; vérifier `extends SysTestCase` et les attributs ; réouvrir Test Explorer |
| Échec du test 2 | Le groupe '10' n'existe pas dans la société de test : utiliser un CustGroup existant |
| Champ absent de l'entité en OData | Build+sync non refaits après l'extension d'entité ; vérifier la propriété IsPublic de l'entité (CustomersV3 est publique) |
| 401 sur /data | La session navigateur a expiré : se reconnecter au client F&O puis rejouer l'URL |
| Erreur de syntaxe du filtre enum | Utiliser la forme complète Microsoft.Dynamics.DataEntities.<EnumType>'<Valeur>' ; à défaut, filtrer côté démonstration sur un champ simple |

## Annexe A : App registration Entra ID (niveau A)

1. Portail Azure > Microsoft Entra ID > **App registrations** > New registration (`ARC-OData-Demo`).
2. Noter Application (client) ID et Tenant ID ; créer un **client secret**.
3. Dans F&O : **Administration système > Configuration > Applications Microsoft Entra ID** : nouvelle ligne : Client ID + utilisateur associé (compte de service disposant des droits).
4. Jeton : POST `https://login.microsoftonline.com/<tenant>/oauth2/v2.0/token` avec `grant_type=client_credentials`, `client_id`, `client_secret`, `scope=https://<env>.operations.dynamics.com/.default`.
5. Appeler l'API avec l'en-tête `Authorization: Bearer <token>`.
