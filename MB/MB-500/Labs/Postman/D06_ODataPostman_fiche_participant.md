# Fiche D06, niveau A : créer un client critique sans groupe par OData avec Postman, et voir la CoC refuser, en 1 heure

Formation D365 F&O Cloud, ARCHIA365. Fiche participant.
Position dans la formation : démo D06, slot intégration OData, après D03 (champ `ARCDeliveryPriority` sur `CustTable`) et la CoC sur `CustTable.validateWrite()`, avant D07 (sécurité). S'appuie sur l'extension de `CustCustomerV3Entity` qui expose `ARCDeliveryPriority` dans l'entité `CustomersV3`. Le même client `ARC-O002` est réutilisé en H03 (Copilot) et en H04 (rapport Fabric).
Sources : Microsoft Learn, « Services home page » (F&O, OAuth 2.0 et flux client credentials pour OData), « Service endpoints authentication », « Customers V3 (CustCustomerV3Entity) », « Microsoft Entra applications » (page de F&O), « OData » (dev-itpro, data entities).

---

## Ce qui change par rapport à AX et à D365 on-premises

| Monde AX 2012 et D365 on-premises | Monde cloud (F&O + Microsoft Entra ID) |
|---|---|
| AIF : ports d'entrée, services documentaires, adaptateurs, WCF | OData REST sur `/data/`, une entité publique = une ressource, JSON en entrée et en sortie |
| Authentification Windows ou compte AX, souvent un compte technique partagé | jeton OAuth 2.0 délivré par Microsoft Entra ID, application inscrite dans le tenant, secret ou certificat |
| L'appelant est un utilisateur AX, la sécurité vient de son rôle | l'appelant est une **application** ; F&O la fait correspondre à un utilisateur F&O par la page **Microsoft Entra applications** |
| La logique métier passe par `AxBC` (`AxCustTable`) et ses règles propres | la logique métier passe par l'entité, puis par la table : `CustTable.validateWrite()` et ses CoC sont appelés, comme depuis le client |
| Test d'un service : client .NET, SoapUI, code à écrire | Postman, deux requêtes, aucun code |
| Pas de contrat public : les champs sont ceux de la table | contrat public : `/data/$metadata`, noms publics des champs et des énumérations |

Ce qui ne change pas : la règle métier vit dans la table. Une CoC posée sur `CustTable.validateWrite()` protège l'écran, l'import, l'OData et le Data management sans une ligne de plus. C'est ce que l'heure démontre.

## Les trois façons de faire entrer un client dans F&O cloud

| Chemin | Quand | Ce que ça coûte |
|---|---|---|
| **OData `POST` sur `CustomersV3`** (cette heure) | intégration synchrone, un enregistrement ou quelques dizaines, réponse immédiate attendue par l'appelant | une inscription Entra, un utilisateur F&O associé, un jeton par heure |
| **Data management, package et API REST DMF** | volumes, chargement initial, reprise sur erreur | un projet d'import, un traitement asynchrone, la lecture du journal d'exécution |
| **Saisie dans le client ou Excel add-in** | ponctuel, utilisateur métier | rien, mais pas automatisable |

Le résultat de l'heure : un `POST` refusé pour `ARC-O001` (priorité `Critical`, sans groupe de clients), puis un `POST` accepté pour `ARC-O002` (même priorité, groupe `10`), avec la preuve au débogueur que c'est la CoC ARC qui décide.

Le flux :

```text
Postman
  → Microsoft Entra ID : obtention du jeton
  → OData F&O : POST /data/CustomersV3
  → CustCustomerV3Entity → CustTable.validateWrite()
  → règle CoC ARC
  → refus (400) ou création (201)
```

---

## Étape 0, avant la séance : prérequis

Les prérequis ont été préparés la veille par le formateur. Vérifiez-les en trois minutes.

