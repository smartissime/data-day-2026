# Fiches de synthèse par module

*Formation Dynamics 365 Sales, niveau Product Owner / Business Analyst*

ARCHIA365

Chaque fiche résume un module en quatre rubriques : ce que propose le standard, la logique de conception, les bonnes pratiques et les questions que le Product Owner doit se poser. Les fonctions et leur répartition par licence évoluent à chaque vague de publication Microsoft : vérifiez la documentation en vigueur avant toute décision.

## M1 · Dynamics 365 Sales dans l’écosystème

**Ce que propose le standard.** Une application pilotée par modèle (Sales Hub) bâtie sur Dataverse, qui partage ses données avec les autres applications Dynamics 365 et la Power Platform. Trois niveaux de licence (Professional, Enterprise, Premium) répartissent les fonctions, de la gestion du pipeline aux fonctions prédictives.

**Logique de conception.** Une base de données commune et des tables standard partagées permettent à Microsoft d’ajouter des fonctions (IA, Copilot, analyses) qui s’appliquent à tous les clients restés proches du modèle.

**Bonnes pratiques.**

- Suivre le plan de publication à chaque vague (avril et octobre).
- Revoir chaque année les personnalisations au regard des nouveautés natives.
- Vérifier les droits de licence avant de spécifier une fonction.

**Questions du PO.** Quelles fonctions natives n’utilisons-nous pas ? Qui suit le plan de publication ? Quel spécifique est devenu natif ?

**À retenir.** Plus le CRM reste proche du modèle standard, plus il bénéficie des nouveautés sans projet.

## M2 · Configuration : vue d’ensemble

**Ce que propose le standard.** Sécurité par unités commerciales, rôles (privilèges et portée), équipes (propriétaires ou d’accès), profils de sécurité de colonne et hiérarchie de responsables. Tableaux de bord personnels et système.

**Logique de conception.** Le modèle combine la structure de l’organisation (unités) et le besoin d’accès ponctuel (équipes, partage) ; la protection fine d’une donnée sensible passe par la colonne, pas par la table.

**Bonnes pratiques.**

- Partir des besoins de visibilité, pas de l’organigramme.
- Limiter le nombre de rôles et de profils de colonne.
- Documenter qui voit quoi et pourquoi.

**Questions du PO.** Le besoin relève-t-il d’un rôle, d’une équipe ou d’un partage ? Quelles données sont réellement confidentielles ?

**À retenir.** Un modèle de sécurité trop fin coûte en maintenance, en support et en performance.

## M3 · Le modèle de données commercial standard

**Ce que propose le standard.** Comptes et contacts, prospects, opportunités, devis, commandes, factures, catalogue (familles, unités, listes de prix), concurrents, connexions et rôles de connexion, activités.

**Logique de conception.** Chaque table porte une étape du cycle : le prospect se qualifie en opportunité, l’opportunité porte l’estimation et les produits, le devis porte l’engagement de prix, la commande porte l’accord. Les parties prenantes, les rôles de connexion et l’équipe commerciale décrivent les intervenants d’un projet et leur rôle : c’est la réponse standard à une table spécifique comme la « Toile projet » d’ARCHIFRIDAYS.

**Bonnes pratiques.**

- Un seul client potentiel par opportunité, les autres acteurs en parties prenantes.
- Utiliser les hiérarchies de comptes pour les groupes et filiales.
- Éviter les tables spécifiques qui doublonnent une structure standard, par exemple une Toile projet parallèle aux parties prenantes.

**Questions du PO.** Qui est le client du projet ? Que porte la Toile projet que les parties prenantes et les rôles de connexion ne portent pas ? Quelle table spécifique doublonne le standard, et que perd-on ?

**À retenir.** Une table spécifique parallèle aux parties prenantes, comme la Toile projet, prive Copilot, l’analyse des relations et les vues standard des intervenants du projet, et impose une double saisie.

## M4 · Gestion des leads et conversion

**Ce que propose le standard.** Prospects avec origine et campagne, détection des doublons, processus d’entreprise de qualification, disqualification avec motif, conversion en compte, contact et opportunité. Avec les licences adaptées : notation prédictive, accélérateur des ventes et séquences.

**Logique de conception.** Le prospect est une donnée non qualifiée, séparée des comptes et contacts pour ne pas polluer la base clients ; la conversion trace l’origine jusqu’au chiffre d’affaires.

**Bonnes pratiques.**

- Toujours renseigner la source et la campagne.
- Définir des critères de qualification partagés et courts.
- Disqualifier avec un motif plutôt que supprimer.

**Questions du PO.** Qui qualifie ? Quels critères ? Comment mesurer le retour sur investissement d’un salon ?

**À retenir.** Sans source ni campagne, aucune mesure du retour sur investissement marketing n’est possible.

## M5 · Opportunités, devis, commandes et factures

