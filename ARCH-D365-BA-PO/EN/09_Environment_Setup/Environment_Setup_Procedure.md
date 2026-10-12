# Demo Environment Setup Procedure

*Dynamics 365 Sales training, Product Owner / Business Analyst level · Step by step for a non-expert*

ARCHIA365

This procedure explains, step by step, how to prepare the Dynamics 365 Sales environment used during the two days of training. It is written for someone who has never administered Dynamics 365: each step states where to click, what to enter, how to check that it worked and what to do if it does not.

## Before you start

### What you are going to build

A Dynamics 365 Sales **Enterprise** environment (Hager’s licence), with no customisation, containing the fictitious company ARCHIFRIDAYS, its users, its product catalogue, its customers, its 47 trade show leads, its fourth-quarter pipeline and a few demo automations. All the data comes from the kit’s `05_Dataset` folder.

### Duration and schedule

| Phase | Content                                   | Deadline    | Estimated duration               |
|-------|-------------------------------------------|-------------|----------------------------------|
| A     | Accounts, tools and files                 | D-21        | 1 h                              |
| B     | Environment creation                      | D-15        | 1 h (plus the provisioning wait) |
| C     | Organisation and users                    | D-15        | 2 h                              |
| D     | Basic settings                            | D-14        | 1 h 30 min                       |
| E     | Data import                               | D-12        | 3 h                              |
| F     | Manual entries (quotes, activities)       | D-11        | 2 h                              |
| G     | Features demonstrated, episode by episode | D-10 to D-7 | 5 h                              |
| H     | Rehearsal and checks                      | D-5         | 3 h                              |
| I     | Reset before the session                  | D-1         | 1 h                              |

Allow three working days in total, spread over three weeks. Do not start later than D-15: a trial environment usually lasts 30 days, and some features take several hours to become active.

### How to read each step

- **Where:** the path in the interface, in the form `Application > Area > Menu`.
- **Do:** the numbered actions.
- **Enter:** the exact values (copy them from the dataset).
- **Check:** what you should see if the step worked.
- **If it fails:** the most frequent cause and the fix.

> **Important.** Microsoft updates the interface twice a year. If a menu is not exactly where stated, use the search box at the top of the page (or the settings search) with the English name given in this procedure, for example “Business units”. English names are stable from one release to the next. When the session is delivered in French, the French label is given in parentheses the first time a major menu appears.

### Addresses you need

| Tool                        | Address                                                                | What it is for                                                   |
|-----------------------------|------------------------------------------------------------------------|------------------------------------------------------------------|
| Microsoft 365 admin center  | admin.microsoft.com                                                    | Create users and assign licences                                 |
| Power Platform admin center | admin.powerplatform.microsoft.com                                      | Create the environment, business units, security, email settings |
| Power Apps (maker portal)   | make.powerapps.com                                                     | Columns, solutions, Power Apps app                               |
| Power Automate              | make.powerautomate.com                                                 | Discount approval flow                                           |
| Sales Hub app               | link shown in the environment (Power Platform \> Environments \> Open) | All the data and most Sales settings                             |

## Phase A: accounts, tools and files (D-21)

### A1. Gather the access rights

**Do:**

1.  Get a Microsoft work account (not a personal Outlook.com or Hotmail account). If you do not have one, signing up for the Dynamics 365 Sales trial creates one.
2.  Check that you can be **Global administrator** of the trial tenant (this is the case if you create the trial yourself).
3.  If you want to demonstrate email synchronisation (episode 6), also plan a Microsoft 365 trial (for example Business Standard or E3) in the **same** tenant, so that you have Exchange Online mailboxes. Otherwise, this demo will be shown with screenshots.

**Check:** you can sign in to admin.microsoft.com with this account.

### A2. Prepare your computer

**Do:**

1.  An up-to-date Microsoft Edge or Google Chrome browser; a private browsing window will be used to sign in as a second user.
2.  Microsoft Word and Excel installed (desktop), for the quote template and the workshop workbooks.
3.  Power BI Desktop (free) if you prepare the forecast history report (step G13).
4.  Unzip the kit into a local folder, for example `C:\Training_D365_Sales`.

**Check:** you can open `05_Dataset/Dataset_ARCHIFRIDAYS.xlsx` without error, and the `CSV_Dataverse_import` folder contains 14 files.

### A3. Prepare a logbook

Create a document in which you record, as you go: the environment address, the demo users’ credentials, and every problem you meet. It will help you during the session and for the reset.

## Phase B: environment creation (D-15)

### B1. Start the Dynamics 365 Sales trial

**Where:** Microsoft Dynamics 365 website, Sales page, **Free trial** button.

**Do:**

1.  Choose the **Dynamics 365 Sales** trial (Sales Enterprise).
2.  Sign in with the account from step A1, or create one.
3.  Select **France** as the country.
4.  Wait for provisioning to finish (from a few minutes to an hour). An environment is created automatically.

**Check:** in admin.powerplatform.microsoft.com, **Environments** menu (Environnements), an environment of type “Trial” appears with the state “Ready”.

**If it fails:** if no environment appears, go to step B2 and create one yourself.

### B2. (If needed) create the environment manually

**Where:** Power Platform admin center \> Environments \> **New**.

**Enter:**

| Field                      | Value                                                     |
|----------------------------|-----------------------------------------------------------|
| Name                       | ARCHIFRIDAYS D365 Sales Demo                              |
| Region                     | Europe                                                    |
| Type                       | Trial                                                     |
| Add a Dataverse data store | Yes                                                       |
| Language                   | English (or French if the session is delivered in French) |
| Currency                   | **EUR**                                                   |
| Enable Dynamics 365 apps   | Yes, then select **Sales Enterprise**                     |

