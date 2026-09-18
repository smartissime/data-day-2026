# AB-730 : Labs de la Partie 3
## Agents Copilot et rédaction de contenu métier

**Organisme :** ARCHIALEARN  |  **Formateur :** Rodrigue YENGO  |  **Domaines du guide d'étude :** 2 (agents) et 3 (rédaction)  |  **Slides :** 25 à 33

| Lab | Titre | Durée | Compétence du guide d'étude |
|---|---|---|---|
| 3.1 | Magasin d'agents ou création : explorer et décider | 10 min | Comprendre quand utiliser le Store d'agents ou créer un nouvel agent |
| 3.2 | Créer un agent : Décrire, puis Configurer (connaissances, instructions, capacités) | 25 min | Créer un agent à l'aide d'un modèle, configurer les connaissances, configurer les paramètres |
| 3.3 | Tester et partager l'agent avec l'équipe | 15 min | Partager un agent avec les membres de l'équipe |
| 3.4 | Rédiger dans Word et Outlook : créer, générer à partir d'un document, coacher | 15 min | Créer un document à partir d'une invite, générer un document à partir d'un document existant |
| 3.5 | Générer une présentation PowerPoint à partir d'un Word (avec étiquette) | 10 min | Générer un document à partir d'un document existant |

---

## Lab 3.1 : Magasin d'agents ou création : explorer et décider

**Durée :** 10 min  |  **Slide de référence :** 27

### Prérequis

