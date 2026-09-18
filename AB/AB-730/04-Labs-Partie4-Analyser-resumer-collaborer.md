# AB-730 : Labs de la Partie 4
## Analyser, résumer, collaborer avec Copilot

**Organisme :** ARCHIALEARN  |  **Formateur :** Rodrigue YENGO  |  **Domaine du guide d'étude :** 3 (25 à 30 %)  |  **Slides :** 34 à 42

| Lab | Titre | Durée | Compétence du guide d'étude |
|---|---|---|---|
| 4.1 | Générer un résumé de gestion dans quatre surfaces | 15 min | Générer un résumé de gestion basé sur un document |
| 4.2 | Analyser des données : Copilot dans Excel, fonction COPILOT et agent Analyste | 20 min | Déplacer des données et des insights entre les applications |
| 4.3 | Déplacer les insights : Excel vers PowerPoint, Word vers Outlook, Chat vers Pages | 10 min | Déplacer des données et des insights entre les applications |
| 4.4 | Copilot dans les réunions Teams : avant, pendant, après | 20 min | Décrire comment utiliser Microsoft 365 Copilot pour les réunions |
| 4.5 | Pages Copilot : collaborer sur le contenu généré | 15 min | Décrire comment utiliser des pages Copilot pour la collaboration |
| 4.6 | Instructions personnalisées et mémoire | 10 min | Décrire comment Copilot utilise la mémoire et les instructions |

---

## Lab 4.1 : Générer un résumé de gestion dans quatre surfaces

**Durée :** 15 min  |  **Slide de référence :** 36

### Prérequis

- [ ] Compte avec licence Microsoft 365 Copilot.
- [ ] Word, Outlook, Teams et l'application Microsoft 365 Copilot.
- [ ] Fichiers `Proposition-Partenariat.docx` et `Rapport-Q3.docx` dans OneDrive.
- [ ] Un fil d'e-mails d'au moins trois messages (celui du Lab 3.4) et quelques e-mails non lus.
- [ ] Au moins dix messages publiés dans le canal **Général** de l'équipe Teams AB-730 (le formateur anime une discussion de 5 minutes avant le lab : décisions, questions ouvertes).

### Scénario ARCHIALEARN

Le comité de lancement du partenariat avec ARCHIFRIDAYS demande un résumé de gestion en quatre points. Vous produisez le même type de résumé depuis Word, Outlook, Copilot Chat et Teams.

### Procédure pas à pas

**Word (document ouvert)**

1. Ouvrir `Proposition-Partenariat.docx` dans Word. Onglet **Accueil**, **Copilot**. Dans le volet, saisir :
   ```
   Résume ce document en 5 points clés pour la direction.
   ```
2. Vérifier les références (numéros renvoyant aux passages du document). Cliquer sur **Copier**.

**Outlook (fil et non lus)**

3. Ouvrir Outlook, ouvrir le fil **Préparation rapport Q3**. Cliquer sur **Résumé par Copilot** en haut du fil.
4. Ouvrir l'application Copilot (icône **Copilot** dans Outlook, ou l'application Microsoft 365 Copilot) et saisir :
   ```
   Résume mes e-mails non lus de cette semaine en 5 points, avec les actions attendues.
   ```

**Copilot Chat (source référencée, audience, format)**

5. Application Microsoft 365 Copilot, **Nouvelle conversation**, portée **Travail**. Taper `/`, sélectionner `Proposition-Partenariat.docx`, puis :
   ```
   Rédige un résumé de gestion en 4 points concis, en langage simple, pour le comité de lancement du projet.
   ```
6. Envoyer une invite de suivi : `Présente-le sous forme de tableau décisions / risques / actions.`
7. Repérer l'**icône bouclier** si le document est étiqueté : le résumé hérite de l'étiquette de la source.

**Teams (canal)**

8. Dans Teams, ouvrir le canal **Général** de l'équipe AB-730. Cliquer sur l'icône **Copilot** en haut à droite du canal (ou **Ouvrir Copilot**).
9. Saisir : `Résume les décisions et les points ouverts de ce canal aujourd'hui.` Vérifier que chaque point renvoie au message d'origine.

