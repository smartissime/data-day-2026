# Procédure de préparation de l'environnement de démonstration

*Formation Dynamics 365 Sales, niveau Product Owner / Business Analyst · Pas à pas pour un non-expert*

ARCHIA365

Cette procédure explique, étape par étape, comment préparer l’environnement Dynamics 365 Sales utilisé pendant les deux jours de formation. Elle est écrite pour une personne qui n’a jamais administré Dynamics 365 : chaque étape indique où cliquer, quoi saisir, comment vérifier que c’est réussi et quoi faire si cela bloque.

## Avant de commencer

### Ce que vous allez construire

Un environnement Dynamics 365 Sales **Enterprise** (la licence de Hager), sans personnalisation, qui contient la société fictive ARCHIFRIDAYS, ses utilisateurs, son catalogue, ses clients, ses 47 leads de salon, son pipeline du quatrième trimestre et quelques automatisations de démonstration. Toutes les données viennent du dossier `05_Jeu_de_donnees` du kit.

### Durée et calendrier

| Phase | Contenu                                   | Échéance   | Durée estimée                           |
|-------|-------------------------------------------|------------|-----------------------------------------|
| A     | Comptes, outils et fichiers               | J-21       | 1 h                                     |
| B     | Création de l’environnement               | J-15       | 1 h (plus l’attente du provisionnement) |
| C     | Organisation et utilisateurs              | J-15       | 2 h                                     |
| D     | Paramètres de base                        | J-14       | 1 h 30                                  |
| E     | Import des données                        | J-12       | 3 h                                     |
| F     | Saisies manuelles (devis, activités)      | J-11       | 2 h                                     |
| G     | Fonctions démontrées, épisode par épisode | J-10 à J-7 | 5 h                                     |
| H     | Répétition et contrôles                   | J-5        | 3 h                                     |
| I     | Remise à zéro avant la session            | J-1        | 1 h                                     |

Prévoyez au total trois jours de travail répartis sur trois semaines. Ne commencez pas plus tard que J-15 : un environnement d’essai dure en général 30 jours, et certaines fonctions mettent plusieurs heures à s’activer.

### Comment lire chaque étape

- **Où :** le chemin dans l’interface, sous la forme `Application > Zone > Menu`.
- **Faire :** les actions numérotées.
- **Saisir :** les valeurs exactes (copiez-les depuis le jeu de données).
- **Contrôle :** ce que vous devez voir si l’étape a réussi.
- **Si ça bloque :** la cause la plus fréquente et la solution.

> **Important.** Microsoft fait évoluer l’interface deux fois par an. Si un menu n’est pas exactement à l’endroit indiqué, utilisez la zone de recherche en haut de la page (ou la recherche des paramètres) avec le nom anglais indiqué entre parenthèses, par exemple « Business units ». Les noms anglais sont stables d’une version à l’autre.

### Les adresses à connaître

| Outil                                  | Adresse                                                                        | À quoi il sert                                                                 |
|----------------------------------------|--------------------------------------------------------------------------------|--------------------------------------------------------------------------------|
| Centre d’administration Microsoft 365  | admin.microsoft.com                                                            | Créer les utilisateurs et attribuer les licences                               |
| Centre d’administration Power Platform | admin.powerplatform.microsoft.com                                              | Créer l’environnement, unités commerciales, sécurité, paramètres de messagerie |
| Power Apps (portail des créateurs)     | make.powerapps.com                                                             | Colonnes, solutions, application Power Apps                                    |
| Power Automate                         | make.powerautomate.com                                                         | Flux d’approbation des remises                                                 |
| Application Sales Hub                  | lien affiché dans l’environnement (Power Platform \> Environnements \> Ouvrir) | Toutes les données et la plupart des paramètres Sales                          |

## Phase A : comptes, outils et fichiers (J-21)

### A1. Réunir les accès

**Faire :**

1.  Obtenez un compte professionnel Microsoft (pas un compte personnel Outlook.com ou Hotmail). Si vous n’en avez pas, l’inscription à l’essai Dynamics 365 Sales en crée un.
2.  Vérifiez que vous pourrez être **administrateur global** du locataire d’essai (c’est le cas si vous créez l’essai vous-même).
3.  Si vous voulez démontrer la synchronisation des e-mails (épisode 6), prévoyez aussi un essai Microsoft 365 (par exemple Business Standard ou E3) dans le **même** locataire, pour disposer de boîtes aux lettres Exchange Online. Sinon, cette démonstration se fera en captures d’écran.

**Contrôle :** vous pouvez vous connecter à admin.microsoft.com avec ce compte.

### A2. Préparer le poste

**Faire :**

1.  Navigateur Microsoft Edge ou Google Chrome à jour ; une fenêtre de navigation privée servira à vous connecter avec un second utilisateur.
2.  Microsoft Word et Excel installés (bureau), pour le modèle de devis et les classeurs d’atelier.
3.  Power BI Desktop (gratuit) si vous préparez le rapport d’historique de prévision (étape G13).
4.  Décompressez le kit dans un dossier local, par exemple `C:\Formation_D365_Sales`.

**Contrôle :** vous ouvrez sans erreur `05_Jeu_de_donnees/Jeu_de_donnees_ARCHIFRIDAYS.xlsx` et le dossier `CSV_import_Dataverse` contient 14 fichiers.

### A3. Préparer un journal de bord

Créez un document où vous noterez, au fur et à mesure : l’adresse de l’environnement, les identifiants des utilisateurs de démonstration, et chaque problème rencontré. Il vous servira pendant la session et pour la remise à zéro.

## Phase B : création de l’environnement (J-15)

### B1. Démarrer l’essai Dynamics 365 Sales

**Où :** site Microsoft Dynamics 365, page Sales, bouton « Essai gratuit » (Free trial).

**Faire :**

1.  Choisissez l’essai de **Dynamics 365 Sales** (Sales Enterprise).
2.  Connectez-vous avec le compte de l’étape A1, ou créez-en un.
3.  Indiquez le pays **France**.
4.  Attendez la fin du provisionnement (de quelques minutes à une heure). Un environnement est créé automatiquement.

**Contrôle :** dans admin.powerplatform.microsoft.com, menu **Environnements** (Environments), un environnement de type « Essai » (Trial) apparaît avec l’état « Prêt » (Ready).

**Si ça bloque :** si aucun environnement n’apparaît, passez à l’étape B2 pour en créer un vous-même.

### B2. (Si besoin) créer l’environnement à la main

**Où :** Centre d’administration Power Platform \> Environnements \> **Nouveau** (New).

**Saisir :**

| Champ                                 | Valeur                                                    |
|---------------------------------------|-----------------------------------------------------------|
| Nom                                   | ARCHIFRIDAYS Démo D365 Sales                              |
| Région                                | Europe                                                    |
| Type                                  | Essai (Trial)                                             |
| Ajouter une base de données Dataverse | Oui                                                       |
| Langue                                | Français (ou anglais si la session est animée en anglais) |
| Devise                                | **EUR**                                                   |
| Activer les applications Dynamics 365 | Oui, puis cocher **Sales Enterprise**                     |

