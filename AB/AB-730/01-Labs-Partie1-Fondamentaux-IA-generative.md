# AB-730 : Labs de la Partie 1
## Fondamentaux de l'IA générative dans Microsoft 365

**Organisme :** ARCHIALEARN  |  **Formateur :** Rodrigue YENGO  |  **Domaine du guide d'étude :** 1 (25 à 30 %)  |  **Slides :** 4 à 14

| Lab | Titre | Durée | Compétence du guide d'étude |
|---|---|---|---|
| 1.1 | Observer l'ancrage (grounding) en action | 15 min | Comprendre les fonctionnalités d'IA générative dans les expériences Microsoft 365 |
| 1.2 | Même invite, trois contextes : Travail, Web, application | 15 min | Comprendre comment le contexte affecte les réponses Copilot |
| 1.3 | Vérifier l'héritage des permissions et des étiquettes de confidentialité | 15 min | Comprendre comment Copilot maintient les informations privées et sécurisées |
| 1.4 | Conversation ou agent : choisir le bon outil | 10 min | Comprendre la différence entre une expérience de conversation et une expérience d'agent |
| 1.5 | IA responsable : provoquer, reconnaître et vérifier | 15 min | Identifier les pratiques responsables en matière d'IA et de protection des données |

---

## Lab 1.1 : Observer l'ancrage (grounding) en action

**Durée :** 15 min  |  **Slides de référence :** 5 et 6

### Prérequis

- [ ] Compte professionnel ARCHIALEARN **avec licence Microsoft 365 Copilot**.
- [ ] Application Microsoft 365 Copilot accessible sur https://m365.cloud.microsoft (ou application de bureau).
- [ ] Fichier `Rapport-Q3.docx` présent dans OneDrive, dossier `AB-730-Labs` (déposé depuis au moins 15 minutes pour être indexé).
- [ ] Au moins un e-mail reçu dans les 7 derniers jours et une réunion Teams passée dans le calendrier (le tenant de formation en fournit).

### Scénario ARCHIALEARN

Vous êtes chargé(e) de mission chez ARCHIALEARN. La direction vous demande de comprendre « ce que Copilot va chercher » avant de répondre, afin de rassurer les équipes sur l'usage des données internes.

### Procédure pas à pas

1. Ouvrir le navigateur et saisir l'adresse `m365.cloud.microsoft`. Se connecter avec le compte professionnel.
2. Dans la barre de navigation de gauche, cliquer sur **Copilot** (icône Copilot). La page **Chat** s'ouvre.
3. Au-dessus de la zone de saisie, vérifier que le sélecteur est positionné sur **Travail** (Work) et non sur **Web**.
4. Dans la zone de saisie **Poser une question ou faire une demande**, taper l'invite suivante, puis appuyer sur **Entrée** :
   ```
   Quels sont les trois chiffres clés du rapport de performance du troisième trimestre d'ARCHIALEARN ? Cite tes sources.
   ```
5. Observer la réponse. Sous le texte, repérer la section **Références** (ou les numéros de citation cliquables). Cliquer sur la première référence : le fichier `Rapport-Q3.docx` s'ouvre dans un nouvel onglet.
6. Revenir dans la conversation. Passer la souris sur une citation : une carte affiche le nom du fichier, son emplacement (OneDrive) et la date de modification.
7. Saisir maintenant une deuxième invite :
   ```
   Résume les e-mails que j'ai reçus cette semaine au sujet de la formation AB-730, en 3 points.
   ```
8. Observer que les références pointent cette fois vers des **e-mails Outlook** et non vers un fichier.
9. Saisir une troisième invite :
   ```
   Quelles décisions ont été prises lors de ma dernière réunion Teams ?
   ```
10. Constater que la référence est une **réunion** (transcription ou récapitulatif). Si le compte n'a pas de réunion transcrite, Copilot l'indique explicitement.
11. Cliquer sur l'icône **Copier** sous la première réponse, puis coller dans un bloc-notes Windows : vérifier que les citations sont conservées sous forme de liste de sources.

### Résultat attendu

Trois réponses, chacune ancrée sur un type de source différent (fichier, e-mail, réunion), toutes accompagnées de citations cliquables vers Microsoft Graph.

