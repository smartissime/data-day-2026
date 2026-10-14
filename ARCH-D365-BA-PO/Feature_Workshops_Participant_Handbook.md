# Feature workshops: participant handbook

*Dynamics 365 Sales Enterprise in six demonstrations: business process flow, goals, sales accelerator, Copilot, forecasting, dashboards · What each feature is and why it matters to a Product Owner*

ARCHIA365

This handbook accompanies a 3-hour series of demonstrations on the ARCHIFRIDAYS demonstration environment. For each workshop it gives the concepts, the vocabulary in English and in French, why the feature matters, what to watch for during the demonstration, and the questions a Product Owner or Business Analyst should bring back to their own organisation. Nothing in it requires access to the environment: it is written to be read before, during and after the session.

## The setting

ARCHIFRIDAYS is a fictitious group of the electrical installation industry, with two sales channels: **Diffuse** (installers and distributors, handled by Julien Bernard for key accounts and Karim Haddad in the field) and **Project** (tertiary projects followed with specifiers, handled by Sophie Leroy). Claire Martin is the Sales Director France. The demonstration environment contains 18 accounts, 47 trade show leads, 12 fourth-quarter opportunities worth 2,170,000 € and one flagship project, **Campus Lumière**: three office buildings in Lyon, an electrical package worth 429,700 € at list price, a quote under negotiation at 20 % discount.

The trainer is signed in as a system administrator and as the manager of everyone in the company: what is shown is the complete picture. A seller sees only their own records and what is shared with them; one workshop shows that view.

| Time | Workshop                            | The question it answers                          |
|------|-------------------------------------|--------------------------------------------------|
| 0:10 | 1\. Business process flow           | How does the tool guide a seller through a sale? |
| 0:40 | 2\. Goals                           | How does a manager measure the quarter?          |
| 1:20 | 3\. Sales accelerator and sequences | How does nobody forget a lead?                   |
| 1:50 | 4\. Copilot and the assistant       | What does the AI layer add, and on what data?    |
| 2:15 | 5\. Forecasting                     | How does a manager commit a number?              |
| 2:40 | 6\. The manager’s dashboard         | How does it all fit on one screen?               |

## Workshop 1: business process flow

### The concept

A **business process flow** (flux de processus d’entreprise) is the bar of stages displayed at the top of a record. Each **stage** (étape) carries a few **data steps** (étapes de données), that is, fields to fill in; a data step marked as required blocks the **Next Stage** button until it is filled. **Conditions** create branches: depending on a field’s value, the process goes to one stage or another. Each process has its own **process table** that stores, for every record, the active stage, when it was entered, how long it has been active and the path traversed. A record can be moved from one process to another with **Switch Process**; the new process restarts at the first stage.

| English                               | French                                     | In one sentence                                          |
|---------------------------------------|--------------------------------------------|----------------------------------------------------------|
| Business process flow                 | Flux de processus d’entreprise             | The guided bar of stages on a record                     |
| Stage, data step                      | Étape, étape de données                    | A box of the bar, and a field asked in that box          |
| Condition                             | Condition                                  | A branch depending on a field value                      |
| Switch Process, Finish, Abandon       | Changer de processus, Terminer, Abandonner | Change, close or drop the process on a record            |
| Process table, Active Stage, Duration | Table du processus, Étape active, Durée    | Where the stage data lives for reporting                 |
| Pipeline Phase                        | Phase du pipeline                          | The opportunity column used by the standard funnel chart |

### Why it matters

The process is the part of the CRM that sellers see every day. A good one tells them what to do next and asks for the right information at the right time; a bad one, too long or too chatty, is bypassed within two weeks. For a Product Owner it is also a design tool: listing the stages and the fields asked at each one is the fastest way to decide which columns an opportunity really needs. Finally, the process table is the only reliable source for “how long do deals stay in each stage”, a question every sales director asks.

### What to watch for

- The standard process has four stages: Qualify, Develop, Propose, Close. Note which fields it asks for.
- The ARCHIFRIDAYS process adds a **Specification** stage only for the Project channel and a **Management approval** stage only when the discount exceeds 18 %. The same process produces four stages for Karim and six for Sophie.
- The blocking at Management approval is a reminder, not a lock: the seller could tick the box. Locking belongs to column security or to an approval flow.
- The chart “Opportunities by active stage” is built on the process table, not on the opportunity.

