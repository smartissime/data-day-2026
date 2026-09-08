# Fiche pratique : étendre Copilot dans D365 F&O en environnement unifié, en 1 heure

Formation D365 F&O Cloud, ARCHIA365.
Objet : partir d'un UDE fonctionnel et obtenir, en une heure, une extension de Copilot écrite en X++ (un « AI tool »), publiée dans Dataverse, branchée dans l'agent Copilot Studio de F&O, et testée depuis le volet Copilot de l'application.
À qui elle s'adresse : développeur ou consultant technique venant d'AX 2009, AX 2012 ou D365 on premise, disposant déjà d'un UDE et d'un Visual Studio configuré (fiche H01), idéalement d'un dépôt Git (fiche H02).
Sources : Microsoft Learn, série « Extend Copilot in finance and operations apps » (AI tools, client plugins, low-code plugins, architecture), état de la documentation au 03/2026. Les AI tools et les client plugins sont en préversion : conditions d'utilisation de préversion, pas de production.

---

## Ce qui change par rapport à ce que vous connaissez

| Avant, AX 2012 et D365 on premise | Maintenant, Copilot en environnement unifié |
|---|---|
| L'utilisateur clique dans un formulaire, le code X++ répond à un clic | L'utilisateur écrit en langage naturel, un orchestrateur choisit le code X++ à appeler |
| Une classe métier est exposée par un menu item ou un service AIF | Une classe métier est exposée par un attribut `[CustomAPI]` et un Custom API Dataverse |
| La sécurité passe par les privilèges des menu items | La sécurité passe toujours par les privilèges des menu items, rien ne change ici |
| L'interface est le client AX, point | L'interface est le volet Copilot dans F&O, mais aussi Teams, Microsoft 365 Copilot, ou un agent maison |
| Une extension se teste en lançant le formulaire | Une extension se teste en posant une question dans le volet Copilot, ou dans le volet de test de Copilot Studio |

La bascule mentale : vous n'écrivez plus le dialogue. Vous écrivez une opération métier bien décrite en langage naturel (nom, description, paramètres décrits), et c'est l'orchestrateur de Copilot Studio qui décide quand l'appeler et avec quelles valeurs. La qualité des descriptions compte autant que la qualité du code.

---

## Les trois façons d'étendre Copilot, et celle que nous faisons

| Approche | Où vit la logique | Quand l'utiliser | Dans cette fiche |
|---|---|---|---|
| **AI tool** (plugin X++ « headless ») | classe X++ avec `[CustomAPI]`, appelée via un Custom API Dataverse ou via le serveur MCP Dynamics 365 ERP | calcul, lecture ou action métier sans dépendance au formulaire ouvert : solde client, stock disponible, création d'une tâche | **Oui, c'est l'heure** |
| **Client plugin** | classe X++ qui étend `SysCopilotChatAction`, exécutée dans le client F&O | action qui a besoin du contexte du formulaire ouvert : naviguer, filtrer, agir sur l'enregistrement courant | Annexe A |
| **Plugin low-code** | topic Copilot Studio, flux Power Automate, AI Builder, entités virtuelles | pas de X++ disponible, ou orchestration de plusieurs sources | Annexe B |

Les trois s'ajoutent au même agent, nommé **Copilot for finance and operations apps**, livré par la solution `msdyn_FnoCopilot`. C'est un agent managé que vous étendez, vous ne le remplacez pas.

---

## Avant l'heure : prérequis

Ces éléments doivent être prêts avant de lancer le chronomètre.

### Côté environnement

- Un UDE à l'état Ready (fiche H01), version d'application 10.0.40 ou postérieure. Les développements Copilot ne sont pas supportés sur les environnements de dev provisionnés par LCS.
- Dans le Power Platform admin center, sur l'environnement de l'UDE, **Resources**, **Dynamics 365 apps** : les applications suivantes installées.

| Application | Rôle |
|---|---|
| **Copilot for finance and operations apps** (contient trois solutions : Copilot, generation, anchor) | l'agent Copilot Studio et le volet Copilot |
| **Finance and Operations Virtual Entity** | entités virtuelles, utiles à l'annexe B et à la plupart des scénarios |

- Power Platform admin center, **Settings**, ligne **Publish bots with AI features** : Enabled. Sans cela, la publication de l'agent échoue.
- Dans F&O, **System administration**, **Workspaces**, **Feature management** : fonctionnalité **(Preview) Custom API Generation** activée.
- Le volet Copilot s'affiche déjà dans F&O : bouton **Copilot** dans la barre de navigation, une question du type « Comment créer un client ? » reçoit une réponse. Si ce n'est pas le cas, traitez d'abord la page Microsoft Learn « Enable Copilot capabilities in finance and operations apps » (Bing search, mouvement de données inter-régions).