### À noter pour l'examen

* Le mécanisme s'appelle **ancrage** (grounding) : Copilot enrichit l'invite avec le contexte pertinent de Microsoft Graph (fichiers, e-mails, réunions, conversations Teams) **avant** d'envoyer l'ensemble au LLM.
* Affirmation type : « Copilot utilise les informations contextuelles de votre organisation pour enrichir l'invite avant de l'envoyer au LLM » : **Oui**.
* Affirmation type : « Copilot utilise les informations de votre organisation pour entraîner le LLM » : **Non**. Les données servent uniquement à l'exécution.
* Le LLM (Azure OpenAI) **n'accède jamais directement** au tenant : c'est l'orchestrateur Copilot qui lit Microsoft Graph, avec les droits de l'utilisateur.
* La réponse revient **avec des citations** vers les sources utilisées : c'est le moyen de vérification attendu.

### Question flash

Un collègue affirme que Copilot « apprend » des documents ARCHIALEARN à chaque question. Vrai ou faux ?
**Faux.** Les documents sont utilisés à l'exécution pour l'ancrage, jamais pour entraîner le modèle.

---

## Lab 1.2 : Même invite, trois contextes : Travail, Web, application

**Durée :** 15 min  |  **Slide de référence :** 7

### Prérequis

- [ ] Compte **avec licence** Microsoft 365 Copilot (compte principal).
- [ ] Compte **sans licence** Copilot (compte témoin du binôme ou compte de démonstration) pour l'étape 8.
- [ ] Word (bureau ou web) avec le bouton **Copilot** dans le ruban.
- [ ] Fichier `Rapport-Q3.docx` dans OneDrive.

### Scénario ARCHIALEARN

Le service marketing d'ARCHIALEARN veut comparer les tendances internes des inscriptions avec les tendances du marché de la formation. Vous testez la même question dans trois contextes.

### Procédure pas à pas

**Contexte 1 : portée Travail**

1. Dans l'application Microsoft 365 Copilot, ouvrir **Chat** et cliquer sur **Nouvelle conversation** (icône crayon ou bouton **+**).
2. Vérifier que le sélecteur est sur **Travail**.
3. Saisir :
   ```
   Quelles sont les tendances des inscriptions aux formations Microsoft ce trimestre ?
   ```
4. Noter dans un fichier texte : la source des références (fichiers internes) et les trois premières idées de la réponse.

**Contexte 2 : portée Web**

5. Cliquer sur **Nouvelle conversation**. Basculer le sélecteur sur **Web**.
6. Saisir exactement la même invite qu'à l'étape 3.
7. Observer : les références sont des **sites web** (via Bing), le contenu parle du marché en général, aucun chiffre ARCHIALEARN n'apparaît.

**Contexte 3 : sans licence (compte témoin)**

8. Dans une fenêtre de navigation privée, se connecter sur `m365.cloud.microsoft` avec le compte **sans licence**. Ouvrir **Copilot**.
9. Constater qu'il n'y a **pas de sélecteur Travail / Web** : Copilot Chat répond à partir du contexte de l'invite, de la recherche internet et de l'historique de la conversation.
10. Saisir la même invite. Vérifier qu'aucun document interne n'est cité.
11. Toujours avec le compte sans licence, cliquer sur **Agents** dans le volet gauche : l'agent **Chercheur** n'est pas proposé. Cliquer sur **Pages** : la fonctionnalité est disponible.

**Contexte 4 : l'application en cours**

12. Revenir au compte avec licence. Ouvrir `Rapport-Q3.docx` dans Word.
13. Dans l'onglet **Accueil** du ruban, cliquer sur **Copilot**. Le volet **Copilot** s'ouvre à droite.
14. Saisir :
    ```
    Quelles sont les tendances des inscriptions décrites dans ce document ?
    ```
15. Observer que Copilot répond uniquement à partir du **document ouvert**, sans aller chercher d'autres fichiers ni le web.

**Vérification du caractère probabiliste**

16. Dans Copilot Chat (portée Travail), renvoyer deux fois de suite la même invite dans deux nouvelles conversations. Comparer : la formulation diffère à chaque fois.

### Résultat attendu

