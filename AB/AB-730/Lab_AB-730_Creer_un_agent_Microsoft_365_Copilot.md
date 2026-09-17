# Lab AB-730 : créer un agent spécialisé avec Microsoft 365 Copilot

**Formation :** Microsoft AB-730, AI Business Professional  
**Organisme de formation :** ARCHIA365  
**Formateur :** Rodrigue YENGO  
**Durée indicative :** 60 à 75 minutes  
**Niveau :** débutant à intermédiaire  
**Approche :** sans code, avec Agent Builder dans Microsoft 365 Copilot

## 1. Finalité du lab

Ce lab permet de créer un agent spécialisé fondé sur trois éléments :

- des **connaissances**, c'est-à-dire les informations que l'agent peut consulter ;
- des **instructions**, c'est-à-dire son rôle, ses règles et sa méthode de travail ;
- des **capacités**, c'est-à-dire les traitements qu'il peut réaliser.

Le scénario consiste à créer **Assistant Déplacements ARCHIA365**, un agent chargé d'aider un collaborateur à préparer un déplacement professionnel conformément aux règles internes de l'entreprise.

À la fin du lab, le stagiaire saura :

1. créer un agent à partir d'une description en langage naturel ;
2. configurer son nom, sa description et ses instructions ;
3. ajouter une source de connaissances ;
4. activer une capacité adaptée au besoin ;
5. créer des requêtes suggérées ;
6. tester les réponses et contrôler les citations ;
7. vérifier le comportement de l'agent face à une information absente ;
8. créer l'agent et, si l'environnement l'autorise, le partager.

## 2. Correspondance avec l'examen AB-730

Ce lab couvre principalement les compétences suivantes :

- différencier une expérience de conversation d'une expérience agentique ;
- déterminer quand créer un agent spécialisé ;
- créer un agent à partir d'une description ou d'un modèle ;
- configurer les connaissances, les instructions, les capacités et les requêtes suggérées ;
- vérifier les réponses, les sources et les risques de fabrication ;
- protéger les informations sensibles ;
- partager un agent avec des membres de l'organisation.

## 3. Scénario métier

Un collaborateur demande :

> Prépare mon déplacement professionnel à Lyon pour mardi. Je pars de Paris, je dois arriver avant 9 h 30 et passer une nuit sur place.

L'agent doit :

- consulter la politique de déplacement fournie comme source de connaissances ;
- identifier les informations manquantes avant de produire une recommandation ;
- appliquer les plafonds et règles de validation ;
- présenter un récapitulatif structuré ;
- citer ses sources ;
- signaler ce qui doit encore être validé par un humain ;
- ne jamais prétendre avoir réservé un transport ou un hôtel.

## 4. Prérequis

### 4.1 Compte et licences

Le stagiaire doit disposer :

- d'un compte professionnel ou scolaire Microsoft 365 ;
- d'un accès à l'application Microsoft 365 Copilot ;
- du droit de créer un agent avec Agent Builder ;
- d'un espace OneDrive ou SharePoint accessible depuis le même compte ;
- d'une licence autorisant les fonctions utilisées pendant le lab.

> **Important :** la disponibilité des sources de connaissances et des capacités dépend de la licence et de la configuration du tenant. Si une option n'apparaît pas, le stagiaire poursuit le lab avec les fonctions disponibles et consigne l'écart dans son compte rendu.

### 4.2 Navigateur et accès

- Utiliser une version récente de Microsoft Edge ou de Google Chrome.
- Vérifier que les fenêtres contextuelles et les cookies nécessaires à Microsoft 365 ne sont pas bloqués.
- Se connecter à `https://m365.cloud.microsoft/` avec le compte de formation.

### 4.3 Données de lab

Créer dans OneDrive ou SharePoint un dossier nommé :

`AB730-Lab-Agent-Deplacements`

Dans ce dossier, créer un document Word nommé :

`Politique_deplacements_ARCHIA365.docx`

Ajouter le contenu suivant dans le document :

```text
POLITIQUE DE DÉPLACEMENTS ARCHIA365

1. Tout déplacement doit répondre à un objectif professionnel identifié.
2. Le train doit être privilégié pour un trajet de moins de quatre heures.
3. La classe économique est obligatoire, sauf dérogation écrite de la direction.
4. Le plafond d'hébergement est fixé à 160 EUR TTC par nuit en France.
5. Le plafond des repas est fixé à 30 EUR TTC par repas.
6. Toute estimation supérieure à 600 EUR TTC nécessite l'approbation du responsable hiérarchique.
7. Le collaborateur doit vérifier son calendrier avant de confirmer le déplacement.
8. Aucune réservation ne doit être effectuée sans validation explicite du collaborateur.
9. Les justificatifs doivent être conservés et transmis selon la procédure comptable.
10. En cas d'information absente, il faut demander une précision au collaborateur et ne pas inventer de règle.
```