| Prérequis | Où vérifier |
|---|---|
| URL de l'environnement F&O, par exemple `https://arcfodev01.operations.dynamics.com`, société `USMF` | barre d'adresse de F&O, paramètre `?cmp=USMF` |
| Identifiant du **tenant** Microsoft Entra | portail Azure, **Microsoft Entra ID**, **Overview** |
| Droits pour créer une **inscription d'application** dans Entra | portail Azure, **App registrations**, bouton **New registration** actif |
| Droits **System Administrator** dans F&O | F&O, **System administration**, **Users**, votre compte |
| Un utilisateur F&O actif, avec accès à `USMF` et le droit de créer un client, à associer à l'application | F&O, **System administration**, **Users** |
| Postman installé, ou un client REST équivalent | poste de séance |
| Extension de `CustCustomerV3Entity` avec `ARCDeliveryPriority`, modèle `ARCDeliveryModel` compilé, synchronisé, déployé | F&O, `/data/$metadata` contient `ARCDeliveryPriority` |
| CoC `ARC_CustTable_Extension.validateWrite()` présente dans le modèle, message d'erreur ARC visible en saisie manuelle | F&O, **All customers**, créer un client `Critical` sans groupe : le message ARC doit apparaître |

Si un point manque, ne passez pas à l'étape 2 : le jeton s'obtiendra peut-être, mais le `POST` échouera sur autre chose que la règle ARC, et la démonstration ne prouvera rien.

Règle d'écriture de l'URL, à appliquer partout dans l'heure : **minuscules, sans `/` final**.

```text
Incorrect : https://arcfodev01.operations.dynamics.com/
Correct   : https://arcfodev01.operations.dynamics.com
```

---

## Étape 1, minute 3 à 12 : inscrire l'application dans Microsoft Entra ID

### 1.1 Créer l'inscription

1. https://portal.azure.com, **Microsoft Entra ID**, **App registrations**, **New registration**.
2. Renseignez :

| Paramètre | Valeur |
|---|---|
| **Name** | `ARC-OData-Demo` |
| **Supported account types** | Accounts in this organizational directory only |
| **Redirect URI** | vide |

3. **Register**.

### 1.2 Relever les identifiants

Page **Overview**, copiez dans votre fichier texte de séance :

```text
Tenant ID : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
Client ID : yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy
```

### 1.3 Créer un secret

1. **Certificates & secrets**, onglet **Client secrets**, **New client secret**.
2. Description : `Postman D06`. Durée : la plus courte adaptée au laboratoire.
3. **Add**, puis copiez **immédiatement** la colonne **Value**. Elle ne se réaffiche plus.

À retenir : c'est la **Value** du secret qu'on utilise, pas son **Secret ID**. Et ce secret ne va jamais dans le code X++, ni dans un dépôt Azure DevOps.

Aucune permission d'API n'est à ajouter : F&O ne vérifie pas de permission Entra, il vérifie l'audience du jeton et la correspondance Client ID / utilisateur (étape 2).

---

## Étape 2, minute 12 à 20 : autoriser l'application dans F&O

### 2.1 L'utilisateur F&O associé

Pour la séance, un compte disposant de droits suffisants convient. En projet, créez un compte de service dédié, avec uniquement les rôles nécessaires. L'utilisateur doit exister dans F&O, être activé, avoir accès à `USMF` et posséder le droit de créer un client.

### 2.2 Enregistrer l'application

1. F&O, société `USMF`, **System administration**, **Setup**, **Microsoft Entra applications** (en français : **Administration système**, **Paramétrage**, **Applications Microsoft Entra ID**).
2. **New**.
3. Renseignez :

| Champ | Valeur |
|---|---|
| **Client ID** | l'Application (client) ID de l'étape 1.2 |
| **Name** | `ARC OData Demo` |
| **User ID** | l'utilisateur F&O de 2.1 |

4. **Save**.

À retenir : le jeton identifie l'**application**. F&O utilise cette ligne pour décider **quel utilisateur** agit, donc quels rôles s'appliquent. Un `403` à l'étape 4 se corrige ici ou dans les rôles de cet utilisateur, jamais dans Entra.

---

## Étape 3, minute 20 à 30 : Postman, environnement et jeton

### 3.1 Créer un environnement Postman