- [ ] Compte avec licence Microsoft 365 Copilot.
- [ ] Application Microsoft 365 Copilot, menu **Agents** visible dans le volet gauche.
- [ ] Le bouton **Créer un agent** est présent (droit de création activé par l'administrateur du tenant de formation).
- [ ] Feuille de réponses.

### Scénario ARCHIALEARN

Trois besoins remontent des équipes ARCHIALEARN. Pour chacun, décider entre un agent du magasin et la création d'un agent.

### Procédure pas à pas

1. Dans le volet gauche, cliquer sur **Agents**. La page affiche vos agents récents et un bouton **Tous les agents** (ou **Explorer les agents**, Get agents).
2. Cliquer sur **Tous les agents** : le **Magasin d'agents** (Agent Store) s'ouvre. Repérer les trois catégories : **Créés par Microsoft** (Chercheur, Analyste, etc.), **Créés par des partenaires**, **Créés par votre organisation**.
3. Cliquer sur la carte **Chercheur** (Researcher). Lire la description, puis chercher un bouton **Modifier** ou **Paramètres** : il n'existe pas. Les instructions et les invites suggérées d'un agent Microsoft sont **verrouillées**.
4. Cliquer sur **Ajouter** (ou **Ouvrir**) pour l'épingler dans votre liste d'agents s'il n'y est pas déjà.
5. Revenir sur **Agents** et cliquer sur **Créer un agent** (Create agent). L'**Agent Builder** s'ouvre, avec deux onglets en haut du volet gauche : **Décrire** (Describe) et **Configurer** (Configure), et un volet de test **Aperçu** à droite.
6. Ne rien saisir pour l'instant. Observer dans l'onglet **Configurer** les sections : **Nom**, **Description**, **Instructions**, **Connaissances**, **Invites suggérées**, **Fonctionnalités** (ou **Capacités**). Fermer sans enregistrer.
7. Sur la feuille de réponses, décider pour chaque besoin : magasin ou création, et pourquoi.
   - a. Le service commercial veut une étude comparative de trois concurrents avec sources web et documents SharePoint.
   - b. Le service formation veut un assistant qui répond uniquement à partir de la politique de déplacements et des procédures internes, avec un ton formel.
   - c. Un chef de projet veut « au plus vite » un agent pour les organisateurs de réunions et le tester avec un minimum d'effort.
8. Correction : a Magasin (Chercheur) ; b Création, onglet Configurer (connaissances SharePoint + instructions) ; c Création, onglet **Décrire** avec une description basique.

### Résultat attendu

Le magasin exploré, le verrouillage des agents Microsoft constaté, l'Agent Builder repéré avec ses deux onglets, et la grille de décision remplie.

### À noter pour l'examen

* **Magasin d'agents** : agents prêts à l'emploi de Microsoft (Chercheur, Analyste), de partenaires et de votre organisation. Paramètres **verrouillés** pour les agents Microsoft : instructions et invites suggérées non modifiables. Bon choix quand un agent existant couvre le besoin.
* **Créer un agent** quand vous avez besoin de **vos connaissances** (SharePoint, fichiers), d'une **persona** ou d'un **processus** spécifique. Création dans l'application Microsoft 365 Copilot avec l'**Agent Builder** (version allégée de Copilot Studio).
* Deux voies : **Décrire** (langage naturel, l'IA générative construit l'agent) ou **Configurer** (manuel).
* Créer un agent au plus vite et le tester avec un minimum d'effort : **onglet Décrire, description basique** (et non Configurer, ni un modèle).
* Phrase à compléter : « exploiter l'IA générative pour construire l'agent en utilisant... » : **l'onglet Décrire**.

### Question flash

Un collègue voit le Chercheur dans son application Copilot, pas vous. Que faire ?
**Sélectionner Explorer les agents (Tous les agents) puis rechercher Researcher.** Inutile de demander une licence ou d'utiliser un compte personnel.

---

## Lab 3.2 : Créer un agent : Décrire, puis Configurer

**Durée :** 25 min  |  **Slides de référence :** 10 et 28

### Prérequis

- [ ] Compte avec licence Microsoft 365 Copilot et droit de création d'agents.
- [ ] Accès en lecture au site SharePoint **ARCHIALEARN - Formation AB-730** (bibliothèque Documents, dossier Labs).
- [ ] Fichiers `Politique-Deplacements.docx` et `Process-Onboarding.docx` sur ce site SharePoint.
- [ ] Fichier `Logo-ARCHIALEARN.png` sur le poste (pour tester le téléversement d'une image comme connaissance).
- [ ] Fichier `Ventes-2025.xlsx` dans OneDrive (pour tester l'interpréteur de code).
- [ ] Une boîte aux lettres partagée existante sur le tenant (par exemple `formation@archialearn.fr`) pour l'étape 12, ou à défaut la démonstration du formateur.

### Scénario ARCHIALEARN

Vous créez « Assistant Réunions ARCHIALEARN » : il prépare les invitations, propose un ordre du jour, attribue les rôles, rédige le compte rendu, et connaît la politique de déplacements pour les réunions hors site.

### Procédure pas à pas

**Voie 1 : onglet Décrire**

1. **Agents**, **Créer un agent**. Dans l'onglet **Décrire**, saisir dans la zone de conversation :
   ```
   Un agent qui aide les organisateurs de réunions d'ARCHIALEARN : il prépare les e-mails d'invitation, propose un ordre du jour, attribue les rôles et rédige le compte rendu à partir des notes fournies.
   ```
2. Répondre aux questions posées par l'assistant de création (nom souhaité, ton, etc.). Proposer le nom `Assistant Réunions ARCHIALEARN`.
3. Basculer sur l'onglet **Configurer** : constater que **Nom**, **Description**, **Instructions** et **Invites suggérées** ont été **remplis automatiquement** par l'IA générative. Lire les instructions générées.

**Voie 2 : onglet Configurer, ajustements manuels**

4. Section **Instructions** : remplacer le texte par une persona formelle :
   ```
   Tu es l'assistant des organisateurs de réunions d'ARCHIALEARN. Ton formel et concis, en français. Pour chaque demande : 1) proposer un ordre du jour numéroté, 2) attribuer un animateur, un rapporteur et un gardien du temps, 3) rédiger l'e-mail d'invitation. Pour une réunion hors site, rappelle les règles de la politique de déplacements (seuil de validation à 1 000 euros, hôtels référencés). Ne réponds qu'à partir des connaissances fournies ; si l'information manque, dis-le.
   ```
5. Section **Description** : `Prépare invitations, ordres du jour, rôles et comptes rendus de réunion pour ARCHIALEARN.` (Cette description sert à la découverte de l'agent, pas à son comportement.)
6. Section **Connaissances** (Knowledge) : cliquer sur **Ajouter des connaissances** (ou **+**). Observer les types proposés : **Sites SharePoint**, **Fichiers OneDrive**, **Sites web**, **Conversations et réunions Teams**, **Téléverser des fichiers**.
7. Choisir **SharePoint**, coller l'URL du site **ARCHIALEARN - Formation AB-730** ou le sélectionner dans la liste, valider.
8. Cliquer à nouveau sur **+**, choisir **Fichiers**, sélectionner `Politique-Deplacements.docx` et `Process-Onboarding.docx`.
9. Cliquer sur **+**, choisir **Téléverser**, sélectionner `Logo-ARCHIALEARN.png` : constater qu'une **image** est acceptée comme connaissance.
10. Cliquer sur **+**, choisir **Site web**, saisir `https://learn.microsoft.com/fr-fr/copilot/microsoft-365/` et valider.
11. Compter les sources : noter la limite affichée (**20 sources maximum**).
12. Test négatif : chercher une option pour ajouter une **boîte aux lettres partagée**, **un autre agent** ou **une conversation Copilot** comme connaissance : ces options n'existent pas.
13. Section **Invites suggérées** (Suggested prompts) : ajouter trois entrées, chacune avec un titre et un message :
    - `Ordre du jour` / `Propose un ordre du jour pour une réunion de lancement de projet d'une heure.`
    - `Invitation` / `Rédige l'e-mail d'invitation pour la réunion mensuelle des formateurs.`
    - `Compte rendu` / `Rédige le compte rendu à partir des notes que je vais coller.`
14. Section **Fonctionnalités** (Capabilities) : activer **Interpréteur de code** (Code interpreter) et **Générateur d'images** (Image generator). Lire les infobulles : calculs, graphiques et agrégations sur fichiers Excel pour le premier ; logos et visuels pour le second.
15. Cliquer sur **Créer** (Create) en haut à droite. L'agent apparaît dans votre liste **Agents**.

**Tester dans le volet Aperçu**

16. Avant de fermer, dans le volet **Aperçu** (Test) à droite, cliquer sur l'invite suggérée **Ordre du jour** et vérifier le ton formel et la structure en trois blocs.
17. Saisir : `La réunion aura lieu à Lyon, budget hôtel 1 200 euros par personne.` Vérifier que l'agent rappelle le seuil de validation à 1 000 euros issu de `Politique-Deplacements.docx` (connaissances) et refuse de valider seul (instructions).
18. Saisir : `Génère un visuel d'en-tête pour l'invitation.` : le générateur d'images produit une image (capacité).
19. Taper `/`, sélectionner `Ventes-2025.xlsx`, puis : `Fais un graphique des ventes par région.` : l'interpréteur de code produit le graphique.

### Résultat attendu

Un agent créé en deux temps (Décrire puis Configurer), avec quatre types de connaissances, une persona formelle, trois invites suggérées, deux capacités, et testé sur les trois briques connaissances / instructions / capacités.

### À noter pour l'examen

* **Connaissances** acceptées : sites SharePoint, fichiers OneDrive, sites web, conversations et réunions Teams, fichiers téléversés (**y compris images**). **Non acceptées** : boîtes aux lettres partagées, un autre agent, une conversation Copilot. Jusqu'à **20 sources** ; l'agent ne répond qu'à partir des sources approuvées.
* **Instructions** = persona, ton, tâches, style (« chaleureux et amical » : modifier les **instructions**). **Description** = découverte. **Invites suggérées** = exemples cliquables au démarrage.
* **Capacités** : **interpréteur de code** (visualisations, calculs, agrégations sur Excel) ; **générateur d'images** (logos, visuels marketing). **Modèles** (Career Coach, Customer Insights...) pour démarrer vite.
* Agent d'analyse sur fichiers Excel : ajouter **l'interpréteur de code**. Agent marketing pour logos et illustrations : ajouter **le générateur d'images**.
* Affirmation type sur un agent créé à partir d'un modèle : « vous pouvez choisir les sources de connaissances » : **vrai** ; « rechercher dans des boîtes partagées », « un autre agent comme source », « partager avec des externes » : **faux**.

### Question flash

Vous voulez que votre agent réponde de manière « chaleureuse et amicale ». Que modifiez-vous ?
**Les instructions.**

---

## Lab 3.3 : Tester et partager l'agent avec l'équipe

**Durée :** 15 min  |  **Slides de référence :** 29 et 30

### Prérequis

- [ ] Agent `Assistant Réunions ARCHIALEARN` créé au Lab 3.2.
- [ ] Binôme identifié dans le même tenant.
- [ ] Microsoft Teams ouvert (client de bureau ou web), membre de l'équipe **AB-730 - Session du 18/09/2026**.
- [ ] Word (bureau) avec Copilot, pour vérifier la disponibilité de l'agent dans le volet Copilot.
- [ ] (Facultatif) Adresse e-mail d'un compte externe ou d'un compte Microsoft personnel pour le test négatif de l'étape 6.

### Scénario ARCHIALEARN

Vous mettez l'agent à disposition des organisateurs de réunions et vous vérifiez ce qu'un collègue peut ou ne peut pas faire.

### Procédure pas à pas

**Tester dans Teams via @mention**

1. Dans Teams, ouvrir le canal **Général** de l'équipe AB-730. Dans une nouvelle publication, taper `@Assistant Réunions ARCHIALEARN` et sélectionner l'agent, puis : `Propose un ordre du jour pour la réunion de clôture de la formation.` Envoyer.
2. Si l'agent n'est pas proposé, ouvrir **Applications** dans Teams, rechercher l'agent par son nom, **Ajouter**. Refaire l'étape 1.
3. Ouvrir une discussion privée avec l'agent (Teams, **Chat**, rechercher son nom) et poser la même question.

**Vérifier l'état par défaut : privé**

4. Binôme : ouvrir **Agents** dans l'application Microsoft 365 Copilot et rechercher `Assistant Réunions ARCHIALEARN` : l'agent **n'apparaît pas**. Un agent n'est jamais partagé automatiquement.

**Partager**

5. Créateur : **Agents**, ouvrir l'agent, cliquer sur `...` puis **Modifier** (ou ouvrir directement l'Agent Builder), puis sur le bouton **Partager** en haut à droite. Observer les options :
   - **Toute personne de votre organisation disposant du lien**.
   - **Utilisateurs ou groupes spécifiques** : saisir le nom du binôme.
   - **Publier dans le catalogue de l'organisation** (soumis à **approbation de l'administrateur**).
6. Choisir **Utilisateurs spécifiques**, ajouter le binôme, cliquer sur **Copier le lien** puis **Terminé**. Test négatif facultatif : tenter d'ajouter une adresse externe (`test@archifridays.fr`) ou un compte Microsoft personnel : le sélecteur ne le propose pas.
7. Envoyer le lien au binôme dans Teams.

**Ce que le binôme peut faire**

8. Binôme : ouvrir le lien, l'agent s'ajoute dans sa liste **Agents**. L'utiliser : `Rédige l'e-mail d'invitation pour la réunion des formateurs.` Fonctionne.
9. Binôme : dans Word, onglet **Accueil**, **Copilot** ; dans le volet Copilot, ouvrir le sélecteur d'agents (icône ou menu en haut du volet) : l'agent partagé y est disponible.
10. Binôme : dans **Agents**, `...` sur l'agent : les options sont **Ouvrir**, **Supprimer** (désinstaller), éventuellement **Détails**. Il n'y a **pas de « Modifier »** : le binôme ne peut pas changer les instructions.
11. Binôme : cliquer sur **Supprimer** (désinstaller l'agent), puis ouvrir **Conversations** : la conversation menée avec l'agent à l'étape 8 est **toujours présente**, et les invites enregistrées éventuelles aussi.
12. Créateur : tenter d'ajouter un connecteur tiers ou un flux multi-étapes dans l'agent : l'Agent Builder ne le propose pas. Noter que ce type de workflow relève de **Copilot Studio**.

### Résultat attendu

Un agent utilisable dans Teams via `@`, partagé à un collègue interne qui peut l'utiliser dans Copilot, Teams et Word mais pas le modifier ; la désinstallation conserve les conversations.

### À noter pour l'examen

* Partage possible avec des **utilisateurs ou groupes de votre organisation**, ou par **lien interne** ; agent disponible dans **Teams**, **Word** et le **volet Copilot** des applications ; publication au **catalogue de l'organisation après approbation de l'administrateur**.
* Un agent est **privé par défaut**, jamais partagé automatiquement. **Pas de partage** avec des utilisateurs externes ni des comptes Microsoft personnels.
* Un utilisateur avec qui l'agent est partagé **ne peut pas modifier ses instructions**.
* **Désinstaller** un agent conserve les conversations et les invites enregistrées associées.
* Workflows complexes avec connecteurs tiers : **Copilot Studio**, pas l'Agent Builder.
* Série type (coordinateur de projet dans un cabinet de conseil) : « partagés automatiquement » **Non** ; « interagir dans Teams » **Oui** ; « un utilisateur partagé peut modifier les instructions » **Non** ; « avec qui partager ? » **uniquement les personnes de votre organisation**.

### Question flash

Vous partagez votre agent avec un collègue. Peut-il en modifier les instructions ?
**Non.**

---

## Lab 3.4 : Rédiger dans Word et Outlook : créer, générer à partir d'un document, coacher

**Durée :** 15 min  |  **Slide de référence :** 31

### Prérequis

- [ ] Compte avec licence Microsoft 365 Copilot.
- [ ] Word (bureau ou web) et Outlook (nouveau Outlook ou Outlook web) avec Copilot activé.
- [ ] Fichier `Rapport-Q3.docx` dans OneDrive.
- [ ] Un fil d'e-mails d'au moins trois messages dans la boîte de réception (le binôme envoie deux réponses successives à un message « Préparation rapport Q3 » avant le lab).

### Scénario ARCHIALEARN

Vous rédigez l'introduction du rapport Q3 dans Word, vous transformez un paragraphe en tableau, puis vous répondez à la direction dans Outlook avec l'aide du coaching.

### Procédure pas à pas

**Word : créer un document à partir d'une invite**

1. Ouvrir Word, **Nouveau document vide**. Sur la page vide, l'icône **Copilot** apparaît dans la marge (ou onglet **Accueil**, **Copilot**, **Brouillon avec Copilot**).
2. Cliquer sur **Brouillon avec Copilot** (Draft with Copilot). Dans la zone, saisir :
   ```
   Rédige une introduction professionnelle pour notre rapport de performance Q3 d'ARCHIALEARN, deux paragraphes, ton formel.
   ```
   Cliquer sur **Générer**.
3. Dans la barre d'actions du brouillon, tester **Régénérer**, puis la zone d'affinage : `Rends-le plus court.` Cliquer sur **Conserver** (Keep it).

**Word : générer à partir d'un document existant (Travail et Web)**

4. Placer le curseur sous l'introduction. **Brouillon avec Copilot**, cliquer sur l'icône **Référencer un fichier** (trombone ou `/`), sélectionner `Rapport-Q3.docx`, puis :
   ```
   Résume les tendances internes du trimestre en 5 puces à partir de ce document.
   ```
   **Générer**, **Conserver**.
5. Ouvrir le **volet Copilot** (onglet **Accueil**, **Copilot**). Vérifier le sélecteur **Travail / Web** en haut du volet ; basculer sur **Web** et saisir :
   ```
   Donne 3 tendances 2026 du secteur de la formation professionnelle en France, avec sources.
   ```
   Cliquer sur **Copier** puis coller dans le document.

**Word : texte vers tableau, ton et clarté**

6. Sélectionner les 5 puces de l'étape 4. Cliquer sur l'icône **Copilot** qui apparaît à côté de la sélection, choisir **Visualiser sous forme de tableau** (Visualize as a table). Valider avec **Conserver**.
7. Sélectionner le premier paragraphe, icône **Copilot**, **Réécrire avec Copilot** (Rewrite), puis **Ajuster le ton**, choisir **Professionnel** ou **Concis**. Remplacer.
8. Dans le volet Copilot, saisir : `Résume ce document en 3 points clés.` (résumé du document ouvert).
9. Onglet **Références**, **Table des matières** : Copilot peut aussi la générer à partir des titres via le volet (`Insère une table des matières basée sur les titres`). Constater en revanche qu'une demande `Modifie les marges à 1,5 cm` ou `Ajoute un filigrane CONFIDENTIEL` n'est pas exécutée par Copilot : ces réglages passent par le ruban **Mise en page** / **Création**.
10. Enregistrer sous `Rapport-Q3-v2.docx` dans OneDrive.

**Outlook : rédiger, résumer, coacher**

11. Ouvrir Outlook. Ouvrir le fil **Préparation rapport Q3** (au moins trois messages). En haut du fil, cliquer sur **Résumé par Copilot** (Summary by Copilot) : un résumé du fil s'affiche avec les points clés et les références aux messages.
12. Cliquer sur **Répondre**. Dans le corps du message, cliquer sur l'icône **Copilot**, **Rédiger avec Copilot** (Draft with Copilot). Saisir :
    ```
    Réponds en confirmant que l'introduction et les tendances sont rédigées, et propose une relecture jeudi.
    ```
    Choisir le ton **Formel** et la longueur **Courte** dans les options, **Générer**, puis **Conserver**.
13. Icône **Copilot**, **Coaching par Copilot** (Coaching by Copilot) : lire les suggestions sur le ton, la clarté et le sentiment du lecteur. Appliquer une suggestion.
14. Ne pas envoyer (ou envoyer au binôme). Constater qu'aucune option Copilot ne permet d'**insérer une signature HTML** ni de **réorganiser les dossiers** : ces fonctions relèvent des **Paramètres** d'Outlook.

### Résultat attendu

Un document Word créé par invite, enrichi à partir d'un fichier référencé (Travail) et du web, avec tableau et ton ajusté ; un e-mail rédigé et coaché dans Outlook après résumé du fil.

### À noter pour l'examen

* **Word** : créer un document à partir d'une invite ; générer à partir d'un document existant (`/Rapport.docx`, portée Travail ou Web) ; **Visualiser sous forme de tableau** ; ajuster ton et clarté par invites de suivi ; résumer les points clés ; **insérer une table des matières à partir des titres**. Copilot **ne** modifie **pas** les marges ni n'insère de filigrane personnalisé.
* **Outlook** : **Rédiger avec Copilot** (brouillon basé sur le contexte du fil, ton et longueur ajustables) ; **Résumé par Copilot** en haut d'un long fil ; **Coaching** avant l'envoi ; résumé des e-mails non lus. Copilot **n'insère pas** de signature HTML et **ne modifie pas** l'arborescence des dossiers.
* Deux tâches Outlook (question type) : **générer un brouillon de réponse basé sur le contexte de la conversation** et **créer un résumé des e-mails non lus**.
* Deux tâches Word (question type) : **insérer une table des matières basée sur les titres** et **générer un résumé des points clés**.
* Logique générale : Copilot **génère, résume, analyse et transforme du contenu** ; il ne fait **pas de mise en forme fine ni d'actions techniques de configuration**.

### Question flash

Quelles deux tâches pouvez-vous réaliser avec Copilot dans Word ?
**Insérer une table des matières basée sur les titres et générer un résumé des points clés.**

---

## Lab 3.5 : Générer une présentation PowerPoint à partir d'un Word (avec étiquette)

**Durée :** 10 min  |  **Slides de référence :** 31 et 8

### Prérequis

- [ ] Compte avec licence Microsoft 365 Copilot.
- [ ] PowerPoint (bureau) avec Copilot.
- [ ] Fichier `Rapport-Q3-v2.docx` (créé au Lab 3.4) ou `Rapport-Q3.docx` dans OneDrive, **avec des titres de niveaux 1 et 2** (les titres structurent les diapositives).
- [ ] Fichier `Confidentiel-Plan-Strategique.docx` étiqueté **Hautement confidentiel** sur SharePoint (test d'héritage).

### Scénario ARCHIALEARN

Le comité de direction veut une présentation courte issue du rapport Q3, centrée sur les décisions, les risques et les prochaines étapes.

### Procédure pas à pas

1. Ouvrir PowerPoint, **Nouveau**, **Présentation vierge** (ou un modèle ARCHIALEARN s'il est fourni).
2. Onglet **Accueil**, cliquer sur **Copilot**. Dans le volet Copilot, cliquer sur **Créer une présentation à partir d'un fichier** (Create a presentation from a file).
3. Dans la zone d'invite, taper `/` et sélectionner `Rapport-Q3-v2.docx`, puis compléter :
   ```
   Crée une présentation pour le comité de direction à partir de ce document, centrée sur les décisions, les risques et les prochaines étapes. 6 diapositives maximum.
   ```
   Cliquer sur **Envoyer**.
4. Observer la génération : titre, diapositives par section, notes du présentateur générées automatiquement (volet **Notes**).
5. Dans le volet Copilot, saisir : `Ajoute une diapositive de synthèse à la fin.` : Copilot crée une diapositive **Résumé / Points clés**.
6. Saisir : `Réorganise la diapositive 3 en liste à puces prête à présenter.`
7. Test négatif : saisir `Ajoute une animation de rebond sur le titre de la diapositive 2` puis `Applique le thème aux couleurs ARCHIALEARN (bleu #1F4E79)`. Constater que Copilot ne réalise pas ces mises en forme spécifiques (animations personnalisées, thème de marque) : elles se font via **Animations** et **Création** dans le ruban.
8. Vérifier l'étiquette : onglet **Fichier**, **Informations** (ou bouton **Confidentialité** du ruban). La présentation a hérité de l'étiquette du document source (par exemple **Général**).
9. Refaire les étapes 2 et 3 avec `/Confidentiel-Plan-Strategique.docx` : la présentation générée porte l'étiquette **Hautement confidentiel**, appliquée automatiquement, sans refus ni demande.
10. Enregistrer sous `Comite-Direction-Q3.pptx` dans OneDrive.

### Résultat attendu

Une présentation générée depuis un document Word, avec diapositive de synthèse, et l'héritage de l'étiquette de confidentialité vérifié dans les deux cas.

### À noter pour l'examen

* **PowerPoint** : créer une présentation à partir d'un document Word (`/Rapport.docx` dans l'invite) ; produire une **diapositive de synthèse** ; réorganiser en listes prêtes à présenter ; créer une mise en page à partir du contenu. Copilot **ne fait pas** d'animation personnalisée d'un objet ni de thème aux couleurs de l'entreprise.
* L'**étiquette de confidentialité** du document source est **héritée** par la présentation (cas « Hautement confidentiel » : génère **et** applique l'étiquette).
* Flux officiel à retenir : Word (introduction Q3, invites Travail et Web) ; PowerPoint (présentation pour la direction à partir de `/Rapport-Q3.docx`, centrée décisions / risques / prochaines étapes) ; Outlook (e-mail de mise à jour à la direction résumant `/Rapport-Q3.docx`).

### Question flash

Quelle tâche Copilot ne réalise-t-il pas dans PowerPoint : générer une présentation à partir d'un Word, produire une diapositive de synthèse, ou appliquer un thème aux couleurs de l'entreprise ?
**Appliquer un thème aux couleurs de l'entreprise.**

---

## Synthèse de la Partie 3 : vocabulaire à maîtriser

| Terme | Ce qu'il faut savoir | Piège associé |
|---|---|---|
| Magasin d'agents | Microsoft, partenaires, organisation ; agents Microsoft verrouillés | Chercher à modifier les instructions du Chercheur |
| Agent Builder | Dans l'application Microsoft 365 Copilot ; onglets Décrire / Configurer | Copilot Studio (réservé aux workflows complexes) |
| Décrire | L'IA générative construit l'agent depuis une description ; « minimum d'effort » | Configurer, modèle, bloc-notes, page |
| Connaissances | SharePoint, OneDrive, sites web, Teams, fichiers téléversés (images) ; 20 max | Boîte partagée, autre agent, conversation Copilot |
| Instructions / Description / Invites suggérées | Comportement / découverte / exemples cliquables | Modifier la description pour changer le ton |
| Capacités | Interpréteur de code (Excel, graphiques) ; générateur d'images (logos) | Inverser les deux |
| Partage d'agent | Interne seulement, privé par défaut, pas de modification par l'utilisateur partagé | Partage externe, modification par le destinataire |
| Copilot dans Word / Outlook / PowerPoint | Génère, résume, transforme ; pas de mise en forme fine ni de configuration | Marges, filigrane, signature HTML, animations, thème |


---

*Propriété intellectuelle : ARCHIA365 ([Société ARCHIA365 à 75008 PARIS - SIREN 990 705 055 | L'Annuaire des Entreprises](https://annuaire-entreprises.data.gouv.fr/entreprise/archia365-990705055)) et ARCHIALEARN. Supports réservés à la formation AB-730 délivrée par ARCHIALEARN. Pour des besoins de formation, nous contacter : contact@archia365.fr*