**Contrôle :** l’environnement passe à l’état « Prêt ».

> **Point de vigilance.** La devise de base **ne peut plus être changée** après la création. Vérifiez qu’il s’agit bien de l’euro (EUR) avant de valider.

### B3. Ouvrir Sales Hub et fixer vos préférences

**Où :** Centre d’administration Power Platform \> Environnements \> votre environnement \> **Ouvrir** (Open), puis l’application **Sales Hub**.

**Faire :**

1.  Cliquez sur la roue dentée en haut à droite \> **Paramètres de personnalisation** (Personalization settings).
2.  Onglet **Général** : fuseau horaire **(UTC+01:00) Paris**, devise **Euro**.
3.  Onglet **Formats** : **Français (France)** (dates jj/mm/aaaa).
4.  Onglet **Langues** : langue de l’interface selon la langue de la session.

**Contrôle :** les dates s’affichent sous la forme 16/11/2026.

**Si ça bloque :** si la langue souhaitée n’est pas proposée, activez-la dans Power Platform \> Environnement \> Paramètres \> **Langues** (Languages), puis attendez quelques minutes.

### B4. Noter les informations de l’environnement

Notez dans votre journal : le nom de l’environnement, l’adresse de Sales Hub (copiez-la depuis la barre d’adresse) et la date de fin de l’essai (visible dans la fiche de l’environnement).

## Phase C : organisation et utilisateurs (J-15)

### C1. Renommer l’unité commerciale racine et créer les autres unités

**Où :** Centre d’administration Power Platform \> Environnements \> votre environnement \> **Paramètres** (Settings) \> **Utilisateurs + autorisations** (Users + permissions) \> **Unités commerciales** (Business units).

**Faire :**

1.  Ouvrez l’unité commerciale racine (celle qui porte le nom de l’organisation) et renommez-la **Siège ARCHIFRIDAYS (Obernai)**.
2.  Cliquez sur **Nouveau** et créez les unités suivantes, en respectant le parent.

**Saisir :**

| Unité commerciale                      | Unité parente                        |
|----------------------------------------|--------------------------------------|
| Direction commerciale France (Paris)   | Siège ARCHIFRIDAYS (Obernai)         |
| Région Sud-Est                         | Direction commerciale France (Paris) |
| ARCHIFRIDAYS Deutschland (Blieskastel) | Siège ARCHIFRIDAYS (Obernai)         |

**Contrôle :** la liste affiche 4 unités ; Région Sud-Est a pour parent Direction commerciale France (Paris).

### C2. Créer les utilisateurs et attribuer les licences

**Où :** admin.microsoft.com \> **Utilisateurs** (Users) \> **Utilisateurs actifs** \> **Ajouter un utilisateur** (Add a user).

**Saisir :** un utilisateur par persona de l’onglet `01_Utilisateurs_et_equipes`.

| Prénom | Nom      | Nom d’utilisateur suggéré | Licence                                                    |
|--------|----------|---------------------------|------------------------------------------------------------|
| Claire | Martin   | claire.martin@            | Dynamics 365 Sales Enterprise                              |
| Julien | Bernard  | julien.bernard@           | Dynamics 365 Sales Enterprise                              |
| Sophie | Leroy    | sophie.leroy@             | Dynamics 365 Sales Enterprise (+ Microsoft 365 si e-mails) |
| Karim  | Haddad   | karim.haddad@             | Dynamics 365 Sales Enterprise                              |
| Nadia  | Benali   | nadia.benali@             | Dynamics 365 Sales Enterprise                              |
| Émilie | Roux     | emilie.roux@              | Dynamics 365 Sales Enterprise                              |
| Lucas  | Fontaine | lucas.fontaine@           | Dynamics 365 Sales Enterprise                              |
| Anna   | Becker   | anna.becker@              | Dynamics 365 Sales Enterprise                              |
| Thomas | Petit    | thomas.petit@             | Dynamics 365 Sales Enterprise                              |

**Faire :** pour chaque utilisateur, notez le mot de passe temporaire dans votre journal.

**Contrôle :** après 10 à 30 minutes, les 9 utilisateurs apparaissent dans Power Platform \> votre environnement \> Paramètres \> Utilisateurs + autorisations \> **Utilisateurs** (Users).

**Si ça bloque :** si vous n’avez pas assez de licences d’essai, créez au minimum **Claire Martin, Sophie Leroy et Thomas Petit** avec licence ; vous serez propriétaire des autres enregistrements et vous indiquerez oralement le responsable. Si un utilisateur n’apparaît pas dans l’environnement, ouvrez la liste des utilisateurs et cliquez sur **Ajouter un utilisateur** (Add user) pour le synchroniser.

### C3. Rattacher chaque utilisateur à son unité et à son responsable

**Où :** Power Platform \> votre environnement \> Paramètres \> Utilisateurs + autorisations \> Utilisateurs \> sélectionner l’utilisateur.

**Faire :**

1.  **Changer d’unité commerciale** (Change business unit) : choisissez l’unité du tableau ci-dessous.
2.  Ouvrez la fiche complète de l’utilisateur (lien vers la fiche dans Sales Hub ou « Gérer les utilisateurs dans Dynamics 365 ») et renseignez le champ **Responsable** (Manager).

**Saisir :**

| Utilisateur    | Unité commerciale                      | Responsable   |
|----------------|----------------------------------------|---------------|
| Claire Martin  | Direction commerciale France (Paris)   | (aucun)       |
| Julien Bernard | Direction commerciale France (Paris)   | Claire Martin |
| Lucas Fontaine | Direction commerciale France (Paris)   | Claire Martin |
| Sophie Leroy   | Région Sud-Est                         | Claire Martin |
| Karim Haddad   | Région Sud-Est                         | Claire Martin |
| Anna Becker    | ARCHIFRIDAYS Deutschland (Blieskastel) | Claire Martin |
| Nadia Benali   | Siège ARCHIFRIDAYS (Obernai)           | Claire Martin |
| Émilie Roux    | Siège ARCHIFRIDAYS (Obernai)           | Claire Martin |
| Thomas Petit   | Siège ARCHIFRIDAYS (Obernai)           | (aucun)       |

**Contrôle :** dans la fiche de Sophie Leroy, le champ Responsable affiche Claire Martin.

> **Point de vigilance.** Changer l’unité commerciale d’un utilisateur retire ses rôles de sécurité. Attribuez donc les rôles (étape C4) **après** ce changement.

### C4. Attribuer les rôles de sécurité

**Où :** Power Platform \> votre environnement \> Paramètres \> Utilisateurs + autorisations \> Utilisateurs \> sélectionner l’utilisateur \> **Gérer les rôles de sécurité** (Manage security roles).

**Saisir :**

| Utilisateur                        | Rôles                                                           |
|------------------------------------|-----------------------------------------------------------------|
| Claire Martin                      | Sales Manager (Responsable commercial), Basic User              |
| Julien, Sophie, Karim, Lucas, Anna | Salesperson (Commercial), Basic User                            |
| Nadia Benali                       | Salesperson, Basic User (le rôle Marketing Manager s’il existe) |
| Émilie Roux                        | Salesperson, Basic User                                         |
| Thomas Petit                       | System Customizer (Personnalisateur système), Salesperson       |
| Vous (formateur)                   | System Administrator (Administrateur système)                   |

