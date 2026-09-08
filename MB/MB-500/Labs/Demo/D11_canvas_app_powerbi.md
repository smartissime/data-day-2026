# Démo D11 : L'app canvas ARC Priorités + aperçu Power BI

**Formation :** Dynamics 365 F&O, du On-Premises au Cloud (ARCHIA365)
**Demi-journée :** DJ6, Slot 1 (jeudi 27/08, après-midi)
**Durée :** 30 minutes (la plus longue démo de la formation)
**Alignement MB-500 :** Connect to Power Platform services (Power Apps) ; Implement reporting : Power BI

---

## 1. Objectif

1. Construire une **canvas app** listant les clients avec leur priorité de livraison : filtre « critiques seulement », code couleur, appel téléphonique en un geste.
2. Tester l'app dans le simulateur mobile.
3. **Aperçu Power BI** : visualiser la répartition des clients par priorité.

## 2. Prérequis

| Élément | Détail |
|---|---|
| Données | Clients F&O accessibles dans Dataverse (virtual table mserp ou table Account en dual-write : vu en D09) ; à défaut, **plan C** : une table Dataverse `arc_clients` importée d'un fichier (modèle fourni en annexe) : l'app se construit à l'identique |
| Portail | `https://make.powerapps.com`, environnement de démonstration sélectionné |
| Solution | La solution `ARC Delivery` créée en D10 (l'app y sera créée) |
| Power BI | Power BI service (`app.powerbi.com`) avec licence d'essai, OU le fichier `ARC_Priorites.pbix` préparé à l'avance (plan B analytique) |

## 3. Pas à pas : l'app canvas (20 min)

### Étape 1 : Créer l'app dans la solution (3 min)

1. Maker portal > **Solutions > ARC Delivery > Nouveau > Application > Application canvas**.
2. Nom : `ARC Priorités` ; format **Téléphone**.
3. L'éditeur (Power Apps Studio) s'ouvre : tour d'écran de 30 secondes : arborescence à gauche, canevas au centre, propriétés à droite, barre de formules en haut (« Excel qui pilote des écrans »).

### Étape 2 : Connecter les données (4 min)

1. Volet **Données > Ajouter des données** : chercher la table clients retenue (virtual table `mserp_custcustomerv3entity`, table `Compte`, ou `arc_clients` du plan C).
2. La table apparaît dans les sources de l'app.

### Étape 3 : La galerie (7 min)

1. **Insérer > Galerie verticale** ; source : la table connectée ; l'assistant remplit un premier rendu.
2. Ajuster les champs de la galerie : Titre = nom du client ; Sous-titre = numéro de compte ; troisième zone = priorité.
3. Code couleur : sélectionner l'étiquette de priorité > propriété **Color** :

```powerfx
Switch(ThisItem.ARCDeliveryPriority,
    "Critical", Color.Red,
    "High",     Color.Orange,
    "Normal",   Color.Green,
    Color.Gray)
```

   (adapter le nom de colonne à la source : `arc_deliverypriority` côté Dataverse : la barre de formules propose l'IntelliSense).
4. Tester la prévisualisation (F5) : la liste vit.

### Étape 4 : Filtre « critiques seulement » (4 min)

1. **Insérer > Bascule (Toggle)** au-dessus de la galerie ; libellé : `Critiques seulement`.
2. Propriété **Items** de la galerie :

```powerfx
If(Toggle1.Value,
   Filter(Source, ARCDeliveryPriority = "Critical"),
   Source)
```

3. F5 : activer la bascule : la liste se réduit aux critiques.

### Étape 5 : L'action d'appel + test mobile (2 min)

1. Ajouter dans le modèle de galerie une icône téléphone ; propriété **OnSelect** : `Launch("tel:" & ThisItem.Phone)` (selon colonne disponible ; sinon pointer l'e-mail avec `mailto:`).
2. F5 en mode téléphone : dérouler le scénario : le logisticien filtre les critiques et appelle le client en deux gestes.
3. **Enregistrer** l'app (elle appartient à la solution ARC Delivery).

> **Parallèle on-prem :** rappeler ce que ce mini-portail aurait coûté en Enterprise Portal (WebParts, code, déploiement) : ici, vingt minutes en session de formation.

## 4. Pas à pas : aperçu Power BI (10 min)

**Plan A (tenant permettant la connexion) :**
1. `app.powerbi.com` > Nouveau rapport > source : export Excel de l'entité clients (généré depuis F&O : Gestion des données > export CustomersV3) ou connexion Dataverse.
2. Visuel **secteurs / anneau** : répartition des clients par `ARCDeliveryPriority` ; visuel **carte** : nombre de critiques.
3. Montrer l'interaction croisée (clic sur une tranche filtre l'autre visuel).

**Plan B (fichier préparé) :**
1. Ouvrir le fichier `ARC_Priorites.pbix` fourni (construit sur un export du jeu Contoso enrichi).
2. Dérouler la même interaction ; montrer en 1 minute le modèle de données sous-jacent (table clients, mesure Nb critiques).

3. Conclure sur la trajectoire (slide du support) : Entity store / BYOD aujourd'hui, Fabric / OneLake comme direction : et Copilot par-dessus (démo D12).

## 5. Récapitulatif des acquis

- Une canvas app de consultation métier se construit en une vingtaine de minutes sur les données de l'ERP.
- Power Fx : des formules type Excel (Switch, Filter, If) pilotent l'interface.
- L'app vit dans la solution ARC Delivery : transportable (D12).
- Power BI : l'analytique interactive sur les données F&O, en attendant le branchement Fabric industrialisé.

## 6. Dépannage

| Problème | Solution |
|---|---|
| La table clients n'apparaît pas dans les données | Virtual table non activée / dual-write absent : passer au plan C (table arc_clients importée : modèle en annexe) |
| Lenteur de la galerie sur virtual table | Normal (appels distants) : point pédagogique sur la latence ; limiter les colonnes et éléments |
| La formule Switch renvoie une erreur de type | La colonne priorité est un Choice côté Dataverse : comparer avec la syntaxe de choix (ex. `'Priorité (arc_clients)'.Critique`) : l'IntelliSense guide |
| Pas de licence Power BI | Utiliser le plan B (pbix préparé) ; l'activation d'essai Power BI se fait en deux clics si le tenant l'autorise |

## Annexe : plan C : table arc_clients autonome

1. Maker portal > Solutions > ARC Delivery > Nouveau > **Table** `arc_clients` : colonnes : Nom (texte), Compte (texte), Priorité (Choice : Basse/Normale/Haute/Critique), Téléphone (texte).
2. Importer le fichier CSV fourni (30 clients fictifs avec priorités variées) via **Importer > Importer des données depuis Excel/CSV**.
3. L'app et le rapport se construisent à l'identique sur cette table : aucun impact pédagogique.
