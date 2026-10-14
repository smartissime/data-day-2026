# DP-800 — SQL AI Developer

Donnez une âme IA à vos bases SQL. Intégrez la recherche vectorielle, les embeddings et le RAG directement dans SQL Server, Azure SQL et Fabric. Développez des applications intelligentes et scalables.

Référence : [Data Day — DP-800](https://data-day.archifridays.com/)  
Formation délivrée par **Data & AI France**.

---

## Contenu de ce dossier

Ces fichiers permettent de **suivre et de réaliser l’ensemble des sessions** de la formation **DP-800** (SQL AI Developer) : slides formateur (Jours 1 à 3), scripts à exécuter tout au long du parcours, guide pas à pas avec prérequis, et bases de démonstration.

Fil rouge : **AdventureWorks Commerce Cloud** (SQL Server 2025).

### Prérequis & guide pas à pas

| Fichier | Description |
|---------|-------------|
| `00-GUIDE PAS A PAS - Ateliers pratiques DP-800.txt` | Guide complet des ateliers : prérequis (poste, **SQL Server 2025**, Docker/Azure SQL, **SSMS 22+**), puis déroulement pas à pas de tous les exercices |

Suivre la **Partie 0 — Prérequis généraux** du guide **avant** le Jour 1.

### Scripts à exécuter pendant la formation

| Fichier | Description |
|---------|-------------|
| `02-AdventureWorks Commerce Cloud  (SCRIPT COMPLET).sql` | Script SQL complet (12 blocs = 12 modules) à exécuter dans l’ordre, jour après jour |

Avant le Jour 3 (modules Azure OpenAI), remplacer dans le script : `<VOTRE_RESSOURCE>`, `<VOTRE_CLE_API>`, `<DEPLOIEMENT_EMBED>`, `<DEPLOIEMENT_CHAT>`.

### Slides formateur

| Fichier | Description |
|---------|-------------|
| `DP-800-Jour 1 - Session 1.pptx` … `Session 4.pptx` | Jour 1 — Sessions 1 à 4 |
| `DP-800-Jour 2 - Session 1.pptx` … `Session 4.pptx` | Jour 2 — Sessions 1 à 4 |
| `DP-800-Jour 3 - Session 1.pptx` … `Session 4.pptx` | Jour 3 — Sessions 1 à 4 |

### Bases de données de démonstration

| Dossier | Fichier | Description |
|---------|---------|-------------|
| [`OLTP/`](./OLTP/) | `AdventureWorks2025.bak` | Sauvegarde AdventureWorks2025 (Microsoft) — démos OLTP |
| [`Lightweight/`](./Lightweight/) | `AdventureWorksLT2025.bak` | Sauvegarde légère AdventureWorksLT2025 (Microsoft) |
| [`Lightweight/`](./Lightweight/) | `AdventureWorksLT2025.bacpac` | Export BACPAC AdventureWorksLT2025 |

Sources samples : [AdventureWorks — Microsoft Learn](https://learn.microsoft.com/sql/samples/adventureworks-install-configure).

---

© ARCHIA365 — Bureau 326, 59 rue de Ponthieu, 75008 Paris  
Licence : [CC BY 4.0](../LICENSE)