**Contrôle :** connectez-vous en navigation privée avec Sophie Leroy : Sales Hub s’ouvre et affiche le plan du site Ventes.

**Si ça bloque :** « Vous n’avez pas accès à cette application » signifie qu’il manque la licence (C2) ou le rôle (C4).

### C5. Activer la hiérarchie de responsables

**Où :** Power Platform \> votre environnement \> Paramètres \> Utilisateurs + autorisations \> **Sécurité de la hiérarchie** (Hierarchy security).

**Faire :**

1.  Cochez **Activer la modélisation de hiérarchie** (Enable hierarchy modeling).
2.  Choisissez le modèle **Hiérarchie de responsables** (Manager hierarchy).
3.  Profondeur : **3**. Enregistrez.

**Contrôle :** connectée en tant que Claire, vous verrez les opportunités de Sophie après l’import (contrôle repris en H1).

### C6. Créer les équipes

**Où :** Power Platform \> votre environnement \> Paramètres \> Utilisateurs + autorisations \> **Équipes** (Teams) \> **Créer une équipe**.

**Saisir :** équipes de type **Propriétaire** (Owner), utiles pour illustrer les canaux.

| Équipe        | Unité commerciale                    | Membres                                   |
|---------------|--------------------------------------|-------------------------------------------|
| Canal Diffuse | Direction commerciale France (Paris) | Julien Bernard, Karim Haddad, Anna Becker |
| Canal Project | Direction commerciale France (Paris) | Sophie Leroy                              |

**Contrôle :** les deux équipes apparaissent avec leurs membres. (L’équipe d’accès sur Groupe Distelec est créée à l’étape G1.)

## Phase D : paramètres de base (J-14)

### D1. Exercice fiscal (nécessaire aux objectifs et à la prévision)

**Où :** Sales Hub \> roue dentée \> **Paramètres avancés** (Advanced settings) \> Paramètres \> **Gestion d’entreprise** (Business Management) \> **Paramètres d’exercice** (Fiscal Year Settings).

**Saisir :** date de début **01/01/2026** ; modèle de période **Trimestriel** (Quarterly) ; nom de l’exercice basé sur l’année de début ; affichage « T » + numéro.

**Contrôle :** la fenêtre se ferme sans message d’erreur.

> **Point de vigilance.** Ce paramètre est difficile à modifier une fois des objectifs créés. Faites-le avant la phase G.

### D2. Détection des doublons

**Où :** Power Platform \> votre environnement \> Paramètres \> **Gestion des données** (Data management) \> **Paramètres de détection des doublons** (Duplicate detection settings), puis **Règles de détection des doublons** (Duplicate detection rules).

**Faire :**

1.  Dans les paramètres : cochez **Activer la détection des doublons**, ainsi que « Lors de la création et de la mise à jour d’un enregistrement » et « Pendant l’importation des données ».
2.  Dans les règles : vérifiez que les règles standard suivantes sont **publiées** (Published) ; sinon, sélectionnez-les et cliquez sur **Publier** :
    - prospects avec la même adresse e-mail ;
    - contacts avec la même adresse e-mail ;
    - comptes avec le même nom de compte.
3.  Ajoutez si besoin une règle « Prospect avec la même adresse e-mail qu’un contact » (Lead with same email as Contact) : type d’enregistrement de base Prospect, type à comparer Contact, critère Adresse e-mail = Adresse e-mail.

**Contrôle :** les règles affichent l’état « Publié ».

### D3. Paramètres du catalogue de produits

**Où :** Sales Hub \> en bas à gauche, changer de zone vers **Paramètres de l’application** (App Settings) \> **Catalogue de produits** (Product Catalog) \> **Paramètres du catalogue de produits** (Product Catalog Settings).

**Saisir :** « Créer des produits dans l’état actif » (Create products in active state) : **Oui** ; « Autoriser la sélection de produits sans liste de prix » : **Non**.

**Contrôle :** enregistrez ; aucun message d’erreur. Avec ce réglage, les produits importés seront directement utilisables (sinon il faudra les **Publier** un par un).

### D4. Rôles de connexion

**Où :** Sales Hub \> Paramètres avancés \> Paramètres \> **Gestion d’entreprise** \> **Rôles de connexion** (Connection Roles). Si ce menu a disparu, cherchez « Connection roles » dans la recherche des paramètres.

**Faire :** créez les rôles suivants, catégorie **Ventes** (Sales), en cochant les types d’enregistrement **Compte**, **Contact** et **Opportunité**.

| Rôle                   | Description                                                       |
|------------------------|-------------------------------------------------------------------|
| Maître d’ouvrage       | Décide et finance le projet                                       |
| Prescripteur           | Bureau d’études ou architecte qui influence le choix des produits |
| Installateur titulaire | Installateur qui réalise le lot                                   |
| Distributeur livreur   | Distributeur qui livre et facture l’installateur                  |

**Contrôle :** les 4 rôles apparaissent dans la liste. Ils seront utilisés dans les parties prenantes de Campus Lumière (étape F2).

### D5. Origine du prospect et campagne

**Où :** Sales Hub \> zone Marketing \> **Campagnes** (Campaigns).

**Faire :** créez la campagne **BâtiExpo Lyon 2026** (type Salon professionnel, date de début 08/09/2026, date de fin 10/09/2026) et activez-la.

**Si ça bloque :** si le menu Campagnes n’existe pas dans votre version, ne bloquez pas : lors de l’import des leads (étape E7), laissez la colonne « Campagne source » non mappée et ajoutez le nom du salon dans la description. Vous l’expliquerez oralement en épisode 4.

## Phase E : import des données (J-12)

### E1. Principe de l’assistant d’importation

Vous importerez les fichiers CSV du dossier `CSV_import_Dataverse`, un par un, **dans l’ordre**. La méthode est toujours la même :

1.  Dans Sales Hub, ouvrez la liste correspondante (par exemple **Comptes**).
2.  Dans la barre de commandes, cliquez sur **Importer à partir d’Excel / CSV** (Import from CSV). Si le bouton n’est pas visible, ouvrez le menu « … » (Plus de commandes).
3.  Choisissez le fichier CSV, puis **Suivant**.
4.  Écran des options : délimiteur de champ **Point-virgule** (;), délimiteur de données **Guillemet**, encodage UTF-8 si demandé.
5.  Écran de mappage : vérifiez que chaque colonne du fichier est reliée à la bonne colonne Dynamics 365. Pour les colonnes d’aide au formateur (Profil, Note du stand, Traitement attendu en formation, Rôle dans le scénario), choisissez **Ignorer** (Ignore) ou mappez-les vers Description.
6.  Lancez l’import et attendez : suivez l’avancement dans **Paramètres avancés \> Gestion des données \> Importations** (Imports).

**Contrôle général :** chaque import doit afficher 0 échec. S’il y a des échecs, ouvrez l’import et l’onglet **Échecs** (Failures) pour lire la cause.

