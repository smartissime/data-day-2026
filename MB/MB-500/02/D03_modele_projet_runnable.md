# Démo D03 : Premier modèle, premier projet, premier code (et premier check-in)

**Formation :** Dynamics 365 F&O, du On-Premises au Cloud (ARCHIA365)
**Demi-journée :** DJ2, Slot 1 (mardi 25/08, après-midi)
**Durée :** 20 minutes
**Alignement MB-500 :** Apply developer tools : Create and manage extension models ; perform debugging ; manage source code with Azure DevOps

---

## 1. Objectif

1. Créer le modèle **ARCDelivery** dans son propre package : le socle de tout le fil rouge.
2. Créer un projet Visual Studio rattaché à ce modèle.
3. Écrire, compiler et exécuter une runnable class (l'héritière du Job AX).
4. Poser un point d'arrêt et déboguer.
5. Effectuer le premier check-in Azure DevOps.

## 2. Prérequis

| Élément | Détail |
|---|---|
| Environnement | Tier-1 de développement (cloud-hosted LCS ou environnement UDE) avec Visual Studio et l'extension F&O installée |
| Accès | Compte administrateur local de la VM de dev (RDP) ou accès UDE configuré |
| Azure DevOps | Un projet Azure DevOps avec un dépôt configuré ; le mapping du contrôle de source effectué dans Visual Studio (Team Explorer) : si non configuré, l'étape 6 se fait en démonstration |
| Fallback | Sans Tier-1 disponible pour les participants : démo au projecteur ; le guide permet de refaire chaque étape en autonomie ensuite |

> **Note formateur :** le tenant de démonstration ARCHIA365 (DemoHub) ne contient PAS d'environnement de développement. Prévoir un Tier-1 dédié (cloud-hosted via LCS sur un abonnement Azure, ou UDE provisionné depuis PPAC). Vérifier la veille que Visual Studio s'ouvre et compile.

## 3. Pas à pas

### Étape 1 : Créer le modèle ARCDelivery (5 min)

1. Sur le Tier-1, ouvrir **Visual Studio** (en tant qu'administrateur).
2. Menu **Extensions > Dynamics 365 > Model Management > Create model...**
3. Renseigner :
   - **Model name** : `ARCDelivery`
   - **Publisher** : `ARCHIA365`
   - **Layer** : laisser la valeur proposée (le concept de couche subsiste techniquement mais n'a plus le rôle de personnalisation d'AX)
   - **Model description** : `Fil rouge formation : priorité de livraison client`
4. Écran suivant : choisir **Create new package** (JAMAIS « existing package » d'un package Microsoft).
5. Écran suivant : **Select referenced packages** : cocher au minimum :
   - `ApplicationPlatform`
   - `ApplicationSuite` (contient CustTable et le gros de l'applicatif)
6. Terminer. Cocher « Create new project » si proposé.

> **Point de contrôle :** le modèle apparaît dans la liste des modèles (Dynamics 365 > Model Management > Update model parameters). **Parallèle on-prem :** vous venez de créer l'équivalent de « votre couche USR », mais isolée dans son propre package compilable.

### Étape 2 : Créer le projet Visual Studio (3 min)

1. **File > New > Project** > modèle **Finance Operations** (projet Dynamics 365).
2. Nom : `ARCDelivery.FilRouge`. Créer.
3. Dans **Solution Explorer**, clic droit sur le projet > **Properties** :
   - **Model** : vérifier `ARCDelivery` ;
   - **Company** : `USMF` (société de démo) ;
   - **Synchronize database on build** : `False` pour l'instant.
4. Clic droit sur le projet > **Set as Startup Project**.

> **Point de contrôle :** la propriété Model du projet indique ARCDelivery. Tout élément ajouté à ce projet appartiendra à ce modèle.

### Étape 3 : La runnable class (4 min)

1. Clic droit sur le projet > **Add > New Item** > **Code > Runnable Class (Job)**.
2. Nom : `ARCHelloRunnable`.
3. Compléter le code :

```xpp
internal final class ARCHelloRunnable
{
    public static void main(Args _args)
    {
        // Fil rouge ARC Delivery : premiere execution
        int custCount;

        select count(RecId) from custTable;
        custCount = any2Int(custTable.RecId);

        info(strFmt("ARC Delivery : societe %1, %2 clients.",
            curExt(), custCount));
    }
}
```

4. Observer au passage : déclaration de variable possible n'importe où, IntelliSense actif, coloration.

### Étape 4 : Build et exécution (3 min)

1. Clic droit sur le projet > **Build** (ou Ctrl+Shift+B). Vérifier la fenêtre Output : `Build completed`.
2. Clic droit sur `ARCHelloRunnable.xpp` > **Set as Startup Object**.
3. **Debug > Start Without Debugging** (Ctrl+F5) : le navigateur s'ouvre et affiche le message Infolog avec le nombre de clients.

> **Parallèle on-prem :** c'est exactement le Job AX : clic droit, exécuter : mais compilé en .NET et lancé dans le client web.

### Étape 5 : Débogage (3 min)

1. Poser un point d'arrêt (F9) sur la ligne `select count...`.
2. **Debug > Start Debugging** (F5).
3. À l'arrêt : examiner les fenêtres **Locals** et **Call Stack**, survoler `custTable`.
4. F5 pour continuer, fermer.

> **Point de contrôle :** chacun a vu le point d'arrêt frapper : le débogueur MorphX est officiellement remplacé.

### Étape 6 : Premier check-in (2 min)

1. Ouvrir **View > Team Explorer** > **Pending Changes**.
2. Vérifier que les fichiers du modèle et de la classe sont listés (Descriptor du modèle + AxClass).
3. Commentaire : `D03 : creation modele ARCDelivery + ARCHelloRunnable`.
4. **Check In**.

> **Point de contrôle :** le changeset apparaît dans l'historique Azure DevOps (montrer dans le navigateur si le temps le permet). **Parallèle on-prem :** fini l'XPO par mail : ce check-in EST désormais la définition de l'existant.

## 4. Récapitulatif des acquis

- Modèle = votre espace de personnalisation ; nouveau package = règle d'or.
- Projet VS = unité de travail rattachée à UN modèle.
- Runnable class = le Job modernisé ; build + Ctrl+F5 = le cycle de test rapide.
- Le check-in clôt chaque tâche : c'est le geste professionnel de base.

## 5. Dépannage

| Problème | Solution |
|---|---|
| « Type CustTable introuvable » à la compilation | Référence de package manquante : Model Management > Update model parameters > cocher ApplicationSuite |
| Le menu Dynamics 365 est absent de VS | Lancer VS en administrateur ; vérifier l'extension F&O (installée par défaut sur les images de dev) |
| L'exécution n'ouvre pas le navigateur | Vérifier l'URL du client dans la configuration ; tester l'URL directement |
| Check-in impossible | Mapping du contrôle de source non fait : Team Explorer > Connect > mapper le dossier Metadata et Projects |