### Côté compte

- Votre compte est System Administrator sur F&O et dispose d'un rôle d'auteur dans Copilot Studio sur l'environnement (System Customizer ou Environment Maker suffit pour créer, System Administrator est plus simple pour l'exercice).
- Licence : Copilot Studio est inclus pour l'extension de l'agent F&O dans l'environnement lié. Vérifiez que l'agent **Copilot for finance and operations apps** s'ouvre dans https://copilotstudio.microsoft.com sans message de licence.

### Côté poste

- Visual Studio 2022 configuré selon la fiche H01, Application Explorer fonctionnel, modèle `ARCDeliveryModel` existant (fiche H01 section 4.2 ou fiche H02 section 5.4).
- Un déploiement vers l'UDE déjà réalisé une fois (fiche H01 section 4.7) : vous connaissez la durée sur votre poste, comptez dix à quinze minutes.

Convention de nommage de la fiche : préfixe d'objets `ARC`, éditeur de solution Power Platform `ARCHIA365`, préfixe de solution `arc`. Si votre éditeur a un autre préfixe, remplacez `arc_` partout.

---

## Le scénario : « Quelle est la situation de livraison du client US-001 ? »

Fil rouge ARC Delivery. L'opération X++ reçoit un compte client et rend : le client existe ou non, son nom, sa devise, son solde, sa limite de crédit, et un indicateur de blocage de livraison. Le vendeur pose la question dans le volet Copilot, ou dans Teams, et obtient une réponse en langage naturel sans ouvrir la fiche client.

Pourquoi ce périmètre : une seule entrée, plusieurs sorties, de la logique métier existante (`balanceAllCurrency`, blocage), aucun formulaire nécessaire. C'est le cas typique d'un AI tool.

---

## Plan de l'heure

| Minute | Étape | Résultat visible |
|---|---|---|
| 0 à 5 | 1. Contrôle des prérequis | volet Copilot ouvert, feature activée, agent visible dans Copilot Studio |
| 5 à 20 | 2. Classe X++, menu item, privilège, rôle, build, déploiement lancé | le déploiement vers l'UDE tourne |
| 20 à 30 | 3. Custom API Dataverse | un Custom API `arc_ARCCustomerDeliveryInfo` avec 1 paramètre et 6 propriétés de réponse |
| 30 à 40 | 4. Outil dans l'agent Copilot Studio | l'outil « Get customer delivery info » enregistré, orchestration générative active |
| 40 à 45 | 5. Sécurité et cache côté F&O | rôle affecté, cache vidé, classe visible dans la page Dataverse Custom APIs |
| 45 à 55 | 6. Publication et tests | une réponse correcte dans le volet de test, puis dans le volet Copilot de F&O |
| 55 à 60 | 7. Contrôle et checklist | la checklist cochée, le code poussé dans Git |

Le déploiement vers l'UDE dure dix à quinze minutes. Il se lance à la minute 20 et vous ne l'attendez pas : les étapes 3 et 4 se font entièrement côté Power Platform pendant qu'il tourne.

---

## Étape 1, minute 0 à 5 : contrôle des prérequis

1. Ouvrez l'UDE dans le navigateur, cliquez sur **Copilot** dans la barre de navigation. Le volet s'ouvre à droite. Posez une question quelconque, vous devez avoir une réponse.
2. **System administration**, **Workspaces**, **Feature management**, recherchez `Custom API`. **(Preview) Custom API Generation** doit être Enabled. Sinon activez-la maintenant, cela prend une minute.
3. Ouvrez https://copilotstudio.microsoft.com, sélectionnez l'environnement de l'UDE en haut à droite, **Agents**. L'agent **Copilot for finance and operations apps** doit être listé. Ouvrez-le, onglet **Settings**, **Generative AI** : notez si **Orchestration** est sur Generative ou Classic. Nous en aurons besoin à l'étape 4.
4. Dans Visual Studio, ouvrez la solution `ARCDelivery` et vérifiez que le modèle `ARCDeliveryModel` compile.

---

## Étape 2, minute 5 à 20 : la classe X++ et sa sécurité

### 2.1 Références du modèle

**Extensions**, **Dynamics 365**, **Model management**, **Update model parameters**, modèle `ARCDeliveryModel`. Les références nécessaires pour ce code : `ApplicationPlatform`, `ApplicationFoundation`, `ApplicationSuite`, `ApplicationCommon`, `Currency`, `Directory`. Ajoutez celles qui manquent.

