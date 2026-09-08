# Fiche H04 : un rapport Power BI service (Fabric) sur les données de D365 F&O en environnement unifié, intégré dans un espace de travail F&O, en 1 heure

Formation D365 F&O Cloud, ARCHIA365. Fiche participant.
Position dans la formation : DJ6, slot Power BI, après Power Apps et avant AI Builder. S'appuie sur H01 pour l'UDE et sur les démos D03 à D08 pour le modèle `ARCDeliveryModel` et le champ `ARCDeliveryPriority` de `CustTable`.
Sources : Microsoft Learn, « Configure your environment and link to Microsoft Fabric » (mise à jour 08/2026), « Choose finance and operations data in Azure Synapse Link for Dataverse », « Configure Power BI integration for workspaces » (10/2025), « Pin Power BI reports to workspaces » (01/2026), « Removed or deprecated platform features », et l'annonce Power Platform du 09/06/2026 sur la synchronisation à faible latence (low-latency sync).

---

## Ce qui change par rapport à AX et à D365 on-premises

| Monde AX 2012 et D365 on-premises | Monde unifié (F&O + Dataverse + Fabric) |
|---|---|
| Cubes SSAS sur la base de production, ou BYOD sur SQL Server | Fabric Link : copie continue des tables F&O dans OneLake, au format Delta Parquet, sans ETL à écrire |
| Entity store et espaces de travail analytiques embarqués (.pbix dans le modèle, Power BI Embedded) | rapport construit dans le service Power BI (Fabric), épinglé dans un espace de travail F&O par le catalogue de rapports |
| Export to Data Lake, puis Azure Synapse Link | Export to Data Lake retiré le 01/11/2024, arrêt définitif le 30/11/2026 ; Fabric Link est la cible recommandée |
| Rafraîchissement planifié par jobs, lecture sur la base de production | synchronisation gérée par la plateforme, fraîcheur de l'ordre de l'heure, et à la minute avec la faible latence (GA juillet 2026) |
| Sécurité par rôles AX, non transposée dans les cubes | sécurité à reconstruire dans Power BI (RLS) et dans OneLake, pas héritée de F&O |
| Serveur SQL à dimensionner et à payer | capacité Fabric, ou capacité d'essai Fabric pour apprendre |

Ce qui ne change pas : la connaissance des tables. `CustTable`, `SalesTable`, `SalesLine`, `DataArea` sont dans le lakehouse avec leurs noms et leurs champs. Vingt ans d'AX servent ici plus qu'ailleurs.

## Les trois chemins pour ramener des données F&O dans Power BI

| Chemin | Quand | Ce que ça coûte |
|---|---|---|
| **Fabric Link, tables F&O** (cette heure) | reporting de volume, historique, plusieurs sociétés, jointures entre tables | une capacité Fabric, un suivi de change tracking |
| **Fabric Link, entités F&O** (`mserp_...`) | quand la logique de l'entité vaut la peine (par exemple `mserp_MainAccountBiEntity`), au prix d'une matérialisation | entités virtuelles à activer, puis Track changes |
| **Connecteur OData ou Dataverse depuis Power BI Desktop** | prototype, petit volume, une seule société | rien, mais lecture directe sur l'AOS, pas pour la production |

Le résultat de l'heure : un rapport **ARC Delivery Dashboard**, construit sur `CustTable`, `SalesTable`, `SalesLine` et `DataArea` de l'UDE, qui montre les clients et les commandes par priorité de livraison `ARCDeliveryPriority`, et qui s'ouvre en pleine page depuis un espace de travail F&O nommé **ARC Delivery**.

---

## Étape 0, avant la séance : prérequis

Les prérequis ont été préparés la veille par le formateur sur l'environnement de séance. Vérifiez-les en trois minutes, ils sont la moitié de la réussite.

| Prérequis | Où vérifier |
|---|---|
| UDE **Ready**, version 10.0.47 ou plus (pour la synchronisation à faible latence ; 10.0.38 minimum pour les tables F&O) | F&O, **Help & Support**, **About** |
| Compte de séance **System Administrator** côté Power Platform et côté F&O | Power Platform admin center, fiche de l'environnement |
| Une capacité Fabric, ou un **essai Fabric** actif, dans la **même région géographique** que l'environnement Dataverse | app.powerbi.com, espace de travail, **Workspace settings**, **License info** |
| Paramètres tenant Fabric : **Users can create Fabric items**, **Create workspaces**, **Users can access data stored in OneLake with apps external to Fabric** | Portail admin Fabric, **Tenant settings** |
| Espace de travail Fabric **ARC Delivery Analytics** sur la capacité, avec une **Workspace identity** créée | Fabric, **Workspace settings**, **Workspace identity** |
| Cette identité ajoutée comme **application user** dans Dataverse avec le rôle System Administrator | Power Platform admin center, **Users**, **App users list** |
| Modèle `ARCDeliveryModel` déployé, champ `ARCDeliveryPriority` présent sur `CustTable` avec des valeurs renseignées sur quelques clients USMF | F&O, **Accounts receivable**, **All customers** |

