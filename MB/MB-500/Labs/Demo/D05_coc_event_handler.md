# Démo D05 : Chain of Command et event handler : la logique du champ ARC

**Formation :** Dynamics 365 F&O, du On-Premises au Cloud (ARCHIA365)
**Demi-journée :** DJ3, Slot 1 (mercredi 26/08, matin)
**Durée :** 20 minutes
**Alignement MB-500 :** Develop and test code : Implement Chain of Command ; implement event handler classes and delegates

---

## 1. Objectif

Donner au champ `ARCDeliveryPriority` sa logique métier, sans toucher au code standard :

1. **Chain of Command** sur `CustTable.validateWrite()` : un client en priorité **Critique** doit avoir un groupe de clients renseigné (règle métier du fil rouge).
2. **Event handler** sur l'insertion de CustTable : journaliser la création d'un client critique.
3. Vérifier les deux comportements dans le client web.

## 2. Prérequis

- Tier-1 avec le modèle **ARCDelivery** à l'état de la démo D04 (champ + formulaire opérationnels).

## 3. Pas à pas

### Étape 1 : La classe d'extension CoC (8 min)

1. Dans le projet, **Add > New Item > Code > Class**. Nom : `ARC_CustTable_Extension`.
2. Remplacer le contenu par :

```xpp
[ExtensionOf(tableStr(CustTable))]
final class ARC_CustTable_Extension
{
    /// <summary>
    /// Regle ARC : un client en priorite Critique doit avoir
    /// un groupe de clients renseigne.
    /// </summary>
    public boolean validateWrite()
    {
        boolean ret = next validateWrite();

        if (ret
            && this.ARCDeliveryPriority == ARCDeliveryPriority::Critical
            && !this.CustGroup)
        {
            ret = checkFailed("ARC : un client en priorite Critique doit avoir un groupe de clients.");
        }

        return ret;
    }
}
```

3. Lire le code à voix haute avec la salle :
   - `[ExtensionOf(tableStr(CustTable))]` : la cible de l'extension ;
   - `final class` : obligatoire pour une classe d'extension ;
   - `next validateWrite()` : appelle la chaîne (standard + autres extensions) : **son omission est une erreur de compilation** ;
   - tout ce qui précède `next` = pré-traitement, tout ce qui suit = post-traitement ;
   - `this` = l'enregistrement CustTable courant, votre champ d'extension y est accessible directement.

> **Parallèle on-prem :** en 2012, cette règle aurait été insérée DANS validateWrite en couche USR ; à la montée de version suivante, fusion manuelle obligatoire. Ici, le standard peut changer librement : votre enveloppe reste valide.

### Étape 2 : L'event handler (5 min)

1. **Add > New Item > Code > Class**. Nom : `ARC_CustTableEventHandler`.
2. Contenu :

```xpp
final class ARC_CustTableEventHandler
{
    /// <summary>
    /// Journalise la creation d'un client en priorite Critique.
    /// </summary>
    [DataEventHandler(tableStr(CustTable), DataEventType::Inserted)]
    public static void CustTable_onInserted(Common _sender, DataEventArgs _e)
    {
        CustTable custTable = _sender as CustTable;

        if (custTable.ARCDeliveryPriority == ARCDeliveryPriority::Critical)
        {
            info(strFmt("ARC : client critique cree : %1 (%2).",
                custTable.AccountNum, custTable.name()));
            // En reel : ecrire dans une table de journal ARC,
            // ou emettre un business event (vu au slot 2 et en DJ5).
        }
    }
}
```

3. Commenter la différence de nature avec le CoC :
   - méthode **statique**, classe non liée par ExtensionOf : abonnement découplé ;
   - l'événement `Inserted` arrive APRÈS l'insertion : on ne peut plus l'empêcher, on peut seulement réagir ;
   - c'est le canal des effets de bord (journal, notification), pas celui des validations.

### Étape 3 : Build et tests manuels (5 min)

1. **Build** du projet (sync inutile : pas de changement de schéma).
2. Dans le client web, **Clients > Tous les clients** :
   - **Test 1 (CoC bloque) :** créer un nouveau client, mettre la priorité `Critique`, laisser le groupe de clients vide > Enregistrer > le message d'erreur ARC apparaît, la sauvegarde est refusée.
   - **Test 2 (CoC laisse passer) :** renseigner un groupe de clients > Enregistrer > succès.
   - **Test 3 (event handler) :** le message d'information « client critique créé » s'affiche dans l'Infolog après la création.
3. Ouvrir Application Explorer > CustTable : montrer une dernière fois que le standard est **intact**.

> **Point de contrôle :** les 3 tests passent. La règle est active pour TOUTES les portes d'entrée (écran, mais aussi OData et DMF : à vérifier en D06 : c'est l'argument décisif pour loger les règles dans la table plutôt que dans le formulaire).

### Étape 4 : Check-in (2 min)

1. Pending Changes : les 2 classes.
2. Commentaire : `D05 : regle CoC validateWrite + event handler onInserted (fil rouge)`.
3. **Check In**.

## 4. Récapitulatif des acquis

- CoC = participer au traitement (avant/après, valeur de retour) ; event handler = réagir sans interférer.
- `next` obligatoire : la chaîne ne se brise jamais.
- La règle posée sur la TABLE s'applique à tous les canaux (écran, API, imports) : principe d'or de l'architecture F&O.

## 5. Dépannage

| Problème | Solution |
|---|---|
| Erreur « next must be called » | L'appel `next validateWrite()` manque ou est conditionnel : il doit être inconditionnel |
| L'extension ne compile pas : champ inconnu | Le build de D04 n'est pas passé, ou référence de modèle manquante |
| La règle ne se déclenche pas | Vérifier que le build a réussi et que la session client a été actualisée ; vérifier la valeur de l'enum comparée |
| Message doublé | L'event handler est peut-être enregistré deux fois (classe dupliquée) : rechercher les abonnements sur CustTable |