**Environments**, **+**, nom `ARC D06`. Variables :

| Variable | Valeur |
|---|---|
| `tenantId` | identifiant du tenant |
| `clientId` | Application (client) ID |
| `clientSecret` | Value du secret (type **secret**) |
| `foUrl` | `https://arcfodev01.operations.dynamics.com` |
| `accessToken` | vide au départ |

Sélectionnez cet environnement en haut à droite. `foUrl` sans `/` final : c'est la variable qui sert d'audience.

### 3.2 La requête de jeton

Nouvelle requête, nom `01 Token` :

```http
POST https://login.microsoftonline.com/{{tenantId}}/oauth2/v2.0/token
```

**Headers** : `Content-Type: application/x-www-form-urlencoded`.

**Body**, **x-www-form-urlencoded** :

| Key | Value |
|---|---|
| `grant_type` | `client_credentials` |
| `client_id` | `{{clientId}}` |
| `client_secret` | `{{clientSecret}}` |
| `scope` | `{{foUrl}}/.default` |

Onglet **Tests** (ou **Scripts**, **Post-response** selon la version de Postman), collez :

```javascript
const response = pm.response.json();
pm.environment.set("accessToken", response.access_token);
```

**Send**. Réponse attendue :

```json
{
  "token_type": "Bearer",
  "expires_in": 3599,
  "access_token": "eyJ..."
}
```

La variable `accessToken` est remplie automatiquement. Le jeton vaut une heure : si un `401` apparaît plus tard dans la séance, rejouez `01 Token`.

À retenir : le `scope` est l'URL F&O suivie de `/.default`. Une majuscule ou un `/` de trop dans `foUrl` donne un jeton valide pour Entra et refusé par F&O.

---

## Étape 4, minute 30 à 40 : vérifier l'accès en lecture

### 4.1 Les métadonnées

Requête `02 Metadata` :

```http
GET {{foUrl}}/data/$metadata
```

**Authorization** : **Bearer Token**, valeur `{{accessToken}}`. **Send**.

Résultat attendu : `200 OK`. Dans la réponse (Ctrl+F), retrouvez `CustomersV3` et `ARCDeliveryPriority`. Lisez aussi les valeurs de l'énumération publique de `ARCDeliveryPriority` : c'est le nom **public** qu'il faudra envoyer dans le JSON, pas le libellé.

### 4.2 Lire trois clients

Requête `03 Get customers` :

```http
GET {{foUrl}}/data/CustomersV3?$top=3&$select=dataAreaId,CustomerAccount,CustomerGroupId,ARCDeliveryPriority
```

Même **Authorization**. Résultat attendu : `200 OK` et trois clients de `USMF`.

Ce `GET` prouve quatre choses avant d'écrire quoi que ce soit : le jeton est valide pour F&O, l'utilisateur associé a des droits, l'entité est accessible, le champ personnalisé est exposé. Si une des quatre manque, le `POST` échouera pour une raison qui n'est pas la règle ARC.

---

## Étape 5, minute 40 à 50 : le `POST` refusé, puis le `POST` accepté

### 5.1 Le `POST` invalide

Requête `04 Post invalid` :

```http
POST {{foUrl}}/data/CustomersV3
```

**Authorization** : Bearer Token `{{accessToken}}`.
**Headers** : `Content-Type: application/json` et `Accept: application/json`.
**Body**, **raw**, **JSON**, avec un numéro de client qui n'existe pas encore :

```json
{
  "dataAreaId": "USMF",
  "CustomerAccount": "ARC-O001",
  "PartyType": "Organization",
  "OrganizationName": "Client critique sans groupe",
  "SalesCurrencyCode": "USD",
  "CustomerGroupId": "",
  "ARCDeliveryPriority": "Critical"
}
```

**Send**. Résultat attendu : un statut d'erreur, en général `400 Bad Request`, avec dans le corps un message de validation. Si la CoC est atteinte, le message est le vôtre :

```text
ARC : un client en priorité Critique doit avoir un groupe de clients.
```