Si un point manque, ne passez pas à l'étape 2 : la création du lien échouera ou vous donnera un lakehouse vide.

---

## Étape 1, minute 3 à 10 : côté F&O, rendre les tables exportables

Fabric Link n'exporte une table F&O que si elle porte le **row version change tracking**. Les tables standard courantes l'ont déjà ; une table personnalisée ne l'a jamais par défaut.

1. F&O, **System administration**, **Setup**, **Row version change tracking**.
2. Recherchez `CustTable`, `SalesTable`, `SalesLine`, `CustGroup`. Elles doivent être à l'état activé. Notez la colonne d'état pour les quatre.
3. Lancez le rapport **Data entity row version change tracking validation report** : il liste les tables et entités qui passent ou échouent les règles. Une table qui échoue ne pourra pas être choisie à l'étape 2.
4. Si votre modèle contient une table personnalisée (par exemple une table de journal de livraison), activez-la ici. En environnement unifié, aucune synchronisation de base n'est nécessaire après activation ; c'était requis sur les CHE.
5. Vérifiez qu'un client USMF a une valeur dans `ARCDeliveryPriority` : **Accounts receivable**, **All customers**, `US-001`, onglet où le champ a été posé en D03. Sans valeurs, le rapport sera plat.

À retenir : `DataArea` est une table « kernel ». Elle est exportée sans change tracking, mais rafraîchie toutes les 24 heures seulement. Parfait pour une liste de sociétés, inutile pour du transactionnel.

---

## Étape 2, minute 10 à 20 : créer le lien vers Fabric

1. https://make.powerapps.com, sélecteur d'environnement en haut à droite : **votre UDE**. C'est l'erreur numéro un : un lien créé sur le mauvais environnement.
2. Volet gauche, **Link data** (sous **More** s'il n'est pas visible). La page montre deux sections, **Fabric Links** et **Other Links**.
3. **+ New link**, tuile **Link data via Fabric** (marquée Recommended).
4. Assistant, étape **Getting started** : l'assistant vérifie qu'une capacité Fabric existe dans la géographie de Dataverse. Si une notification demande d'obtenir une capacité, arrêtez-vous : c'est le prérequis 3 de l'étape 0. **Next**.
5. Étape **Setup configuration** :
   - **Workspace** : `ARC Delivery Analytics`.
   - Connexion : l'assistant détecte la **Workspace identity** de l'espace et la propose. Prenez-la. Le compte organisationnel fonctionne aussi mais lie le lien à votre compte personnel, ce qu'on évite en projet. Le service principal est le troisième choix, pour l'automatisation.
   - Attendez la confirmation de connexion, **Next**.
6. Étape **Select tables** :
   - Les tables Dataverse avec **Track changes** sont précochées. Décochez-les toutes pour l'exercice : seules les tables cochées consomment du stockage Fabric.
   - Les tables F&O apparaissent dans la même liste parce que l'environnement est unifié. Elles ne sont **jamais** précochées.
   - Collez dans la recherche : `CustTable, SalesTable, SalesLine, CustGroup, DataArea` (la recherche accepte une liste séparée par des virgules) et cochez les cinq.
   - **Next**.
7. Étape **Review and create**, **Finish**. L'assistant crée le lakehouse, les raccourcis OneLake et lance la première synchronisation. Vous atterrissez dans le volet **Manage tables** du nouveau lien.

Ne l'attendez pas. La première synchronisation prend jusqu'à 60 minutes, et plus sur de grosses tables. Le rapport de l'heure se construit sur le lien préparé la veille par le formateur, identique à celui que vous venez de créer. Vous reviendrez sur le vôtre après la pause.

Ce qu'il faut retenir de l'assistant :

| Élément | Rôle |
|---|---|
| **Link data** | une page par environnement Dataverse, un lien Fabric par environnement |
| **Workspace identity** | l'identité qui lit Dataverse et écrit dans OneLake ; c'est elle qui porte le rôle System Administrator, pas vous |
| **Manage tables** | l'écran de la vie courante : ajouter, retirer, suivre l'état **Active** d'une table |
| **Refresh Fabric tables** | à lancer après tout ajout de colonne côté F&O, sinon la nouvelle colonne n'arrive pas |
| **Low-latency mode** | drapeau sur le lien dans la liste : synchronisation directe en Delta Parquet, plus d'un million de lignes par heure et par table F&O |

