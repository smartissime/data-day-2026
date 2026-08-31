# Formation ARCHIA365 : Dynamics 365 F&O, du On-Premises au Cloud

**Dates :** 25, 26, 27 août 2026 : 6 demi-journées : chaque demi-journée = Slot 1 (1 h 30) + pause 15 min + Slot 2 (1 h 30).
**Public :** experts on-premises (AX 2009 > AX 2012 R3 > AX 7 > D365 on-prem), environ 20 ans d'expérience.
**Référentiel :** cours officiel Microsoft MB-500T00 (decks 01 à 05), orientation Cloud renforcée + tiers Power Platform / Copilot.

## Contenu du dossier

### Supports de cours (6 decks PowerPoint)

| Fichier | Demi-journée | Contenu |
|---|---|---|
| DJ1_Paradigme_Cloud_Architecture_ALM.pptx | Mardi matin | Lignée AX>Cloud, One Version, architecture, LCS/PPAC, ALM |
| DJ2_Outils_Developpeur_Extensions.pptx | Mardi après-midi | Visual Studio, modèles, Azure DevOps, extensions données/UI |
| DJ3_Xpp_CoC_Tests_Integrations.pptx | Mercredi matin | X++ moderne, Chain of Command, frameworks, SysTest, OData/DMF |
| DJ4_Reporting_Securite_Performance_Migration.pptx | Mercredi après-midi | SSRS/ER, sécurité, Trace Parser, migration AX>Cloud |
| DJ5_PowerPlatform_Dataverse_PowerAutomate.pptx | Jeudi matin | Dataverse, dual-write, virtual tables, Power Automate |
| DJ6_PowerApps_PowerBI_IA_ALM.pptx | Jeudi après-midi | Power Apps, Power BI/Fabric, AI Builder, Copilot, solutions |

Chaque slide contient : le contenu autoporteur, la bande « Parallèle on-prem » (le pont AX > Cloud), et des **notes présentateur détaillées** (discours naturel + transitions) dans le volet Commentaires.

### Guides de démonstration (12 fichiers .md, UTF-8)

Fil rouge **ARC Delivery** : un besoin client (priorité de livraison) construit de bout en bout sur les 3 jours.

| Guide | Slot | Démo |
|---|---|---|
| D01_tour_tenant_cloud.md | DJ1-S1 | Tour du tenant, DemoHub, One Version |
| D02_lcs_ppac_alm.md | DJ1-S2 | LCS, Issue Search, Power Platform admin center |
| D03_modele_projet_runnable.md | DJ2-S1 | Modèle ARCDelivery, projet VS, runnable, check-in |
| D04_extension_table_formulaire.md | DJ2-S2 | Enum, EDT, extensions de table et de formulaire |
| D05_coc_event_handler.md | DJ3-S1 | Chain of Command + event handler |
| D06_systest_odata.md | DJ3-S2 | Tests SysTest + extension d'entité + OData |
| D07_securite_er.md | DJ4-S1 | Privilèges, devoir, rôle + Electronic Reporting |
| D08_trace_parser_optimisation.md | DJ4-S2 | Trace Parser, row-based vs set-based |
| D09_dualwrite_virtual_tables.md | DJ5-S1 | Dual-write, virtual tables |
| D10_flux_power_automate.md | DJ5-S2 | Flux d'alerte Teams (3 chemins de déclenchement) |
| D11_canvas_app_powerbi.md | DJ6-S1 | Canvas app ARC Priorités + Power BI |
| D12_ai_builder_copilot_solution.md | DJ6-S2 | AI Builder, Copilot, export de la solution |

Chaque guide contient : objectif, alignement MB-500, prérequis, pas à pas numéroté avec points de contrôle, parallèles on-prem, dépannage, et plans de secours pour les tenants d'essai.

## Environnements requis (expérience de développeur unifiée, UDE)

Les 12 guides sont écrits pour l'**expérience de développeur unifiée** : pas de machine virtuelle Tier-1, Visual Studio 2022 tourne sur le poste du formateur et se connecte à un environnement Cloud unifié (Dataverse + F&O dans le même environnement).

1. **Tenant ARCHIA365** (DemoHub All-in-One, Finance, SCM, Power Platform) : suffit pour D01, D02, D09 (exploration), D10, D11, D12.
2. **Un environnement de développement unifié** pour D03 à D08 :
   - type **Sandbox** obligatoire (un environnement Trial ne supporte pas le développement Visual Studio) ;
   - créé dans PPAC soit par le modèle ERP à la création, soit en installant sur un Sandbox existant « Finance and Operations Platform Tools » puis « Finance and Operations Provisioning App » avec **Enable Developer Tools** et **Enable Demo Data** (Contoso) ;
   - capacité minimale 1 Go (Operations + Dataverse) ; environ 1 heure par installation ; rôle System Administrator pour le formateur dans l'environnement.
3. **Poste du formateur** : Visual Studio 2022 (workload .NET Desktop + Modeling SDK), extension Power Platform Tools, métadonnées téléchargées (Tools > Download Dynamics 365 FinOps assets), Trace Parser installé (TraceParser.msi livré avec les métadonnées), 16 Go libres.
4. **Azure DevOps** : projet avec dépôt Git (recommandé) contenant le dossier des métadonnées locales.
5. **Teams** : un canal « ARC Delivery » pour la démo D10.

Chaque guide comporte des blocs **Contrôle visuel** décrivant ce qui doit être visible à l'écran (Visual Studio, client F&O, PPAC, maker portal) à chaque étape.

## Check-list formateur (la veille de chaque séquence)

- [ ] Licences du tenant actives ; connexion au DemoHub vérifiée
- [ ] Environnement unifié Sandbox opérationnel : URL F&O présente dans PPAC, données Contoso, rôle System Administrator
- [ ] Visual Studio connecté (Tools > Options > Power Platform Tools), Application Explorer ouvert, build + déploiement de contrôle passés
- [ ] Rôle System tracing user affecté (D08) ; Trace Parser lancé une fois
- [ ] État du fil rouge conforme à la fin de la séquence précédente (modèle, champ, règle, entité...)
- [ ] Table virtuelle Customers V3 (mserp) activée (D09) ; chemin de déclenchement D10 testé (A, B ou C)
- [ ] Canal Teams de démo accessible ; essai AI Builder activé
- [ ] Captures de secours à portée de main (D02 provisioning, D07-ER, D09 dual-write, D12-Copilot)