### 2.2 La classe

Dans le projet, **Add**, **New Item**, **Dynamics 365 Items**, **Code**, **Class**, nom `ARCCustomerDeliveryInfo`. Remplacez le contenu :

```xpp
/// <summary>
/// AI tool Copilot : situation de livraison d'un client (fil rouge ARC Delivery).
/// </summary>
[CustomAPI('Get customer delivery info',
    'Returns the delivery situation of a customer: name, currency, current balance, credit limit and whether deliveries are blocked')]
[AIPluginOperationAttribute]
[DataContract]
public final class ARCCustomerDeliveryInfo implements ICustomAPI
{
    private CustAccount   accountNum;
    private boolean       customerFound;
    private Name          customerName;
    private CurrencyCode  currencyCode;
    private AmountCur     balance;
    private AmountMST     creditLimit;
    private boolean       deliveryBlocked;

    [CustomAPIRequestParameter('The customer account number, for example US-001', true),
        DataMember('accountNumber')]
    public CustAccount parmAccountNum(CustAccount _accountNum = accountNum)
    {
        accountNum = _accountNum;
        return accountNum;
    }

    [CustomAPIResponseProperty('True when the customer account exists'),
        DataMember('customerFound')]
    public boolean parmCustomerFound(boolean _customerFound = customerFound)
    {
        customerFound = _customerFound;
        return customerFound;
    }

    [CustomAPIResponseProperty('The customer name'),
        DataMember('customerName')]
    public Name parmCustomerName(Name _customerName = customerName)
    {
        customerName = _customerName;
        return customerName;
    }

    [CustomAPIResponseProperty('The currency code of the customer balance'),
        DataMember('currencyCode')]
    public CurrencyCode parmCurrencyCode(CurrencyCode _currencyCode = currencyCode)
    {
        currencyCode = _currencyCode;
        return currencyCode;
    }

    [CustomAPIResponseProperty('The current open balance of the customer'),
        DataMember('balance')]
    public AmountCur parmBalance(AmountCur _balance = balance)
    {
        balance = _balance;
        return balance;
    }

    [CustomAPIResponseProperty('The credit limit of the customer, zero when no limit is defined'),
        DataMember('creditLimit')]
    public AmountMST parmCreditLimit(AmountMST _creditLimit = creditLimit)
    {
        creditLimit = _creditLimit;
        return creditLimit;
    }

    [CustomAPIResponseProperty('True when the customer is blocked for invoicing and delivery'),
        DataMember('deliveryBlocked')]
    public boolean parmDeliveryBlocked(boolean _deliveryBlocked = deliveryBlocked)
    {
        deliveryBlocked = _deliveryBlocked;
        return deliveryBlocked;
    }

    public void run(Args _args)
    {
        // La societe est fixee pour l'exercice. En reel : ajouter un parametre 'company' en entree.
        changecompany('USMF')
        {
            CustTable custTable = CustTable::find(this.parmAccountNum());

            if (custTable)
            {
                this.parmCustomerFound(true);
                this.parmCustomerName(custTable.name());
                this.parmCurrencyCode(custTable.Currency);
                this.parmBalance(custTable.balanceAllCurrency());
                this.parmCreditLimit(custTable.CreditMax);
                this.parmDeliveryBlocked(custTable.Blocked == CustVendorBlocked::All
                    || custTable.Blocked == CustVendorBlocked::Invoice);
            }
            else
            {
                this.parmCustomerFound(false);
            }
        }
    }
}
```

Ce qu'il faut retenir de cette classe, à lire une fois :

| Élément | Rôle | Ce qui se passe si vous l'oubliez |
|---|---|---|
| `[CustomAPI(nom, description)]` | nom et description lus par l'orchestrateur | la classe n'apparaît pas dans la page Dataverse Custom APIs |
| `[AIPluginOperationAttribute]` | marque la classe comme opération d'IA | idem |
| `[DataContract]` sur la classe, `[DataMember('nom')]` sur chaque méthode | sérialisation JSON, le nom entre quotes est le nom du champ JSON | paramètres vides à l'exécution |
| `[CustomAPIRequestParameter(description, obligatoire)]` | paramètre d'entrée | l'orchestrateur ne sait pas quoi passer |
| `[CustomAPIResponseProperty(description)]` | propriété de sortie | Copilot ne peut pas formuler la réponse |
| `implements ICustomAPI` et `run(Args)` | point d'entrée exécuté par le plugin Dataverse | erreur d'invocation |