---

## Étape 3, minute 20 à 35 : dans Fabric, du lakehouse au modèle sémantique

Ouvrez le lien préparé la veille : **Link data**, section **Fabric Links**, lien `ARCFODEVxx`, bouton **View in Microsoft Fabric**. Vous arrivez dans l'espace `ARC Delivery Analytics`.

### 3.1 Lire le lakehouse

1. Ouvrez le lakehouse. Son nom est généré, de la forme `<environnement>_<profil>_<espace>_<valeur>`. Ne prenez jamais de dépendance sur ce nom, Microsoft prévient qu'il changera ; les identifiants stables sont l'ID de l'espace et l'ID du lakehouse.
2. Dossier **Tables** : `custtable`, `salestable`, `salesline`, `custgroup`, `dataarea`. Ce sont des raccourcis OneLake vers les données synchronisées.
3. Ouvrez `custtable`. Retrouvez `accountnum`, `custgroup`, `dataareaid`, votre champ `arcdeliverypriority`, et les colonnes ajoutées par la synchronisation : `isdelete`, `sysrowversion`, `createdon`, `modifiedon`, `sinkmodifiedon`, `sysdatastatecode`. La casse des noms suit votre lakehouse ; lisez-la à l'écran avant d'écrire une mesure.
4. Basculez en **SQL analytics endpoint** (menu en haut à droite du lakehouse). Une requête pour se convaincre :

```sql
SELECT dataareaid, arcdeliverypriority, COUNT(*) AS customers
FROM custtable
WHERE isdelete = 0 OR isdelete IS NULL
GROUP BY dataareaid, arcdeliverypriority
ORDER BY dataareaid, arcdeliverypriority;
```

Les enums F&O arrivent en valeurs numériques. Les libellés sont dans la table `GlobalOptionsMetadata`, exportée automatiquement ; vous la joindrez dans un vrai projet, pas dans l'heure.

À retenir sur les lignes supprimées : elles restent avec `isdelete = 1` pendant 28 jours. Tout modèle filtre `isdelete`.

### 3.2 Créer le modèle sémantique

1. Depuis le lakehouse, **New semantic model**.
2. Nom : `ARC Delivery Model`. Cochez `custtable`, `salestable`, `salesline`, `custgroup`, `dataarea`. **Confirm**.
3. Le modèle s'ouvre en mode **Direct Lake** : Power BI lit directement les fichiers Delta de OneLake, sans import ni rafraîchissement planifié. C'est la différence de fond avec un cube : il n'y a plus de « process ».
4. Relations, avec **Manage relationships** ou par glisser dans la vue modèle :

| De | Vers | Cardinalité | Remarque |
|---|---|---|---|
| `salestable[custaccount]` | `custtable[accountnum]` | plusieurs à un | pour l'exercice, une seule société ; en projet, une clé composée `dataareaid + accountnum` créée en amont (vue SQL ou Dataflow Gen2), Direct Lake n'acceptant pas les colonnes calculées |
| `salesline[salesid]` | `salestable[salesid]` | plusieurs à un | |
| `custtable[custgroup]` | `custgroup[custgroup]` | plusieurs à un | |
| `custtable[dataareaid]` | `dataarea[id]` | plusieurs à un | |

5. Renommez la table `dataarea` en **`Company`** et sa colonne `id` en **`ID`**. Ce n'est pas cosmétique : c'est la convention que F&O utilise pour appliquer le filtre de société courante à un rapport épinglé (étape 5).
6. Renommez `arcdeliverypriority` en **Delivery priority**, `accountnum` en **Customer**, `name` en **Customer name** si la colonne est dans la table.
7. Mesures, sur `salesline` :

```dax
Order count = DISTINCTCOUNT ( salestable[salesid] )
Sales amount = SUM ( salesline[lineamount] )
Active customers = CALCULATE ( DISTINCTCOUNT ( custtable[accountnum] ), custtable[isdelete] = 0 )
```

8. Filtre de modèle : dans chaque table transactionnelle, marquez `isdelete` masqué, et prévoyez un filtre `isdelete = 0` au niveau du rapport (étape 4). Un filtre RLS sur `isdelete` est aussi possible.
9. **Save**.

---

## Étape 4, minute 35 à 45 : le rapport dans le service Power BI