Vérification dans F&O : **Accounts receivable**, **Customers**, **All customers**, filtre `ARC-O001`. Résultat attendu : aucun client. La transaction OData a été annulée avec le refus.

### 5.2 Le `POST` valide

Requête `05 Post valid`, même URL, mêmes en-têtes, corps :

```json
{
  "dataAreaId": "USMF",
  "CustomerAccount": "ARC-O002",
  "PartyType": "Organization",
  "OrganizationName": "Client critique valide",
  "SalesCurrencyCode": "USD",
  "CustomerGroupId": "10",
  "ARCDeliveryPriority": "Critical"
}
```

`10` est un groupe existant dans `USMF` ; si votre environnement en a d'autres, prenez-en un dans **Accounts receivable**, **Setup**, **Customer groups**.

Résultat attendu : `201 Created`, et le corps de la réponse renvoie le client créé avec `ARCDeliveryPriority` à `Critical`. Dans **All customers**, `ARC-O002` existe.

À retenir : le second `POST` n'est pas décoratif. Il prouve que le refus du premier n'est pas un problème technique général (jeton, droits, entité) mais bien une décision de la logique métier.

---

## Étape 6, minute 50 à 58 : la preuve décisive au débogueur

Il y a une difficulté dans le scénario : `CustomerGroupId` est déjà un champ **obligatoire** de l'entité standard `CustomersV3`. L'entité peut donc rejeter `ARC-O001` avant que la CoC ARC ne soit évaluée, et le message d'erreur ne serait alors pas le vôtre.

Pour savoir qui a refusé :

1. Visual Studio, ouvrez `ARC_CustTable_Extension`, point d'arrêt sur la première ligne de `validateWrite()`.
2. **Extensions**, **Dynamics 365**, **Launch debugger**.
3. Rejouez `04 Post invalid` depuis Postman.
4. Le point d'arrêt est atteint ? Lisez dans la fenêtre **Locals** :

```xpp
this.ARCDeliveryPriority
this.CustGroup
ret
```

5. Continuez (F5) et lisez la réponse dans Postman.

Deux lectures possibles :

| Observation | Conclusion |
|---|---|
| Point d'arrêt atteint, `ret` passe à `false`, message ARC dans la réponse Postman | c'est la CoC qui refuse : la démonstration est complète |
| Point d'arrêt **non** atteint, réponse Postman parlant seulement de `CustomerGroupId` obligatoire | l'entité a refusé avant la table ; la règle ARC n'a pas été testée |

Dans le second cas, la règle à démontrer doit porter sur une combinaison que `CustomersV3` n'impose pas déjà. Exemple, prévu comme variante au niveau B :

> Si la priorité vaut `Critical`, le plafond de crédit (`CreditLimit`) doit être supérieur à zéro.

Le `POST` fournit alors un groupe valide, atteint `CustTable.validateWrite()`, et seule la CoC ARC peut le refuser.

---

## Étape 7, minute 58 à 60 : contrôle et fermeture de boucle

Checklist :

- [ ] Inscription `ARC-OData-Demo` dans Entra, secret `Postman D06` noté, jamais collé dans le code
- [ ] Ligne `ARC OData Demo` dans **Microsoft Entra applications** de F&O, avec un utilisateur actif sur `USMF`
- [ ] Environnement Postman `ARC D06`, `foUrl` en minuscules sans `/` final, `accessToken` rempli par le script
- [ ] `GET $metadata` en `200`, `CustomersV3` et `ARCDeliveryPriority` trouvés
- [ ] `GET CustomersV3` en `200`, trois clients lus
- [ ] `POST ARC-O001` refusé, absent de **All customers**
- [ ] `POST ARC-O002` en `201`, présent dans **All customers** avec `Critical`
- [ ] Point d'arrêt dans `validateWrite()` atteint, ou variante niveau B identifiée

Après la pause : `ARC-O002` sert de client de référence pour la suite du fil rouge. Ne le supprimez pas.

---

## Annexe A : dépannage