**Si ça bloque :** l’échec le plus fréquent est une **recherche non résolue** (lookup) : la valeur (par exemple le nom du compte parent) n’existe pas encore ou est écrite différemment. Importez d’abord l’enregistrement référencé, puis relancez.

### E2. Groupes d’unités (fichier 02)

**Où :** Paramètres de l’application \> Catalogue de produits \> **Groupes d’unités** (Unit Groups). La création manuelle est plus simple que l’import pour 3 lignes.

**Saisir :**

| Groupe d’unités | Unité principale |
|-----------------|------------------|
| Matériel        | Unité            |
| Services        | Jour             |
| Contrats        | Borne et an      |

**Contrôle :** chaque groupe affiche son unité principale.

### E3. Familles et produits (fichier 03)

**Où :** Paramètres de l’application \> Catalogue de produits \> **Familles et produits** (Families & Products).

**Faire :**

1.  Créez 4 **familles** : Distribution d’énergie, Gestion du bâtiment, Mobilité électrique, Services.
2.  Créez les 6 **produits** dans leur famille (création manuelle conseillée, ou import du fichier 03).

**Saisir :**

| ID de produit | Nom                                        | Famille                | Groupe d’unités | Unité par défaut |
|---------------|--------------------------------------------|------------------------|-----------------|------------------|
| DE-TGBT-630   | Tableau général basse tension (TGBT) 630 A | Distribution d’énergie | Matériel        | Unité            |
| DE-TD-250     | Tableau divisionnaire 250 A                | Distribution d’énergie | Matériel        | Unité            |
| GTB-SUP-MB    | Pack supervision GTB multi-bâtiments       | Gestion du bâtiment    | Matériel        | Unité            |
| ME-BRN-2X22   | Borne de recharge double 2 x 22 kW         | Mobilité électrique    | Matériel        | Unité            |
| SV-MES-J      | Mise en service sur site                   | Services               | Services        | Jour             |
| SV-MNT-BRN    | Contrat de maintenance borne               | Services               | Contrats        | Borne et an      |

**Contrôle :** les produits sont à l’état **Actif** (grâce à D3). Sinon, ouvrez chaque produit et cliquez sur **Publier**.

### E4. Listes de prix et éléments de liste (fichiers 04 et 05)

**Où :** Paramètres de l’application \> Catalogue de produits \> **Listes de prix** (Price Lists).

**Faire :**

1.  Créez les 3 listes de prix (devise Euro, du 01/01/2026 au 31/12/2026) : **Tarif public 2026**, **Tarif accord cadre distributeurs**, **Tarif projets**.
2.  Dans chaque liste, onglet **Éléments de liste de prix** (Price List Items), ajoutez les 6 produits avec leur unité et le montant du fichier 05. Exemple pour le Tarif public 2026 :

| Produit                     | Unité       | Montant  |
|-----------------------------|-------------|----------|
| TGBT 630 A                  | Unité       | 18 500 € |
| Tableau divisionnaire 250 A | Unité       | 4 200 €  |
| Pack supervision GTB        | Unité       | 48 000 € |
| Borne double 2 x 22 kW      | Unité       | 2 900 €  |
| Mise en service             | Jour        | 950 €    |
| Maintenance borne           | Borne et an | 180 €    |

3.  Ouvrez chaque produit et renseignez **Liste de prix par défaut** = Tarif public 2026.

**Contrôle :** la liste Tarif public 2026 contient 6 éléments. Les deux autres en contiennent 6 chacune (montants à 68 % et 85 % du tarif public, voir fichier 05).

### E5. Comptes (fichier 06)

**Faire :**

1.  Ouvrez le fichier 06 dans Excel et **enregistrez une copie** contenant toutes les lignes **sauf** Distelec Sud-Est (fichier A), puis une copie avec **seulement** Distelec Sud-Est (fichier B).
2.  Importez le fichier A dans **Comptes**. Au mappage : Nom du compte, Type de relation, Ville, Code postal, Téléphone principal, Site Web, Description ; « Propriétaire » vers Propriétaire si les utilisateurs existent, sinon Ignorer ; « Secteur d’activité » vers Secteur d’activité ou Description.
3.  Importez le fichier B : la colonne « Compte parent » se mappe sur **Compte parent** (Parent Account).

**Contrôle :** 18 comptes ; la fiche Distelec Sud-Est affiche Groupe Distelec comme compte parent.

**Mappage des valeurs de « Type de relation ».** L’assistant affiche un écran de correspondance des valeurs, car certaines valeurs du fichier n’existent pas dans la liste standard. Choisissez : Client → **Client** ; Concurrent → **Concurrent** ; Prescripteur → **Influenceur** (Influencer) ; Distributeur → **Revendeur** (Reseller). Notez ce choix : c’est un bon exemple de discussion « standard ou spécifique » en épisode 3.

**Si ça bloque :** si l’écran de correspondance n’apparaît pas et que l’import échoue sur ce champ, mappez la colonne vers Ignorer et renseignez le type à la main sur les 6 comptes clés du fil rouge (Vitalis, Kelvin, Atelier Brunel, ERS, Groupe Distelec, Distelec Sud-Est).

### E6. Contacts et concurrents (fichiers 07 et 08)

**Faire :**

1.  Importez le fichier 07 dans **Contacts** : « Nom du compte » se mappe sur **Nom de la société** (Company Name), qui est une recherche vers le compte. « Rôle dans le scénario » : Ignorer ou Description.
2.  Créez les 2 concurrents dans **Concurrents** (Competitors), à la main : NovaVolt et Elektra Systems, avec forces et faiblesses du fichier 08.

**Contrôle :** 18 contacts, chacun rattaché à son compte ; Inès Garnier est rattachée à **Kelvin Ingénierie** (elle passera chez Vitalis pendant l’épisode 6, ne le faites pas maintenant).

### E7. Les 47 leads du salon (fichier 09)

Le fichier simule le flux réel : capture sur le salon par la Lead App, passage par Eloqua, arrivée dans le CRM.

**Faire :**

1.  **Désactivez temporairement** la détection des doublons « pendant l’importation » (D2), sinon l’import refusera volontairement le doublon d’Inès Garnier dont vous avez besoin pour la démonstration.
2.  Importez le fichier 09 dans **Prospects** (Leads). Mappage : Rubrique, Prénom, Nom, Nom de la société, Fonction, Adresse e-mail, Téléphone professionnel, Ville, **Origine du prospect** (si la valeur « Salon professionnel » n’est pas reconnue, l’assistant propose de la faire correspondre à une valeur existante : choisissez la valeur de type salon, en anglais **Trade Show**), Campagne source (si D5 a réussi) ; les trois colonnes d’aide vers Ignorer ou Description.
3.  Réactivez la détection des doublons pendant l’importation.

**Contrôle :** 47 prospects ouverts ; deux prospects Inès / Ines Garnier existent ; l’étudiante (INSA Lyon) et le salarié de NovaVolt sont présents (ils seront disqualifiés en direct).

> **Point de vigilance.** Ne qualifiez et ne disqualifiez **aucun** prospect pendant la préparation : ce sont des gestes de démonstration.