### Questions to bring back

1.  Is your sales process written somewhere, and do sellers recognise it in the tool?
2.  Which of your opportunity columns would be asked at a precise stage, and which at none? What does that say about the columns?
3.  One process with branches or one process per channel: what does each choice do to reporting and to vocabulary?
4.  Who owns the process, and what happens to open deals when a new version is published?

## Workshop 2: goals

### The concept

A **goal** (objectif) is a target for one person over one period, measured by a **goal metric** (métrique d’objectif). The metric defines what counts: for the standard **Revenue** metric, the **Actual** is the actual revenue of opportunities won in the period (by actual close date) and the **In-progress** is the estimated revenue of open opportunities (by estimated close date). The system **rolls up** the records owned by the **goal owner** and computes Actual, In-progress, Percentage Achieved and **Today’s Target** (the linear trajectory to date). Goals are organised in a tree: a **parent goal** consolidates its **child goals**; the option **Roll Up Only from Child Goals** prevents counting the manager’s own records twice. A **rollup query** restricts what is counted, for example to one product line.

| English                             | French                                          | In one sentence                                      |
|-------------------------------------|-------------------------------------------------|------------------------------------------------------|
| Goal, goal owner, manager           | Objectif, propriétaire, responsable             | The target, whose records count, who owns the record |
| Goal metric, rollup field           | Métrique d’objectif, champ de cumul             | What counts, and from which table and column         |
| Actual, In-progress, Today’s Target | Réalisé, En cours, Cible du jour                | The three computed figures                           |
| Parent goal, child goals            | Objectif parent, objectifs enfants              | The consolidation tree                               |
| Roll Up Only from Child Goals       | Cumul uniquement à partir des objectifs enfants | Avoids double counting on the parent                 |
| Rollup query                        | Requête de cumul                                | A filter on what counts                              |

### Why it matters

Targets usually live in a spreadsheet that one person updates by hand, with a definition of “achieved” that varies from one manager to the next. Native goals put the definition in one place (the metric), compute the figures automatically from the opportunities, and consolidate by hierarchy without any formula. The price is discipline: the opportunity owner, the actual close date and the estimated close date must be right, or the figures are wrong whatever the tool.

### What to watch for

- The expected figures after the import: Karim 202,000 € won (67 %) and 245,000 € in progress; Julien 0 won, 901,000 € in progress; Sophie 0 won, 907,700 € in progress.
- Sophie’s in-progress includes Campus Lumière at 429,700 €, the list price of the products, not the 343,760 € of the discounted quote: the goal reads the opportunity, not the quote.
- Karim’s in-progress includes an opportunity whose forecast category is Omitted: goals and forecasts do not share the same logic.
- The consolidated goal of the company shows 202,000 € won against 1,600,000 €: 12.6 %.

### Questions to bring back

1.  Where are your targets stored today, and who recalculates them?
2.  Is the “actual” the won opportunity, the order in SAP or the invoice? Which date counts?
3.  Which axis do you consolidate first: hierarchy, channel, region, product line?
4.  A goal counts the records of its owner. How do you handle a deal carried by two people?
5.  Which indicators will stay in Power BI (share of wallet, margin), and which can become native goals?

## Workshop 3: sales accelerator and sequences

### The concept

The **sales accelerator** (accélérateur des ventes) is a workspace that tells a seller what to do next. A **sequence** (séquence) is a scripted series of steps, emails, phone calls, tasks, waits and conditions, that is **connected** to records (leads or opportunities). The seller sees the next step in the **Up next** widget on the record and in the **work list** (liste de travail), sorted by due date. **Assignment rules** route new records to the right person or team according to criteria, and **segments** group records so that the right sequence is connected automatically.

| English                      | French                                    | In one sentence                            |
|------------------------------|-------------------------------------------|--------------------------------------------|
| Sales accelerator, work list | Accélérateur des ventes, liste de travail | The seller’s to-do, computed by the system |
| Sequence, step, connect      | Séquence, étape, connecter                | A scripted follow-up attached to records   |
| Up next                      | À suivre                                  | The next step shown on the record          |
| Assignment rule, segment     | Règle d’affectation, segment              | Automatic routing and grouping of records  |

Dynamics 365 Sales Enterprise includes the sales accelerator with limited capabilities; the full capacity, predictive lead scoring and conversation intelligence belong to Sales Premium.

### Why it matters