Les noms entre quotes dans `DataMember` (`accountNumber`, `balance`, ...) seront retapés à l'identique à l'étape 3. Notez-les.

### 2.3 Le menu item d'action

**Add**, **New Item**, **User Interface**, **Action Menu Item**, nom `ARCCustomerDeliveryInfo`. Propriétés : **Object Type** = Class, **Object** = `ARCCustomerDeliveryInfo`, **Label** = « Get customer delivery info ».

C'est ce menu item qui porte la sécurité. Sans lui, la classe n'est jamais exposée, quel que soit le reste.

### 2.4 Privilège et rôle

1. **Add**, **New Item**, **Security**, **Security Privilege**, nom `ARCCopilotCustomerDeliveryInfoPrivilege`. Dans le nœud **Entry Points**, **New Entry Point** : **Object Type** = MenuItemAction, **Object Name** = `ARCCustomerDeliveryInfo`, **Access Level** = Create.
2. **Add**, **New Item**, **Security**, **Security Role**, nom `ARCSalesCopilotRole`, label « ARC Sales Copilot ». Dans **Privileges**, **New Privilege**, **Name** = `ARCCopilotCustomerDeliveryInfoPrivilege`.

Un rôle dédié plutôt qu'une extension du rôle Sales manager : en préversion, on veut pouvoir retirer la capacité en retirant un rôle.

### 2.5 Build et déploiement

1. **Build** du projet. Zéro erreur, les avertissements sur les préversions sont acceptables.
2. Fenêtre **Git Changes** : commit `Ajout de l AI tool ARCCustomerDeliveryInfo et de sa securite` dans une branche `feature/arc-copilot-tool`. Ne poussez pas encore, vous le ferez à la minute 55.
3. **Extensions**, **Dynamics 365**, **Deploy to Dataverse**, comme dans la fiche H01 section 4.7. Le déploiement démarre. Ne l'attendez pas.

---

## Étape 3, minute 20 à 30 : le Custom API Dataverse

Le Custom API est l'objet Dataverse qui reçoit l'appel et le transmet à votre classe X++ par le plugin `Microsoft.Dynamics.Fno.Copilot.Plugins.InvokeFnoCustomAPI`. Il se crée dans une solution, pour être transportable.

### 3.1 La solution

1. https://make.powerapps.com, environnement de l'UDE, **Solutions**, **New solution**.