**Revue humaine**

10. Choisir l'un des quatre résumés et, en binôme, vérifier point par point dans la source. Corriger au moins une formulation avant de considérer le résumé « prêt à diffuser ».

### Résultat attendu

Quatre résumés de gestion produits depuis quatre surfaces, un tableau décisions / risques / actions, et une relecture humaine effectuée.

### À noter pour l'examen

* Où produire un résumé de gestion : **Word** (document ouvert), **Outlook** (Résumé par Copilot sur un fil ; résumé des e-mails non lus), **Copilot Chat** (référencer le document avec `/`, préciser audience, longueur, format), **Teams** (résumer un canal ou une conversation : décisions et points ouverts).
* Bonnes pratiques : **une source précise + des instructions concises** = résumé fiable ; demander explicitement le **format** (3 à 5 points, tableau) ; **vérifier les citations et relire** avant diffusion ; le résumé **hérite de l'étiquette** du document source.
* Question type « résumer une proposition de partenariat en 3 à 5 points pour une réunion de lancement » : les deux détails à inclure sont **une source de connaissances précise** et **des instructions concises**.

### Question flash

Que devez-vous inclure dans l'invite pour obtenir un résumé fiable d'une proposition ?
**Une source de connaissances précise et des instructions concises.**

---

## Lab 4.2 : Analyser des données : Copilot dans Excel, fonction COPILOT et agent Analyste

**Durée :** 20 min  |  **Slide de référence :** 37

### Prérequis

- [ ] Compte avec licence Microsoft 365 Copilot.
- [ ] Excel (Microsoft 365 Apps, canal actuel) ou Excel pour le web, avec le bouton **Copilot** dans l'onglet **Accueil**.
- [ ] Fichier `Ventes-2025.xlsx` **enregistré dans OneDrive ou SharePoint** (Copilot dans Excel exige un fichier enregistré dans le cloud avec enregistrement automatique activé) ; les données sont mises en forme en **tableau Excel** nommé `Ventes` (Insertion, Tableau).
- [ ] Fichier `Budget-Marketing.xlsx` (une feuille par trimestre) dans OneDrive.
- [ ] La fonction `=COPILOT()` disponible dans la version d'Excel utilisée (vérifier en tapant `=COPILOT(` dans une cellule ; si elle n'est pas proposée, l'étape 6 est remplacée par une démonstration du formateur).
- [ ] Agent **Analyste** accessible dans l'application Microsoft 365 Copilot.

### Scénario ARCHIALEARN

L'assistante marketing d'ARCHIALEARN prépare la réunion budget : elle doit repérer les tendances de ventes, puis évaluer les dépenses et le retour sur investissement par canal sur l'année.

### Procédure pas à pas

**Copilot dans Excel : insights, tableau croisé, formules**

1. Ouvrir `Ventes-2025.xlsx` depuis OneDrive. Cliquer dans une cellule du tableau `Ventes`. Onglet **Accueil**, **Copilot**. Le volet s'ouvre.
2. Cliquer sur la suggestion **Afficher les insights sur les données** (Show data insights), ou saisir : `Montre-moi les tendances et les valeurs hors norme de ce tableau.` Copilot propose des graphiques et des constats (tendances, corrélations, valeurs extrêmes). Cliquer sur **Ajouter à une nouvelle feuille** sur l'un des insights.
3. Saisir : `Crée un tableau croisé dynamique du montant total par région et par mois.` Cliquer sur **Ajouter à une nouvelle feuille**.
4. Saisir : `Ajoute une colonne qui calcule le trimestre à partir de OrderDate et explique la formule.` Copilot propose la formule (**Ajouter des colonnes de formule**), l'explique, puis **Insérer la colonne**.
5. Saisir : `Crée un graphique en courbes du montant total par mois.` Insérer le graphique.
6. Fonction COPILOT : dans une cellule vide hors du tableau, saisir :
   ```
   =COPILOT("Classe ce canal de vente en Direct, Partenaire ou Web"; D2)
   ```
   (D2 = première cellule de la colonne Channel). Valider, puis recopier vers le bas sur dix lignes. Puis dans une autre cellule :
   ```
   =COPILOT("Résume en une phrase la tendance de ces montants"; E2:E50)
   ```