After a trade show, the question is not whether the leads are in the CRM but whether each one gets the same, timely follow-up. A sequence makes the follow-up explicit (what, when, in which order), visible (the manager sees where each lead stands) and measurable (how many leads completed the sequence, where they dropped). For the Product Owner, writing the sequence is a way to agree with sales and marketing on who does what after the lead lands.

### What to watch for

- The sequence “BâtiExpo installer follow-up”: email, wait, call, then a branch depending on whether the call was made.
- Thirty installer leads connected and assigned to Karim; his work list sorted by due date; the Up next widget on one lead.
- The difference between a sequence (what the seller does) and an assignment rule (who gets the record).
- What is greyed or absent in the Enterprise licence.

### Questions to bring back

1.  Who follows up the leads from a trade show today, and how do you know nobody was forgotten?
2.  What would your sequence contain for an installer, and for a specifier?
3.  Should the sequence be imposed, or should the seller be allowed to skip a step?
4.  Where does the Lead App to Eloqua to CRM path leave the lead, and when does the sequence start?

## Workshop 4: Copilot and the assistant

### The concept

**Copilot in Dynamics 365 Sales** is a conversational pane inside Sales Hub. It summarises a record (opportunity, lead, account), explains what changed recently, prepares a meeting, answers questions on the user’s records and drafts emails from the timeline. Every answer is built from the records the user can see, with citations; it does not know what is in Excel, in SAP or in a colleague’s head. The **assistant** (assistant, formerly relationship assistant) shows insight cards on the home page: close date approaching, no activity for a while, email not opened. In Sales Enterprise the standard cards and Copilot are included; **relationship analytics**, **who knows whom** and **conversation intelligence** belong to Sales Premium, and **Copilot for Sales** in Outlook and Teams is licensed separately.

| English                          | French                               | In one sentence                               |
|----------------------------------|--------------------------------------|-----------------------------------------------|
| Copilot pane, summary, catch-up  | Volet Copilot, résumé, récapitulatif | Ask, summarise, see what changed              |
| Email assist, Draft with Copilot | Aide à la rédaction d’e-mails        | A draft generated in the email editor         |
| Assistant, insight card          | Assistant, carte d’insight           | A suggestion on the home page                 |
| Citation                         | Citation                             | The record behind each sentence of the answer |

### Why it matters

The value of Copilot is time: a manager catches up on a deal in one question instead of reading nine activities. But Copilot only reflects the CRM: if activities are not logged, if quotes are built in Excel, if the owner is wrong, the summary is wrong or empty. For the Product Owner, Copilot is an argument for data discipline and a reason to decide, explicitly, where the AI should stay silent (discount rules, margins) and who checks generated emails against the commercial policy.

### What to watch for

- The summary of Campus Lumière and the citations it carries.
- “What’s changed in the last 30 days”: the quote revision and the October activities.
- The drafted email to Marc Duval, and the fact that it is a draft to be edited.
- The difference between the trainer’s answers (everything) and Karim’s answers (his own records only).

### Questions to bring back

1.  Which of these answers would have taken a seller ten minutes to assemble by hand?
2.  What must be true in the data for the summary to be right?
3.  Where should Copilot be silent in your organisation?
4.  Who validates a generated email before it goes to a customer?

## Workshop 5: forecasting

### The concept

A **forecast** (prévision) is a grid that adds up opportunities by **forecast category** (Pipeline, Best case, Committed, Omitted, Won) for a period, along a hierarchy. The **org chart forecast** follows the manager hierarchy: each seller has a line, each manager a consolidated line. A manager can **adjust** a figure (the opportunity is unchanged, the adjustment is recorded with a note); a seller changes the category on the opportunity itself, for example by dragging it in the **kanban** view. The **underlying records** behind each cell are one click away. Forecast snapshots are deprecated: history is kept by exporting the grid or by feeding Power BI.

| English                              | French                                              | In one sentence                                         |
|--------------------------------------|-----------------------------------------------------|---------------------------------------------------------|
| Forecast, forecast configuration     | Prévision, configuration de prévision               | The grid and its definition                             |
| Forecast category                    | Catégorie de prévision                              | The opportunity column the grid reads                   |
| Org chart forecast, top of hierarchy | Prévision par organigramme, sommet de la hiérarchie | Rollup by manager                                       |
| Adjustment                           | Ajustement                                          | The manager’s judgement, recorded apart from the record |
| Underlying records, kanban           | Enregistrements sous-jacents, kanban                | The deals behind the number, and a way to move them     |