| Champ | Valeur |
|---|---|
| Display name | `ARC Delivery Copilot` |
| Name | `ARCDeliveryCopilot` |
| Publisher | `ARCHIA365`, préfixe `arc` (créez l'éditeur s'il n'existe pas : **New publisher**) |

2. **Create**, puis ouvrez la solution.

### 3.2 Le Custom API

**New**, **More**, **Other**, **Custom API** :

| Champ | Valeur |
|---|---|
| Unique Name | `arc_ARCCustomerDeliveryInfo` |
| Name | `Get customer delivery info` |
| Display Name | `Get customer delivery info` |
| Description | `Returns the delivery situation of a customer: name, currency, current balance, credit limit and whether deliveries are blocked` |
| Binding Type | Global |
| Is Function | No |
| Enabled for Workflow | No |
| Allowed Custom Processing Step Type | None |
| Plugin Type | `Microsoft.Dynamics.Fno.Copilot.Plugins.InvokeFnoCustomAPI` |

Règle de nommage, sans exception : `<préfixe>_<nom exact de la classe X++>`. C'est par ce nom que le plugin retrouve la classe. Le champ **Plugin Type** est une recherche : tapez `InvokeFno` et sélectionnez l'entrée. S'il ne trouve rien, la solution Copilot for finance and operations apps n'est pas installée sur cet environnement.

**Save**.

### 3.3 Le paramètre d'entrée

**New**, **More**, **Other**, **Custom API Request Parameter** :

| Champ | Valeur |
|---|---|
| Custom API | Get customer delivery info |
| Unique Name | `arc_ARCCustomerDeliveryInfo_accountNumber` |
| Name | `accountNumber` |
| Display Name | `accountNumber` |
| Description | `The customer account number, for example US-001` |
| Type | String |
| Is Optional | No |

Règle : `<préfixe>_<classe>_<DataMember>`. Le **Name** est exactement le `DataMember` de la classe.

### 3.4 Les propriétés de réponse

**New**, **More**, **Other**, **Custom API Response Property**, six fois. Même règle de nommage.

| Unique Name | Name | Type | Description |
|---|---|---|---|
| `arc_ARCCustomerDeliveryInfo_customerFound` | `customerFound` | Boolean | True when the customer account exists |
| `arc_ARCCustomerDeliveryInfo_customerName` | `customerName` | String | The customer name |
| `arc_ARCCustomerDeliveryInfo_currencyCode` | `currencyCode` | String | The currency code of the customer balance |
| `arc_ARCCustomerDeliveryInfo_balance` | `balance` | Decimal | The current open balance of the customer |
| `arc_ARCCustomerDeliveryInfo_creditLimit` | `creditLimit` | Decimal | The credit limit of the customer, zero when no limit is defined |
| `arc_ARCCustomerDeliveryInfo_deliveryBlocked` | `deliveryBlocked` | Boolean | True when the customer is blocked for invoicing and delivery |

Correspondance des types : `boolean` X++ vers Boolean, `str` et EDT chaîne vers String, `real` et EDT montant vers Decimal, `int` vers Integer, `date` vers DateTime.

Dix minutes pour sept objets, c'est serré. Astuce : ouvrez chaque formulaire de création dans un nouvel onglet, et copiez la ligne `arc_ARCCustomerDeliveryInfo_` une fois pour la coller six fois.

---

## Étape 4, minute 30 à 40 : l'outil dans l'agent Copilot Studio

### 4.1 Ouvrir l'agent

https://copilotstudio.microsoft.com, environnement de l'UDE, **Agents**, **Copilot for finance and operations apps**.

### 4.2 Ajouter l'outil

1. Onglet **Tools**, **Add a tool**.
2. Recherchez le connecteur **Microsoft Dataverse**, puis l'action **Perform an unbound action in selected environment**.
3. **Connection** : **Add and configure**, connectez-vous avec votre compte. Une fois la connexion créée, **Add and configure** ouvre les détails de l'outil.

### 4.3 Configurer l'outil

Section **Details** :

| Champ | Valeur |
|---|---|
| Name | `Get customer delivery info` |
| Description | `Returns the delivery situation of a customer: name, currency, current balance, credit limit and whether deliveries are blocked. Use it when the user asks about a customer's balance, credit, delivery status or whether the customer is blocked.` |

La description de l'outil est le texte que l'orchestrateur lit pour décider d'appeler l'outil. Dites quand l'utiliser, pas seulement ce qu'il fait.

Section **Inputs** :

| Entrée | Fill using | Valeur |
|---|---|---|
| Environment | Custom value | **(Current)** |
| Action Name | Custom value | `arc_ARCCustomerDeliveryInfo` |
| **Add input**, `arc_ARCCustomerDeliveryInfo_accountNumber` | Dynamically fill with AI, **Customize** | Description : `The customer account number, for example US-001` |

Si `arc_ARCCustomerDeliveryInfo_accountNumber` n'apparaît pas dans **Add input**, l'étape 3.3 n'est pas enregistrée, ou la connexion pointe sur un autre environnement.

Section **Completion**, ouvrez **Advanced**, puis pour chaque sortie mettez la description du tableau de l'étape 3.4. Au minimum `balance`, `currencyCode` et `deliveryBlocked` : ce sont elles qui portent la réponse.

**Save**, fermez l'outil.

### 4.4 Orchestration

**Settings**, **Generative AI**, **Orchestration** = **Generative**. **Save**.

Avec l'orchestration générative, l'agent choisit lui-même d'appeler l'outil à partir de la question. Avec l'orchestration classique, il faudrait créer un topic avec des phrases de déclenchement, une question pour obtenir le compte, et un nœud **Call an action** vers l'outil. C'est faisable, mais pas dans l'heure. Si l'organisation impose l'orchestration classique, voyez l'annexe B pour la structure d'un topic.

Ne publiez pas encore : le code X++ doit être déployé et le cache vidé, sinon le premier test échoue et vous perdrez cinq minutes à chercher pourquoi.

---

## Étape 5, minute 40 à 45 : sécurité et cache côté F&O

1. Dans Visual Studio, le déploiement doit être terminé. Sinon, vérifiez dans le Power Platform admin center, **Finance and Operations Package Manager**, **Operation History**, comme dans la fiche H01.
2. Vider le cache des extensions. Dans l'URL de l'UDE :

```
https://<votre-ude>.operations.dynamics.com/?cmp=USMF&mi=SysClassRunner&cls=SysFlushAOD
```

Une page blanche, ou une infolog, c'est normal. Sans ce vidage, la classe fraîchement déployée est inconnue du runtime Copilot.

3. Affecter le rôle : **System administration**, **Security**, **Assign users to roles**, rôle **ARC Sales Copilot**, **Manually assign / exclude users**, ajoutez votre compte. Pour l'exercice, vous êtes déjà System Administrator, mais l'affectation valide que le rôle existe bien après déploiement.
4. Contrôle : **System administration**, **Setup**, **Synchronize Dataverse Custom APIs**. La page **Dataverse Custom APIs** liste les classes qui remplissent les trois conditions : `ICustomAPI`, attribut `[CustomAPI]`, menu item d'action dans un privilège affecté à un rôle. `ARCCustomerDeliveryInfo` doit y figurer. Si la page propose une synchronisation, lancez-la.

Si la classe n'apparaît pas, revenez à la table de l'étape 2.2 : neuf fois sur dix, c'est le menu item ou le privilège.

---

## Étape 6, minute 45 à 55 : publication et tests

### 6.1 Test dans Copilot Studio

1. Dans l'agent, volet **Test** (bouton **Test** en haut à droite).
2. Tapez : `What is the delivery situation of customer US-001?`
3. Attendu : l'orchestrateur affiche qu'il appelle **Get customer delivery info** avec `accountNumber = US-001`, puis une réponse formulée : nom, solde, devise, limite de crédit, blocage.
4. Cliquez sur l'appel d'outil dans la trace pour voir les entrées et sorties brutes. C'est votre journal de débogage.
5. Testez le cas d'erreur : `What about customer ZZ-999?`. Attendu : `customerFound = false`, une réponse disant que le client n'existe pas.

### 6.2 Publier

**Publish**, en haut à droite, puis **Publish** dans la boîte de dialogue. Une à deux minutes. Tant que ce n'est pas publié, le volet Copilot de F&O utilise la version précédente de l'agent.

### 6.3 Test dans le volet Copilot de F&O

1. Dans l'UDE, société USMF, ouvrez **Accounts receivable**, **Customers**, **All customers**, ou n'importe quelle page.
2. Bouton **Copilot** dans la barre de navigation.
3. Tapez en français : `Quelle est la situation de livraison du client US-001 ?`. L'orchestrateur est multilingue, les descriptions en anglais suffisent.
4. La réponse doit reprendre les mêmes valeurs que dans le volet de test.

Vous venez d'exécuter du X++ depuis une phrase en langage naturel, sans formulaire, sans menu, avec la sécurité standard de F&O.

---

## Étape 7, minute 55 à 60 : contrôle et checklist

1. Visual Studio, **Git Changes**, **Push**. Ouvrez la pull request vers `main` selon la fiche H02. La solution Power Platform `ARC Delivery Copilot` sera exportée et versionnée dans la séance ALM Power Platform (DJ6).
2. Cochez la checklist.

---

## Checklist

**Prérequis, avant l'heure**

- [ ] UDE Ready, 10.0.40 ou plus, volet Copilot fonctionnel
- [ ] Applications Copilot for finance and operations apps et Finance and Operations Virtual Entity installées
- [ ] Publish bots with AI features = Enabled
- [ ] Feature (Preview) Custom API Generation activée
- [ ] Agent Copilot for finance and operations apps visible dans Copilot Studio
- [ ] Modèle `ARCDeliveryModel` compilé, un déploiement déjà réalisé

**X++**

- [ ] Classe `ARCCustomerDeliveryInfo` avec `[CustomAPI]`, `[AIPluginOperationAttribute]`, `[DataContract]`, `ICustomAPI`
- [ ] Un `DataMember` par paramètre, noms notés
- [ ] Menu item d'action `ARCCustomerDeliveryInfo`
- [ ] Privilège `ARCCopilotCustomerDeliveryInfoPrivilege`, entry point MenuItemAction, Create
- [ ] Rôle `ARCSalesCopilotRole` contenant le privilège
- [ ] Build sans erreur, déploiement terminé, commit local

**Dataverse**

- [ ] Solution `ARC Delivery Copilot`, éditeur ARCHIA365, préfixe arc
- [ ] Custom API `arc_ARCCustomerDeliveryInfo`, Global, plugin `InvokeFnoCustomAPI`
- [ ] Paramètre `arc_ARCCustomerDeliveryInfo_accountNumber`, String, obligatoire
- [ ] Six propriétés de réponse, types conformes

**Copilot Studio**

- [ ] Outil Dataverse « Perform an unbound action », Action Name = `arc_ARCCustomerDeliveryInfo`, Environment = (Current)
- [ ] Entrée `accountNumber` en Dynamically fill with AI, sorties décrites
- [ ] Orchestration Generative
- [ ] Test OK dans le volet Test, cas d'erreur OK
- [ ] Agent publié

**F&O**

- [ ] `SysFlushAOD` exécuté
- [ ] Rôle ARC Sales Copilot affecté
- [ ] Classe visible dans Dataverse Custom APIs
- [ ] Réponse correcte dans le volet Copilot
- [ ] Code poussé, PR ouverte

---

## Si ça coince

| Symptôme | Cause probable | Ce que vous faites |
|---|---|---|
| Plugin Type `InvokeFnoCustomAPI` introuvable à l'étape 3.2 | solution Copilot for finance and operations apps absente de l'environnement | installez-la depuis le Power Platform admin center, Dynamics 365 apps |
| La classe n'apparaît pas dans Dataverse Custom APIs | menu item, privilège ou rôle manquant, ou cache non vidé | vérifiez les trois objets de sécurité, relancez `SysFlushAOD` |
| Le volet Test appelle l'outil, erreur « action not found » | Unique Name du Custom API différent du nom de la classe, ou mauvais environnement dans l'outil | comparez `arc_ARCCustomerDeliveryInfo` avec le nom de classe, Environment = (Current) |
| L'outil s'exécute, toutes les sorties sont vides | `DataMember` de la classe différent du **Name** du paramètre Dataverse | alignez les deux, respectez la casse |
| L'outil s'exécute, `customerFound = false` pour US-001 | société différente, ou données de démo absentes | vérifiez `changecompany('USMF')` et l'existence du client |
| Erreur de droits à l'exécution | l'utilisateur n'a pas le rôle contenant le privilège du menu item | affectez `ARCSalesCopilotRole` |
| L'orchestrateur n'appelle jamais l'outil | orchestration classique, ou description d'outil trop vague | passez en Generative, enrichissez la description avec « Use it when... » |
| L'agent ne se publie pas | Publish bots with AI features désactivé | activez-le dans le Power Platform admin center, Settings |
| Le volet Copilot répond avec l'ancien comportement | agent non publié, ou cache navigateur | **Publish**, puis rechargez F&O |
| Le volet Copilot n'apparaît pas dans F&O | Copilot non activé sur l'environnement | page Microsoft Learn « Enable Copilot capabilities », Bing search et région |
| Réponse en anglais alors que la question est en français | comportement possible en préversion | ajoutez une instruction dans **Settings**, **Instructions** de l'agent : répondre dans la langue de l'utilisateur |
| Le déploiement n'est pas terminé à la minute 40 | premier déploiement lent | poursuivez l'étape 4 au complet, testez d'abord dans le volet Test à la fin du déploiement |

---

## Annexe A : client plugin, agir dans le formulaire ouvert

Un AI tool ne connaît pas le formulaire ouvert. Quand l'action a besoin de ce contexte, naviguer, filtrer, agir sur l'enregistrement courant, on écrit un client plugin : une classe qui étend `SysCopilotChatAction`, exécutée dans le client F&O. Même prérequis, environnement unifié et version 10.0.40 ou plus, préversion.

Exemple, ouvrir un formulaire à la demande :

```xpp
[SysCopilotChatActionDefinition(
    identifierStr(MS.PA.ARC.ClientNavigate),
    'Navigate',
    'Navigates to or opens a defined form in the application client',
    menuItemActionStr(ARCCopilotNavigateAction), MenuItemType::Action)]
[SysCopilotChatGlobalAction]
[DataContract]
public class ARCCopilotNavigateAction extends SysCopilotChatAction
{
    private MenuItemName menuItemName;
    private str navResponse;

    [DataMember('menuItemName'),
    SysCopilotChatActionInputParameter('The name of the menu item for the form to launch', true)]
    internal MenuItemName parmMenuItemName(MenuItemName _menuItemName = menuItemName)
    {
        menuItemName = _menuItemName;
        return menuItemName;
    }

    [DataMember('navResponse'),
    SysCopilotChatActionOutputParameter('The response from the navigation')]
    public str parmNavResponse(str _navResponse = navResponse)
    {
        navResponse = _navResponse;
        return navResponse;
    }

    public void executeAction(SysCopilotChatActionDefinitionAttribute _actionDefinition, Object _context)
    {
        super(_actionDefinition, _context);

        if (this.parmMenuItemName())
        {
            MenuFunction::runClient(this.parmMenuItemName(), MenuItemType::Display, false, new Args());
            this.parmNavResponse("You were navigated to the " + menuItemName + " form.");
        }
        else
        {
            throw Error(Error::wrongUseOfFunction(funcName()));
        }
    }
}
```

Points à retenir :

| Élément | Règle |
|---|---|
| Identifiant | commence obligatoirement par `MS.PA`, déclaré avec `identifierStr()` |
| Menu item | un menu item d'action `ARCCopilotNavigateAction` porte la sécurité, comme pour l'AI tool |
| Portée | `[SysCopilotChatGlobalAction]` pour tous les formulaires ; `[ExportMetadata(formStr(SalesTable), identifierStr(FormName))]` avec `[Export(identifierstr(Microsoft.Dynamics.AX.Application.SysCopilotChatAction))]` pour un formulaire précis ; `SysCopilotChatAction::addToCopilotRuntimeActions()` pour un ajout à l'exécution |
| Côté Copilot Studio | un nœud **Event activity** dont le **Name** est l'identifiant et le **Value** un JSON `{"menuItemName": "SalesTable"}` ; le retour arrive par un topic à déclencheur **Event received** de même nom, payload dans `System.Activity.Text`, à décoder avec **Parse value** |

En l'état de la documentation, l'appel d'un client plugin passe par un topic. Microsoft annonce l'invocation par orchestration générative dans une version ultérieure.

## Annexe B : plugin low-code, sans X++

Le tutoriel Microsoft « Create low-code plugins » montre la même mécanique sans Visual Studio : dans l'agent **Copilot for finance and operations apps**, onglet **Topics**, un topic déclenché par une phrase, une condition sur le contexte de page (`Global.PA_Copilot_ServerForm_PageContext.metadataName` égal au nom du formulaire, `titleField1Value` pour l'enregistrement courant), un flux Power Automate qui lit une entité virtuelle (`List rows` sur `Courses V2 (mserp)`), un prompt AI Builder, puis **Send a message**. Publication et test identiques aux étapes 6.2 et 6.3.