7. Test négatif : saisir dans le volet `Applique une mise en forme conditionnelle : rouge si Amount < 100, vert si > 1000, avec bordure épaisse.` Constater que Copilot propose au mieux une mise en évidence standard mais ne personnalise pas les règles fines : passer par **Accueil**, **Mise en forme conditionnelle**.

**Agent Analyste : consolidation, variations, graphiques**

8. Application Microsoft 365 Copilot, **Agents**, **Analyste**.
9. Taper `/`, sélectionner `Budget-Marketing.xlsx`, puis :
   ```
   Consolide les quatre feuilles trimestrielles, calcule pour chaque canal les dépenses annuelles, les résultats annuels et le retour sur investissement (résultats / dépenses), classe les canaux du meilleur au moins bon ROI, et produis un graphique à barres. Termine par un résumé de 3 lignes prêt à partager.
   ```
10. Observer le **raisonnement** affiché étape par étape et le lien **Afficher le code** (Python exécuté en arrière-plan). Vérifier un calcul à la main sur un canal.
11. Cliquer sur **Télécharger** sur le graphique ou le tableau produit, ou copier le résumé.

**Décider : Excel ou Analyste ?**

12. Sur la feuille de réponses, pour chaque demande, écrire « Copilot dans Excel » ou « Analyste » :
   - a. Résumer les insights du tableau ouvert et créer un tableau croisé dynamique.
   - b. Consolider trois fichiers, calculer des variations et produire un tableau de bord.
   - c. Évaluer les dépenses et le ROI par canal sur l'année pour la réunion budget.
   - d. Expliquer une formule présente dans la feuille.
   Correction : a Excel ; b Analyste ; c Analyste ; d Excel.

### Résultat attendu

Une feuille d'insights, un tableau croisé dynamique, une colonne de formule expliquée, un graphique, deux cellules `=COPILOT()`, et une analyse consolidée de l'Analyste avec ROI par canal et graphique.

### À noter pour l'examen

* **Copilot dans Excel** : **afficher les insights** (tendances, corrélations, valeurs hors norme), **créer un tableau croisé dynamique** ou un **graphique** par invite, **suggérer et expliquer des formules**, fonction **`=COPILOT("invite", plage)`** pour résumer ou classer. Il **ne personnalise pas** les règles de mise en forme conditionnelle ni les graphiques à mise en forme spécifique.
* Deux tâches Excel (question type) : **générer un résumé des insights** et **construire un tableau croisé dynamique**.
* **Agent Analyste** : raisonnement avancé sur données structurées (consolidation de fichiers, calculs, variations), graphiques, tableaux de bord, résumés prêts à partager, **code Python en arrière-plan**. Dès que l'énoncé parle d'**agréger des données et produire des graphiques depuis Copilot**, la réponse est **l'Analyste** (et non Chat, le Chercheur, un bloc-notes ou une page).
* Cas type de l'assistant marketing (dépenses, tendances, ROI par canal sur l'année) : **l'agent Analyste**.

### Question flash

Depuis Microsoft 365 Copilot, pour agréger des données et produire des graphiques, vous devez utiliser...
**L'agent Analyste.**

---

## Lab 4.3 : Déplacer les insights : Excel vers PowerPoint, Word vers Outlook, Chat vers Pages

**Durée :** 10 min  |  **Slide de référence :** 37 (colonne Déplacer les insights)

### Prérequis

