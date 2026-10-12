# Kit de formation Dynamics 365 Sales

*Niveau Product Owner / Business Analyst · 2 jours sur site · Fil rouge ARCHIFRIDAYS*

ARCHIA365

Ce dossier rassemble tout ce qu’il faut pour préparer, animer et évaluer la formation. Toutes les organisations, personnes et données du fil rouge sont fictives.

## Organisation du kit

Le kit existe en deux langues : le dossier **FR** contient la version française, le dossier **EN** la version anglaise, avec la même structure. Chaque document est fourni en trois formats : Word (DOCX) pour l’édition, PDF pour la diffusion et Markdown (MD) pour la réutilisation dans un wiki, un dépôt Git ou un outil de documentation. Les images utilisées par les fichiers Markdown sont placées à côté d’eux.

## Contenu du dossier FR

| Dossier                      | Fichier                                        | Usage                                                                                                                                                                                                                                                                                         | Public                                                    |
|------------------------------|------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------|
| 01_Programme                 | Programme_Formation_D365_Sales_PO_BA           | Programme détaillé et planning, réponse aux retours de Hager                                                                                                                                                                                                                                  | Client, participants                                      |
| 02_Fil_rouge                 | Fil_rouge_ARCHIFRIDAYS                         | Scénario complet : groupe, acteurs, données, épisodes, pipeline, corrigés                                                                                                                                                                                                                     | Formateur                                                 |
| 03_Guide_formateur           | Guide_formateur                                | Préparation (dont le call d’alignement avec Hager), contexte Hager, paramétrages, déroulé minute par minute, gestion du temps, questions fréquentes                                                                                                                                           | Formateur                                                 |
| 03_Guide_formateur           | Fiches_rappel_formateur (DOCX, PDF, MD)        | Une fiche par module et par atelier : attente du client, vocabulaire EN / FR, concepts essentiels, lien avec le contexte Hager, message clé, bonne pratique, angle PO, vigilance, Say it in English, questions à poser                                                                        | Formateur                                                 |
| 04_Supports_participants     | Cahier_exercices_participant                   | Exercices de chaque épisode et transposition Hager, sans corrigés                                                                                                                                                                                                                             | Participants (à imprimer)                                 |
| 04_Supports_participants     | Fiches_synthese_modules                        | Une fiche par module : standard, logique, bonnes pratiques, questions du PO                                                                                                                                                                                                                   | Participants                                              |
| 05_Jeu_de_donnees            | Jeu_de_donnees_ARCHIFRIDAYS.xlsx               | Toutes les données du fil rouge, avec ordre d’import et points de vigilance                                                                                                                                                                                                                   | Formateur                                                 |
| 05_Jeu_de_donnees            | CSV_import_Dataverse (14 fichiers)             | Fichiers prêts à importer dans l’environnement de démonstration                                                                                                                                                                                                                               | Formateur                                                 |
| 06_Ateliers                  | Atelier_Fit_Gap.xlsx                           | Grille fit-gap : corrigé ARCHIFRIDAYS, grille Hager à compléter, synthèse calculée                                                                                                                                                                                                            | Participants (ateliers 1 et 2)                            |
| 06_Ateliers                  | Exercice_Prevision_et_KPI_T4_participants.xlsx | Pipeline T4, synthèse de prévision calculée, atterrissage, KPI à définir                                                                                                                                                                                                                      | Participants (épisode 7)                                  |
| 06_Ateliers                  | Exercice_Prevision_et_KPI_T4_formateur.xlsx    | Même classeur avec l’atterrissage corrigé et le référentiel de 8 KPI                                                                                                                                                                                                                          | Formateur                                                 |
| 07_Evaluation                | Quiz_positionnement_et_acquis                  | 15 questions, passées en ouverture et en clôture                                                                                                                                                                                                                                              | Participants                                              |
| 07_Evaluation                | Corrige_quiz                                   | Réponses et explications                                                                                                                                                                                                                                                                      | Formateur                                                 |
| 07_Evaluation                | Questionnaire_satisfaction                     | Évaluation à chaud                                                                                                                                                                                                                                                                            | Participants                                              |
| 08_Diaporama                 | Diaporama_D365_Sales_PO_BA (PPTX, PDF)         | Support projeté des 2 jours (environ 70 diapositives, dont un glossaire EN / FR par module) ; les notes de chaque diapositive contiennent le texte prompteur à lire, le message clé, un point de vigilance, l’angle PO, des formulations Say it in English et des questions à poser au groupe | Formateur                                                 |
| 08_Diaporama                 | Script_prompteur_D365_Sales_PO_BA (MD)         | Texte prompteur complet, diapositive par diapositive, pour répéter ou imprimer                                                                                                                                                                                                                | Formateur                                                 |
| 09_Preparation_environnement | Procedure_preparation_environnement            | Procédure pas à pas, pour un non-expert, de préparation de l’environnement de démonstration Dynamics 365 Sales : environnement, utilisateurs, import des données, fonctions par épisode, répétition, remise à zéro                                                                            | Formateur ou personne chargée de préparer l’environnement |

**Utiliser les notes prompteur.** Dans PowerPoint, lancer le diaporama en mode Présentateur : les notes s’affichent sur l’écran du formateur. Le texte est rédigé pour être lu tel quel ; les indications entre crochets (par exemple \[Démo\], \[Pause\], \[Question au groupe\]) sont des consignes de scène à ne pas lire. Sous le texte prompteur, les notes rappellent le message clé, le point de vigilance, l’angle PO, les formulations Say it in English et les questions à poser.

## Import du jeu de données

Les fichiers CSV utilisent le point-virgule comme séparateur et l’encodage UTF-8. Les en-têtes reprennent les noms d’affichage français de Dynamics 365 Sales pour faciliter le mappage dans l’assistant d’importation. Les colonnes « Profil », « Note du stand », « Traitement attendu en formation » et « Rôle dans le scénario » sont des aides pour le formateur : les ignorer au mappage ou les importer dans la description.

**Ordre recommandé**

1.  Utilisateurs, unités commerciales et équipes (création manuelle) : 01_Utilisateurs_et_equipes.
2.  Groupes d’unités et unités (02), produits (03), listes de prix (04) et éléments de liste de prix (05) ; publier les produits.
3.  Comptes (06) : d’abord les comptes sans parent, puis Distelec Sud-Est.
4.  Contacts (07), puis concurrents (08).
5.  Campagne « BâtiExpo Lyon 2026 » (création manuelle), puis prospects du salon (09).
6.  Opportunités (10) et produits d’opportunité (11) ; devis (12) créés depuis l’opportunité pour conserver les révisions.
7.  Activités de Campus Lumière (13), objectifs (14), puis configuration de la prévision.

**Points de vigilance**

- Le prospect d’Inès Garnier est présent deux fois (doublon volontaire) et son contact existe déjà : la détection des doublons est démontrée à l’épisode 4.
- Ne pas ajouter d’activité sur Campus Lumière après le 26/10/2026 : le silence de 21 jours est l’objet de l’épisode 6 (date de référence : lundi 16/11/2026).
- Montants de référence : Campus Lumière 429 700 € au tarif public, devis V1 365 245 €, devis V2 343 760 € ; objectif Sud-Est 1 600 000 €.

## Avant d’utiliser le kit

- Vérifier dans la semaine qui précède la session la répartition des fonctions par licence et les nouveautés de la vague de publication en cours.
- Distribuer aux participants la version « participants » du classeur de prévision ; la version « formateur » contient les corrigés.
- Adapter les exemples Hager à partir des informations reçues et du call d’alignement (voir le guide formateur).