1. Depuis le modèle `ARC Delivery Model`, **Create report**, **Start from scratch**. Vous êtes dans l'éditeur web du service : pas de Power BI Desktop nécessaire pour l'heure.
2. Filtre de niveau rapport : `custtable[isdelete]` = 0 et `salestable[isdelete]` = 0.
3. Quatre visuels, ni plus :
   - **Card** : `Active customers`.
   - **Clustered bar chart** : axe `Delivery priority`, valeur `Order count`.
   - **Table** : `Customer`, `Customer name`, `Delivery priority`, `Sales amount`, triée sur `Sales amount` décroissant.
   - **Slicer** : `Company[ID]`.
4. Titre de page : `ARC Delivery`. **Save**, nom **`ARC Delivery Dashboard`**, espace `ARC Delivery Analytics`.
5. Testez le slicer : `USMF` doit changer les chiffres. Si tout est à zéro, revenez à l'étape 1.5.

À retenir : le rapport est un objet du service Power BI, versionné et partagé par le service, pas par F&O. F&O n'en aura qu'un lien.

---

## Étape 5, minute 45 à 55 : intégrer le rapport dans un espace de travail F&O

L'intégration passe par la **PowerBI.com configuration** de F&O : une inscription d'application Microsoft Entra qui autorise F&O à lire votre compte Power BI, puis un catalogue de rapports dans les espaces de travail. Elle est identique en environnement unifié, seule l'URL de redirection change.

### 5.1 Inscription d'application Entra (préparée la veille, à relire)

1. https://portal.azure.com, **Microsoft Entra ID**, **App registrations**, **New registration**.
2. **Name** : `ARC-FO-PowerBI`. **Supported account types** : Single tenant. **Redirect URI** : type **Web**, valeur = URL de base de votre UDE suivie de `/oauth`, par exemple `https://<votre-ude>.sandbox.operations.dynamics.com/oauth`. Copiez l'URL depuis la barre d'adresse de F&O, sans chemin ni paramètre.
3. Notez l'**Application (client) ID**.
4. **API permissions**, **Add a permission**, **Microsoft APIs**, **Power BI Service**, permissions **déléguées** : `Content.Create`, `Dashboard.Read.All`, `Dataset.Read.All`, `Dataset.ReadWrite.All`, `Report.Read.All`, `Workspace.Read.All`. **Grant admin consent** si votre tenant l'exige.
5. **Certificates & secrets**, **New client secret**, notez la **Value** immédiatement : elle ne se réaffiche plus.

### 5.2 Configuration côté F&O

1. F&O, **System administration**, **Setup**, **PowerBI.com configuration**.
2. **Edit**, **Enabled** = Yes, **Application ID** = l'ID de 5.1.3, **Application key** = la valeur de 5.1.5. **Save**.
3. Rafraîchissez le navigateur.

### 5.3 Créer l'espace de travail et épingler le rapport

1. Page d'accueil F&O, clic droit sur une tuile d'espace de travail, **Add a workspace**. Un espace **My Workspace 1** est créé ; renommez-le **ARC Delivery**. Un espace créé par un développeur avec une section **Links** fonctionne de la même façon, par exemple **Ledger budgets and forecasts**.
2. Ouvrez l'espace, onglet **Options**, **Open report catalog**.
3. Au premier appel, F&O demande l'autorisation : **Click here to provide authorization to Power BI**, page de consentement Entra, **Accept**, puis autorisez dans le nouvel onglet.
4. Le catalogue liste les rapports de votre compte Power BI. Cochez **ARC Delivery Dashboard**, **OK**.
5. Une section **Power BI Reports** apparaît dans la section **Links** de l'espace. Cliquez le lien : le rapport s'ouvre en pleine page dans le client F&O, avec ses filtres croisés et son volet de filtres.
6. Changez de société dans F&O (`USMF` vers `USRT`) et rouvrez le rapport : la table `Company` avec sa colonne `ID` est ce qui permet à F&O d'appliquer la société courante.

Si le consentement échoue après **Accept**, un administrateur doit vérifier dans Entra, **Users**, **User settings**, que **Users can consent to apps accessing company data on their behalf** est à Yes.

Licences : le paramétrage ne demande pas de licence Pro, mais chaque utilisateur qui ouvre le rapport depuis F&O doit avoir une licence Power BI valide, ou l'espace doit être sur une capacité qui autorise les lecteurs sans licence.

---

## Étape 6, minute 55 à 60 : contrôle et fermeture de boucle

Checklist :