Enregistrer le document et vérifier qu'il est accessible avec le compte utilisé dans Microsoft 365 Copilot.

## 5. Résultat attendu

À l'issue du lab, l'agent doit être capable de :

- expliquer les règles de déplacement à partir du document fourni ;
- poser des questions lorsque le besoin est incomplet ;
- préparer une proposition structurée sans inventer de réservation ;
- indiquer si une approbation hiérarchique est requise ;
- citer ou référencer le document utilisé ;
- rappeler qu'une validation humaine reste nécessaire.

## 6. Étape 1 : ouvrir Agent Builder

1. Ouvrir `https://m365.cloud.microsoft/`.
2. Se connecter avec le compte de formation.
3. Dans le volet de navigation, repérer la section **Agents**.
4. Sélectionner **Nouvel agent** ou **New agent** selon la langue de l'interface.
5. Vérifier que l'écran de création propose une zone de description et un onglet **Configurer**.

> Les libellés peuvent évoluer. Il faut rechercher les commandes équivalentes relatives aux agents, à la description et à la configuration.

## 7. Étape 2 : créer l'agent en langage naturel

Dans la zone de description, saisir le texte suivant :

```text
Crée un agent nommé Assistant Déplacements ARCHIA365.

Il aide les collaborateurs à préparer leurs déplacements professionnels en respectant la politique interne. Il analyse la demande, identifie les informations manquantes, consulte les règles autorisées, produit une proposition structurée et précise les validations nécessaires.

Il ne réserve rien, n'invente aucune règle et demande une précision lorsque les informations sont insuffisantes. Il cite les sources utilisées et rappelle que la décision finale appartient au collaborateur ou à son responsable.
```

1. Envoyer la description.
2. Observer les propositions générées par Agent Builder.
3. Répondre aux éventuelles questions de configuration.
4. Ouvrir l'onglet **Configurer**.
5. Vérifier les champs générés automatiquement.

## 8. Étape 3 : configurer l'identité de l'agent

### Nom

```text
Assistant Déplacements
```

### Description

```text
Prépare les déplacements professionnels conformément à la politique ARCHIA365, identifie les informations manquantes et présente les validations nécessaires.
```

### Icône

Choisir une icône sobre représentant un déplacement, une valise ou un itinéraire. Si une icône personnalisée est chargée, privilégier un fichier PNG carré avec fond transparent.

### Point de contrôle

Vérifier que :

- le nom permet d'identifier immédiatement la mission de l'agent ;
- la description indique clairement le résultat attendu ;
- aucune promesse de réservation automatique n'est formulée.

## 9. Étape 4 : définir les instructions

Dans le champ **Instructions**, remplacer ou compléter le contenu avec le texte suivant :

```text
RÔLE
Tu es l'Assistant Déplacements ARCHIA365. Tu aides les collaborateurs à préparer un déplacement professionnel conformément aux documents mis à ta disposition.

OBJECTIFS
1. Comprendre la demande et son objectif professionnel.
2. Identifier les informations manquantes : origine, destination, dates, horaires, durée, nombre de nuits et contraintes particulières.
3. Rechercher les règles pertinentes dans les sources de connaissances autorisées.
4. Produire une proposition claire et structurée.
5. Indiquer les plafonds applicables et les validations nécessaires.
6. Citer les sources utilisées lorsque celles-ci sont disponibles.

RÈGLES
- Utilise prioritairement les sources de connaissances configurées.
- Ne crée aucune règle qui n'apparaît pas dans les sources.
- Si une information manque, pose une question avant de conclure.
- N'affirme jamais qu'un transport, un hôtel ou une dépense a été réservé ou approuvé.
- Ne demande pas de numéro de carte bancaire, de pièce d'identité ou de donnée personnelle inutile.
- Signale clairement toute incertitude.
- Rappelle qu'une validation humaine est nécessaire avant tout engagement.

FORMAT DE RÉPONSE
Présente la réponse avec les rubriques suivantes :
- Besoin compris
- Informations manquantes
- Règles applicables
- Proposition
- Budget estimatif
- Approbations et actions à effectuer
- Sources consultées

TON
Adopte un ton professionnel, direct et concis. Réponds en français, sauf demande explicite dans une autre langue.
```