Quatre réponses différentes à une invite identique, et l'observation que deux exécutions identiques ne produisent jamais un texte strictement identique.

### À noter pour l'examen

* **Portée Travail** : ancrage Microsoft Graph, uniquement les données auxquelles **vous** avez accès, plus la connaissance générale du modèle. **Nécessite la licence** Microsoft 365 Copilot.
* **Portée Web** : ancrage Bing. Disponible dans Copilot Chat **même sans licence**.
* **Sans licence**, Copilot Chat utilise trois sources : **le contexte de l'invite, la recherche internet, l'historique de la conversation** (question à réponses multiples classique).
* Dans une application (Word, Excel), Copilot travaille sur le **contenu ouvert**.
* Piège : « Copilot utilise toutes les données de l'environnement Microsoft 365 de l'organisation » est **faux**, il respecte vos permissions.
* Une même invite **ne donne jamais** une réponse strictement identique : l'IA générative est probabiliste.

### Question flash

Quelles fonctionnalités sont disponibles à la fois avec et sans licence Copilot : le Chercheur, les blocs-notes ou les pages ?
**Les pages Copilot.** Chercheur et blocs-notes exigent la licence.

---

## Lab 1.3 : Vérifier l'héritage des permissions et des étiquettes de confidentialité

**Durée :** 15 min  |  **Slide de référence :** 8

### Prérequis

- [ ] Compte avec licence Microsoft 365 Copilot.
- [ ] Binôme : le stagiaire A possède dans son OneDrive un fichier `Prive-A.docx` **non partagé** ; le stagiaire B ne doit pas y avoir accès.
- [ ] Fichier `Confidentiel-Plan-Strategique.docx` étiqueté **Hautement confidentiel** (étiquette Purview publiée sur le tenant) dans le site SharePoint **ARCHIALEARN - Formation AB-730**, avec droit de lecture pour tous les stagiaires.
- [ ] PowerPoint (bureau) avec Copilot.

### Scénario ARCHIALEARN

Le responsable conformité d'ARCHIALEARN veut la preuve que Copilot ne « voit » pas plus que l'utilisateur et que les étiquettes de confidentialité suivent les contenus générés.

### Procédure pas à pas

**Partie A : Copilot n'élève jamais les droits**

1. Stagiaire A : dans Word, créer un document `Prive-A.docx` contenant la phrase `Le code secret du lab est ARCHIA-2026`. L'enregistrer dans OneDrive, **sans le partager**.
2. Stagiaire B : ouvrir Copilot Chat en portée **Travail** et saisir :
   ```
   Quel est le code secret du lab indiqué dans le document Prive-A.docx ?
   ```