- [ ] Compte avec licence Microsoft 365 Copilot.
- [ ] Résultats du Lab 4.2 (graphique Excel et résumé de l'Analyste).
- [ ] Présentation `Comite-Direction-Q3.pptx` (Lab 3.5) et document `Rapport-Q3-v2.docx` (Lab 3.4) dans OneDrive.
- [ ] Outlook avec Copilot.

### Scénario ARCHIALEARN

Les résultats de l'analyse doivent alimenter la présentation du comité, un e-mail à la direction et une page partageable.

### Procédure pas à pas

**Excel vers PowerPoint**

1. Dans Excel, sélectionner le graphique du Lab 4.2, **Ctrl+C**.
2. Ouvrir `Comite-Direction-Q3.pptx`. Volet **Copilot** : `Ajoute une diapositive de synthèse intitulée Résultats par canal.` Sur la nouvelle diapositive, **Ctrl+V** le graphique.
3. Volet Copilot : `Rédige 3 puces de conclusion pour cette diapositive à partir du graphique et du texte des autres diapositives.`

**Word vers Outlook**

4. Ouvrir Outlook, **Nouveau message**. Icône **Copilot**, **Rédiger avec Copilot**. Taper `/` (ou cliquer sur l'icône de référence) et sélectionner `Rapport-Q3-v2.docx`, puis :
   ```
   Rédige un e-mail de mise à jour à la direction résumant les points clés de ce rapport, ton formel, 10 lignes.
   ```
   **Générer**, **Conserver**. Destinataire : le binôme.

**Copilot Chat vers Pages**

5. Application Microsoft 365 Copilot, **Nouvelle conversation**, portée **Travail**. Coller le résumé de 3 lignes produit par l'Analyste et saisir : `Transforme ce résumé en note de synthèse d'une demi-page avec un titre et trois sous-parties.`
6. Sous la réponse, cliquer sur **Modifier dans Pages** (Edit in Pages). La page s'ouvre à droite de la conversation. Elle sera utilisée au Lab 4.5.

### Résultat attendu

Une diapositive de synthèse avec graphique et conclusions, un e-mail de mise à jour issu du rapport Word, et une page Copilot créée depuis une réponse.

### À noter pour l'examen

* **Excel vers PowerPoint** : graphique et conclusions dans une **diapositive de synthèse**.
* **Word vers Outlook** : e-mail de mise à jour à partir du rapport (référencer `/Rapport-Q3.docx` dans Rédiger avec Copilot).
* **Copilot Chat vers Pages** : transformer une réponse en **contenu modifiable et partageable** (bouton **Modifier dans Pages**).

### Question flash

Vous voulez qu'une réponse Copilot devienne un contenu modifiable et partageable. Que faites-vous ?
**L'ouvrir dans une page (Modifier dans Pages).**

---

## Lab 4.4 : Copilot dans les réunions Teams : avant, pendant, après

**Durée :** 20 min  |  **Slide de référence :** 38

### Prérequis

- [ ] Compte avec licence Microsoft 365 Copilot.
- [ ] Teams (client de bureau recommandé).
- [ ] Une **réunion Teams de test** planifiée par le formateur, 15 minutes, avec tous les stagiaires invités ; **un stagiaire par binôme volontairement non invité** à une seconde réunion courte (« Réunion privée formateur ») pour le test négatif de l'étape 12.
- [ ] Stratégie Teams autorisant la **transcription** et **Copilot** dans les réunions (vérifiée par l'administrateur).
- [ ] Micro fonctionnel (au moins deux participants parlent pendant 3 à 4 minutes pour produire une transcription exploitable).
- [ ] Dans Outlook, le fil d'e-mails **Préparation rapport Q3** (Lab 3.4).

### Scénario ARCHIALEARN

Réunion de clôture de la formation AB-730. Vous préparez la réunion, vous rejoignez en retard, et vous exploitez le récapitulatif.

### Procédure pas à pas

**Avant**

1. Outlook : ouvrir le fil **Préparation rapport Q3**. **Résumé par Copilot**, puis dans le volet Copilot : `Propose un ordre du jour de 4 points pour une réunion de 15 minutes à partir de ce fil.` Copier l'ordre du jour.
2. Teams, **Calendrier**, ouvrir la réunion de test, **Modifier**. Coller l'ordre du jour dans la description. Cliquer sur **Options de réunion** (icône `...` ou lien dans l'invitation).
3. Dans **Options de réunion**, section **Copilot** : choisir **Pendant et après la réunion** (During and after the meeting). Activer **Enregistrer et transcrire automatiquement** (ou s'assurer que la transcription est autorisée). **Enregistrer**.
4. Application Microsoft 365 Copilot, portée **Travail** : `Résume tous mes prochains rendez-vous Teams de la journée.` Vérifier que la réunion de test est listée.

**Pendant**

5. À l'heure prévue, l'organisateur (formateur) démarre la réunion. Dès le début, cliquer sur **Plus** (`...`), **Enregistrer et transcrire**, **Démarrer la transcription** si elle ne démarre pas automatiquement.
6. Les participants échangent 3 à 4 minutes : chacun annonce une décision fictive (« nous décidons de planifier l'examen la semaine prochaine ») et une action (« Rodrigue enverra le lien d'inscription »).
7. Un stagiaire par binôme quitte la réunion 2 minutes, puis la rejoint (« arrivée en retard »). Dans la barre d'outils de la réunion, cliquer sur **Copilot** (icône en haut à droite). Dans le volet, saisir : `Dis-moi ce que j'ai manqué.` Puis : `Quels sont les points clés jusqu'ici ?` et `Où sommes-nous en désaccord ?`
8. Saisir : `Liste les éléments d'action sous forme de tableau responsable / action / échéance.`

**Après**

9. Une fois la réunion terminée, ouvrir dans Teams le chat de la réunion. Cliquer sur l'onglet **Récapitulatif** (Recap). Observer : **Notes IA** (points clés, décisions), **Éléments d'action**, **Mentions**, la **transcription** et, si enregistrée, la vidéo avec les temps forts par intervenant.
10. Depuis l'onglet **Récapitulatif**, ouvrir **Copilot** et demander : `Rédige le compte rendu à envoyer aux participants, avec décisions et actions.`
11. Test transcription : le formateur a créé une seconde réunion de test **sans transcription** (chat écrit uniquement). Ouvrir son chat, cliquer sur **Copilot** : le résumé du **chat de réunion** fonctionne ; la demande `Résume la discussion de la réunion` renvoie un message indiquant qu'**aucune transcription** n'est disponible.
12. Test permission : le stagiaire non invité à « Réunion privée formateur » demande dans Copilot Chat : `Résume la réunion « Réunion privée formateur ».` Copilot ne trouve pas la réunion : il ne répond que sur les réunions auxquelles vous êtes invité.

### Résultat attendu

Une réunion préparée (ordre du jour, options Copilot), des questions posées pendant la réunion (dont « ce que j'ai manqué »), un récapitulatif exploité après, et les deux limites vérifiées (transcription obligatoire pour le récapitulatif de la discussion ; pas d'accès aux réunions non invitées).

### À noter pour l'examen

* **Avant** : Outlook (résumer le fil, proposer un ordre du jour, planifier) ; Copilot Chat (« résume mes prochains rendez-vous ») ; **Options de réunion** : **Autoriser Copilot pendant et après la réunion**, **activer la transcription**.
* **Pendant** : « Quels sont les points clés jusqu'ici ? », « Où sommes-nous en désaccord ? » ; arrivée en retard : **« Dis-moi ce que j'ai manqué »** ou le **récapitulatif intelligent** ; tableaux, listes et éléments d'action générés à partir de la transcription.
* **Après** : **Recap** (récapitulatif) : points clés, décisions, éléments d'action, temps forts par intervenant.
* Nuance testée : le **récapitulatif de la discussion exige la transcription** ; le **résumé du chat de réunion non**.
* Copilot **ne répond que sur les réunions auxquelles vous êtes invité** (affirmation « Copilot peut répondre sur des réunions auxquelles vous n'êtes pas invité » : **Non**).
* Question type : rejoindre en retard une réunion enregistrée et résumer **au plus vite** la partie manquée : **afficher le récapitulatif intelligent depuis Teams** (la lecture de la transcription est écartée par la contrainte « au plus vite »).

### Question flash

Que faut-il activer pour obtenir le récapitulatif de la discussion d'une réunion Teams ?
**La transcription.**

---

## Lab 4.5 : Pages Copilot : collaborer sur le contenu généré

**Durée :** 15 min  |  **Slide de référence :** 39

### Prérequis

- [ ] Compte avec licence Microsoft 365 Copilot (pour le rapport du Chercheur à l'étape 8) ; le compte témoin **sans licence** pour l'étape 10.
- [ ] Page créée au Lab 4.3 (ou une nouvelle page créée à l'étape 1).
- [ ] Binôme identifié ; Teams et OneNote ouverts (pour le composant Loop).
- [ ] Bloc-notes du Lab 2.5 (ou nouveau).

### Scénario ARCHIALEARN

La note de synthèse doit être relue et complétée par un collègue avant envoi, puis servir de base à plusieurs conversations futures.

### Procédure pas à pas

**Créer et enrichir une page**

1. Si nécessaire : Copilot Chat, générer une réponse, puis **Modifier dans Pages**. La page s'ouvre à droite de la conversation, dans un canevas **Loop**.
2. Dans la conversation, poser une nouvelle question : `Ajoute une section Risques en 3 points.` Sous la réponse, cliquer sur **Ajouter à la page** : le contenu s'ajoute à la page existante.
3. Dans la page, modifier directement un titre (cliquer, taper). Le texte est éditable comme un document.

**Collaborer**

4. En haut de la page, cliquer sur **Partager** (Share), copier le **lien** (Toute personne de votre organisation disposant du lien) et l'envoyer au binôme dans Teams.
5. Dans la page, taper `@` puis le nom du binôme et une phrase : `@<binôme> peux-tu relire la section Risques ?` Le binôme reçoit une **notification** (Teams / e-mail).
6. Binôme : ouvrir le lien, modifier une phrase. Observer côté créateur l'**avatar (initiales ou photo)** du binôme à côté du texte modifié, en temps réel.
7. Sélectionner un paragraphe, `...` ou bouton **Copier le composant** : coller dans une conversation Teams ou une page OneNote. Modifier le texte dans Teams : la page se met à jour (composant Loop synchronisé).

**Rapport du Chercheur dans une page**

8. **Agents**, **Chercheur** : lancer une courte recherche (`Tendances des certifications Microsoft en 2026, 5 points avec sources.`). Une fois le rapport prêt, cliquer sur **Modifier dans Pages** : le rapport devient sauvegardé et éditable.

**Convertir et réutiliser**

9. Dans la page, `...` (menu de la page), **Ouvrir dans Word** (ou **Exporter vers Word**) : un document Word est créé en un clic.
10. Compte **sans licence** : ouvrir Copilot Chat, générer une réponse et vérifier que **Modifier dans Pages** est disponible ; le **Chercheur** et les **blocs-notes** ne le sont pas.
11. Retour au compte avec licence : ouvrir le **bloc-notes** du Lab 2.5, **Ajouter des références**, **Pages**, sélectionner la page et le rapport du Chercheur. Poser dans le bloc-notes : `Compare la note de synthèse et le rapport du Chercheur.`

### Résultat attendu

Une page enrichie par plusieurs réponses, partagée par lien, avec mention et suivi des modifications ; un composant Loop synchronisé dans Teams ; un rapport du Chercheur ouvert dans une page ; une conversion Word ; les pages ajoutées à un bloc-notes.

### À noter pour l'examen

* Une **page** est un **canevas persistant et modifiable**, intégré à **Microsoft Loop**, créé depuis une réponse via **Modifier dans Pages** ; chaque nouvelle réponse peut y être **ajoutée** ; la page s'ouvre **à côté** de la conversation.
* Disponible **avec et sans licence** Copilot (contrairement au Chercheur et aux blocs-notes) : c'est ce qui est **disponible dans les deux versions** (Microsoft 365 Copilot et Copilot Chat).
* Le rapport du **Chercheur s'ouvre dans une page** pour être sauvegardé et édité.
* Collaborer : **partager le lien de la page** ; **copier un composant Loop** dans Teams, Outlook ou OneNote (synchronisation temps réel) ; **mentionner un collègue** pour le notifier ; suivi des modifications (initiales ou photo) ; **convertir en Word** en un clic ; **ajouter des pages à un bloc-notes** pour multiplier les conversations.
* Question type : deux façons de collaborer avec un collègue sur une page : **mentionner le collègue** et **partager le lien de la page** (le bloc-notes est privé, Word n'est pas la collaboration).
* Plusieurs pages de recherche sur un produit, pour multiplier les conversations : **d'abord les ajouter à un bloc-notes**.

### Question flash

Qu'est-ce qui est disponible à la fois dans Microsoft 365 Copilot et dans Microsoft 365 Copilot Chat ?
**Les pages Copilot.**

---

## Lab 4.6 : Instructions personnalisées et mémoire

**Durée :** 10 min  |  **Slide de référence :** 40

### Prérequis

- [ ] Compte avec licence Microsoft 365 Copilot.
- [ ] Application Microsoft 365 Copilot, accès aux **Paramètres** (icône engrenage ou avatar en haut à droite).
- [ ] La **mémoire** et la **personnalisation** activées par l'administrateur sur le tenant de formation (paramètres de personnalisation Copilot). Si elles sont désactivées, les étapes 6 à 10 sont remplacées par une démonstration du formateur.
- [ ] Agent Chercheur ou Analyste accessible (étape 5).

### Scénario ARCHIALEARN

Vous voulez que Copilot réponde toujours en style professionnel adapté au métier de la formation, et vous lui demandez de retenir un détail de déplacement... avant que celui-ci ne soit annulé.

### Procédure pas à pas

**Instructions personnalisées**

1. Dans l'application Microsoft 365 Copilot, cliquer sur l'**avatar** (ou l'icône **Paramètres**) en haut à droite, puis **Paramètres**, puis **Instructions personnalisées** (Custom instructions) (parfois sous **Personnalisation**).
2. Saisir :
   ```
   Réponds de façon professionnelle, adaptée au secteur de la formation certifiante Microsoft. Utilise le vouvoiement, des phrases courtes, et termine chaque réponse par une ligne « Prochaine étape : ».
   ```
   **Enregistrer**.
3. Ouvrir une **Nouvelle conversation** : `Quels conseils pour réussir l'examen AB-730 ?` Vérifier le vouvoiement, les phrases courtes et la ligne « Prochaine étape : ».
4. Revenir dans une **conversation antérieure** (Lab 2.1) et relire la réponse : elle n'a **pas changé**. Les instructions s'appliquent aux **nouvelles conversations**.
5. Ouvrir l'agent **Chercheur** (ou **Analyste**) et poser une question : la ligne « Prochaine étape : » **n'apparaît pas**. Les instructions personnalisées ne s'appliquent pas à ces agents.

**Mémoire**

6. **Nouvelle conversation** : `Souviens-toi que je pars en déplacement à Lyon le 12 octobre pour la session AB-730 chez ARCHIFRIDAYS, hôtel réservé, budget 900 euros.` Copilot confirme la mise à jour de la mémoire (mention « Mémoire mise à jour » ou similaire).
7. **Nouvelle conversation** : `Quand est mon prochain déplacement et pour quel client ?` Copilot répond à partir de la mémoire, sans que vous ayez rappelé le contexte.
8. **Paramètres**, **Mémoire** (Memory) : la liste des mémoires s'affiche. Cliquer sur la mémoire du déplacement, **Modifier** (changer le budget à 950 euros), enregistrer.
9. Scénario « voyage annulé » : dans **Paramètres**, **Mémoire**, sélectionner la mémoire du déplacement, **Supprimer**. Ouvrir une nouvelle conversation : `Quand est mon prochain déplacement ?` Copilot ne le connaît plus. Vérifier dans **Conversations** que les conversations des étapes 6 et 7 existent toujours : la mémoire est stockée **séparément** de l'historique.
10. Ouvrir une **Conversation temporaire** et saisir : `Souviens-toi que ma couleur préférée est le bleu.` Fermer, ouvrir une nouvelle conversation classique : `Quelle est ma couleur préférée ?` Copilot ne le sait pas : rien n'est enregistré en conversation temporaire.
11. Nettoyage : retirer les instructions personnalisées si le compte est réutilisé pour une autre session.

### Résultat attendu

Des instructions personnalisées appliquées aux nouvelles conversations mais pas aux anciennes ni aux agents Chercheur / Analyste ; une mémoire créée, réutilisée, modifiée puis supprimée sans effet sur l'historique ; une conversation temporaire sans trace.

### À noter pour l'examen

* **Instructions personnalisées** : préférences appliquées à **toutes** les interactions (ton, style, format) ; configurées dans les **Paramètres** ; s'appliquent aux **nouvelles conversations**, pas aux réponses passées ; **ne s'appliquent pas** aux agents Chercheur et Analyste. Cas type « chercheur médical qui veut des réponses professionnelles adaptées à son domaine » : **configurer les instructions personnalisées** (et non la mémoire, un exemple attaché ou une invite enregistrée).
* Objectif des instructions personnalisées (question type) : **définir des préférences appliquées à toutes les interactions, comme le ton et le style des réponses** (pas agir à votre place, pas des règles de sécurité, pas fournir nom / titre / entreprise).
* **Mémoire** : Copilot retient des faits et préférences que **vous** lui donnez et les réutilise ; **afficher, modifier, supprimer** les mémoires dans les paramètres ; les administrateurs pilotent la mémoire via les **paramètres de personnalisation**. Cas type du voyage annulé : **supprimer les mémoires depuis Copilot** (et non l'historique d'activité depuis Mon compte, les instructions personnalisées ou les conversations).
* **Conversation temporaire** : rien n'est enregistré, contenu supprimé immédiatement.

### Question flash

Vous aviez demandé à Copilot de mémoriser les détails d'un voyage, finalement annulé. Que faire ?
**Supprimer les mémoires depuis Copilot.**

---

## Synthèse de la Partie 4 : vocabulaire à maîtriser

| Terme | Ce qu'il faut savoir | Piège associé |
|---|---|---|
| Résumé de gestion | Word, Outlook (Résumé par Copilot), Chat (`/` + audience + format), Teams (canal) ; source précise + instructions concises | Oublier la revue humaine et l'héritage d'étiquette |
| Copilot dans Excel | Insights, tableau croisé, formules expliquées, graphique, `=COPILOT()` | Mise en forme conditionnelle personnalisée |
| Agent Analyste | Agréger, consolider, calculer, graphiques, Python en arrière-plan | Répondre Chat, Chercheur, bloc-notes ou page |
| Déplacer les insights | Excel vers PowerPoint, Word vers Outlook, Chat vers Pages | Croire qu'il faut ressaisir le contenu |
| Réunions Teams | Options de réunion (Copilot pendant et après, transcription) ; « ce que j'ai manqué » ; Recap | Transcription oubliée ; réunion non invitée |
| Pages | Canevas Loop, partagé par lien, mention, composant, Word en un clic, avec et sans licence | Confondre avec le bloc-notes (privé) |
| Instructions personnalisées | Ton et style pour toutes les nouvelles interactions ; pas pour Chercheur / Analyste | Confondre avec la mémoire |
| Mémoire | Faits fournis par l'utilisateur, réutilisés ; gérée dans les paramètres | Supprimer l'historique ou les conversations à la place |

---

## Grille de correction de l'examen blanc (slides 45 à 50), à utiliser en clôture

| Série | Q1 | Q2 | Q3 | Q4 |
|---|---|---|---|---|
| 1/3 | B : les pages Copilot | C : les content credentials | B : l'invite enfreint les règles de sécurité | D : référencer des fichiers précis |
| 2/3 | D : uniquement avec accès aux fichiers | B : portail Mon compte | A : les citations | B : dépendance excessive |
| 3/3 | B : le générateur d'images | A : un bloc-notes | B : l'agent Analyste | B : supprimer les mémoires depuis Copilot |

Seuil indicatif : à partir de 9 bonnes réponses sur 12, le stagiaire est dans la zone de réussite ; en dessous, reprendre les labs de la partie correspondante.


---

*Propriété intellectuelle : ARCHIA365 ([Société ARCHIA365 à 75008 PARIS - SIREN 990 705 055 | L'Annuaire des Entreprises](https://annuaire-entreprises.data.gouv.fr/entreprise/archia365-990705055)) et ARCHIALEARN. Supports réservés à la formation AB-730 délivrée par ARCHIALEARN. Pour des besoins de formation, nous contacter : contact@archia365.fr*