### E8. Opportunités du pipeline (fichier 10)

**Faire :**

1.  Importez le fichier 10 dans **Opportunités**. Mappage : Rubrique, **Client potentiel** (Potential Customer, recherche vers le compte), Propriétaire, Chiffre d’affaires estimé, Probabilité, **Catégorie de prévision** (Forecast category), Date de clôture estimée.
2.  La colonne « Étape du processus » ne s’importe pas directement : notez-la et ajustez l’étape à la main (E9).

**Contrôle :** 12 opportunités. Les deux affaires « Gagnée » (Entrepôt Logisud, Hôtel Belvédère) sont encore ouvertes : vous les fermerez en F4.

### E9. Mettre chaque opportunité à la bonne étape

**Faire :** ouvrez chaque opportunité et, dans la barre du processus d’entreprise (en haut de la fiche), cliquez sur **Étape suivante** (Next Stage) jusqu’à l’étape du fichier 10 (Qualifier, Développer, Proposer, Conclure). Remplissez les champs obligatoires demandés en chemin avec des valeurs plausibles.

**Contrôle :** dans la vue « Mes opportunités ouvertes », la colonne Étape correspond au fichier 10.

> **Point de vigilance.** Pour Campus Lumière, laissez « Chiffre d’affaires » en mode **calculé par le système** (System Calculated) : le montant viendra des produits ajoutés en F1. Pour les autres, laissez le mode « saisi par l’utilisateur ».

### E10. Objectifs (fichier 14)

Les objectifs sont créés en phase G (étape G7), après l’exercice fiscal.

## Phase F : saisies manuelles (J-11)

### F1. Produits de l’opportunité Campus Lumière

**Où :** Sales Hub \> Opportunités \> Campus Lumière, lot électricité.

**Faire :**

1.  Champ **Liste de prix** : Tarif public 2026.
2.  Champ **Chiffre d’affaires** : Calculé par le système.
3.  Onglet **Produits** : ajoutez les 6 lignes.

**Saisir :**

| Produit                     | Quantité | Montant attendu |
|-----------------------------|----------|-----------------|
| TGBT 630 A                  | 3        | 55 500 €        |
| Tableau divisionnaire 250 A | 24       | 100 800 €       |
| Pack supervision GTB        | 1        | 48 000 €        |
| Borne double 2 x 22 kW      | 60       | 174 000 €       |
| Mise en service             | 20       | 19 000 €        |
| Maintenance borne           | 180      | 32 400 €        |

**Contrôle :** le **Chiffre d’affaires estimé** affiche **429 700 €**.

**Faire ensuite :** même opération sur **Entrepôt Logisud** avec le fichier 11 : TGBT x 2, tableau divisionnaire x 12, borne double x 20, mise en service x 8, soit 153 000 € au tarif public.

### F2. Parties prenantes et concurrents de Campus Lumière

**Faire :** dans l’opportunité Campus Lumière :

1.  Onglet ou section **Parties prenantes** (Stakeholders) : ajoutez Marc Duval (rôle Maître d’ouvrage ou Décideur), Inès Garnier (Prescripteur), Léa Brunel (Prescripteur), Paul Lefèvre (Installateur titulaire), Sandrine Morel (Distributeur livreur).
2.  Section **Concurrents** : ajoutez NovaVolt et Elektra Systems.
3.  Section **Équipe commerciale** (Sales team) : ajoutez Julien Bernard et Karim Haddad.

**Contrôle :** les trois sections sont remplies. Ne remplissez pas le client potentiel autrement que **Vitalis Immobilier**.

### F3. Devis de Campus Lumière : V1 puis révision V2

**Faire :**

1.  Depuis l’opportunité, onglet **Devis** (Quotes) \> **Nouveau devis**. Les produits sont repris de l’opportunité.
2.  Renseignez **Remise sur le devis (%)** = **15**. Enregistrez. Le total doit être **365 245 €**.
3.  Cliquez sur **Activer le devis** (Activate Quote). Notez son numéro.
4.  Cliquez sur **Réviser** (Revise) : une révision 1 s’ouvre en brouillon. Remise = **20**. Total attendu : **343 760 €**. Activez-la.

**Contrôle :** l’onglet Devis de l’opportunité montre la révision 0 fermée (révisée) et la révision 1 active.

> **Point de vigilance.** Ne marquez pas ce devis comme gagné : Campus Lumière doit rester à l’étape Proposer pour les épisodes 6 et 7.

### F4. Entrepôt Logisud : devis gagné et commande (démonstration de fin de cycle)

**Choix à faire :** soit vous préparez tout maintenant (plus sûr), soit vous gardez les deux derniers gestes pour la démonstration en direct de l’épisode 5 (plus vivant). Conseil : préparez le devis activé et gardez « Gagné » et « Créer une commande » pour le direct.

**Faire :**

1.  Depuis Entrepôt Logisud, créez un devis, remise **8,5 %** (total 139 995 €), activez-le.
2.  (En direct ou maintenant) sur le devis activé, cliquez sur **Créer une commande** (Create Order) : Dynamics 365 propose alors de conclure le devis comme gagné et, si vous le souhaitez, de fermer l’opportunité comme gagnée. Acceptez.
3.  Fermez Hôtel Belvédère comme **Gagnée** (bouton **Fermer comme gagnée**), date réelle 22/10/2026.

**Contrôle :** dans la vue des opportunités fermées, Hôtel Belvédère (et Entrepôt Logisud si fait) apparaissent comme gagnées.

### F5. Activités de Campus Lumière (fichier 13)

**Faire :** dans l’opportunité Campus Lumière, onglet **Chronologie** (Timeline), créez les 9 activités du fichier 13 (rendez-vous, appels, e-mails, tâche), avec la date du fichier, le contact concerné et le statut.

**Saisir :** les 8 premières activités sont **terminées** (Mark complete) ; la tâche « Relancer Marc Duval sur le calendrier de décision » (échéance 02/11/2026) reste **ouverte**.

> **Point de vigilance.** N’ajoutez **aucune** activité datée après le 26/10/2026 : le silence de 21 jours est le sujet de l’épisode 6. Les e-mails peuvent être créés comme activités e-mail sans être envoyés (enregistrez-les puis marquez-les comme terminés).

**Contrôle :** la chronologie affiche 9 éléments, le plus récent étant le devis V2 du 26/10.

**Si ça bloque :** la chronologie peut trier les activités par date de création plutôt que par date d’échéance. Si l’ordre n’est pas parlant, montrez la vue **Activités** filtrée sur Campus Lumière et triée par date d’échéance.

## Phase G : fonctions démontrées, épisode par épisode (J-10 à J-7)

### G1. Épisode 2 : équipe d’accès et sécurité de colonne

**Équipe d’accès sur Groupe Distelec :**