**Ce que propose le standard.** Processus d’entreprise de l’opportunité (Qualifier, Développer, Proposer, Conclure), produits d’opportunité et prix calculé ou saisi, devis avec révisions et modèles Word, génération de commande, table facture, clôture gagnée ou perdue avec motif.

**Logique de conception.** Le CRM porte l’engagement commercial ; l’ERP porte l’exécution (livraison, facturation, comptabilité). Les tables commande et facture existent pour les organisations sans ERP ou pour donner de la visibilité.

**Bonnes pratiques.**

- Calculer le chiffre d’affaires estimé à partir des produits quand le catalogue est fiable.
- Utiliser les révisions de devis plutôt que des copies.
- Décider explicitement de la frontière CRM / ERP.

**Questions du PO.** Où vit le calcul du prix ? La facture doit-elle être dans le CRM, ou seulement son statut ? Que perd-on avec un devis Excel ?

**À retenir.** La frontière CRM / ERP se décide, elle ne se subit pas.

## M6 · Interactions et intelligence relationnelle

**Ce que propose le standard.** Activités (e-mail, appel, rendez-vous, tâche) et chronologie, synchronisation côté serveur avec Exchange, complément pour Outlook, intégration Teams, assistant (cartes d’insights), analyse des relations, Copilot dans Sales, accélérateur des ventes et liste de travail.

**Logique de conception.** Les fonctions d’intelligence s’appuient sur les interactions capturées : plus la capture est automatique, plus les signaux (affaire silencieuse, contact clé absent) sont fiables.

**Bonnes pratiques.**

- Automatiser la capture des e-mails et rendez-vous plutôt que de demander la saisie.
- Définir des règles de confidentialité claires.
- Mettre à jour un contact qui change d’entreprise en conservant son historique.

**Questions du PO.** Quelles interactions capturer automatiquement ? Quel effort de saisie est acceptable pour un commercial terrain ?

**À retenir.** Un CRM sans e-mails ne voit pas les signaux faibles.

## M7 · Données, analytique et prévisions

**Ce que propose le standard.** Vues, graphiques, tableaux de bord, vue pipeline, objectifs, prévision native (hiérarchie, catégories, ajustements) et, avec les licences adaptées, prévision prédictive. Power BI pour les analyses transverses.

**Logique de conception.** La prévision native est au plus près des commerciaux : elle s’appuie directement sur les opportunités et garde la trace des ajustements des managers.

**Bonnes pratiques.**

- Lier la catégorie de prévision à une règle partagée (ou à l’étape).
- Construire l’historique de la prévision hors de la fonction (export ou API de prévision vers la data platform, rapport Power BI) pour mesurer la précision semaine après semaine.
- Garder dans Power BI ce qui croise d’autres sources (marge, ERP).

**Questions du PO.** Qui renseigne la catégorie ? Quels KPI natifs, quels KPI Power BI ? Les dates de clôture sont-elles crédibles ?

**À retenir.** Une prévision fiable repose sur la discipline des dates et des montants, plus que sur l’outil.

## M8 · Écosystème Microsoft et personnalisation

**Ce que propose le standard.** Teams et Outlook intégrés, Power Automate (flux, approbations), Power Apps (applications compagnons), Copilot Studio (agents), Power BI ; personnalisation des tables et colonnes dans des solutions, déployées par environnements.

**Logique de conception.** Trois niveaux de réponse : configuration, low-code, développement. Chacun a un coût de maintenance croissant et un propriétaire différent.

**Bonnes pratiques.**

- Chercher le besoin réel derrière la demande de colonne.
- Donner un propriétaire à chaque flux et application.
- Gérer les personnalisations en solutions, avec un cycle développement, test, production.

**Questions du PO.** Quel niveau de réponse pour chaque demande ? Qui maintient ? Quelles données maîtres restent dans l’ERP ?

**À retenir.** Low-code ne veut pas dire sans maintenance.

## M9 · Bonnes pratiques et retours d’expérience

**Erreurs fréquentes.** Répliquer l’ancien outil, ajouter une colonne par demande, multiplier les étapes des processus d’entreprise, laisser les données de référence sans propriétaire, négliger l’adoption.

**Arbre de décision « standard ou personnalisé ».**

1.  Le besoin est-il formulé comme un problème métier ?
2.  Le standard le couvre-t-il, même avec une autre licence ?
3.  Le processus peut-il s’adapter au standard ?
4.  Une configuration suffit-elle ?
5.  Une extension low-code est-elle possible, avec un propriétaire ?
6.  Le développement est-il justifié par la valeur ?

**Posture du PO.** Reformuler les demandes en problèmes, chiffrer le coût complet (construction et maintenance), arbitrer avec les métiers sur la valeur, s’appuyer sur l’architecte pour la cohérence et sur l’intégrateur pour la faisabilité.

**À retenir.** Rester proche du standard n’est pas renoncer au besoin : c’est choisir où l’entreprise investit sa différence.
