# AB-730 : Labs de la Partie 2
## Invites et conversations dans Microsoft 365 Copilot

**Organisme :** ARCHIALEARN  |  **Formateur :** Rodrigue YENGO  |  **Domaine du guide d'étude :** 2 (35 à 40 %, le plus lourd de l'examen)  |  **Slides :** 15 à 24

| Lab | Titre | Durée | Compétence du guide d'étude |
|---|---|---|---|
| 2.1 | Construire une invite efficace en quatre composants | 15 min | Comprendre comment créer une invite efficace |
| 2.2 | Référencer les bonnes ressources : `/`, `@`, `#` | 15 min | Sélectionner les ressources appropriées à référencer dans une invite |
| 2.3 | Enregistrer une invite et la retrouver dans la Galerie d'invites | 10 min | Enregistrer une invite |
| 2.4 | Programmer et partager une invite | 15 min | Programmer une invite, partager une invite |
| 2.5 | Gérer ses conversations : rechercher, renommer, supprimer, bloc-notes | 15 min | Rechercher, renommer, supprimer une conversation, ajouter à un bloc-notes |
| 2.6 | Atelier guidé : rédiger et affiner du contenu métier (module 1 du cours officiel) | 20 min | Synthèse des compétences de la partie |

---

## Lab 2.1 : Construire une invite efficace en quatre composants

**Durée :** 15 min  |  **Slide de référence :** 17

### Prérequis

- [ ] Compte avec licence Microsoft 365 Copilot.
- [ ] Application Microsoft 365 Copilot, page **Chat**, portée **Travail**.
- [ ] Fichiers `Rapport-Q3.docx` et `Ventes-2025.xlsx` dans OneDrive (dossier `AB-730-Labs`).
- [ ] Le gabarit d'invite ci-dessous imprimé ou copié dans un fichier texte.

### Scénario ARCHIALEARN

Le comité de direction d'ARCHIALEARN attend une introduction de rapport trimestriel. Vous partez d'une invite vague et vous l'améliorez composant par composant.

### Procédure pas à pas

1. Ouvrir Copilot Chat, **Nouvelle conversation**, portée **Travail**.
2. Saisir l'invite **volontairement faible** :
   ```
   Fais une intro pour le rapport.
   ```
   Observer la réponse : générique, sans chiffre, ton indéterminé.
3. Cliquer sur **Nouvelle conversation**. Saisir maintenant l'invite complète, en repérant les quatre composants :
   ```
   [Objectif] Rédige une introduction professionnelle pour notre rapport de performance du troisième trimestre.
   [Contexte] Elle est destinée au comité de direction d'ARCHIALEARN, ton formel, 150 mots, en deux paragraphes.
   [Source] Appuie-toi sur /Rapport-Q3.docx.
   [Attentes] Termine par une phrase qui annonce le plan du rapport.
   ```
   Retirer les crochets avant d'envoyer ; utiliser `/` pour sélectionner le fichier.
4. Comparer les deux réponses en binôme : longueur, présence de chiffres cités, adéquation du ton.
5. Cliquer sur **Nouvelle conversation** et tester le cas Excel de l'examen. Taper `/`, choisir `Ventes-2025.xlsx`, puis :
   ```
   Produis un résumé mensuel du montant total des commandes (colonne Amount) sur l'année 2025, sous forme de tableau mois / total / variation.
   ```
6. Observer que Copilot produit le tableau sans que vous ayez indiqué de plage de cellules ni de formule : c'est **l'objectif clair** qui a fait la différence.
7. Sur la feuille de réponses, réécrire l'invite suivante pour supprimer ses trois défauts (acronymes, généricité, empilement d'instructions) :
   ```
   Fais un truc sur le CA, le NPS et le TJM, résume, traduis en anglais, fais un tableau, un mail et une présentation.
   ```
8. Mise en commun avec le formateur : une invite = un objectif, du contexte, une source, des attentes.

### Résultat attendu

Deux introductions comparées, un tableau mensuel Excel obtenu par une invite en langage naturel, et une invite réécrite sans acronyme ni empilement.

### À noter pour l'examen

