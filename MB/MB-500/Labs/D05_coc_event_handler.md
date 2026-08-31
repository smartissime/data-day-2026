# Démo D05 : Chain of Command et event handler : la logique du champ ARC (UDE)

**Formation :** Dynamics 365 F&O, du On-Premises au Cloud (ARCHIA365)
**Séquence :** DJ3, partie 1
**Durée :** 20 minutes
**Alignement MB-500 :** Develop and test code : implement Chain of Command ; implement event handler classes and delegates
**Environnement :** Visual Studio 2022 (UDE), modèle ARCDelivery à l'état D04.

---

## 1. Objectif

1. **Chain of Command** sur `CustTable.validateWrite()` : un client en priorité Critique doit avoir un groupe de clients renseigné.
2. **Event handler** sur l'insertion de CustTable : journaliser la création d'un client critique.
3. Déployer, vérifier les deux comportements dans le client web, puis déboguer le CoC à distance.

## 2. Prérequis et repères d'environnement

| Élément | Détail |
|---|---|
| Visual Studio | Projet ARCDelivery.FilRouge, option Deploy changes to online environment = True |
| Données | USMF ; groupe de clients existant, par ex. `10` ou `30` (Clients > Configuration > Groupes de clients) |
| Sécurité | Utilisateur System Administrator dans l'environnement (requis pour Launch debugger) |

> **Repère UDE :** pas de changement de schéma dans cette démo : le build déploie le code sans synchronisation de base. Le débogage se fait à distance avec Launch debugger, sur le code qui s'exécute dans le Cloud.

## 3. Pas à pas

### Étape 1 : La classe d'extension CoC (7 min)

1. **Add > New Item > Dynamics 365 Items > Code > Class** : `ARC_CustTable_Extension`.

```xpp
[ExtensionOf(tableStr(CustTable))]
final class ARC_CustTable_Extension
{
    /// <summary>
    /// Regle ARC : un client en priorite Critique doit avoir un groupe de clients.
    /// </summary>
    public boolean validateWrite()
    {
        boolean ret = next validateWrite();

        if (ret
            && this.ARCDeliveryPriority == ARCDeliveryPriority::Critical
            && !this.CustGroup)
        {
            ret = checkFailed("@ARC:CriticalNeedsGroup");
        }

        return ret;
    }
}
```

2. Ajouter le label `CriticalNeedsGroup` = `ARC : un client en priorité Critique doit avoir un groupe de clients.` dans le fichier ARC.

**Contrôle visuel :**
- L'attribut `[ExtensionOf(...)]` est reconnu (pas de soulignement rouge) ; `next` est coloré comme mot-clé.
- Supprimer temporairement `next validateWrite()` pour montrer l'erreur de compilation « must call next », puis le remettre.

> **Parallèle on-prem :** en 2012, cette règle aurait été insérée dans validateWrite copiée en couche USR. Ici, l'enveloppe vit dans votre modèle ; le standard reste intact.

### Étape 2 : L'event handler (4 min)

1. **Add > New Item > Code > Class** : `ARC_CustTableEventHandler`.

```xpp
final class ARC_CustTableEventHandler
{
    [DataEventHandler(tableStr(CustTable), DataEventType::Inserted)]
    public static void CustTable_onInserted(Common _sender, DataEventArgs _e)
    {
        CustTable custTable = _sender as CustTable;

        if (custTable.ARCDeliveryPriority == ARCDeliveryPriority::Critical)
        {
            info(strFmt("ARC : client critique cree : %1 (%2).", custTable.AccountNum, custTable.name()));
        }
    }
}
```

**Contrôle visuel :**
- Méthode statique, attribut `[DataEventHandler(...)]` reconnu ; pas d'attribut ExtensionOf sur la classe : c'est un abonnement découplé.

### Étape 3 : Build, déploiement, tests fonctionnels (5 min)

1. Ctrl+Shift+B (déploiement incrémental sans synchronisation).
2. Client web > Clients > Tous les clients > **Nouveau**.
   - Test 1 : nom, priorité `Critique`, groupe de clients vide > Enregistrer.
   - Test 2 : renseigner le groupe `10` > Enregistrer.
   - Test 3 : observer l'Infolog après la création.

**Contrôle visuel :**
- Output : build et déploiement `Succeeded`, aucune ligne de synchronisation (pas de changement de schéma).
- Test 1 : bandeau rouge en haut du formulaire avec le message ARC ; l'enregistrement n'est pas créé (le bouton Enregistrer reste actif, la fiche reste en création).
- Test 2 : la fiche passe en mode enregistré (numéro de compte attribué).
- Test 3 : notification bleue (Infolog) « ARC : client critique créé : ... ».

### Étape 4 : Déboguer le CoC à distance (3 min)

1. Point d'arrêt sur la ligne `if (ret && ...)`.
2. **Extensions > Dynamics 365 > Launch debugger**.
3. Dans le client, modifier la priorité d'un client et enregistrer.

**Contrôle visuel :**
- Visual Studio s'arrête sur le point d'arrêt ; **Locals** montre `ret = true`, `this.ARCDeliveryPriority = Critical`, `this.CustGroup = ""`.
- **Call Stack** : votre méthode d'extension, puis les méthodes standard appelées via `next` en dessous : la chaîne est visible.

### Étape 5 : Vérification du standard et check-in (1 min)

1. Application Explorer > CustTable > Methods > validateWrite : lecture seule, inchangée.
2. Commit + Push : `D05 : regle CoC validateWrite + event handler onInserted`.

**Contrôle visuel :**
- Application Explorer : validateWrite affiche le code Microsoft d'origine ; votre logique n'y figure pas.

## 4. Récapitulatif des acquis

- CoC = participer au traitement ; event handler = réagir sans interférer.
- `next` obligatoire : erreur de compilation sinon.
- La règle sur la TABLE s'applique à tous les canaux (écran, OData, DMF) : vérifié en D06.
- Le débogueur à distance montre la chaîne d'appels réelle.

## 5. Dépannage

| Problème | Solution |
|---|---|
| Erreur « next must be called » | Appel `next validateWrite()` manquant ou conditionnel |
| Champ inconnu à la compilation | Le déploiement de D04 n'a pas eu lieu ou le modèle n'est pas référencé |
| La règle ne se déclenche pas | Vérifier le déploiement (Output) et actualiser le navigateur ; vérifier la valeur d'enum comparée |
| Point d'arrêt non atteint | Launch debugger non actif, ou build non déployé ; vérifier que la session utilisateur est la vôtre |
| Message doublé | Event handler enregistré deux fois : rechercher les abonnements en double sur CustTable |