Deux usages pour vous : le contexte de page (`PA_Copilot_ServerForm_PageContext`) est disponible dans tout topic, y compris pour alimenter l'entrée `accountNumber` de votre AI tool quand l'utilisateur est sur la fiche client ; et les entités virtuelles couvrent la lecture simple sans écrire une ligne de X++.

## Annexe C : le serveur MCP Dynamics 365 ERP

La même classe `ARCCustomerDeliveryInfo`, déployée avec sa sécurité, est automatiquement exposée par le serveur **Dynamics 365 ERP MCP** aux agents qui l'utilisent, via les outils `find_actions` et `invoke_action`, sans Custom API Dataverse. C'est la voie à regarder pour les agents Copilot Studio maison et Microsoft 365 Copilot. L'étape 3 de cette fiche reste nécessaire pour l'agent F&O livré par Microsoft.

---

## Pour aller plus loin

- Microsoft Learn, [Extend Copilot in finance and operations apps](https://learn.microsoft.com/en-us/dynamics365/fin-ops-core/dev-itpro/copilot/extend-copilot)
- Microsoft Learn, [Architecture of Copilot in finance and operations apps](https://learn.microsoft.com/en-us/dynamics365/fin-ops-core/dev-itpro/copilot/copilot-architecture)
- Microsoft Learn, [Create AI plugins for copilots with finance and operations business logic](https://learn.microsoft.com/en-us/dynamics365/fin-ops-core/dev-itpro/copilot/copilot-ai-plugins)
- Microsoft Learn, [Tutorial: Create AI tools for copilots with finance and operations business logic](https://learn.microsoft.com/en-us/dynamics365/fin-ops-core/dev-itpro/copilot/tutorial-create-ai-plugins)
- Microsoft Learn, [Create client plugins for Copilot in finance and operations apps](https://learn.microsoft.com/en-us/dynamics365/fin-ops-core/dev-itpro/copilot/copilot-client-plugins)
- Microsoft Learn, [Tutorial: Create low-code plugins](https://learn.microsoft.com/en-us/dynamics365/fin-ops-core/dev-itpro/copilot/tutorial-create-low-code-plugins)
- Microsoft Learn, [Enable Copilot capabilities in finance and operations apps](https://learn.microsoft.com/en-us/dynamics365/fin-ops-core/dev-itpro/copilot/enable-copilot)
- Microsoft Learn, [TechTalk: Extending Copilot in Dynamics 365 finance and operations apps](https://learn.microsoft.com/en-us/dynamics365/guidance/techtalks/dynamics-365-finance-operations-apps-copilot-extend)
- Microsoft Learn, [Turn on generative orchestration for an agent](https://learn.microsoft.com/en-us/microsoft-copilot-studio/advanced-generative-actions#turn-on-generative-orchestration-for-an-agent)