| Erreur | Cause probable | Correction |
|---|---|---|
| `401 Unauthorized` | jeton incorrect, expiré, ou mauvaise audience | rejouer `01 Token` ; vérifier `scope = {{foUrl}}/.default` |
| `401` avec audience incorrecte | URL avec majuscules ou `/` final | `foUrl` = URL F&O exacte, minuscules, sans `/` |
| `403 Forbidden` | utilisateur associé sans droits, ou sans accès à `USMF` | rôles de l'utilisateur F&O ; page **Microsoft Entra applications** |
| Application non reconnue | Client ID absent de F&O | ajouter la ligne dans **Microsoft Entra applications** |
| Champ inconnu (`ARCDeliveryPriority`) | extension non déployée sur cet environnement | build, synchronisation, déploiement, puis relire `$metadata` |
| Valeur d'énumération invalide | nom public incorrect | lire l'énumération dans `/data/$metadata`, envoyer le nom public |
| Groupe introuvable | le groupe `10` n'existe pas dans `USMF` | prendre un groupe de **Customer groups** |
| Client déjà existant | numéro réutilisé d'une séance précédente | changer `CustomerAccount` (`ARC-O003`, …) |
| Erreur de champ obligatoire | corps JSON incomplet | fournir `dataAreaId`, `CustomerAccount`, `PartyType`, `OrganizationName` (ou `NameAlias`), `SalesCurrencyCode`, `CustomerGroupId` |
| `AADSTS7000215` à l'étape 3 | secret invalide : Secret ID collé à la place de la Value, ou secret expiré | régénérer le secret, coller la **Value** |
| Point d'arrêt jamais atteint | débogueur non lancé, ou refus en amont par l'entité | **Launch debugger** avant le `POST` ; sinon voir l'étape 6 |

## Annexe B : ce que l'entité fait entre le JSON et la table

`CustomersV3` est l'entité publique de `CustCustomerV3Entity`. À la réception du `POST`, le framework OData crée un enregistrement de l'entité, applique le mappage des champs vers `CustTable` et `DirPartyTable`, exécute la logique de l'entité (`mapEntityToDataSource`, `insertEntityDataSource`), puis insère dans les tables. C'est à ce moment que `CustTable.validateWrite()` et `insert()` s'exécutent, avec leurs CoC. Une extension de `CustCustomerV3Entity` n'est nécessaire que pour **exposer** un champ ajouté à la table ; la règle métier, elle, reste sur la table et n'a pas à être dupliquée.

Ordre des contrôles, du plus tôt au plus tard : validité du jeton (Entra puis F&O), correspondance application / utilisateur, droits de l'utilisateur sur l'entité, champs obligatoires de l'entité, logique de l'entité, `validateWrite()` de la table, `insert()`.

## Annexe C : sécurité, ce qu'il faut savoir

- L'application Entra n'a aucun droit propre dans F&O. Tous ses droits sont ceux de l'utilisateur F&O associé. Un compte de service dédié, avec un rôle limité à la création de clients, est la règle en projet.
- Le secret est une chaîne à protéger comme un mot de passe : coffre Azure Key Vault ou variables secrètes du pipeline, jamais un fichier de collection Postman exporté avec ses valeurs.
- Un certificat remplace avantageusement le secret pour une intégration durable ; le flux client credentials accepte les deux.
- Le jeton contient l'identifiant de l'application et l'audience F&O ; il ne contient rien sur l'utilisateur F&O. C'est la page **Microsoft Entra applications** qui fait le lien, à chaque appel.

## Annexe D : la même démonstration sans Postman

- **curl** : deux commandes, l'une vers `login.microsoftonline.com` avec `-d` pour le formulaire, l'autre vers `/data/CustomersV3` avec `-H "Authorization: Bearer …"`. Utile en pipeline.
- **Power Automate** : action HTTP avec authentification Active Directory OAuth, ou connecteur Fin & Ops, action **Create record**. Le même refus ARC remonte comme erreur d'action.
- **Data management, package Excel** avec l'entité `Customers V3` : la ligne `ARC-O001` est rejetée dans le journal d'exécution avec le même message ARC. C'est l'argument final : une seule règle, tous les canaux.
