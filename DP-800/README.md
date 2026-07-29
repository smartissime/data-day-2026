# DP-800 — SQL AI Developer

Donnez une âme IA à vos bases SQL. Intégrez la recherche vectorielle, les embeddings et le RAG directement dans SQL Server, Azure SQL et Fabric. Développez des applications intelligentes et scalables.

Référence : [Data Day — DP-800](https://data-day.archifridays.com/)

---

## Contenu de ce dossier

Supports de la formation **DP-800** (SQL AI Developer) : slides formateur, scripts à exécuter tout au long de la formation, et guide incluant les **prérequis** (poste, VM/SQL Server, SSMS, etc.).

Fil rouge : **AdventureWorks Commerce Cloud** (SQL Server 2025).

### Base de données de démonstration (OLTP)

Dossier [`OLTP/`](./OLTP/) :

| Fichier | Description |
|---------|-------------|
| `OLTP/AdventureWorks2025.bak` | Sauvegarde SQL Server **AdventureWorks2025** provenant du [site officiel Microsoft](https://learn.microsoft.com/sql/samples/adventureworks-install-configure) — sert à alimenter les démos et ateliers de la formation |

Restauration typique (SSMS ou `RESTORE DATABASE`) à partir de ce fichier `.bak`, conformément au guide pas à pas.

### Base de données légère (Lightweight)

Dossier [`Lightweight/`](./Lightweight/) :

| Fichier | Description |
|---------|-------------|
| `Lightweight/AdventureWorksLT2025.bak` | Sauvegarde SQL Server **AdventureWorksLT2025** (version légère) provenant du [site officiel Microsoft](https://learn.microsoft.com/sql/samples/adventureworks-install-configure) — base utilisée pour les ateliers et le fil rouge Commerce Cloud |

### Prérequis & guide pas à pas

| Fichier | Description |
|---------|-------------|
| `00-GUIDE PAS A PAS - Ateliers pratiques DP-800.txt` | Guide complet des ateliers : prérequis généraux (Windows/macOS/Linux, RAM, réseau), installation **SQL Server 2025** (local, Docker ou Azure SQL), **SSMS 22+**, base AdventureWorksLT, puis déroulement pas à pas des exercices |

Suivre la **Partie 0 — Prérequis généraux** du guide **avant** le Jour 1.

### Scripts à exécuter pendant la formation

| Fichier | Description |
|---------|-------------|
| `02-AdventureWorks Commerce Cloud  (SCRIPT COMPLET).sql` | Script SQL complet (12 blocs = 12 modules) à exécuter dans l’ordre, jour après jour |

Avant le Jour 3 (modules Azure OpenAI), remplacer dans le script : `<VOTRE_RESSOURCE>`, `<VOTRE_CLE_API>`, `<DEPLOIEMENT_EMBED>`, `<DEPLOIEMENT_CHAT>`.

### Slides formateur

| Fichier | Description |
|---------|-------------|
| `DP-800-Jour 1 - Session 1.pptx` | Jour 1 — Session 1 |
| `DP-800-Jour 1 - Session 2.pptx` | Jour 1 — Session 2 |
| `DP-800-Jour 1 - Session 3.pptx` | Jour 1 — Session 3 |
| `DP-800-Jour 1 - Session 4.pptx` | Jour 1 — Session 4 |

---

© ARCHIA365 — Bureau 326, 59 rue de Ponthieu, 75008 Paris  
Licence : [CC BY 4.0](../LICENSE)