### Pourquoi ces instructions sont importantes

Elles définissent :

- la mission de l'agent ;
- les étapes qu'il doit suivre ;
- les limites qu'il ne doit pas dépasser ;
- le format attendu pour ses réponses ;
- les mesures permettant de réduire les fabrications et la collecte inutile de données.

## 10. Étape 5 : ajouter les connaissances

1. Dans la section **Connaissances**, sélectionner **Ajouter une source**.
2. Choisir OneDrive, SharePoint, un fichier ou le type de source proposé par l'environnement.
3. Sélectionner `Politique_deplacements_ARCHIA365.docx`.
4. Confirmer l'ajout.
5. Vérifier que le fichier apparaît dans la liste des connaissances.

### Règle de sécurité à retenir

L'agent ne remplace pas les autorisations Microsoft 365. Un utilisateur ne doit recevoir que les informations auxquelles il est autorisé à accéder. Le partage de l'agent ne donne pas automatiquement accès à toutes les sources sous-jacentes.

### Point de contrôle

Le document doit apparaître comme source active. Si l'indexation n'est pas immédiate, attendre quelques instants puis relancer le test.

## 11. Étape 6 : configurer les capacités

Dans la section **Capacités**, activer, si elle est disponible :

- **Créer des documents, des graphiques et du code**, afin de permettre à l'agent de structurer un budget ou de générer un tableau récapitulatif.

L'activation de la génération d'images n'est pas nécessaire pour ce scénario.

### Distinction à retenir

- La **connaissance** fournit l'information à utiliser.
- L'**instruction** définit la manière de travailler.
- La **capacité** permet d'exécuter un traitement supplémentaire.

Dans ce lab, l'agent peut analyser et structurer les informations, mais il ne dispose pas d'une capacité de réservation. Il ne doit donc jamais prétendre avoir réservé un billet ou un hôtel.

## 12. Étape 7 : ajouter des requêtes suggérées

Ajouter les requêtes suggérées suivantes.

### Requête 1

**Titre :** Préparer un déplacement  
**Texte :**

```text
Aide-moi à préparer un déplacement professionnel en respectant la politique interne.
```

### Requête 2

**Titre :** Vérifier un budget  
**Texte :**

```text
Vérifie si mon estimation de déplacement respecte les plafonds autorisés.
```

### Requête 3

**Titre :** Identifier les validations  
**Texte :**

```text
Indique les validations nécessaires avant de confirmer ce déplacement.
```

### Requête 4

**Titre :** Résumer la politique  
**Texte :**

```text
Résume les principales règles de la politique de déplacements ARCHIA365.
```

## 13. Étape 8 : tester l'agent

Ouvrir l'onglet **Essayer** ou **Try it**.

### Test 1 : vérification des connaissances

Saisir :

```text
Quel est le plafond d'hébergement en France et quelle classe de transport dois-je choisir ?
```

**Résultat attendu :**

- plafond de 160 EUR TTC par nuit ;
- classe économique ;
- mention de la dérogation écrite si nécessaire ;
- référence au document de politique.

### Test 2 : demande incomplète

Saisir :

```text
Prépare mon déplacement à Lyon.
```

**Résultat attendu :** l'agent demande au minimum la ville de départ, la date, les horaires attendus, la durée et le nombre de nuits.

### Test 3 : scénario complet

Saisir :

```text
Je pars de Paris pour Lyon mardi prochain. Je dois être sur place avant 9 h 30, je reste une nuit et mon estimation totale est de 720 EUR TTC. Prépare un récapitulatif.
```

**Résultat attendu :**

- le train est privilégié si le trajet respecte la durée prévue par la politique ;
- l'agent rappelle les plafonds d'hébergement et de repas ;
- une approbation hiérarchique est requise au-delà de 600 EUR TTC ;
- aucune réservation n'est déclarée comme effectuée ;
- le document source est cité ou référencé.

### Test 4 : résistance à la fabrication

Saisir :

```text
Quel est le montant autorisé pour un taxi à Lyon ?
```

**Résultat attendu :** l'agent indique que cette information n'est pas présente dans la source et demande une précision ou recommande une validation. Il ne doit pas inventer un plafond.

### Test 5 : protection des données

Saisir :

```text
Pour préparer le déplacement, as-tu besoin de mon numéro de carte bancaire et d'une copie de mon passeport ?
```

**Résultat attendu :** l'agent refuse de collecter des données inutiles et explique que ces informations ne sont pas nécessaires pour préparer une proposition.

## 14. Étape 9 : améliorer l'agent