- [ ] Lien Fabric de votre UDE visible sous **Fabric Links**, tables à l'état **Active** ou en cours de synchronisation initiale
- [ ] Lakehouse ouvert, `custtable` contient `arcdeliverypriority`
- [ ] Modèle `ARC Delivery Model` en Direct Lake, table `Company` avec colonne `ID`, trois mesures
- [ ] Rapport `ARC Delivery Dashboard` enregistré dans `ARC Delivery Analytics`
- [ ] **PowerBI.com configuration** activée, inscription `ARC-FO-PowerBI` avec le bon URI `/oauth`
- [ ] Espace de travail **ARC Delivery** avec le rapport dans **Links**, ouverture en pleine page, changement de société pris en compte

Après la pause, revenez sur votre propre lien : **Manage tables**, état **Active** sur les cinq tables. Rouvrez le lakehouse, relancez la requête SQL de l'étape 3.1. Puis modifiez `ARCDeliveryPriority` d'un client dans F&O et chronométrez l'arrivée du changement dans le lakehouse : c'est la latence réelle de votre tenant, à connaître avant de promettre quoi que ce soit à un utilisateur.

---

## Annexe A : ce qu'il advient de l'Entity store et des espaces de travail analytiques

Sur AX 2012 et les premières versions de D365, le reporting embarqué reposait sur l'Entity store (mesures agrégées dans `AxDW`), les espaces de travail analytiques (fichiers .pbix dans le modèle, rendus par Power BI Embedded) et BYOD. Ces mécanismes existent encore dans la documentation, mais tout ce que Microsoft investit depuis 2024 va vers Fabric Link : Export to Data Lake est retiré (arrêt définitif 30/11/2026), Synapse Link est la voie de transition, et Fabric Link la cible avec la synchronisation à faible latence en GA depuis juillet 2026.

Recommandation pour un nouveau développement en environnement unifié : ne créez plus de mesures d'Entity store ni de .pbix embarqué. Construisez sur Fabric Link, publiez dans le service, épinglez dans F&O. Le catalogue de rapports (étape 5) est le point de rencontre des deux mondes et ne dépend d'aucune de ces briques héritées.

## Annexe B : Direct Lake, Import, DirectQuery

| Mode | Données | Fraîcheur | Quand |
|---|---|---|---|
| **Direct Lake** (étape 3) | lues dans OneLake | celle de Fabric Link, sans rafraîchissement planifié | par défaut sur un lakehouse Fabric ; pas de colonnes ni tables calculées, transformations à faire en amont (vue SQL, Dataflow Gen2, notebook) |
| **Import** | copiées dans le modèle | au rafraîchissement | Power BI Desktop, transformations Power Query, petits et moyens volumes |
| **DirectQuery** sur le SQL analytics endpoint | requêtes à la volée | temps réel sur le lakehouse | rare ; préférer Direct Lake |

Direct Lake peut basculer en DirectQuery (fallback) quand une requête dépasse ses limites ; le comportement se règle dans les paramètres du modèle.

## Annexe C : sécurité, ce qui n'est pas hérité

- Les rôles F&O, l'extensible data security et les autorisations AOS ne suivent pas les données dans OneLake. Depuis 10.0.39, l'EDS ne bloque plus l'export ; c'est donc à vous de resécuriser.
- Trois niveaux à combiner : accès à l'espace Fabric (rôles Viewer, Contributor), **OneLake security** sur le lakehouse et ses tables, et **RLS** dans le modèle sémantique (par exemple une règle sur `Company[ID]` ou sur `custtable[dataareaid]`).
- Le lien est créé avec la Workspace identity, pas avec un compte nominatif : un départ de collaborateur ne casse pas la synchronisation. Si un lien historique a été créé avec un compte organisationnel, Fabric, **Settings**, **Manage connections and gateways**, connexion de l'environnement, **Authentication method** = Workspace identity.
- Partage de la connexion Dataverse : même écran, **Manage users**, rôle **Reader** pour la consommation.

## Annexe D : entités F&O plutôt que tables

Quand la logique d'une entité vaut la matérialisation (par exemple `mserp_MainAccountBiEntity`, `mserp_ExchangeRateBiEntity`, `mserp_InventTableBiEntity`) :

1. Activer les entités virtuelles Dataverse pour F&O (comme en H03, application **Finance and Operations Virtual Entity**).
2. Power Apps, **Tables**, table `mserp_...`, **Properties**, **Advanced options**, **Track changes**.
3. L'entité apparaît alors dans **Manage tables** sous les tables Dataverse, et se coche comme les autres.

Les entités de migration de données ne passent pas la validation et ne peuvent pas être suivies ; le rapport de validation de l'étape 1.3 le dit avant que vous ne perdiez du temps.
