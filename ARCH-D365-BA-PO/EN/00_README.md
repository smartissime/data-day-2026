# Dynamics 365 Sales training kit

*Product Owner / Business Analyst level · 2 days on site · ARCHIFRIDAYS running case*

ARCHIA365

This folder contains everything needed to prepare, deliver and assess the training. All organisations, people and data in the running case are fictitious.

## How the kit is organised

The kit comes in two languages: the **FR** folder holds the French version and the **EN** folder the English version, with the same structure. Each document is provided in three formats: Word (DOCX) for editing, PDF for distribution and Markdown (MD) for reuse in a wiki, a Git repository or a documentation tool. Images used by the Markdown files sit next to them.

## Contents of the EN folder

| Folder                   | File                                           | Purpose                                                                                                                                                                                                                                                                    | Audience                         |
|--------------------------|------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------|
| 01_Training_Programme    | Training_Programme_D365_Sales_PO_BA            | Detailed programme and schedule, response to Hager’s feedback                                                                                                                                                                                                              | Client, participants             |
| 02_Running_Case          | Running_Case_ARCHIFRIDAYS                      | Full scenario: group, stakeholders, data, episodes, pipeline, answer keys                                                                                                                                                                                                  | Trainer                          |
| 03_Trainer_Guide         | Trainer_Guide                                  | Preparation (including the alignment call with Hager), Hager context, demo configuration, minute-by-minute flow, time management, FAQ                                                                                                                                      | Trainer                          |
| 03_Trainer_Guide         | Trainer_Recap_Sheets (DOCX, PDF, MD)           | One sheet per module and per workshop: client focus, EN / FR vocabulary, essential concepts, link to the Hager context, key message, best practice, PO angle, watch out, Say it in English, questions to ask                                                               | Trainer                          |
| 04_Participant_Materials | Participant_Workbook                           | Exercises for each episode and how to apply them to Hager, without answers                                                                                                                                                                                                 | Participants (to print)          |
| 04_Participant_Materials | Module_Summary_Sheets                          | One sheet per module: standard, rationale, good practices, questions for the PO                                                                                                                                                                                            | Participants                     |
| 05_Dataset               | Dataset_ARCHIFRIDAYS.xlsx                      | All running case data, with import order and points of attention                                                                                                                                                                                                           | Trainer                          |
| 05_Dataset               | CSV_Dataverse_import (14 files)                | Files ready to import into the demo environment                                                                                                                                                                                                                            | Trainer                          |
| 06_Workshops             | Workshop_Fit_Gap.xlsx                          | Fit-gap grid: ARCHIFRIDAYS answer key, Hager grid to complete, calculated summary                                                                                                                                                                                          | Participants (workshops 1 and 2) |
| 06_Workshops             | Forecast_and_KPI_Exercise_Q4_participants.xlsx | Q4 pipeline, calculated forecast summary, landing, KPIs to define                                                                                                                                                                                                          | Participants (episode 7)         |
| 06_Workshops             | Forecast_and_KPI_Exercise_Q4_trainer.xlsx      | Same workbook with the landing answer key and the 8 KPI reference                                                                                                                                                                                                          | Trainer                          |
| 07_Assessment            | Pre_and_Post_Quiz                              | 15 questions, taken at the opening and at the wrap-up                                                                                                                                                                                                                      | Participants                     |
| 07_Assessment            | Quiz_Answer_Key                                | Answers and explanations                                                                                                                                                                                                                                                   | Trainer                          |
| 07_Assessment            | Satisfaction_Survey                            | End-of-course evaluation                                                                                                                                                                                                                                                   | Participants                     |
| 08_Slides                | Slides_D365_Sales_PO_BA (PPTX, PDF)            | Slides projected over the 2 days (about 70 slides, including an EN / FR glossary for each module); each slide’s notes contain the teleprompter script to read, the key message, a watch-out point, the PO angle, Say it in English phrasing and questions to ask the group | Trainer                          |
| 08_Slides                | Teleprompter_Script_D365_Sales_PO_BA (MD)      | Full teleprompter text, slide by slide, for rehearsal or printing                                                                                                                                                                                                          | Trainer                          |

**Using the teleprompter notes.** In PowerPoint, start the slide show in Presenter View: the notes appear on the trainer’s screen. The text is written to be read as is; cues in square brackets (for example \[Demo\], \[Break\], \[Ask the group\]) are stage directions, not to be read aloud. Below the script, the notes recall the key message, the watch-out point, the PO angle, the Say it in English phrasing and the questions to ask.

## Importing the dataset

The CSV files use a semicolon separator and UTF-8 encoding. Headers use the English display names of Dynamics 365 Sales to make mapping easier in the import wizard. The “Profile”, “Booth note”, “Expected handling in training” and “Role in the scenario” columns are trainer aids: ignore them when mapping or import them into the description.

**Recommended order**

1.  Users, business units and teams (created manually): 01_Users_and_teams.
2.  Unit groups and units (02), products (03), price lists (04) and price list items (05); publish the products.
3.  Accounts (06): first the accounts without a parent, then Distelec Sud-Est.
4.  Contacts (07), then competitors (08).
5.  Campaign “BâtiExpo Lyon 2026” (created manually), then trade show leads (09).
6.  Opportunities (10) and opportunity products (11); quotes (12) created from the opportunity to keep the revisions.
7.  Campus Lumière activities (13), goals (14), then forecast configuration.

**Points of attention**

- Inès Garnier’s lead appears twice (deliberate duplicate) and her contact already exists: duplicate detection is demonstrated in episode 4.
- Do not add any activity on Campus Lumière after 26/10/2026: the 21-day silence is the subject of episode 6 (reference date: Monday 16/11/2026).
- Reference amounts: Campus Lumière 429,700 € at list price, quote V1 365,245 €, quote V2 343,760 €; South-East target 1,600,000 €.

## Before using the kit

- In the week before the session, check how features are split across licences and what the current release wave brings.
- Give participants the “participants” version of the forecast workbook; the “trainer” version contains the answer keys.
- Adapt the Hager examples using the information received and the alignment call (see the trainer guide).