* Une invite est une **question ou une instruction** donnée à Copilot. Le cours officiel retient quatre composants : **objectif, contexte, source, attentes**.
* L'examen teste surtout les deux premiers : les deux facteurs d'une invite efficace sont **fournir un objectif clair** et **ajouter du contexte**.
* Mauvaises réponses systématiques : utiliser des **acronymes**, rester **générique**, empiler une **large gamme d'instructions**.
* Cas Excel (OrderDate, OrderNumber, Amount, résumé mensuel) : le meilleur élément à inclure est **un objectif clair du résumé**, et non le nom du fichier, une plage de cellules ou une formule.

### Question flash

Quels sont les deux facteurs à considérer pour rendre une invite efficace ?
**Un objectif clair et du contexte.**

---

## Lab 2.2 : Référencer les bonnes ressources : `/`, `@`, `#`

**Durée :** 15 min  |  **Slide de référence :** 18

### Prérequis

- [ ] Compte avec licence Microsoft 365 Copilot.
- [ ] Fichier `Proposition-Partenariat.docx` dans OneDrive, **non partagé** avec le binôme au début du lab.
- [ ] Une réunion Teams passée dans le calendrier (pour le symbole `#`).
- [ ] Un agent disponible dans l'onglet **Agents** (le Chercheur suffit ; à partir de la Partie 3, l'agent créé au Lab 3.2 pourra remplacer).
- [ ] Le binôme est identifié (nom exact dans l'annuaire).

### Scénario ARCHIALEARN

Vous préparez la réunion de lancement du partenariat ARCHIALEARN / ARCHIFRIDAYS. Vous devez résumer la proposition, impliquer un collègue et un agent, puis constater ce qui se passe quand le collègue n'a pas accès au fichier.

### Procédure pas à pas

**Symbole `/` : fichiers et dossiers**

1. Copilot Chat, **Nouvelle conversation**, portée **Travail**.
2. Taper `/` dans la zone de saisie : une liste **Fichiers récents** apparaît. Commencer à taper `Proposition` pour filtrer, sélectionner `Proposition-Partenariat.docx`. Le fichier apparaît sous forme de **puce** (chip) dans l'invite.
3. Compléter :
   ```
   Résume cette proposition de partenariat en 3 à 5 points concis pour la réunion de lancement du projet.
   ```
   Envoyer. Vérifier que la référence en bas de réponse est bien le fichier.
4. Nouvelle conversation. Poser la **même question sans référencer le fichier** :
   ```
   Résume la proposition de partenariat en 3 points.
   ```
   Observer : Copilot cherche dans Graph, peut trouver le bon fichier ou un autre, ou répondre de façon générique. Conclusion : sans source, l'ancrage n'est pas garanti.

**Symbole `@` : personnes et agents**

5. Nouvelle conversation. Taper `@` puis les premières lettres du nom du binôme, le sélectionner, puis :
   ```
   Quels e-mails ai-je échangés avec @<binôme> cette semaine ?
   ```
6. Nouvelle conversation. Taper `@` puis `Chercheur` (ou le nom de votre agent), sélectionner l'agent dans la liste : l'invite est adressée à l'agent depuis la conversation ouverte. Saisir :
   ```
   @Chercheur Quelles sont les tendances 2026 du marché de la formation certifiante Microsoft en France ?
   ```

**Symbole `#` : réunions et sujets**

7. Nouvelle conversation. Taper `#` et sélectionner une réunion récente, puis :
   ```
   Liste les décisions et les actions de cette réunion.
   ```

**Permissions : le piège de l'invite partagée**

8. Reprendre la conversation de l'étape 3. Sous la réponse, cliquer sur **Plus d'options** (`...`), puis **Enregistrer l'invite**. Donner le titre `Résumé proposition partenariat`. (Le mécanisme complet est détaillé au Lab 2.3.)
9. Aller dans **Galerie d'invites** (bouton **Afficher les invites** sous la zone de saisie), onglet **Vos invites**, ouvrir `...` sur l'invite, cliquer sur **Partager**, copier le lien et l'envoyer au binôme par Teams.
10. Binôme : ouvrir le lien, exécuter l'invite. Constater le message d'échec (« fichier vide, corrompu ou format non traité » ou « je n'ai pas pu accéder au fichier »), car le fichier n'est **pas partagé**.
11. Partager le fichier avec le binôme (OneDrive, **Partager**, **Peut afficher**). Binôme : relancer l'invite, elle fonctionne.

### Résultat attendu

Trois invites utilisant `/`, `@` et `#`, et la démonstration qu'une invite partagée ne transporte ni les fichiers ni les droits.

### À noter pour l'examen

* `/` pointe un **fichier ou un dossier** ; `@` mentionne une **personne** ou appelle un **agent** (pour appeler Agent1 dans une conversation ouverte, taper `@Agent1`) ; `#` désigne une **réunion ou un sujet**.
* Pour une réponse fondée sur une proposition : **référencer le contenu de la proposition** dans l'invite. Pour améliorer l'ancrage pendant une conversation : **référencer des fichiers précis** (et non raccourcir l'invite, éviter le jargon ou préciser le format).
* Les deux détails à inclure pour résumer une proposition en 3 à 5 points : **une source de connaissances précise** et **des instructions concises**.
* Une invite partagée contenant des fichiers OneDrive ne fonctionne que si le destinataire **a déjà accès aux fichiers** : l'invite pointe vers les fichiers, elle **ne les embarque pas et n'accorde aucun accès** (le destinataire n'obtient pas l'accès automatiquement et n'est pas invité à le demander).

### Question flash

Vous partagez par e-mail une invite contenant plusieurs fichiers de votre OneDrive. Que se passe-t-il quand le destinataire l'utilise ?
**Il ne peut exécuter l'invite que s'il a accès aux fichiers.**

---

## Lab 2.3 : Enregistrer une invite et la retrouver dans la Galerie d'invites

**Durée :** 10 min  |  **Slide de référence :** 19 (colonne Enregistrer)

### Prérequis

- [ ] Compte avec licence Microsoft 365 Copilot (l'enregistrement d'invite est aussi disponible dans Copilot Chat sans licence, mais le lab utilise une source Travail).
- [ ] Fichier `Rapport-Q3.docx` dans OneDrive.

### Scénario ARCHIALEARN

Chaque mois, vous rédigez un rapport d'avancement de projet. Vous voulez retrouver l'invite dans la Galerie d'invites sans la retaper.

### Procédure pas à pas

1. Copilot Chat, **Nouvelle conversation**, portée **Travail**.
2. Saisir l'invite :
   ```
   Rédige un rapport d'avancement de projet d'une page à partir de /Rapport-Q3.docx, structuré en : réalisations, risques, prochaines étapes.
   ```
3. **Avant d'envoyer**, chercher une option « Enregistrer » : constater qu'elle **n'existe pas** sur une invite non exécutée. Envoyer l'invite (**Entrée**).
4. Une fois la réponse affichée, remonter à votre message d'invite (bulle de droite). Passer la souris dessus ou cliquer sur **Plus d'options** (`...`) : cliquer sur **Enregistrer l'invite** (Save prompt).
5. Dans la boîte de dialogue, saisir le titre `Rapport d'avancement mensuel`. Cliquer sur **Enregistrer**.
6. Sous la zone de saisie, cliquer sur **Afficher les invites** (View prompts). La **Galerie d'invites** (Prompt Gallery) s'ouvre.
7. Cliquer sur l'onglet **Vos invites** (Your prompts). L'invite `Rapport d'avancement mensuel` est listée avec son titre et son texte.
8. Cliquer sur **Plus d'options** (`...`) de l'invite. Observer les actions disponibles : **Partager**, **Supprimer de la galerie**. Constater qu'il n'y a **ni « Modifier le texte » ni « Renommer »**.
9. Pour « modifier » une invite enregistrée : cliquer sur l'invite pour la charger dans la zone de saisie, changer le texte (par exemple remplacer « une page » par « une demi-page »), exécuter, puis enregistrer sous un nouveau titre `Rapport d'avancement mensuel court`. Vérifier que deux invites coexistent dans **Vos invites**.
10. Supprimer la première version : `...`, **Supprimer de la galerie**, confirmer.

### Résultat attendu

Une invite enregistrée visible dans **Vos invites**, la constatation que le texte et le titre ne sont pas modifiables, et la méthode « nouvelle invite » pour la faire évoluer.

### À noter pour l'examen

* Il faut d'abord **exécuter l'invite** avant de pouvoir choisir **Enregistrer l'invite** (question type : « que faire en premier pour retrouver l'invite dans la galerie ? » : **exécuter l'invite**, et non créer un bloc-notes, ajouter un agent ou créer une page).
* L'invite enregistrée apparaît dans la **Galerie d'invites, onglet Vos invites**.
* Deux actions possibles sur une invite enregistrée : **la supprimer de la galerie** et **la partager** (à une équipe Teams). Le **texte et le titre ne sont pas modifiables** ; la programmation n'est pas une action sur l'invite enregistrée.

### Question flash

Quelles deux actions pouvez-vous effectuer sur une invite enregistrée ?
**La supprimer de la Galerie d'invites et la partager à une équipe Teams.**

---

## Lab 2.4 : Programmer et partager une invite

**Durée :** 15 min  |  **Slide de référence :** 19 (colonnes Programmer et Partager)

### Prérequis

- [ ] Compte avec licence Microsoft 365 Copilot (les invites programmées utilisent des données de travail).
- [ ] Application Microsoft 365 Copilot dans Teams, dans Outlook ou sur m365copilot.com (les trois surfaces permettent la programmation).
- [ ] Membre de l'équipe Teams **AB-730 - Session du 18/09/2026**.
- [ ] Un lien d'invite provenant d'une autre organisation (le formateur fournit un lien de test issu du tenant ARCHIA365, distinct du tenant de formation) pour l'étape 12.

### Scénario ARCHIALEARN

Vous voulez recevoir chaque matin à 8 h un résumé de votre boîte de réception, et mettre à disposition de l'équipe l'invite « rapport d'avancement » créée au lab précédent.

### Procédure pas à pas

**Programmer**

1. Ouvrir l'application Microsoft 365 Copilot (Teams : icône **Copilot** dans la barre de gauche ; ou `m365copilot.com`).
2. **Nouvelle conversation**, portée **Travail**. Saisir et exécuter :
   ```
   Résume les e-mails non lus de ma boîte de réception en 5 points, avec les actions attendues de ma part.
   ```
3. Sur votre invite (bulle de droite), cliquer sur **Plus d'options** (`...`), puis **Programmer l'invite** (Schedule prompt).
4. Dans le volet de programmation : choisir la fréquence **Quotidienne**, l'heure `08:00`, laisser les jours ouvrés cochés. Cliquer sur **Programmer** (ou **Enregistrer**).
5. Dans le volet gauche, ouvrir la section **Conversations** : l'invite programmée apparaît **en gras**, avec une icône horloge. Cliquer dessus pour voir la prochaine exécution.
6. Ouvrir `...` sur cette conversation programmée : observer **Modifier la planification**, **Suspendre** et **Supprimer**. Tenter de créer une seconde exécution du même résumé à 12 h : constater la limite d'**une exécution par jour** pour une invite donnée.
7. À la fin du lab, **supprimer** la programmation (`...`, **Supprimer la planification**) pour ne pas encombrer le compte de formation.

**Partager**

8. Ouvrir la **Galerie d'invites** (bouton **Afficher les invites**), onglet **Vos invites**, `...` sur `Rapport d'avancement mensuel court`, cliquer sur **Partager**.
9. Deux options : **Partager avec une équipe** (choisir **AB-730 - Session du 18/09/2026**) ou **Copier le lien**. Choisir l'équipe, puis **Partager**.
10. Le binôme ouvre la Galerie d'invites, onglet **Équipe** (Team) : l'invite partagée est listée avec le nom de l'auteur. Il clique dessus pour la charger et l'exécute.
11. Vérifier ensemble : le binôme obtient une réponse uniquement s'il a accès à `Rapport-Q3.docx`. L'invite a été partagée, **pas le fichier**.
12. Coller dans le navigateur le lien d'invite fourni par le formateur, provenant du tenant ARCHIA365 : observer le message **« Invite introuvable »** (Prompt not found). Le partage d'invites reste **dans l'organisation**.

### Résultat attendu

Une invite programmée visible en gras dans Conversations, une invite partagée visible dans l'onglet Équipe du binôme, et le message « Invite introuvable » sur un lien externe.

### À noter pour l'examen

* Programmation possible dans **Teams, Outlook ou m365copilot.com** (ex. résumé de boîte de réception à 8 h).
* Limites officielles : **une exécution par jour**, **jusqu'à 15 exécutions**, **données de travail** uniquement.
* Les invites programmées apparaissent **en gras** dans la section **Conversations**.
* Partage à une **équipe Teams** ou **par lien** : l'invite apparaît dans l'onglet **Équipe** de la galerie.
* Le partage reste dans l'organisation : un lien reçu d'une **autre entreprise** donne **« Invite introuvable » / « Prompt not found »**.
* Les fichiers référencés **ne sont pas partagés** avec l'invite.

### Question flash

Un collègue d'une autre entreprise vous envoie un lien d'invite et vous obtenez « Prompt not found ». Pourquoi ?
**L'invite est en dehors de votre organisation.**

---

## Lab 2.5 : Gérer ses conversations : rechercher, renommer, supprimer, bloc-notes

**Durée :** 15 min  |  **Slide de référence :** 20

### Prérequis

- [ ] Compte avec licence Microsoft 365 Copilot (les blocs-notes exigent la licence).
- [ ] Au moins cinq conversations existantes (créées dans les labs précédents).
- [ ] Fichier `Process-Onboarding.docx` disponible **à la fois** sur le site SharePoint **ARCHIALEARN - Formation AB-730** (bibliothèque Documents, dossier Labs) **et** en copie locale sur le poste (dossier `Téléchargements`).
- [ ] Accès au portail **Mon compte** : https://myaccount.microsoft.com (démonstration par le formateur uniquement à l'étape 9, pour ne pas effacer les conversations des stagiaires).
- [ ] Application mobile Microsoft 365 Copilot installée (facultatif, étape 3).

### Scénario ARCHIALEARN

Vous avez utilisé par erreur un document confidentiel dans une conversation. Vous devez supprimer cette seule conversation, organiser les autres par sujet, et regrouper celles qui concernent l'intégration des nouveaux formateurs dans un bloc-notes.

### Procédure pas à pas

**Rechercher et renommer**

1. Dans le volet gauche, cliquer sur **Conversations** (ou **Afficher tout**). La liste des conversations récentes s'affiche, la plus récente en haut.
2. Utiliser la **barre de recherche** en haut du volet et saisir `partenariat` : seules les conversations contenant ce mot apparaissent.
3. (Facultatif) Ouvrir l'application mobile Copilot avec le même compte : la même liste est présente, car l'historique est **lié au compte** et synchronisé bureau / web / mobile.
4. Sur la conversation du Lab 2.2, cliquer sur `...`, puis **Renommer**. Saisir `Partenariat ARCHIFRIDAYS - résumé`, **Entrée**.
5. Repérer, dans la liste, l'**icône de partage** à côté d'une conversation partagée (si vous avez partagé une conversation via `...`, **Partager**, un lien est généré et l'icône apparaît).

**Supprimer une seule conversation**

6. Créer une nouvelle conversation contenant volontairement une référence à `/Confidentiel-Plan-Strategique.docx` (« résume ce document »). La renommer `A SUPPRIMER`.
7. Dans la liste, `...` sur `A SUPPRIMER`, cliquer sur **Supprimer**, confirmer. Vérifier que les autres conversations sont intactes : aucune approbation administrateur n'a été demandée.
8. Ouvrir OneDrive : le fichier référencé existe toujours. Supprimer une conversation ne supprime **ni les fichiers, ni les pages, ni les blocs-notes**.

**Supprimer tout l'historique (démonstration formateur)**

9. Le formateur, avec un compte de démonstration, ouvre https://myaccount.microsoft.com, **Paramètres et confidentialité**, onglet **Confidentialité**, section **Historique des activités Copilot**, bouton **Supprimer l'historique**. Toutes les conversations disparaissent en une action.

**Conversation temporaire**

10. Dans Copilot Chat, ouvrir le menu de la nouvelle conversation et choisir **Conversation temporaire** (icône dédiée ou option dans `...`). Poser une question, fermer la conversation : elle n'apparaît **pas** dans l'historique.

**Ajouter à un bloc-notes**

11. Dans le volet gauche, cliquer sur **Bloc-notes** (Notebooks), puis **Créer un bloc-notes**. Nom : `Intégration nouveaux formateurs`.
12. Dans le bloc-notes, cliquer sur **Ajouter des références** (ou **+**). Choisir **SharePoint / OneDrive** et sélectionner `Process-Onboarding.docx` depuis le site SharePoint.
13. Cliquer à nouveau sur **Ajouter des références**, choisir **Téléverser depuis cet appareil** et sélectionner la copie locale de `Process-Onboarding.docx` (dossier `Téléchargements`). Le bloc-notes contient maintenant deux références du même document.
14. Retourner dans **Conversations**, `...` sur la conversation renommée à l'étape 4, cliquer sur **Ajouter au bloc-notes**, choisir `Intégration nouveaux formateurs`.
15. Dans le bloc-notes, ouvrir **Instructions** et saisir : `Réponds toujours en français, en style procédure numérotée.` Enregistrer.
16. Binôme : demander au binôme de modifier `Process-Onboarding.docx` sur SharePoint (ajouter une ligne « Étape 99 : test AB-730 ») et d'enregistrer.
17. Dans le bloc-notes, poser la question : `Quelle est la dernière étape du processus ?` Copilot cite l'« Étape 99 » à partir de la référence **SharePoint** (dernière version) ; la copie **locale** téléversée reste figée à la version d'origine.
18. Repérer le bouton **Présentation audio** (Audio overview) du bloc-notes : il génère un résumé audio des références. Constater qu'il n'y a **pas de bouton Partager** sur le bloc-notes, contrairement aux pages.

### Résultat attendu

Une conversation renommée, une conversation supprimée sans effet sur les fichiers, une conversation temporaire absente de l'historique, et un bloc-notes avec instructions, deux références (SharePoint synchronisée, locale figée) et une conversation rattachée.

### À noter pour l'examen

* Historique consultable via le menu **Conversations** ou la **barre de recherche** ; lié au compte et **synchronisé bureau / web / mobile** ; **renommer** pour organiser par sujet ; **icône de partage** = conversation partagée.
* Supprimer **une** conversation (sans approbation administrateur, en conservant les autres) : **l'application Microsoft 365 Copilot**.
* Supprimer **toutes** les conversations avec le moins d'effort : **portail Mon compte**, **Supprimer l'historique** (et non l'application web, l'application de bureau, le centre d'administration, Purview ou les Paramètres Windows).
* Supprimer une conversation **ne supprime ni les fichiers, ni les pages, ni les blocs-notes**.
* **Conversation temporaire** : contenu supprimé immédiatement à la fin de la session.
* **Bloc-notes** : espace **privé** regroupant conversations et références sur un sujet ; instructions dédiées ; présentation audio ; **ne se partage pas** (contrairement aux pages).
* Fichier ajouté depuis un **dossier local** : version **figée** ; fichier **SharePoint** : toujours la **dernière version** (scénario Process.docx mis à jour hier : la conversation référence la version la plus récente).
* Pour regrouper plusieurs conversations séparées avec les mêmes références : **un bloc-notes** (et non un agent, une application ou une page).

### Question flash

Vous ajoutez `Process.docx` depuis SharePoint à un bloc-notes ; un collègue modifie le fichier le lendemain. Quelle version la conversation utilise-t-elle ?
**La version la plus récente.** (Réponse inverse pour un fichier ajouté depuis un dossier local.)

---

## Lab 2.6 : Atelier guidé : rédiger et affiner du contenu métier

**Durée :** 20 min  |  **Slide de référence :** 22  |  **Base :** module 1 du cours officiel AB-730T00-A

### Prérequis

- [ ] Tous les prérequis des Labs 2.1 à 2.5 validés.
- [ ] Compte avec licence Microsoft 365 Copilot.
- [ ] Fichier `Rapport-Q3.docx` dans OneDrive.
- [ ] Membre de l'équipe Teams **AB-730 - Session du 18/09/2026**.
- [ ] Bloc-notes `Intégration nouveaux formateurs` créé au Lab 2.5 (ou créer un nouveau bloc-notes `Rapport Q3`).

### Scénario ARCHIALEARN

Vous produisez l'introduction du rapport trimestriel destiné au comité de direction, vous l'affinez, puis vous industrialisez l'invite pour l'équipe.

### Procédure pas à pas

**Étape 1 : invite complète (objectif, contexte, source, attentes)**

1. Copilot Chat, **Nouvelle conversation**, portée **Travail**. Saisir, en sélectionnant le fichier avec `/` :
   ```
   Rédige une introduction professionnelle de 150 mots pour notre rapport de performance du troisième trimestre, destinée au comité de direction, à partir de /Rapport-Q3.docx. Ton formel, structure en deux paragraphes.
   ```

**Étape 2 : affiner par invites de suivi**

2. Dans la même conversation, envoyer successivement :
   ```
   Raccourcis à 100 mots.
   ```
   ```
   Rends le ton plus direct, sans formules de politesse.
   ```
   ```
   Présente les trois chiffres clés sous forme de liste à puces après le premier paragraphe.
   ```
3. Observer que chaque invite de suivi s'appuie sur l'**historique de la conversation** : inutile de répéter le contexte.

**Étape 3 : Travail contre Web**

4. Nouvelle conversation, portée **Travail** :
   ```
   Résume les tendances internes du T3 décrites dans /Rapport-Q3.docx en 3 points.
   ```
5. Nouvelle conversation, portée **Web** :
   ```
   Résume en 3 points les tendances 2026 du secteur de la formation professionnelle en France.
   ```
6. Noter la différence de sources (fichier interne / sites web) : ce sont les deux invites du flux officiel « rapport Q3 ».

**Étape 4 : enregistrer, retrouver, partager**

7. Revenir à la conversation de l'étape 1. Sur l'invite initiale, `...`, **Enregistrer l'invite**, titre `Introduction rapport trimestriel`.
8. **Afficher les invites**, onglet **Vos invites** : vérifier la présence de l'invite.
9. `...`, **Partager**, **Partager avec une équipe**, choisir **AB-730 - Session du 18/09/2026**. Le binôme vérifie l'onglet **Équipe**.

**Étape 5 : renommer et ajouter à un bloc-notes**

10. **Conversations**, `...` sur la conversation de l'étape 1, **Renommer** : `Rapport Q3 - introduction`.
11. `...`, **Ajouter au bloc-notes**, choisir le bloc-notes cible.
12. Ouvrir le bloc-notes et poser : `Reformule l'introduction pour un public de formateurs.` La réponse s'appuie sur la conversation ajoutée et sur les références du bloc-notes.

### Résultat attendu

Une introduction affinée en trois itérations, deux invites Travail / Web comparées, une invite enregistrée et partagée à l'équipe, une conversation renommée et rattachée à un bloc-notes.

### À noter pour l'examen

* Les invites de suivi (**ton, longueur, format**) utilisent l'historique de la conversation : c'est la manière attendue d'« affiner » un résultat.
* Le flux officiel du cours : invite **Travail** pour les tendances internes, invite **Web** pour les tendances du secteur.
* Enchaînement à connaître par coeur : **exécuter, enregistrer, retrouver dans Vos invites, partager à l'équipe, renommer la conversation, ajouter au bloc-notes**.

### Question flash

Pour qu'une invite soit disponible dans la Galerie d'invites, que devez-vous faire en premier ?
**Exécuter l'invite.**

---

## Synthèse de la Partie 2 : vocabulaire à maîtriser

| Terme | Ce qu'il faut savoir | Piège associé |
|---|---|---|
| Invite (prompt) | Objectif, contexte, source, attentes ; l'examen retient objectif clair + contexte | Acronymes, généricité, empilement d'instructions |
| `/` `@` `#` | Fichier ou dossier / personne ou agent / réunion ou sujet | Croire que `/` partage le fichier |
| Galerie d'invites | Onglets Vos invites et Équipe ; exécuter avant d'enregistrer | Chercher « modifier le texte » |
| Invite programmée | Teams, Outlook, m365copilot.com ; 1 exécution par jour, 15 max ; en gras dans Conversations | Confondre avec « partager » |
| Invite partagée | Équipe Teams ou lien, dans l'organisation seulement ; « Invite introuvable » sinon | Croire que le destinataire reçoit l'accès aux fichiers |
| Conversation | Rechercher, renommer, supprimer (app Copilot = une ; Mon compte = toutes) | Centre d'administration, Purview |
| Bloc-notes | Privé, instructions, présentation audio, SharePoint synchronisé / local figé | Croire qu'il se partage comme une page |


---

*Propriété intellectuelle : ARCHIA365 ([Société ARCHIA365 à 75008 PARIS - SIREN 990 705 055 | L'Annuaire des Entreprises](https://annuaire-entreprises.data.gouv.fr/entreprise/archia365-990705055)) et ARCHIALEARN. Supports réservés à la formation AB-730 délivrée par ARCHIALEARN. Pour des besoins de formation, nous contacter : contact@archia365.fr*