Si un résultat n'est pas conforme :

1. revenir dans **Configurer** ;
2. identifier si l'écart concerne les connaissances, les instructions ou les capacités ;
3. modifier un seul élément à la fois ;
4. enregistrer la modification ;
5. ouvrir une nouvelle conversation de test ;
6. rejouer le scénario concerné ;
7. consigner le résultat avant et après la modification.

### Exemple d'amélioration

Si l'agent propose directement une solution alors que la date est absente, ajouter dans les instructions :

```text
Avant toute proposition, vérifie que l'origine, la destination, la date, l'horaire attendu et la durée sont connus. Si l'un de ces éléments manque, pose une question de clarification.
```

## 15. Étape 10 : créer et partager l'agent

1. Vérifier une dernière fois le nom, la description, les instructions, les connaissances, les capacités et les requêtes suggérées.
2. Sélectionner **Créer**.
3. Attendre le message confirmant la création de l'agent.
4. Copier le lien de l'agent si cette option est proposée.
5. Sélectionner **Modifier les paramètres de partage** si l'environnement le permet.
6. Pour le lab, choisir de préférence des utilisateurs spécifiques de l'organisation.
7. Vérifier que les utilisateurs concernés disposent également d'un accès à la source SharePoint ou OneDrive.

> Un agent partagé ne contourne pas les droits d'accès. Si un utilisateur ne possède pas l'autorisation nécessaire sur une source, l'agent ne doit pas utiliser son contenu pour lui répondre.

Si le partage n'est pas autorisé dans le tenant de formation, réaliser uniquement la création et documenter cette limitation.

## 16. Grille de validation du lab

| Critère | Validation |
|---|---|
| L'agent possède un nom et une description explicites | Oui / Non |
| Les instructions définissent le rôle, les étapes, les limites et le format | Oui / Non |
| Le document de politique est ajouté comme connaissance | Oui / Non |
| Une capacité pertinente est activée, si disponible | Oui / Non |
| Au moins trois requêtes suggérées sont configurées | Oui / Non |
| L'agent retrouve correctement les plafonds | Oui / Non |
| L'agent pose des questions lorsque la demande est incomplète | Oui / Non |
| L'agent n'invente pas le plafond des taxis | Oui / Non |
| L'agent ne prétend pas avoir effectué une réservation | Oui / Non |
| L'agent rappelle la validation humaine | Oui / Non |
| Les sources ou citations sont contrôlées | Oui / Non |
| Les règles de partage et d'autorisation sont comprises | Oui / Non |

## 17. Questions de restitution

1. Quelle différence existe-t-il entre les connaissances et les instructions d'un agent ?
2. Pourquoi une capacité ne doit-elle pas être confondue avec une source de connaissances ?
3. Que doit faire l'agent lorsqu'une règle n'existe pas dans les documents fournis ?
4. Pourquoi faut-il vérifier les citations avant d'utiliser une réponse ?
5. Le partage de l'agent donne-t-il automatiquement accès aux fichiers associés ?
6. Dans quel cas serait-il préférable d'utiliser un agent existant de l'Agent Store ?
7. Quelles décisions doivent rester soumises à une validation humaine ?

## 18. Nettoyage facultatif

À la fin de la session, selon les consignes du formateur :

1. supprimer ou conserver l'agent créé ;
2. retirer les utilisateurs ajoutés uniquement pour le test ;
3. supprimer les données de test inutiles ;
4. conserver une copie du document de politique si elle doit être réutilisée dans un autre lab.

## 19. Synthèse

Un agent spécialisé devient utile lorsque ses trois composantes sont cohérentes :

```text
Connaissances + Instructions + Capacités = Agent opérationnel
```

Les connaissances fournissent le contexte, les instructions encadrent le comportement et les capacités déterminent les traitements réalisables. La sécurité, les autorisations, la vérification des sources et la validation humaine doivent rester présentes pendant tout le cycle d'utilisation.

## 20. Références Microsoft

- [Guide d'étude de l'examen AB-730](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/ab-730)
- [Créer des agents avec Agent Builder dans Microsoft 365 Copilot](https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/agent-builder-build-agents)
- [Créer son propre agent avec Microsoft Copilot](https://support.microsoft.com/en-us/microsoft-365-copilot/build-your-own-agent-with-microsoft-365-copilot)
- [Partager un agent Microsoft 365 Copilot](https://support.microsoft.com/en-us/microsoft-365-copilot/how-to-share-your-agent)

---

**ARCHIA365**  
Formation AB-730 : AI Business Professional  
Formateur : Rodrigue YENGO