1.  **Où :** make.powerapps.com \> votre environnement \> **Tables** \> **Compte** (Account) \> **Propriétés** \> Options avancées : cochez l’option relative aux **équipes d’accès** (Access teams). Elle est souvent déjà active pour le compte. Enregistrez.
2.  Sales Hub \> Paramètres avancés \> Paramètres \> **Modèles** (Templates) \> **Modèles d’équipe d’accès** (Access Team Templates) \> Nouveau : nom **Équipe compte Distelec**, entité Compte, droits Lecture, Écriture, Ajout.
3.  Ajoutez le sous-grille « Membres de l’équipe » au formulaire de compte si elle n’existe pas (étape réservée à un personnalisateur ; sinon, montrez le principe en capture).
4.  Sur le compte Groupe Distelec, ajoutez Sophie Leroy à l’équipe d’accès.

**Colonne de remise protégée :**

1.  **Où :** make.powerapps.com \> **Solutions** \> Nouvelle solution **ARCHIFRIDAYS Démo** (éditeur : ARCHIA365).
2.  Dans la solution : **Ajouter existant** \> Table \> Compte, puis **Nouvelle colonne** : nom **Taux de remise accord cadre**, type Nombre décimal, et dans les options avancées, cochez **Activer la sécurité de colonne** (Enable column security).
3.  Ajoutez la colonne au formulaire principal du compte et publiez.
4.  **Où :** Power Platform \> Paramètres \> Utilisateurs + autorisations \> **Profils de sécurité de colonne** (Column security profiles) \> Nouveau : **Remises accord cadre**, membres Claire Martin et Julien Bernard, autorisation Lecture et Mise à jour sur la colonne.
5.  Sur Groupe Distelec, saisissez **32** dans Taux de remise accord cadre.

**Contrôle :** connectée en tant que Sophie, la colonne affiche un cadenas et aucune valeur ; connectée en tant que Julien, elle affiche 32.

> **Point de vigilance.** C’est la seule personnalisation de l’environnement ; elle sert à montrer un mécanisme standard. Dites-le aux participants.

### G2. Épisode 3 : rien de plus à préparer

Les rôles de connexion (D4), les parties prenantes et les concurrents (F2) suffisent. Préparez seulement une capture du schéma des acteurs (fil rouge) au cas où.

### G3. Épisode 4 : doublons, qualification et séquence

**Contrôles de préparation :**

1.  Ouvrez le prospect « Ines Garnier » (sans accent) : un bandeau ou un message de doublons doit apparaître à l’enregistrement. Ne fusionnez pas.
2.  Vérifiez que le processus d’entreprise **Lead to Opportunity Sales Process** est actif : Paramètres avancés \> Paramètres \> **Processus** (Processes), filtre « Flux de processus d’entreprise ».

**Séquence de l’accélérateur des ventes :**

1.  **Où :** Sales Hub \> Paramètres de l’application \> **Accélérateur des ventes** (Sales accelerator) \> **Configuration rapide / Paramètres de l’espace de travail** : activez l’accélérateur pour les rôles Salesperson et Sales Manager.
2.  **Où :** Paramètres de l’application \> **Séquences** (Sequences) \> Nouvelle séquence : nom **Relance installateurs salon**, type d’enregistrement Prospect.
3.  Étapes : **E-mail** (J0, « Merci pour votre visite à BâtiExpo »), **Attendre 3 jours**, **Appel téléphonique** (« Proposer une formation bornes »), **Attendre 4 jours**, **E-mail** (« Invitation à une matinée installateurs »). Activez.
4.  Rattachez la séquence à 3 ou 4 prospects installateurs, avec Karim Haddad comme propriétaire.

**Contrôle :** connecté en tant que Karim, la **Liste de travail** (Work list) affiche des actions à réaliser.

**Si ça bloque :** l’accélérateur est inclus dans Sales Enterprise avec certaines limites qui évoluent ; si le menu est absent ou bloqué, préparez des captures. La **notation prédictive des leads** est Premium : montrez-la en captures (hors licence de Hager).

### G4. Épisode 5 : modèle de devis

**Option simple (recommandée pour un non-expert) :** utilisez le modèle Word standard de devis s’il existe : ouvrez un devis \> menu **Modèle Word** (Word Templates). Vérifiez que le document se génère.

**Option complète :**

1.  Ouvrez un devis \> **Modèles Word** \> **Créer un modèle Word** \> choisissez Devis et les produits du devis (Quote Product) \> téléchargez le fichier.
2.  Dans Word, affichez l’onglet **Développeur** (Fichier \> Options \> Personnaliser le ruban), ouvrez le volet **Mappage XML**, insérez les champs (numéro, client, lignes, total), ajoutez le logo fictif ARCHIFRIDAYS.
3.  Enregistrez, puis chargez le modèle dans Sales Hub (Paramètres avancés \> Modèles \> Modèles de document).

**Contrôle :** depuis le devis V2 de Campus Lumière, le modèle génère un Word avec 343 760 €.

### G5. Épisode 6 : e-mails, Outlook et Copilot

**Synchronisation côté serveur (seulement si vous avez Exchange Online, étape A1) :**

1.  **Où :** Power Platform \> Paramètres \> **E-mail** \> **Boîtes aux lettres** (Mailboxes) : ouvrez la boîte de Sophie Leroy.
2.  Cliquez sur **Approuver l’e-mail** (Approve Email), puis **Tester et activer la boîte aux lettres** (Test & Enable Mailbox).
3.  Attendez que l’état de la messagerie entrante et sortante soit **Succès**.

**Complément Outlook :**

1.  **Où :** Power Platform \> Paramètres \> Intégration \> **Dynamics 365 App for Outlook** : ajoutez Sophie Leroy.
2.  Dans Outlook Web de Sophie, envoyez-vous un e-mail « Inès Garnier, nouvelle adresse chez Vitalis » à suivre en direct.

**Copilot :**

1.  **Où :** Sales Hub \> Paramètres de l’application \> **Copilot** (ou « Fonctionnalités de Copilot ») : activez Copilot dans Dynamics 365 Sales pour les rôles commerciaux.
2.  Si Copilot reste indisponible, vérifiez dans Power Platform \> Environnement \> Paramètres \> **Fonctionnalités** (Features) les options d’IA générative et de déplacement des données entre régions.

**Contrôle :** sur Campus Lumière, le volet Copilot propose un résumé de l’opportunité.

**Si ça bloque :** sans Exchange ou sans Copilot dans votre région, préparez des captures. L’**analyse des relations** est Premium : captures uniquement. Les cartes de l’**assistant** dépendent de règles et de délais ; sur un environnement récent, elles peuvent ne pas apparaître : captures en secours.

### G6. Épisode 6 : Teams

**Où :** Sales Hub \> Paramètres de l’application \> **Discuter et collaborer** (Chat and collaborate) ou **Intégration Microsoft Teams**.

**Faire :** activez l’expérience de collaboration de base, puis, depuis Campus Lumière, utilisez **Collaborer** (Collaborate) pour créer un canal Teams lié.

**Contrôle :** l’opportunité affiche le canal connecté. Sans Teams dans le locataire, captures.

### G7. Épisode 7 : objectifs

**Où :** Sales Hub \> zone Performances \> **Objectifs** (Goals).

**Faire :** créez 3 objectifs, métrique **Revenu** (Revenue), période **T4 2026**, montants du fichier 14.

