# Démo D11 : L'app canvas ARC Priorités + aperçu Power BI (environnement unifié)

**Formation :** Dynamics 365 F&O, du On-Premises au Cloud (ARCHIA365)
**Séquence :** DJ6, partie 1
**Durée :** 30 minutes
**Alignement MB-500 :** Connect to Power Platform services (Power Apps) ; Implement reporting : Power BI
**Environnement :** Maker portal Power Apps sur l'environnement unifié ; table virtuelle `Customers V3 (mserp)` activée (D09) ; Power BI service ou Desktop.

---

## 1. Objectif

1. Construire une **canvas app** listant les clients avec leur priorité, filtre « critiques seulement », code couleur, appel en un geste.
2. Tester dans le simulateur mobile ; l'app vit dans la solution `ARC Delivery`.
3. **Aperçu Power BI** : répartition des clients par priorité.

## 2. Prérequis et repères d'environnement

| Élément | Détail |
|---|---|
| Données | Table virtuelle `Customers V3 (mserp)` visible dans le maker portal ; colonne `mserp_arcdeliverypriority` présente si l'entité a été étendue (D06). Plan C : table Dataverse `arc_clients` importée (annexe) |
| Solution | `ARC Delivery` (D10) |
| Power BI | Service (`app.powerbi.com`) avec essai activé, ou fichier `ARC_Priorites.pbix` préparé |

> **Repère UDE :** l'app lit les données F&O à travers la table virtuelle, dans le même environnement ; il n'y a ni connecteur à paramétrer ni copie de données. La latence des appels distants est normale : limiter les colonnes.

## 3. Pas à pas : l'app canvas (20 min)

### Étape 1 : Créer l'app dans la solution (3 min)

1. Maker portal > **Solutions > ARC Delivery > + Nouveau > Application > Application canvas** ; nom `ARC Priorités` ; format **Téléphone** ; Créer.

**Contrôle visuel :**
- Power Apps Studio s'ouvre : arborescence à gauche, canevas au format téléphone au centre, volet Propriétés à droite, barre de formules en haut (fx).

### Étape 2 : Connecter les données (3 min)

1. Volet **Données > + Ajouter des données** > rechercher `Customers V3` (mserp) et sélectionner.

**Contrôle visuel :**
- La table apparaît dans le volet Données avec l'icône Dataverse ; en la dépliant, les colonnes `mserp_customeraccount`, `mserp_organizationname` (ou nom), `mserp_arcdeliverypriority`.

### Étape 3 : La galerie (7 min)

1. **Insérer > Galerie verticale** ; source = la table.
2. Modifier les champs : Titre = nom du client ; Sous-titre = compte ; troisième étiquette = priorité.
3. Étiquette de priorité > propriété **Color** :

```powerfx
Switch(Text(ThisItem.mserp_arcdeliverypriority),
    "Critical", Color.Red,
    "High",     Color.Orange,
    "Normal",   Color.Green,
    Color.Gray)
```

(adapter au nom exact de la colonne ; l'IntelliSense de la barre de formules le propose).

4. F5 pour prévisualiser.

**Contrôle visuel :**
- La galerie affiche des lignes avec nom, compte et priorité ; les priorités « Critical » apparaissent en rouge.
- La barre de formules n'affiche pas de soulignement rouge (formule valide).

### Étape 4 : Filtre « critiques seulement » (4 min)

1. **Insérer > Bascule** au-dessus de la galerie ; texte `Critiques seulement`.
2. Propriété **Items** de la galerie :

```powerfx
If(Toggle1.Value,
   Filter('Customers V3 (mserp)', Text(mserp_arcdeliverypriority) = "Critical"),
   'Customers V3 (mserp)')
```

**Contrôle visuel :**
- Bascule désactivée : liste complète ; activée : seules les lignes rouges restent.
- Si un avertissement de délégation (triangle bleu) apparaît sur la formule : normal sur une table virtuelle avec `Text()` ; acceptable en démo, à optimiser en projet.

### Étape 5 : Action d'appel + test mobile (3 min)

1. Icône téléphone dans le modèle de galerie ; **OnSelect** : `Launch("tel:" & ThisItem.mserp_phone)` (ou `mailto:` sur l'e-mail selon colonne disponible).
2. F5 : dérouler le scénario ; **Enregistrer** (Ctrl+S) puis **Publier**.

**Contrôle visuel :**
- Le simulateur affiche l'app au format téléphone ; le filtre et l'icône répondent.
- Retour dans la solution ARC Delivery : l'app `ARC Priorités` est listée comme composant.

> **Parallèle on-prem :** ce mini-portail aurait coûté des semaines en Enterprise Portal ; ici vingt minutes en session.

## 4. Pas à pas : aperçu Power BI (10 min)

**Plan A :** `app.powerbi.com` > Nouveau rapport > source : export Excel de l'entité clients (F&O > Gestion des données > Exporter CustomersV3) ou connexion Dataverse à la table virtuelle ; visuel Anneau (répartition par priorité) + Carte (nombre de critiques) ; montrer l'interaction croisée.

**Plan B :** ouvrir `ARC_Priorites.pbix` ; même interaction ; montrer le modèle de données en 1 minute.

**Contrôle visuel :**
- L'anneau affiche quatre tranches (Basse / Normale / Haute / Critique) ; un clic sur « Critique » filtre la carte et les autres visuels.
- Volet Champs à droite : la table clients et la mesure « Nb critiques ».

Conclure sur la trajectoire : Entity store et BYOD aujourd'hui, lien Fabric / OneLake comme direction, et Copilot par-dessus (D12).

## 5. Récapitulatif des acquis

- Une canvas app de consultation métier sur les données F&O en vingt minutes, via la table virtuelle de l'environnement unifié.
- Power Fx : formules type Excel (Switch, Filter, If).
- L'app vit dans la solution ARC Delivery : transportable (D12).
- Power BI : analytique interactive sur les données F&O.

## 6. Dépannage

| Problème | Solution |
|---|---|
| Table virtuelle absente des données | Non activée : refaire D09 étape 2 ; vérifier l'environnement ; sinon plan C |
| Galerie lente | Normal (appels distants) : limiter les colonnes et le nombre d'éléments |
| Erreur de type sur la priorité | La colonne est un Choix : utiliser `Text()` ou la syntaxe de choix ; suivre l'IntelliSense |
| Pas de licence Power BI | Plan B (pbix préparé) ; activer l'essai si le tenant l'autorise |

## Annexe : plan C : table arc_clients autonome

1. Solutions > ARC Delivery > + Nouveau > **Table** `arc_clients` : Nom (texte), Compte (texte), Priorité (Choix : Basse / Normale / Haute / Critique), Téléphone (texte).
2. Importer le CSV fourni (30 clients fictifs) via **Importer > Importer des données**.
3. Construire l'app et le rapport à l'identique.

**Contrôle visuel :** la table `arc_clients` apparaît dans la solution avec 30 lignes dans l'onglet Données.