3. Constater que Copilot ne trouve pas le document (réponse du type « je n'ai pas trouvé de document correspondant »).
4. Stagiaire B : taper `/` dans la zone de saisie, puis `Prive-A` : le fichier n'apparaît **pas** dans la liste de sélection.
5. Stagiaire A : partager le fichier avec B (bouton **Partager** dans Word, saisir le nom de B, droit **Peut afficher**, **Envoyer**).
6. Stagiaire B : après une à deux minutes, relancer l'invite de l'étape 2. Copilot cite désormais le fichier et donne le code.
7. Stagiaire A : retirer le partage (Word, **Partager**, icône engrenage **Gérer l'accès**, supprimer B). Stagiaire B : relancer une nouvelle conversation avec la même invite, Copilot ne trouve plus le document.

**Partie B : héritage de l'étiquette de confidentialité**

8. Dans Copilot Chat (portée Travail), saisir :
   ```
   Résume /Confidentiel-Plan-Strategique.docx en 3 points.
   ```
   Utiliser la barre oblique pour sélectionner le fichier dans la liste proposée.
9. Dans la réponse, repérer l'**icône bouclier** à côté de la référence : elle signale un document étiqueté. Passer la souris pour lire le nom de l'étiquette.
10. Ouvrir PowerPoint, **Nouveau**, **Présentation vierge**. Dans l'onglet **Accueil**, cliquer sur **Copilot**, puis **Créer une présentation à partir d'un fichier**.
11. Dans la zone d'invite, saisir :
    ```
    Crée une présentation de 5 diapositives à partir de /Confidentiel-Plan-Strategique.docx
    ```
    Sélectionner le fichier avec `/`, puis **Envoyer**.
12. Une fois la présentation générée, regarder la **barre de titre** de PowerPoint (ou l'onglet **Fichier**, **Informations**) : l'étiquette **Hautement confidentiel** a été appliquée automatiquement.
13. Cliquer sur le bouton **Confidentialité** du ruban : l'étiquette est cochée, Copilot n'a ni refusé, ni demandé de choisir une étiquette.

### Résultat attendu

Partie A : B ne voit le contenu que pendant la fenêtre de partage. Partie B : la présentation générée porte l'étiquette de son document source.

### À noter pour l'examen

* Copilot **hérite de toutes les politiques** de sécurité, conformité et confidentialité de Microsoft 365. Il **n'attribue jamais de permissions**, n'élève jamais les droits et ne remplace pas les politiques par les siennes.
* Un fichier auquel vous n'avez pas accès n'est pas visible par Copilot. Le message « **fichier vide, corrompu ou format non traité** » signifie en général un problème d'accès.
* Les données restent dans le tenant, ne servent pas à entraîner les modèles ; invites et réponses ne sont pas stockées hors du tenant.
* **Microsoft Purview** (et non Entra ID, Intune ou Defender) applique rétention, étiquettes et eDiscovery aux conversations Copilot.
* Un document étiqueté est signalé par une **icône bouclier** ; Copilot peut le résumer si vous avez les droits VIEW / EXTRACT.
* Le contenu généré **hérite de l'étiquette la plus restrictive** des sources. Scénario type : présentation générée depuis un Word « Hautement confidentiel » : Copilot **génère et applique l'étiquette** (il ne refuse pas, ne demande pas d'étiquette, ne produit pas de fichier sans étiquette).

### Question flash

Quel outil gouverne la rétention et l'eDiscovery des conversations Copilot ?
**Microsoft Purview.**

---

## Lab 1.4 : Conversation ou agent : choisir le bon outil

**Durée :** 10 min  |  **Slides de référence :** 9 et 10

### Prérequis

- [ ] Compte avec licence Microsoft 365 Copilot (les agents Chercheur et Analyste exigent la licence).
- [ ] Fichiers `Ventes-2025.xlsx` et `Politique-Deplacements.docx` dans OneDrive.
- [ ] Une feuille de réponses (papier ou fichier texte) par stagiaire.

### Scénario ARCHIALEARN

Cinq demandes arrivent le même matin à l'assistante de direction d'ARCHIALEARN. Pour chacune, elle doit choisir entre Copilot Chat, l'agent Chercheur, l'agent Analyste, ou la création d'un agent / d'un bloc-notes.

### Procédure pas à pas

1. Dans l'application Microsoft 365 Copilot, cliquer sur **Agents** dans le volet gauche. Observer les deux agents Microsoft : **Chercheur** (Researcher) et **Analyste** (Analyst). Lire la description de chacun (cliquer sur la carte, puis **Détails**).
2. Cliquer sur **Chercheur**, puis dans la zone de saisie taper :
   ```
   Compare ARCHIALEARN et ARCHIFRIDAYS sur leur offre de formation Microsoft, avec un tableau et des sources.
   ```
   Observer que le Chercheur pose d'abord une ou deux **questions de clarification** avant de lancer la recherche. Répondre brièvement, puis laisser tourner (plusieurs minutes).
3. Pendant ce temps, ouvrir **Analyste**. Taper `/` et sélectionner `Ventes-2025.xlsx`, puis :
   ```
   Calcule le total des ventes par région et par trimestre, avec la variation trimestrielle en pourcentage, et produis un graphique.
   ```
   Observer le raisonnement affiché étape par étape et le code Python exécuté en arrière-plan (lien **Afficher le code** ou **Raisonnement**).
4. Ouvrir une **Nouvelle conversation** dans **Chat** (portée Travail) et saisir :
   ```
   À partir de /Politique-Deplacements.docx, rédige un e-mail de 8 lignes au ton formel destiné au vice-président, résumant les règles de remboursement.
   ```
5. Sur la feuille de réponses, classer les cinq demandes suivantes (Chat, Chercheur, Analyste, ou créer un agent / bloc-notes) :
   - a. Consolider trois feuilles Excel, calculer les variations, produire des graphiques.
   - b. Comparer deux entreprises avec sources et tableaux, à partir de SharePoint et du web.
   - c. Résumer un document en e-mail au ton adapté pour un vice-président.
   - d. Téléverser les mêmes cinq fichiers à chaque nouvelle conversation.
   - e. Préparer un déplacement à Lyon en appliquant la politique de voyage, chaque semaine, pour toute l'équipe.
6. Corriger en binôme, puis avec le formateur.

### Résultat attendu

Un rapport du Chercheur avec citations, un graphique de l'Analyste, un e-mail du Chat, et la grille de classement : a Analyste, b Chercheur, c Chat, d créer un agent avec source de connaissances ou un bloc-notes, e créer un agent (connaissances = politique, instructions = règles, capacités = actions).

### À noter pour l'examen

* **Conversation (Copilot Chat)** : assistant généraliste ; vous fournissez le contexte à chaque fois ; idéal pour distiller, reformuler, adapter un ton, extraire des actions.
* **Agent** : assistant spécialisé avec **connaissances** (ce qu'il sait), **instructions** (les règles qu'il suit), **capacités** (ce qu'il peut faire).
* **Chercheur** = recherche multi-sources (travail et web) avec **citations** ; **Analyste** = données, calculs, graphiques (Python en arrière-plan).
* Créer son agent quand on **réutilise les mêmes fichiers, la même persona ou le même processus**. Le scénario « même cinq fichiers à chaque conversation » admet deux bonnes réponses : **un agent avec source de connaissances** ou **un bloc-notes** qui référence les fichiers.

### Question flash

Un assistant marketing doit évaluer les dépenses et le retour sur investissement par canal sur l'année. Meilleure réponse : Chat, Chercheur, Analyste ou bloc-notes ?
**L'agent Analyste.**

---

## Lab 1.5 : IA responsable : provoquer, reconnaître et vérifier

**Durée :** 15 min  |  **Slide de référence :** 12

### Prérequis

- [ ] Compte avec licence Microsoft 365 Copilot.
- [ ] Agent **Chercheur** accessible.
- [ ] Fichier `Rapport-Q3.docx` dans OneDrive.
- [ ] Une image générée avec Copilot (le lab en crée une à l'étape 8) et l'accès au site https://contentcredentials.org/verify (ou l'outil de vérification intégré de l'application).

### Scénario ARCHIALEARN

Avant de diffuser une proposition commerciale rédigée avec Copilot, ARCHIALEARN impose une revue humaine. Vous apprenez à reconnaître les trois risques et à appliquer les étapes de vérification.

### Procédure pas à pas

**Reconnaître la fabrication**

1. Copilot Chat, portée **Web**. Saisir :
   ```
   Donne-moi le chiffre d'affaires 2025 exact d'ARCHIFRIDAYS et le nom de son directeur financier, avec la source.
   ```
   (ARCHIFRIDAYS est une organisation fictive : toute donnée précise est nécessairement inventée ou non sourcée.)
2. Cliquer sur chaque référence proposée. Constater soit l'absence de source, soit une source qui ne contient pas l'information. Écrire sur la feuille : **fabrication**.

**Reconnaître le signal du filtre de sécurité**

3. Dans une nouvelle conversation, formuler une demande qui enfreint manifestement les règles d'usage (par exemple demander la rédaction d'un message d'intimidation envers un collègue). Observer le message du type **« Désolé, il semble que je ne puisse pas répondre à cela. Essayons un autre sujet. »**
4. Noter : ce message signifie que l'invite enfreint les règles de sécurité, et non qu'elle est trop vague ou trop longue.

**Vérifier les citations du Chercheur**

5. Ouvrir l'agent **Chercheur**. Saisir :
   ```
   Rédige une note d'une page sur l'évolution des inscriptions ARCHIALEARN au T3, à partir de /Rapport-Q3.docx et de tendances du marché de la formation trouvées sur le web.
   ```
6. Une fois le rapport produit, cliquer sur **chaque citation**. Pour chacune, cocher sur la feuille : source interne / source web / information vérifiée dans la source / information non retrouvée.
7. Dans le volet de la réponse, ouvrir le **volet d'activité** (icône « Activité » ou « Afficher l'activité ») pour lire la **requête de recherche exacte** utilisée par Copilot pour trouver les pages web.

**Content credentials sur une image**

8. Dans Copilot Chat, saisir :
   ```
   Génère une illustration représentant une salle de formation moderne ARCHIALEARN.
   ```
9. Télécharger l'image (icône **Télécharger** sur l'image).
10. Ouvrir https://contentcredentials.org/verify et glisser l'image : la mention des **content credentials** (C2PA) indique que l'image a été générée par une IA (Microsoft Copilot / modèle utilisé).

**Simuler la dépendance excessive**

11. Lire en binôme le cas suivant : « un merchandiser commande un gros stock en se basant uniquement sur les suggestions de Copilot, sans vérifier les tendances du marché ». Nommer le risque : **dépendance excessive** (overreliance).
12. Écrire en trois lignes la procédure de revue humaine qu'ARCHIALEARN devrait imposer avant toute décision d'achat.

### Résultat attendu

La feuille de réponses comporte les trois risques nommés (fabrication, dépendance excessive, injection d'invite), le message du filtre de sécurité reconnu, la vérification des citations effectuée et l'image vérifiée par content credentials.

### À noter pour l'examen

* Trois risques à nommer précisément :
  - **Fabrication** (hallucination) : information plausible mais fausse (ex. rapport web contenant des informations fictives).
  - **Dépendance excessive** (overreliance) : l'utilisateur accepte la sortie sans la vérifier (ex. le merchandiser).
  - **Injection d'invite** : instructions malveillantes cachées dans un document, un e-mail ou une page web.
* Étapes de vérification : **cliquer sur les citations** (surtout avec le Chercheur), **revue humaine obligatoire** pour tout contenu critique, **content credentials** pour vérifier qu'une image est générée par l'IA (et non les filigranes, noms ou descriptions de fichiers).
* Pour garantir l'exactitude des citations d'une proposition : **vérifier manuellement les citations** (et non créer un agent ou un bloc-notes).
* Signaux : « Désolé, je ne peux pas répondre à cela » = **règles de sécurité enfreintes** ; le **volet d'activité** montre la requête de recherche exacte ; « fichier vide, corrompu ou format non traité » = **accès au fichier manquant**.

### Question flash

Vous soupçonnez qu'une image reçue a été générée par Copilot. Que vérifiez-vous ?
**Les content credentials.**

---

## Synthèse de la Partie 1 : vocabulaire à maîtriser

| Terme | Définition en une ligne | Piège associé |
|---|---|---|
| Ancrage (grounding) | Enrichissement de l'invite avec le contexte Microsoft Graph avant envoi au LLM | Confondre avec l'entraînement du modèle |
| Portée Travail / Web | Source d'ancrage : Graph (licence requise) ou Bing (sans licence) | Croire que Travail voit toutes les données de l'organisation |
| Héritage des politiques | Copilot respecte les permissions et politiques existantes | Réponses « politiques distinctes », « contrôles dynamiques IA » |
| Étiquette de confidentialité | Suivie et héritée par le contenu généré (la plus restrictive) | « Copilot refuse » ou « demande une étiquette » |
| Microsoft Purview | Gouvernance des conversations : rétention, étiquettes, eDiscovery | Entra ID, Intune, Defender |
| Fabrication / Dépendance excessive / Injection d'invite | Les trois risques d'IA responsable | Confondre le risque côté contenu (fabrication) et côté utilisateur (dépendance) |
| Content credentials | Preuve d'origine IA d'une image | Filigrane, nom de fichier |


---

*Propriété intellectuelle : ARCHIA365 ([Société ARCHIA365 à 75008 PARIS - SIREN 990 705 055 | L'Annuaire des Entreprises](https://annuaire-entreprises.data.gouv.fr/entreprise/archia365-990705055)) et ARCHIALEARN. Supports réservés à la formation AB-730 délivrée par ARCHIALEARN. Pour des besoins de formation, nous contacter : contact@archia365.fr*