| Propriétaire   | Objectif  |
|----------------|-----------|
| Sophie Leroy   | 700 000 € |
| Julien Bernard | 600 000 € |
| Karim Haddad   | 300 000 € |

Puis cliquez sur **Recalculer** (Recalculate).

**Contrôle :** l’objectif de Karim affiche une réalisation de 202 000 € (Logisud et Belvédère gagnées) une fois F4 terminée.

### G8. Épisode 7 : prévision

**Où :** Sales Hub \> Paramètres de l’application \> Gestion des performances \> **Configuration de la prévision** (Forecast configuration) \> **Nouvelle**.

**Faire :**

1.  Modèle : **Prévision de l’organigramme** (Org chart forecast).
2.  Nom : **Prévision Sud-Est T4 2026** ; hiérarchie : utilisateur racine **Claire Martin**.
3.  Période : **Trimestriel**, début **T4 2026**, nombre de périodes 1 ou 2.
4.  Colonnes : conservez les colonnes standard liées à la **catégorie de prévision** : Pipeline, Meilleur cas, Validé, Gagné, Omis, et ajoutez la colonne **Objectif** (Quota) reliée aux objectifs de G7 si l’assistant le propose.
5.  Activez la prévision, puis ouvrez-la dans Sales Hub \> Performances \> **Prévisions** et cliquez sur **Recalculer**.

**Contrôle :** pour Claire, le total « Gagné » vaut 202 000 € et « Validé » 611 000 € ; Meilleur cas 612 000 €.

**Si ça bloque :** une prévision vide vient presque toujours d’opportunités sans **date de clôture estimée** dans la période, sans **catégorie de prévision**, ou d’utilisateurs hors de la hiérarchie de Claire (C3). Corrigez puis recalculez.

> **Point de vigilance.** Les instantanés de prévision ont été dépréciés : ne les cherchez pas. L’historique semaine après semaine se prépare en G13.

### G9. Épisode 8 : flux d’approbation des remises (Power Automate)

**Où :** make.powerautomate.com \> votre environnement \> **Créer** \> **Flux de cloud automatisé**.

**Faire :**

1.  Nom : **Approbation remise supérieure à 18 %** ; déclencheur **Microsoft Dataverse : Quand une ligne est ajoutée, modifiée ou supprimée** (When a row is added, modified or deleted).
2.  Paramètres du déclencheur : type de modification **Modifié** (Modified) ; table **Devis** (Quotes) ; étendue **Organisation** ; dans les options avancées, **Sélectionner des colonnes** (Select columns) : `discountpercentage` ; **Filtrer les lignes** (Filter rows) : `discountpercentage gt 18`.
3.  Action **Approbations : Démarrer et attendre une approbation** (Start and wait for an approval) : type « Approuver/Refuser, premier à répondre », titre « Remise de @discountpercentage % sur @name », assignée à l’adresse de Claire Martin.
4.  Action **Condition** : résultat = Approve.
    - Si oui : **Dataverse : Mettre à jour une ligne**, table Devis, ligne = identifiant du devis, colonne Description = « Remise approuvée par Claire Martin ».
    - Si non : mettre à jour la Description = « Remise refusée », et (facultatif) remettre la remise à 18.
5.  Enregistrez, puis testez : passez la remise d’un **devis brouillon** de test à 22 %.

**Contrôle :** Claire reçoit la demande dans l’application **Approbations** de Teams (ou par e-mail) ; sa réponse met à jour le devis.

**Si ça bloque :** le flux ne se déclenche pas si le filtre de lignes est mal écrit ; videz le champ « Filtrer les lignes », testez, puis ajoutez plutôt une action Condition sur la remise dans le flux. Testez sur un devis de test, jamais sur ceux de Campus Lumière.

### G10. Épisode 8 : application « Visite chantier » (Power Apps)

**Où :** make.powerapps.com \> **Créer** \> **Partir des données** (Start from data) \> Dataverse \> table **Rendez-vous** (Appointments).

**Faire :**

1.  Laissez Power Apps générer l’application à trois écrans.
2.  Renommez-la **Visite chantier ARCHIFRIDAYS**. Sur l’écran de modification, gardez Objet, Concernant, Début, Fin, Description ; ajoutez un contrôle **Ajouter une image** si vous êtes à l’aise, sinon restez simple.
3.  Enregistrez et publiez ; partagez-la avec Karim Haddad.

**Contrôle :** depuis l’application, vous créez un rendez-vous « Visite chantier Clinique Saint-Roch » qui apparaît dans Sales Hub.

### G11. Épisode 8 : Copilot Studio et intégrations

Il n’y a rien à construire : l’agent Copilot Studio et les intégrations SAP / Eloqua sont présentés en schéma et en discussion. Préparez seulement le schéma de l’architecture d’intégration (CRM, SAP, Eloqua, Lead App, Event Management Tool, Power BI, data platform) sur une diapositive ou au paperboard.

### G12. Épisode 9 et ateliers

Aucun paramétrage. Vérifiez les classeurs `06_Ateliers` : la grille Hager est pré-remplie et à compléter après le call d’alignement.

### G13. Épisode 7 : historique de prévision dans Power BI (facultatif)

**Faire :**

1.  Dans la grille de prévision de Claire, exportez la grille vers Excel (bouton **Exporter** s’il est proposé ; sinon, exportez la vue des opportunités avec catégorie, montant et date de clôture). Enregistrez le fichier sous `Prevision_S1.xlsx`.
2.  Une semaine plus tard (ou après avoir modifié 2 ou 3 opportunités pour simuler l’évolution), refaites l’export : `Prevision_S2.xlsx`.
3.  Dans Power BI Desktop : **Obtenir les données** \> Excel \> les deux fichiers ; ajoutez une colonne « Semaine » à chacun, **Ajouter des requêtes** (Append) ; créez un histogramme empilé : axe Semaine, légende Catégorie, valeur Montant.

**Contrôle :** le graphique compare les deux semaines. Sinon, utilisez deux captures de la grille à une semaine d’intervalle.

## Phase H : répétition et contrôles (J-5)

### H1. Contrôle par épisode

Connectez-vous successivement avec les utilisateurs indiqués et cochez chaque ligne.

| Épisode | Contrôle                                                                                                   | Utilisateur   | OK  |
|---------|------------------------------------------------------------------------------------------------------------|---------------|-----|
| 1       | Sales Hub s’ouvre, plan du site visible                                                                    | Sophie        | ☐   |
| 2       | Sophie voit les opportunités de Distelec via l’équipe d’accès ; la colonne de remise est masquée pour elle | Sophie        | ☐   |
| 2       | Claire voit les opportunités de toute son équipe                                                           | Claire        | ☐   |
| 3       | Campus Lumière : client potentiel Vitalis, 5 parties prenantes, 2 concurrents                              | Vous          | ☐   |
| 4       | 47 prospects ; doublon Inès détecté ; séquence active sur la liste de travail de Karim                     | Karim         | ☐   |
| 5       | Campus Lumière à 429 700 € ; devis V1 365 245 € révisé ; V2 343 760 € actif ; modèle Word OK               | Sophie        | ☐   |
| 5       | Logisud : devis activé à 139 995 € prêt à être gagné                                                       | Vous          | ☐   |
| 6       | Dernière activité de Campus Lumière au 26/10 ; tâche du 02/11 ouverte ; Copilot ou captures                | Sophie        | ☐   |
| 7       | Prévision : Gagné 202 000 €, Validé 611 000 €, Meilleur cas 612 000 € ; objectifs visibles                 | Claire        | ☐   |
| 8       | Flux d’approbation testé ; application Visite chantier ouverte                                             | Claire, Karim | ☐   |