### Why it matters

A forecast is a commitment, and a commitment needs a trail: who said what, when, and on which deals. The spreadsheet gives the number but not the trail. The native forecast gives both, separates the seller’s commitment (the category) from the manager’s judgement (the adjustment), and shows the deals behind every cell. The Product Owner’s decisions are which column feeds the forecast, which hierarchy it follows, and where the history will live.

### What to watch for

- The expected lines: Julien 611,000 € committed and 290,000 € pipeline; Sophie 697,700 € best case and 210,000 € pipeline; Karim 202,000 € won, 95,000 € pipeline, 150,000 € omitted.
- The adjustment on Sophie’s line, and the opportunity that does not change.
- Lycée Ampère dragged from Best case to Committed, and the opportunity that does change.
- Omitted is still open pipeline in the goals of workshop 2.

### Questions to bring back

1.  Who commits today: the seller, the manager, or the spreadsheet?
2.  Should an opportunity postponed to next year stay open as Omitted, or be closed and reopened?
3.  Does your forecast roll up by manager, by territory or by channel?
4.  What history do you need, and where will it live?

## Workshop 6: the manager’s dashboard

### The concept

A **dashboard** (tableau de bord) assembles tiles: charts built on views, lists, and, when the integration is enabled, Power BI tiles. Each chart tile drills down to the records behind a bar. Dashboards are personal or system, and can be shared. The forecast has its own page and is not a dashboard tile.

### Why it matters

The dashboard is where the previous workshops meet: goals (workshop 2), stage pipeline (workshop 1), the standard funnel, the deals closing soon, the activities due. It is also where the limits appear: anything that needs SAP data (share of wallet, margin, invoicing) is not a native tile and belongs to Power BI, which can sit on the same screen.

### What to watch for

- The six tiles of “Sales management Q4 2026 ARCHIFRIDAYS” and the drill-down from a bar to a record.
- Which tile is built on which table: goal, process table, opportunity, activity.
- The absence of a forecast tile and of any SAP-based indicator.

### Questions to bring back

1.  Which of these six tiles exist today in your organisation, and in which tool?
2.  Which indicator is missing, and does it need CRM data only, or SAP data too?
3.  Who maintains the dashboard when a view or a chart changes?

## Say it in English

- “The business process flow guides the seller; required data steps block Next Stage until they are filled.”
- “A goal rolls up the records owned by the goal owner, within the period, according to the metric.”
- “Child goals roll up into the parent goal; that is how we consolidate the team.”
- “A sequence connects a scripted follow-up to a lead; the work list tells the seller what is next.”
- “Copilot summarises what is in the CRM, with citations; it does not know what is in Excel.”
- “The forecast reads the forecast category; an adjustment is the manager’s judgement, recorded apart from the record.”
- “A dashboard tile drills down to the records behind the number.”

## Glossary of the figures used

| Figure      | Where it comes from                                                                                |
|-------------|----------------------------------------------------------------------------------------------------|
| 429,700 €   | Campus Lumière at list price (6 product lines)                                                     |
| 343,760 €   | Campus Lumière quote revision 1 at 20 % discount                                                   |
| 202,000 €   | Karim’s two won opportunities (Entrepôt Logisud 140,000 €, Hôtel Belvédère 62,000 €)               |
| 1,600,000 € | Sum of the three individual targets (700,000 + 600,000 + 300,000)                                  |
| 2,170,000 € | The 12 opportunities of the fourth quarter at estimated revenue (with Campus Lumière at 344,000 €) |
| 47 and 30   | Leads from BâtiExpo Lyon 2026, of which installers                                                 |
| 18 %        | Discount threshold above which Claire Martin’s approval is required                                |

## Notes

Use this space to write the sentence you would keep for each workshop: what you would adopt as standard, and what you would question for your own organisation. These sentences are collected at the wrap-up.

| Workshop                  | Keep as standard | Question for our organisation |
|---------------------------|------------------|-------------------------------|
| 1\. Business process flow |                  |                               |
| 2\. Goals                 |                  |                               |
| 3\. Sales accelerator     |                  |                               |
| 4\. Copilot               |                  |                               |
| 5\. Forecasting           |                  |                               |
| 6\. Dashboard             |                  |                               |
