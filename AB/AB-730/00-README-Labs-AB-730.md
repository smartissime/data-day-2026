# AB-730 : AI Business Professional
## Kit de labs ARCHIALEARN (accompagnement du deck de formation)

| Élément | Valeur |
|---|---|
| Organisme | ARCHIALEARN (marque formation d'ARCHIA365 SAS) |
| Formateur | Rodrigue YENGO |
| Certification visée | Microsoft Certified: AI Business Professional (examen AB-730) |
| Format | 1 journée, 4 parties, 1 lab par compétence du guide d'étude |
| Supports associés | Deck `AB-730-Archia365-Slides.pptx`, prompteur, banque de questions |



## 1. Organisation du kit

Chaque fichier correspond à une partie du deck. Chaque lab suit toujours la même structure, pour que les stagiaires prennent des réflexes de lecture identiques à ceux attendus le jour de l'examen.

| Fichier | Partie du deck | Domaine du guide d'étude | Nombre de labs |
|---|---|---|---|
| `01-Labs-Partie1-Fondamentaux-IA-generative.md` | Partie 1 (slides 4 à 14) | Domaine 1 (25 à 30 %) | 5 labs |
| `02-Labs-Partie2-Invites-et-conversations.md` | Partie 2 (slides 15 à 24) | Domaine 2 (35 à 40 %) | 6 labs |
| `03-Labs-Partie3-Agents-et-redaction.md` | Partie 3 (slides 25 à 33) | Domaines 2 et 3 | 5 labs |
| `04-Labs-Partie4-Analyser-resumer-collaborer.md` | Partie 4 (slides 34 à 42) | Domaine 3 (25 à 30 %) | 6 labs |
| `Donnees-Labs/` | Jeu de données fictif ARCHIALEARN (Word, Excel, image) | Tous | 9 fichiers |
| `MENTIONS-PROPRIETE-INTELLECTUELLE.md` | Propriété intellectuelle et conditions d'utilisation du kit | | |

Structure de chaque lab :

1. **Fiche d'identité** : durée, compétence du guide d'étude, slide de référence.
2. **Prérequis** : licence, application, fichiers, droits et données de test. Le lab ne démarre pas tant que la liste n'est pas cochée.
3. **Scénario ARCHIALEARN** : le contexte métier fictif.
4. **Procédure pas à pas** : chaque étape nomme l'élément d'interface à utiliser (menu, bouton, onglet, icône).
5. **Résultat attendu** : ce que le stagiaire doit voir à l'écran.
6. **À noter pour l'examen** : les points que l'examen teste sur cette compétence, formulés comme ils apparaissent dans les questions.
7. **Question flash** : une question d'entraînement avec sa réponse.



## 2. Prérequis généraux (à vérifier avant la journée)

### 2.1 Comptes et licences

| Prérequis | Obligatoire pour | Comment vérifier |
|---|---|---|
| Compte professionnel Microsoft 365 (Entra ID) du tenant de formation ARCHIALEARN | Tous les labs | Connexion sur https://m365.cloud.microsoft avec le compte fourni |
| Licence **Microsoft 365 Copilot** attribuée | Labs en portée Travail, agent Chercheur, agent Analyste, blocs-notes, invites programmées, Copilot dans Word / Excel / Outlook / PowerPoint / Teams | Dans l'application Microsoft 365 Copilot, le sélecteur **Travail / Web** est visible et l'onglet **Agents** propose Chercheur et Analyste |
| Compte **sans** licence Copilot (compte témoin) | Labs de comparaison « avec / sans licence » | Un second compte par binôme, ou un compte de démonstration fourni par le formateur |
| Droits de création d'agents activés par l'administrateur | Labs 3.x (Agent Builder) | Dans l'application Microsoft 365 Copilot, menu **Agents**, le bouton **Créer un agent** est présent |
| Copilot autorisé dans les réunions Teams (stratégie de réunion) | Lab 4.4 | Dans **Options de réunion**, le paramètre **Copilot** est modifiable |
| Étiquettes de confidentialité Microsoft Purview publiées (au moins « Général » et « Hautement confidentiel ») | Lab 1.3, Lab 3.5, Lab 4.1 | Dans Word, bouton **Confidentialité** du ruban, les étiquettes sont listées |

### 2.2 Applications

* Application **Microsoft 365 Copilot** : version web (https://m365.cloud.microsoft), application de bureau Windows, ou application mobile. Les labs sont rédigés pour la version web ; les libellés sont identiques dans l'application de bureau.
* **Microsoft Teams** (client de bureau ou web).
* **Word**, **Excel**, **PowerPoint**, **Outlook** : Microsoft 365 Apps pour entreprise à jour (canal actuel) ou versions web. Le bouton **Copilot** doit apparaître dans l'onglet **Accueil** du ruban.
* Navigateur Microsoft Edge ou Google Chrome à jour.

### 2.3 Jeu de données ARCHIALEARN (fourni dans le dossier `Donnees-Labs`)

Les fichiers ci-dessous sont **fournis avec le kit**, dans le sous-dossier `Donnees-Labs`. Toutes les données sont fictives. Avant la session, le formateur les déploie ainsi :

1. Copier l'ensemble du dossier dans le **OneDrive de chaque stagiaire**, dossier `AB-730-Labs` (ou demander aux stagiaires de le faire à l'ouverture de la journée, 15 minutes avant le premier lab pour laisser le temps à l'indexation).
2. Copier l'ensemble du dossier sur le site SharePoint **ARCHIALEARN - Formation AB-730**, bibliothèque **Documents**, dossier `Labs`, avec droit de lecture pour tous les stagiaires.
3. Ouvrir `Confidentiel-Plan-Strategique.docx` sur SharePoint dans Word et lui appliquer manuellement l'étiquette **Hautement confidentiel** (ruban **Accueil**, bouton **Confidentialité**, ou onglet **Fichier**, **Informations**). L'étiquette Purview ne peut pas être livrée dans le fichier : elle dépend du tenant.
4. Copier `Process-Onboarding.docx` une seconde fois dans le dossier `Téléchargements` du poste de chaque stagiaire (copie locale figée pour le Lab 2.5).
5. Remettre `Prive-A.docx` au stagiaire A de chaque binôme uniquement (OneDrive, non partagé).

| Fichier | Contenu | Utilisé dans |
|---|---|---|
| `Rapport-Q3.docx` | Rapport de performance du 3e trimestre 2026 d'ARCHIALEARN : synthèse, chiffres clés, tendances internes, décisions, risques, prochaines étapes (titres de niveaux 1 et 2) | Labs 1.1, 1.2, 2.1, 2.3, 2.6, 3.4, 3.5, 4.1, 4.3 |
| `Proposition-Partenariat.docx` | Proposition de partenariat ARCHIALEARN / ARCHIFRIDAYS : objectifs, engagements, modèle économique, calendrier, risques | Labs 2.2, 4.1 |
| `Ventes-2025.xlsx` | Tableau Excel `Ventes` (330 lignes) : OrderDate, OrderNumber, Region, Channel, Product, Amount, avec quelques valeurs hors norme | Labs 1.4, 2.1, 3.2, 4.2 |
| `Budget-Marketing.xlsx` | Dépenses, leads, inscriptions et résultats par canal marketing, une feuille par trimestre (T1 à T4) | Lab 4.2 |
| `Process-Onboarding.docx` | Procédure interne d'intégration des nouveaux formateurs (7 étapes numérotées) | Labs 2.5, 3.2 |
| `Politique-Deplacements.docx` | Politique de déplacements : plafonds, hôtels référencés, seuil de validation à 1 000 euros, procédure | Labs 1.4, 3.2 |
| `Confidentiel-Plan-Strategique.docx` | Plan stratégique 2027-2029 (contenu fictif), **à étiqueter Hautement confidentiel** par le formateur | Labs 1.3, 3.5 |
| `Prive-A.docx` | Document contenant le « code secret du lab », pour le test de permissions | Lab 1.3 |
| `Logo-ARCHIALEARN.png` | Logo fictif ARCHIALEARN, image utilisée comme source de connaissances d'un agent | Lab 3.2 |

Chaque document Word porte en pied de page la mention de propriété intellectuelle ARCHIA365 / ARCHIALEARN ; chaque classeur Excel comporte une feuille **A propos** avec la même mention.

### 2.4 Organisation de la salle

* Travail en **binômes** : plusieurs labs demandent de partager une invite, un agent ou une page avec un collègue.
* Une **équipe Teams « AB-730 - Session du 18/09/2026 »** est créée par le formateur, avec tous les stagiaires membres et un canal **Général**.
* Une **réunion Teams de test** de 15 minutes est planifiée dans le calendrier de chaque stagiaire pour le Lab 4.4 (transcription autorisée).



## 3. Conventions d'écriture des procédures

* Les éléments d'interface sont en **gras** : bouton, menu, onglet, champ, icône.
* Les textes à saisir sont dans des blocs de code.
* Les libellés sont ceux de l'interface en français. Le libellé anglais est indiqué entre parenthèses quand il apparaît dans les questions d'examen (ex. **Enregistrer l'invite** (Save prompt)).
* Les interfaces Microsoft 365 Copilot évoluent régulièrement : si un libellé diffère légèrement, chercher l'icône ou le menu **Plus d'options** (les trois points `...`) correspondant.
* Les chronométrages sont indicatifs. Le formateur peut regrouper ou raccourcir les labs selon l'avancement de la journée.



## 4. Rappel des réflexes examen (à relire avant chaque « À noter pour l'examen »)

1. Repérer la **contrainte** de l'énoncé : « le moins d'effort », « sans approbation administrateur », « dès que possible », « sans licence Copilot ».
2. Quand l'énoncé dit que plusieurs réponses peuvent atteindre l'objectif, choisir la **plus directe**.
3. Dans les séries **Oui / Non**, évaluer chaque affirmation indépendamment.
4. Maîtriser le **vocabulaire** : invite, galerie d'invites, invite programmée, invite partagée, conversation, bloc-notes (privé), page (collaborative), mémoire, instructions personnalisées, agent (Décrire / Configurer, connaissances, instructions, capacités, invites suggérées).
5. L'examen ne demande **ni code, ni configuration d'administration** : les réponses « centre d'administration », « Purview pour l'utilisateur », « demander une licence » sont presque toujours des pièges quand une action utilisateur existe.




*Propriété intellectuelle : ARCHIA365 ([Société ARCHIA365 à 75008 PARIS - SIREN 990 705 055 | L'Annuaire des Entreprises](https://annuaire-entreprises.data.gouv.fr/entreprise/archia365-990705055)) et ARCHIALEARN. Supports réservés à la formation AB-730 délivrée par ARCHIALEARN. Pour des besoins de formation, nous contacter : contact@archia365.fr*