### H2. Répétition chronométrée

Déroulez toutes les démonstrations dans l’ordre du guide formateur, chronomètre en main, en mode Présentateur. Notez les écarts de temps et les clics superflus.

### H3. Captures de secours

Pour chaque démonstration, faites 2 ou 3 captures (Windows + Maj + S) et rangez-les dans un dossier `Captures_secours`, nommées par épisode : `E04_doublon_Ines.png`, `E07_grille_prevision.png`, etc. Ajoutez obligatoirement les captures des fonctions Premium (notation prédictive, analyse des relations, prévision prédictive), qui ne sont pas dans la licence de Hager.

## Phase I : remise à zéro avant la session (J-1)

Après la répétition, certains gestes de démonstration ont été faits. Remettez l’environnement dans son état de départ.

| À vérifier                                                | Action si nécessaire                                                                                         |
|-----------------------------------------------------------|--------------------------------------------------------------------------------------------------------------|
| Prospects qualifiés ou disqualifiés pendant la répétition | Réactivez-les (bouton **Réactiver le prospect**) ; supprimez l’opportunité créée par la qualification d’Inès |
| Doublons fusionnés                                        | Recréez le prospect « Ines Garnier » depuis le fichier 09 (une seule ligne)                                  |
| Logisud gagnée et commande créée en répétition            | Rouvrez l’opportunité (**Rouvrir l’opportunité**), supprimez la commande, réactivez le devis si besoin       |
| Activités ajoutées sur Campus Lumière après le 26/10      | Supprimez-les                                                                                                |
| Contact d’Inès déplacé chez Vitalis                       | Remettez Kelvin Ingénierie comme société                                                                     |
| Remise d’un devis modifiée par le test du flux            | Remettez les valeurs de F3                                                                                   |
| Prévision                                                 | Cliquez sur **Recalculer**                                                                                   |
| Mots de passe                                             | Vérifiez que chaque utilisateur se connecte sans demander de changement de mot de passe                      |

> **Astuce.** Si votre environnement le permet (environnements Sandbox et Production), faites une **sauvegarde manuelle** à la fin de la phase G : Power Platform \> Environnements \> votre environnement \> **Sauvegarde et restauration** (Backup & Restore) \> Créer. Pour un environnement d’essai, cette option peut ne pas exister : appliquez alors le tableau ci-dessus.

## Annexe 1 : problèmes fréquents

| Symptôme                                                      | Cause probable                                                            | Solution                                                          |
|---------------------------------------------------------------|---------------------------------------------------------------------------|-------------------------------------------------------------------|
| « Vous n’avez pas accès à cette application »                 | Licence ou rôle manquant                                                  | Vérifier C2 et C4                                                 |
| Import en échec : « recherche non résolue »                   | Enregistrement référencé absent ou orthographe différente                 | Importer d’abord le parent, vérifier les accents                  |
| Produit impossible à ajouter à l’opportunité                  | Produit en brouillon ou absent de la liste de prix                        | Publier le produit, l’ajouter à la liste de prix                  |
| Chiffre d’affaires de Campus Lumière à 0                      | Mode « saisi par l’utilisateur » ou liste de prix vide                    | Passer en « calculé par le système », renseigner la liste de prix |
| Prévision vide                                                | Date de clôture hors période, catégorie vide, utilisateur hors hiérarchie | Corriger puis Recalculer                                          |
| Objectifs à 0                                                 | Exercice fiscal absent ou objectif non recalculé                          | Vérifier D1, cliquer sur Recalculer                               |
| Le flux ne se déclenche pas                                   | Filtre de lignes mal écrit                                                | Vider le filtre, tester, utiliser une action Condition            |
| Copilot absent                                                | Fonction non activée ou non disponible dans la région                     | Vérifier G5, captures en secours                                  |
| Sophie voit la remise accord cadre                            | Profil de sécurité de colonne non attribué correctement                   | Vérifier les membres du profil (G1)                               |
| Changement d’unité commerciale : l’utilisateur perd ses accès | Rôles retirés lors du changement                                          | Réattribuer les rôles (C4)                                        |

## Annexe 2 : vocabulaire de l’administration

| Terme français                 | Terme anglais            | Explication simple                                                                       |
|--------------------------------|--------------------------|------------------------------------------------------------------------------------------|
| Environnement                  | Environment              | Espace isolé qui contient une base Dataverse et des applications                         |
| Locataire                      | Tenant                   | Espace Microsoft 365 de l’organisation, qui contient les utilisateurs et les licences    |
| Unité commerciale              | Business unit            | Branche de l’organisation qui délimite qui voit quoi par défaut                          |
| Rôle de sécurité               | Security role            | Ensemble de droits (lire, créer, modifier) sur chaque table                              |
| Équipe propriétaire / d’accès  | Owner team / Access team | Groupe d’utilisateurs qui possède des enregistrements, ou qui reçoit un accès ponctuel   |
| Profil de sécurité de colonne  | Column security profile  | Règle qui masque ou protège une colonne sensible                                         |
| Solution                       | Solution                 | Paquet qui regroupe les personnalisations pour les déplacer d’un environnement à l’autre |
| Mappage                        | Mapping                  | Correspondance entre une colonne du fichier et une colonne de Dynamics 365               |
| Recherche                      | Lookup                   | Colonne qui pointe vers un autre enregistrement (par exemple le compte parent)           |
| Flux de processus d’entreprise | Business process flow    | Barre d’étapes qui guide l’utilisateur sur une fiche                                     |
| Recalculer                     | Recalculate              | Mettre à jour un objectif ou une prévision après un changement de données                |

## Annexe 3 : check-list récapitulative

- [ ] A : accès administrateur, poste prêt, kit décompressé
- [ ] B : environnement Enterprise en EUR, préférences françaises
- [ ] C : 4 unités commerciales, 9 utilisateurs, rôles, responsables, hiérarchie, 2 équipes
- [ ] D : exercice fiscal, doublons, catalogue actif, 4 rôles de connexion, campagne
- [ ] E : unités, produits, listes de prix, 18 comptes, 18 contacts, 2 concurrents, 47 prospects, 12 opportunités aux bonnes étapes
- [ ] F : produits de Campus Lumière (429 700 €) et de Logisud, parties prenantes, devis V1 et V2, Belvédère gagnée, 9 activités
- [ ] G : équipe d’accès et colonne protégée, séquence, modèle de devis, e-mail et Copilot (ou captures), Teams, objectifs, prévision, flux d’approbation, application Visite chantier, historique Power BI (facultatif)
- [ ] H : contrôles par épisode, répétition chronométrée, captures de secours
- [ ] I : remise à zéro à J-1