**Check:** the environment moves to the “Ready” state.

> **Watch out.** The base currency **cannot be changed** after creation. Check that it is the euro (EUR) before confirming.

### B3. Open Sales Hub and set your preferences

**Where:** Power Platform admin center \> Environments \> your environment \> **Open**, then the **Sales Hub** app.

**Do:**

1.  Click the gear icon at the top right \> **Personalization settings** (Paramètres de personnalisation).
2.  **General** tab: time zone **(UTC+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna** or **(UTC+01:00) Brussels, Copenhagen, Madrid, Paris**, currency **Euro**.
3.  **Formats** tab: **English (United Kingdom)** if the session is delivered in English, **French (France)** if it is delivered in French (both display dates as dd/mm/yyyy).
4.  **Languages** tab: user interface language matching the session language.

**Check:** dates are displayed as 16/11/2026.

**If it fails:** if the language you want is not offered, enable it in Power Platform \> Environment \> Settings \> **Languages**, then wait a few minutes.

### B4. Record the environment information

Record in your logbook: the environment name, the Sales Hub address (copy it from the address bar) and the trial end date (visible on the environment page).

## Phase C: organisation and users (D-15)

### C1. Rename the root business unit and create the other units

**Where:** Power Platform admin center \> Environments \> your environment \> **Settings** (Paramètres) \> **Users + permissions** (Utilisateurs + autorisations) \> **Business units** (Unités commerciales).

**Do:**

1.  Open the root business unit (the one named after the organisation) and rename it **ARCHIFRIDAYS headquarters (Obernai)**.
2.  Click **New** and create the following units, respecting the parent.

**Enter:**

| Business unit                          | Parent business unit                |
|----------------------------------------|-------------------------------------|
| France sales management (Paris)        | ARCHIFRIDAYS headquarters (Obernai) |
| South-East region                      | France sales management (Paris)     |
| ARCHIFRIDAYS Deutschland (Blieskastel) | ARCHIFRIDAYS headquarters (Obernai) |

**Check:** the list shows 4 units; South-East region has France sales management (Paris) as its parent.

### C2. Create the users and assign licences

**Where:** admin.microsoft.com \> **Users** \> **Active users** \> **Add a user**.

**Enter:** one user per persona from the `01_Users_and_teams` tab.

| First name | Last name | Suggested user name | Licence                                                    |
|------------|-----------|---------------------|------------------------------------------------------------|
| Claire     | Martin    | claire.martin@      | Dynamics 365 Sales Enterprise                              |
| Julien     | Bernard   | julien.bernard@     | Dynamics 365 Sales Enterprise                              |
| Sophie     | Leroy     | sophie.leroy@       | Dynamics 365 Sales Enterprise (+ Microsoft 365 for emails) |
| Karim      | Haddad    | karim.haddad@       | Dynamics 365 Sales Enterprise                              |
| Nadia      | Benali    | nadia.benali@       | Dynamics 365 Sales Enterprise                              |
| Émilie     | Roux      | emilie.roux@        | Dynamics 365 Sales Enterprise                              |
| Lucas      | Fontaine  | lucas.fontaine@     | Dynamics 365 Sales Enterprise                              |
| Anna       | Becker    | anna.becker@        | Dynamics 365 Sales Enterprise                              |
| Thomas     | Petit     | thomas.petit@       | Dynamics 365 Sales Enterprise                              |

**Do:** for each user, record the temporary password in your logbook.

**Check:** after 10 to 30 minutes, the 9 users appear in Power Platform \> your environment \> Settings \> Users + permissions \> **Users**.

**If it fails:** if you do not have enough trial licences, create at least **Claire Martin, Sophie Leroy and Thomas Petit** with a licence; you will own the other records and state the owner verbally. If a user does not appear in the environment, open the user list and click **Add user** to synchronise them.

### C3. Assign each user to their business unit and manager

**Where:** Power Platform \> your environment \> Settings \> Users + permissions \> Users \> select the user.

**Do:**

1.  **Change business unit**: choose the unit from the table below.
2.  Open the user’s full record (link to the record in Sales Hub, or “Manage users in Dynamics 365”) and fill in the **Manager** field.

**Enter:**

| User           | Business unit                          | Manager       |
|----------------|----------------------------------------|---------------|
| Claire Martin  | France sales management (Paris)        | (none)        |
| Julien Bernard | France sales management (Paris)        | Claire Martin |
| Lucas Fontaine | France sales management (Paris)        | Claire Martin |
| Sophie Leroy   | South-East region                      | Claire Martin |
| Karim Haddad   | South-East region                      | Claire Martin |
| Anna Becker    | ARCHIFRIDAYS Deutschland (Blieskastel) | Claire Martin |
| Nadia Benali   | ARCHIFRIDAYS headquarters (Obernai)    | Claire Martin |
| Émilie Roux    | ARCHIFRIDAYS headquarters (Obernai)    | Claire Martin |
| Thomas Petit   | ARCHIFRIDAYS headquarters (Obernai)    | (none)        |

**Check:** on Sophie Leroy’s record, the Manager field shows Claire Martin.

> **Watch out.** Changing a user’s business unit removes their security roles. Assign the roles (step C4) **after** this change.

### C4. Assign the security roles

**Where:** Power Platform \> your environment \> Settings \> Users + permissions \> Users \> select the user \> **Manage security roles** (Gérer les rôles de sécurité).

**Enter:**

| User                               | Roles                                                             |
|------------------------------------|-------------------------------------------------------------------|
| Claire Martin                      | Sales Manager, Basic User                                         |
| Julien, Sophie, Karim, Lucas, Anna | Salesperson, Basic User                                           |
| Nadia Benali                       | Salesperson, Basic User (the Marketing Manager role if it exists) |
| Émilie Roux                        | Salesperson, Basic User                                           |
| Thomas Petit                       | System Customizer, Salesperson                                    |
| You (trainer)                      | System Administrator                                              |

**Check:** sign in as Sophie Leroy in a private window: Sales Hub opens and shows the Sales site map.

**If it fails:** “You do not have access to this app” means the licence (C2) or the role (C4) is missing.

### C5. Enable the manager hierarchy

**Where:** Power Platform \> your environment \> Settings \> Users + permissions \> **Hierarchy security** (Sécurité de la hiérarchie).

**Do:**

1.  Select **Enable hierarchy modeling**.
2.  Choose the **Manager hierarchy** model.
3.  Depth: **3**. Save.

**Check:** signed in as Claire, you will see Sophie’s opportunities after the import (check repeated in H1).

### C6. Create the teams

**Where:** Power Platform \> your environment \> Settings \> Users + permissions \> **Teams** (Équipes) \> **Create team**.

**Enter:** teams of type **Owner**, useful to illustrate the sales channels.

| Team            | Business unit                   | Members                                   |
|-----------------|---------------------------------|-------------------------------------------|
| Diffuse channel | France sales management (Paris) | Julien Bernard, Karim Haddad, Anna Becker |
| Project channel | France sales management (Paris) | Sophie Leroy                              |

**Check:** both teams appear with their members. (The access team on Groupe Distelec is created in step G1.)

## Phase D: basic settings (D-14)

### D1. Fiscal year (required for goals and forecasting)

**Where:** Sales Hub \> gear icon \> **Advanced settings** (Paramètres avancés) \> Settings \> **Business Management** (Gestion d’entreprise) \> **Fiscal Year Settings**.

**Enter:** start date **01/01/2026**; period template **Quarterly**; fiscal year name based on the start year; display “Q” + number.

**Check:** the window closes without an error message.

> **Watch out.** This setting is hard to change once goals have been created. Do it before phase G.

### D2. Duplicate detection

**Where:** Power Platform \> your environment \> Settings \> **Data management** (Gestion des données) \> **Duplicate detection settings**, then **Duplicate detection rules**.

**Do:**

1.  In the settings: select **Enable duplicate detection**, as well as “When a record is created or updated” and “During data import”.
2.  In the rules: check that the following standard rules are **Published**; otherwise, select them and click **Publish**:
    - leads with the same email address;
    - contacts with the same email address;
    - accounts with the same account name.
3.  If needed, add a “Lead with same email as Contact” rule: base record type Lead, matching record type Contact, criterion Email = Email.

**Check:** the rules show the “Published” status.

### D3. Product catalogue settings

**Where:** Sales Hub \> bottom left, change area to **App Settings** (Paramètres de l’application) \> **Product Catalog** \> **Product Catalog Settings**.

**Enter:** “Create products in active state”: **Yes**; “Allow selection of products without a price list”: **No**.

**Check:** save; no error message. With this setting, imported products are immediately usable (otherwise you would have to **Publish** them one by one).

### D4. Connection roles

**Where:** Sales Hub \> Advanced settings \> Settings \> **Business Management** \> **Connection Roles**. If this menu has disappeared, search for “Connection roles” in the settings search.

**Do:** create the following roles, category **Sales**, selecting the record types **Account**, **Contact** and **Opportunity**.

| Role                          | Description                                                                |
|-------------------------------|----------------------------------------------------------------------------|
| Project owner                 | Decides on and funds the project                                           |
| Specifier                     | Engineering consultancy or architect who influences the choice of products |
| Installer holding the package | Installer who carries out the work package                                 |
| Delivering distributor        | Distributor who delivers to and invoices the installer                     |

**Check:** the 4 roles appear in the list. They will be used in the Campus Lumière stakeholders (step F2).

### D5. Lead source and campaign

**Where:** Sales Hub \> Marketing area \> **Campaigns**.

**Do:** create the **BâtiExpo Lyon 2026** campaign (type Trade Show, start date 08/09/2026, end date 10/09/2026) and activate it.

**If it fails:** if the Campaigns menu does not exist in your version, do not get stuck: during the lead import (step E7), leave the “Source campaign” column unmapped and add the trade show name in the description. You will explain it verbally in episode 4.

## Phase E: data import (D-12)

### E1. How the import wizard works

You will import the CSV files from the `CSV_Dataverse_import` folder, one by one, **in order**. The method is always the same:

1.  In Sales Hub, open the corresponding list (for example **Accounts**).
2.  On the command bar, click **Import from CSV** (Importer à partir d’Excel / CSV). If the button is not visible, open the “…” menu (More commands).
3.  Choose the CSV file, then **Next**.
4.  Options screen: field delimiter **Semicolon** (;), data delimiter **Quotation mark**, UTF-8 encoding if asked.
5.  Mapping screen: check that each column in the file is linked to the right Dynamics 365 column. For the trainer help columns (Profile, Booth note, Expected handling in training, Role in the scenario), choose **Ignore** or map them to Description.
6.  Start the import and wait: follow progress in **Advanced settings \> Data Management \> Imports**.

**General check:** each import must show 0 failures. If there are failures, open the import and the **Failures** tab to read the cause.

**If it fails:** the most frequent failure is an **unresolved lookup**: the value (for example the parent account name) does not exist yet or is spelt differently. Import the referenced record first, then run the import again.

### E2. Unit groups (file 02)

**Where:** App Settings \> Product Catalog \> **Unit Groups** (Groupes d’unités). Manual creation is simpler than importing for 3 rows.

**Enter:**

| Unit group | Primary unit     |
|------------|------------------|
| Equipment  | Unit             |
| Services   | Day              |
| Contracts  | Station per year |

**Check:** each group shows its primary unit.

### E3. Families and products (file 03)

**Where:** App Settings \> Product Catalog \> **Families & Products** (Familles et produits).

**Do:**

1.  Create 4 **families**: Power distribution, Building management, E-mobility, Services.
2.  Create the 6 **products** in their family (manual creation recommended, or import file 03).

**Enter:**

| Product ID  | Name                                      | Family              | Unit group | Default unit     |
|-------------|-------------------------------------------|---------------------|------------|------------------|
| DE-TGBT-630 | Main low voltage switchboard (TGBT) 630 A | Power distribution  | Equipment  | Unit             |
| DE-TD-250   | Distribution board 250 A                  | Power distribution  | Equipment  | Unit             |
| GTB-SUP-MB  | Multi-building BMS monitoring pack        | Building management | Equipment  | Unit             |
| ME-BRN-2X22 | Dual charging station 2 x 22 kW           | E-mobility          | Equipment  | Unit             |
| SV-MES-J    | On-site commissioning                     | Services            | Services   | Day              |
| SV-MNT-BRN  | Charging station maintenance contract     | Services            | Contracts  | Station per year |

**Check:** the products are in the **Active** state (thanks to D3). Otherwise, open each product and click **Publish**.

### E4. Price lists and price list items (files 04 and 05)

**Where:** App Settings \> Product Catalog \> **Price Lists** (Listes de prix).

**Do:**

1.  Create the 3 price lists (currency Euro, from 01/01/2026 to 31/12/2026): **2026 public price list**, **Distributor framework price list**, **Project price list**.
2.  In each list, **Price List Items** tab, add the 6 products with their unit and the amount from file 05. Example for the 2026 public price list:

| Product                         | Unit             | Amount   |
|---------------------------------|------------------|----------|
| TGBT 630 A                      | Unit             | 18,500 € |
| Distribution board 250 A        | Unit             | 4,200 €  |
| BMS monitoring pack             | Unit             | 48,000 € |
| Dual charging station 2 x 22 kW | Unit             | 2,900 €  |
| Commissioning                   | Day              | 950 €    |
| Charging station maintenance    | Station per year | 180 €    |

3.  Open each product and set **Default Price List** = 2026 public price list.

**Check:** the 2026 public price list contains 6 items. The other two contain 6 each (amounts at 68% and 85% of the public price list, see file 05).

### E5. Accounts (file 06)

**Do:**

1.  Open file 06 in Excel and **save a copy** containing all the rows **except** Distelec Sud-Est (file A), then a copy with **only** Distelec Sud-Est (file B).
2.  Import file A into **Accounts**. At the mapping step: Account name, Relationship type, City, ZIP/Postal code, Main phone, Website, Description; “Owner” to Owner if the users exist, otherwise Ignore; “Industry” to Industry or Description.
3.  Import file B: the “Parent account” column maps to **Parent Account**.

**Check:** 18 accounts; the Distelec Sud-Est record shows Groupe Distelec as its parent account.

**Mapping the “Relationship type” values.** The wizard displays a value mapping screen, because some values in the file (Customer, Competitor, Specifier, Distributor) do not exist in the standard list. Choose: Customer → **Customer**; Competitor → **Competitor**; Specifier → **Influencer**; Distributor → **Reseller**. Note this choice: it is a good example for the “standard or custom” discussion in episode 3.

**If it fails:** if the mapping screen does not appear and the import fails on this field, map the column to Ignore and set the type manually on the 6 key accounts of the running case (Vitalis, Kelvin, Atelier Brunel, ERS, Groupe Distelec, Distelec Sud-Est).

### E6. Contacts and competitors (files 07 and 08)

**Do:**

1.  Import file 07 into **Contacts**: “Account name” maps to **Company Name**, which is a lookup to the account. “Role in the scenario”: Ignore or Description.
2.  Create the 2 competitors in **Competitors** manually: NovaVolt and Elektra Systems, with the strengths and weaknesses from file 08.

**Check:** 18 contacts, each linked to their account; Inès Garnier is linked to **Kelvin Ingénierie** (she will move to Vitalis during episode 6; do not do it now).

### E7. The 47 trade show leads (file 09)

The file `09_Leads_BatiExpo` simulates the real flow: capture at the trade show with the Lead App, transit through Eloqua, arrival in the CRM.

**Do:**

1.  **Temporarily disable** duplicate detection “during data import” (D2), otherwise the import will deliberately reject the Inès Garnier duplicate that you need for the demo.
2.  Import file 09 into **Leads**. Mapping: Topic, First name, Last name, Company name, Job title, Email, Business phone, City, **Lead source** (if the value is not recognised, the wizard offers to map it to an existing value: choose **Trade Show**), Source campaign (if D5 worked); the three help columns to Ignore or Description.
3.  Re-enable duplicate detection during data import.

**Check:** 47 open leads; two leads Inès / Ines Garnier exist; the student (INSA Lyon) and the NovaVolt employee are present (they will be disqualified live).

> **Watch out.** Do **not** qualify or disqualify any lead during preparation: these are demo actions.

### E8. Pipeline opportunities (file 10)

**Do:**

1.  Import file `10_Opportunities_Q4` into **Opportunities**. Mapping: Topic, **Potential Customer** (lookup to the account), Owner, Est. revenue, Probability, **Forecast category**, Est. close date.
2.  The “Process stage” column cannot be imported directly: note it and adjust the stage manually (E9).

**Check:** 12 opportunities. The two “Won” deals (Entrepôt Logisud, Hôtel Belvédère) are still open: you will close them in F4.

### E9. Move each opportunity to the right stage

**Do:** open each opportunity and, in the business process flow bar (at the top of the record), click **Next Stage** until you reach the stage in file 10 (Qualify, Develop, Propose, Close). Fill in the required fields requested along the way with plausible values.

**Check:** in the “My Open Opportunities” view, the stage column matches file 10.

> **Watch out.** For Campus Lumière, leave “Revenue” in **System Calculated** mode: the amount will come from the products added in F1. For the others, leave the “User Provided” mode.

### E10. Goals (file 14)

The goals (file `14_Goals_Q4`) are created in phase G (step G7), after the fiscal year.

## Phase F: manual entries (D-11)

### F1. Products of the Campus Lumière opportunity

**Where:** Sales Hub \> Opportunities \> Campus Lumière, electrical package.

**Do:**

1.  **Price List** field: 2026 public price list.
2.  **Revenue** field: System Calculated.
3.  **Products** tab: add the 6 lines.

**Enter:**

| Product                         | Quantity | Expected amount |
|---------------------------------|----------|-----------------|
| TGBT 630 A                      | 3        | 55,500 €        |
| Distribution board 250 A        | 24       | 100,800 €       |
| BMS monitoring pack             | 1        | 48,000 €        |
| Dual charging station 2 x 22 kW | 60       | 174,000 €       |
| Commissioning                   | 20       | 19,000 €        |
| Charging station maintenance    | 180      | 32,400 €        |

**Check:** **Est. revenue** shows **429,700 €**.

**Then do:** the same on **Entrepôt Logisud** with file `11_Opportunity_products`: TGBT x 2, distribution board x 12, dual charging station x 20, commissioning x 8, that is 153,000 € at the public price list.

### F2. Campus Lumière stakeholders and competitors

**Do:** in the Campus Lumière opportunity:

1.  **Stakeholders** tab or section: add Marc Duval (role Project owner or Decision maker), Inès Garnier (Specifier), Léa Brunel (Specifier), Paul Lefèvre (Installer holding the package), Sandrine Morel (Delivering distributor).
2.  **Competitors** section: add NovaVolt and Elektra Systems.
3.  **Sales team** section: add Julien Bernard and Karim Haddad.

**Check:** the three sections are filled in. The potential customer must be **Vitalis Immobilier** and nothing else.

### F3. Campus Lumière quote: V1 then revision V2

**Do:**

1.  From the opportunity, **Quotes** tab \> **New Quote**. The products are copied from the opportunity.
2.  Set **Quote Discount (%)** = **15**. Save. The total must be **365,245 €**.
3.  Click **Activate Quote**. Note its number.
4.  Click **Revise**: revision 1 opens as a draft. Discount = **20**. Expected total: **343,760 €**. Activate it.

**Check:** the opportunity’s Quotes tab shows revision 0 closed (revised) and revision 1 active.

> **Watch out.** Do not mark this quote as won: Campus Lumière must stay at the Propose stage for episodes 6 and 7.

### F4. Entrepôt Logisud: won quote and order (end-of-cycle demo)

**Choice to make:** either you prepare everything now (safer), or you keep the last two actions for the live demo in episode 5 (more engaging). Recommendation: prepare the activated quote and keep “Won” and “Create Order” for the live demo.

**Do:**

1.  From Entrepôt Logisud, create a quote with a discount of **8.5%** (total 139,995 €) and activate it.
2.  (Live or now) on the activated quote, click **Create Order**: Dynamics 365 then offers to close the quote as won and, if you wish, to close the opportunity as won. Accept.
3.  Close Hôtel Belvédère as **Won** (**Close as Won** button), actual date 22/10/2026.

**Check:** in the closed opportunities view, Hôtel Belvédère (and Entrepôt Logisud if done) appear as won.

### F5. Campus Lumière activities (file 13)

**Do:** in the Campus Lumière opportunity, **Timeline** tab (Chronologie), create the 9 activities from file `13_Activities_Campus_Lumiere` (appointments, phone calls, emails, task), with the date from the file, the contact concerned and the status.

**Enter:** the first 8 activities are **completed** (Mark complete); the task “Follow up with Marc Duval on the decision timeline” (due 02/11/2026) stays **open**.

> **Watch out.** Do **not** add any activity dated after 26/10/2026: the 21-day silence is the subject of episode 6. Emails can be created as email activities without being sent (save them, then mark them as completed).

**Check:** the timeline shows 9 items, the most recent being quote V2 of 26/10.

**If it fails:** the timeline may sort activities by creation date rather than by due date. If the order is not meaningful, show the **Activities** view filtered on Campus Lumière and sorted by due date.

## Phase G: features demonstrated, episode by episode (D-10 to D-7)

### G1. Episode 2: access team and column security

**Access team on Groupe Distelec:**

1.  **Where:** make.powerapps.com \> your environment \> **Tables** \> **Account** \> **Properties** \> Advanced options: select the option for **Access teams**. It is often already active for Account. Save.
2.  Sales Hub \> Advanced settings \> Settings \> **Templates** \> **Access Team Templates** \> New: name **Distelec account team**, entity Account, rights Read, Write, Append.
3.  Add the “Team members” subgrid to the account form if it does not exist (a step for a customiser; otherwise, show the principle with a screenshot).
4.  On the Groupe Distelec account, add Sophie Leroy to the access team.

**Protected discount column:**

1.  **Where:** make.powerapps.com \> **Solutions** \> New solution **ARCHIFRIDAYS Demo** (publisher: ARCHIA365).
2.  In the solution: **Add existing** \> Table \> Account, then **New column**: name **Framework agreement discount rate**, type Decimal number, and in the advanced options, select **Enable column security**.
3.  Add the column to the main account form and publish.
4.  **Where:** Power Platform \> Settings \> Users + permissions \> **Column security profiles** (Profils de sécurité de colonne) \> New: **Framework agreement discounts**, members Claire Martin and Julien Bernard, Read and Update permission on the column.
5.  On Groupe Distelec, enter **32** in Framework agreement discount rate.

**Check:** signed in as Sophie, the column shows a padlock and no value; signed in as Julien, it shows 32.

> **Watch out.** This is the only customisation in the environment; it is there to show a standard mechanism. Tell the participants so.

### G2. Episode 3: nothing more to prepare

The connection roles (D4), stakeholders and competitors (F2) are enough. Just prepare a screenshot of the stakeholder diagram (running case) as a fallback.

### G3. Episode 4: duplicates, qualification and sequence

**Preparation checks:**

1.  Open the “Ines Garnier” lead (without the accent): a duplicate banner or message must appear on save. Do not merge.
2.  Check that the **Lead to Opportunity Sales Process** business process flow is active: Advanced settings \> Settings \> **Processes**, filter “Business Process Flow”.

**Sales accelerator sequence:**

1.  **Where:** Sales Hub \> App Settings \> **Sales accelerator** (Accélérateur des ventes) \> **Quick setup / Workspace settings**: enable the accelerator for the Salesperson and Sales Manager roles.
2.  **Where:** App Settings \> **Sequences** \> New sequence: name **Trade show installer follow-up**, record type Lead.
3.  Steps: **Email** (D0, “Thank you for visiting us at BâtiExpo”), **Wait 3 days**, **Phone call** (“Offer charging station training”), **Wait 4 days**, **Email** (“Invitation to an installer morning”). Activate.
4.  Connect the sequence to 3 or 4 installer leads, with Karim Haddad as owner.

**Check:** signed in as Karim, the **Work list** shows actions to carry out.

**If it fails:** the accelerator is included in Sales Enterprise with some limits that change over time; if the menu is missing or locked, prepare screenshots. **Predictive lead scoring** is Premium: show it with screenshots (outside Hager’s licence).

### G4. Episode 5: quote template

**Simple option (recommended for a non-expert):** use the standard Word quote template if it exists: open a quote \> **Word Templates** menu. Check that the document is generated.

**Full option:**

1.  Open a quote \> **Word Templates** \> **Create Word Template** \> choose Quote and the quote products (Quote Product) \> download the file.
2.  In Word, show the **Developer** tab (File \> Options \> Customize Ribbon), open the **XML Mapping** pane, insert the fields (number, customer, lines, total), add the fictitious ARCHIFRIDAYS logo.
3.  Save, then upload the template in Sales Hub (Advanced settings \> Templates \> Document Templates).

**Check:** from the Campus Lumière quote V2, the template generates a Word document showing 343,760 €.

### G5. Episode 6: emails, Outlook and Copilot

**Server-side synchronisation (only if you have Exchange Online, step A1):**

1.  **Where:** Power Platform \> Settings \> **Email** \> **Mailboxes** (Boîtes aux lettres): open Sophie Leroy’s mailbox.
2.  Click **Approve Email**, then **Test & Enable Mailbox**.
3.  Wait until the incoming and outgoing email status is **Success**.

**Outlook add-in:**

1.  **Where:** Power Platform \> Settings \> Integration \> **Dynamics 365 App for Outlook**: add Sophie Leroy.
2.  In Sophie’s Outlook on the web, send yourself an email “Inès Garnier, new address at Vitalis” to track live.

**Copilot:**

1.  **Where:** Sales Hub \> App Settings \> **Copilot** (or “Copilot features”): enable Copilot in Dynamics 365 Sales for the sales roles.
2.  If Copilot stays unavailable, check in Power Platform \> Environment \> Settings \> **Features** the options for generative AI and data movement across regions.

**Check:** on Campus Lumière, the Copilot pane offers a summary of the opportunity.

**If it fails:** without Exchange, or without Copilot in your region, prepare screenshots. **Relationship analytics** is Premium: screenshots only. **Assistant** cards depend on rules and delays; in a recent environment they may not appear: use screenshots as a fallback.

### G6. Episode 6: Teams

**Where:** Sales Hub \> App Settings \> **Chat and collaborate** (Discuter et collaborer) or **Microsoft Teams integration**.

**Do:** enable the basic collaboration experience, then, from Campus Lumière, use **Collaborate** to create a linked Teams channel.

**Check:** the opportunity shows the connected channel. Without Teams in the tenant, use screenshots.

### G7. Episode 7: goals

**Where:** Sales Hub \> Performance area \> **Goals** (Objectifs).

**Do:** create 3 goals, metric **Revenue**, period **Q4 2026**, amounts from file `14_Goals_Q4`.

| Owner          | Target    |
|----------------|-----------|
| Sophie Leroy   | 700,000 € |
| Julien Bernard | 600,000 € |
| Karim Haddad   | 300,000 € |

Then click **Recalculate**.

**Check:** Karim’s goal shows an actual of 202,000 € (Logisud and Belvédère won) once F4 is complete.

### G8. Episode 7: forecast

**Where:** Sales Hub \> App Settings \> Performance management \> **Forecast configuration** (Configuration de la prévision) \> **New**.

**Do:**

1.  Template: **Org chart forecast**.
2.  Name: **South-East forecast Q4 2026**; hierarchy: top user **Claire Martin**.
3.  Period: **Quarterly**, start **Q4 2026**, number of periods 1 or 2.
4.  Columns: keep the standard columns linked to the **forecast category**: Pipeline, Best case, Committed, Won, Omitted, and add the **Quota** column linked to the goals from G7 if the wizard offers it.
5.  Activate the forecast, then open it in Sales Hub \> Performance \> **Forecasts** and click **Recalculate**.

**Check:** for Claire, the “Won” total is 202,000 € and “Committed” 611,000 €; Best case 612,000 €.

**If it fails:** an empty forecast almost always comes from opportunities with no **est. close date** in the period, no **forecast category**, or users outside Claire’s hierarchy (C3). Fix them, then recalculate.

> **Watch out.** Forecast snapshots have been deprecated: do not look for them. The week-by-week history is prepared in G13.

### G9. Episode 8: discount approval flow (Power Automate)

**Where:** make.powerautomate.com \> your environment \> **Create** \> **Automated cloud flow**.

**Do:**

1.  Name: **Discount approval above 18%**; trigger **Microsoft Dataverse: When a row is added, modified or deleted**.
2.  Trigger parameters: change type **Modified**; table **Quotes**; scope **Organization**; in the advanced options, **Select columns**: `discountpercentage`; **Filter rows**: `discountpercentage gt 18`.
3.  Action **Approvals: Start and wait for an approval**: type “Approve/Reject, first to respond”, title “Discount of @discountpercentage% on @name”, assigned to Claire Martin’s address.
4.  Action **Condition**: outcome = Approve.
    - If yes: **Dataverse: Update a row**, table Quotes, row = quote ID, Description column = “Discount approved by Claire Martin”.
    - If no: update Description = “Discount rejected”, and (optional) set the discount back to 18.
5.  Save, then test: set the discount of a **draft test quote** to 22%.

**Check:** Claire receives the request in the Teams **Approvals** app (or by email); her answer updates the quote.

**If it fails:** the flow does not trigger if the row filter is badly written; clear the “Filter rows” field, test, then add a Condition action on the discount in the flow instead. Test on a test quote, never on the Campus Lumière quotes.

### G10. Episode 8: “Site visit” app (Power Apps)

**Where:** make.powerapps.com \> **Create** \> **Start from data** \> Dataverse \> **Appointments** table.

**Do:**

1.  Let Power Apps generate the three-screen app.
2.  Rename it **ARCHIFRIDAYS Site visit**. On the edit screen, keep Subject, Regarding, Start, End, Description; add an **Add picture** control if you are comfortable, otherwise keep it simple.
3.  Save and publish; share it with Karim Haddad.

**Check:** from the app, you create an appointment “Site visit Clinique Saint-Roch” that appears in Sales Hub.

### G11. Episode 8: Copilot Studio and integrations

There is nothing to build: the Copilot Studio agent and the SAP / Eloqua integrations are presented as a diagram and discussed. Just prepare the integration architecture diagram (CRM, SAP, Eloqua, Lead App, Event Management Tool, Power BI, data platform) on a slide or on the flip chart.

### G12. Episode 9 and workshops

No configuration. Check the workbooks in `06_Workshops`: the Hager grid is pre-filled and is to be completed after the alignment call.

### G13. Episode 7: forecast history in Power BI (optional)

**Do:**

1.  In Claire’s forecast grid, export the grid to Excel (**Export** button if offered; otherwise, export the opportunities view with category, amount and close date). Save the file as `Forecast_W1.xlsx`.
2.  One week later (or after changing 2 or 3 opportunities to simulate progress), export again: `Forecast_W2.xlsx`.
3.  In Power BI Desktop: **Get data** \> Excel \> both files; add a “Week” column to each, **Append queries**; create a stacked column chart: axis Week, legend Category, value Amount.

**Check:** the chart compares the two weeks. Otherwise, use two screenshots of the grid taken one week apart.

## Phase H: rehearsal and checks (D-5)

### H1. Check per episode

Sign in successively as the users indicated and tick each row.

| Episode | Check                                                                                                  | User          | OK  |
|---------|--------------------------------------------------------------------------------------------------------|---------------|-----|
| 1       | Sales Hub opens, site map visible                                                                      | Sophie        | ☐   |
| 2       | Sophie sees the Distelec opportunities through the access team; the discount column is hidden from her | Sophie        | ☐   |
| 2       | Claire sees the opportunities of her whole team                                                        | Claire        | ☐   |
| 3       | Campus Lumière: potential customer Vitalis, 5 stakeholders, 2 competitors                              | You           | ☐   |
| 4       | 47 leads; Inès duplicate detected; sequence active in Karim’s work list                                | Karim         | ☐   |
| 5       | Campus Lumière at 429,700 €; quote V1 at 365,245 € revised; V2 at 343,760 € active; Word template OK   | Sophie        | ☐   |
| 5       | Logisud: quote activated at 139,995 €, ready to be won                                                 | You           | ☐   |
| 6       | Last Campus Lumière activity on 26/10; task of 02/11 open; Copilot or screenshots                      | Sophie        | ☐   |
| 7       | Forecast: Won 202,000 €, Committed 611,000 €, Best case 612,000 €; goals visible                       | Claire        | ☐   |
| 8       | Approval flow tested; Site visit app opened                                                            | Claire, Karim | ☐   |

### H2. Timed rehearsal

Run all the demos in the order of the Trainer Guide, stopwatch in hand, in presenter mode. Note the timing gaps and any unnecessary clicks.

### H3. Backup screenshots

For each demo, take 2 or 3 screenshots (Windows + Shift + S) and store them in a `Backup_screenshots` folder, named by episode: `E04_duplicate_Ines.png`, `E07_forecast_grid.png`, etc. You must include screenshots of the Premium features (predictive lead scoring, relationship analytics, predictive forecasting), which are not in Hager’s licence.

## Phase I: reset before the session (D-1)

After the rehearsal, some demo actions have been carried out. Put the environment back into its starting state.

| To check                                             | Action if needed                                                                                  |
|------------------------------------------------------|---------------------------------------------------------------------------------------------------|
| Leads qualified or disqualified during the rehearsal | Reactivate them (**Reactivate Lead** button); delete the opportunity created by qualifying Inès   |
| Merged duplicates                                    | Recreate the “Ines Garnier” lead from file 09 (a single row)                                      |
| Logisud won and order created during the rehearsal   | Reopen the opportunity (**Reopen Opportunity**), delete the order, reactivate the quote if needed |
| Activities added to Campus Lumière after 26/10       | Delete them                                                                                       |
| Inès’s contact moved to Vitalis                      | Set Kelvin Ingénierie back as the company                                                         |
| Quote discount changed by the flow test              | Restore the values from F3                                                                        |
| Forecast                                             | Click **Recalculate**                                                                             |
| Passwords                                            | Check that each user can sign in without being asked to change their password                     |

> **Tip.** If your environment allows it (Sandbox and Production environments), take a **manual backup** at the end of phase G: Power Platform \> Environments \> your environment \> **Backup & Restore** (Sauvegarde et restauration) \> Create. For a trial environment, this option may not exist: in that case, apply the table above.

## Appendix 1: common problems

| Symptom                                           | Probable cause                                                            | Solution                                          |
|---------------------------------------------------|---------------------------------------------------------------------------|---------------------------------------------------|
| “You do not have access to this app”              | Missing licence or role                                                   | Check C2 and C4                                   |
| Import fails: “unresolved lookup”                 | Referenced record missing or spelt differently                            | Import the parent first, check the accents        |
| Product cannot be added to the opportunity        | Product in draft or missing from the price list                           | Publish the product, add it to the price list     |
| Campus Lumière revenue at 0                       | “User Provided” mode or empty price list                                  | Switch to “System Calculated”, set the price list |
| Empty forecast                                    | Close date outside the period, empty category, user outside the hierarchy | Fix, then Recalculate                             |
| Goals at 0                                        | Fiscal year missing or goal not recalculated                              | Check D1, click Recalculate                       |
| The flow does not trigger                         | Badly written row filter                                                  | Clear the filter, test, use a Condition action    |
| Copilot missing                                   | Feature not enabled or not available in the region                        | Check G5, fall back on screenshots                |
| Sophie sees the framework agreement discount      | Column security profile not assigned correctly                            | Check the profile members (G1)                    |
| Business unit change: the user loses their access | Roles removed during the change                                           | Reassign the roles (C4)                           |

## Appendix 2: administration vocabulary

| French term                    | English term             | Simple explanation                                                              |
|--------------------------------|--------------------------|---------------------------------------------------------------------------------|
| Environnement                  | Environment              | Isolated space containing a Dataverse database and apps                         |
| Locataire                      | Tenant                   | The organisation’s Microsoft 365 space, containing users and licences           |
| Unité commerciale              | Business unit            | Branch of the organisation that defines who sees what by default                |
| Rôle de sécurité               | Security role            | Set of rights (read, create, update) on each table                              |
| Équipe propriétaire / d’accès  | Owner team / Access team | Group of users that owns records, or that receives one-off access               |
| Profil de sécurité de colonne  | Column security profile  | Rule that hides or protects a sensitive column                                  |
| Solution                       | Solution                 | Package that groups customisations to move them from one environment to another |
| Mappage                        | Mapping                  | Correspondence between a column in the file and a Dynamics 365 column           |
| Recherche                      | Lookup                   | Column that points to another record (for example the parent account)           |
| Flux de processus d’entreprise | Business process flow    | Stage bar that guides the user on a record                                      |
| Recalculer                     | Recalculate              | Update a goal or a forecast after a data change                                 |

## Appendix 3: summary checklist

- [ ] A: administrator access, computer ready, kit unzipped
- [ ] B: Enterprise environment in EUR, personal preferences set (formats and language of the session)
- [ ] C: 4 business units, 9 users, roles, managers, hierarchy, 2 teams
- [ ] D: fiscal year, duplicates, active catalogue, 4 connection roles, campaign
- [ ] E: units, products, price lists, 18 accounts, 18 contacts, 2 competitors, 47 leads, 12 opportunities at the right stages
- [ ] F: Campus Lumière products (429,700 €) and Logisud products, stakeholders, quotes V1 and V2, Belvédère won, 9 activities
- [ ] G: access team and protected column, sequence, quote template, email and Copilot (or screenshots), Teams, goals, forecast, approval flow, Site visit app, Power BI history (optional)
- [ ] H: checks per episode, timed rehearsal, backup screenshots
- [ ] I: reset at D-1
