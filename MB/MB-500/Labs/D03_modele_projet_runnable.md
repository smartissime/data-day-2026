# Démo D03 : Poste de développement UDE, premier modèle, premier code, premier check-in

**Formation :** Dynamics 365 F&O, du On-Premises au Cloud (ARCHIA365)
**Séquence :** DJ2, partie 1
**Durée :** 20 minutes (hors installation initiale des outils, à faire la veille)
**Alignement MB-500 :** Apply developer tools : create and manage extension models ; debug ; manage source code with Azure DevOps
**Environnement :** Poste local avec Visual Studio 2022 + Power Platform Tools, connecté à un environnement de développement UDE (Sandbox avec Developer Tools + Demo Data).

---

## 1. Objectif

1. Comprendre l'architecture UDE : métadonnées et code X++ sur le poste local (niveau développement), données et exécution dans le Cloud (niveau exécution).
2. Vérifier la connexion Visual Studio à l'environnement unifié.
3. Créer le modèle **ARCDelivery** dans son propre package.
4. Créer un projet, écrire une runnable class, la builder et la **déployer** sur l'environnement en ligne.
5. Déboguer avec **Launch debugger**.
6. Effectuer le premier check-in Azure DevOps.

## 2. Prérequis et repères d'environnement

| Élément | Détail |
|---|---|
| Poste local | Windows, Visual Studio 2022 avec charge de travail « Développement .NET Desktop » et le composant Modeling SDK, 16 Go libres sur le disque système |
| Extension | **Power Platform Tools** pour Visual Studio (Extensions > Gérer les extensions) |
| Environnement | Environnement UDE de type Sandbox, Developer Tools activés, données Contoso ; l'utilisateur a le rôle System Administrator dans l'environnement |
| Métadonnées | Téléchargées une première fois via **Tools > Download Dynamics 365 FinOps assets** (extraction et restauration de la base de références croisées : plusieurs dizaines de minutes) |
| Azure DevOps | Un projet avec dépôt Git (recommandé) ou TFVC ; le dossier des métadonnées locales est placé sous contrôle de source |

> **Repère UDE :** il n'y a plus de machine virtuelle Tier-1 ni de SQL Server local. Visual Studio tourne sur votre PC ; chaque build peut être déployé vers l'environnement Cloud ; le débogueur se connecte à distance. Le parallèle AX le plus proche : un client MorphX sur votre poste connecté à un AOS distant, sauf que le code est compilé localement et poussé.

### Préparation la veille (une seule fois, ~45 min)

1. Installer Visual Studio 2022 (workload .NET Desktop + Modeling SDK) et l'extension Power Platform Tools.
2. Visual Studio > **Tools > Connect to Dataverse** : se connecter, choisir l'environnement Sandbox UDE.
3. **Tools > Download Dynamics 365 FinOps assets** : télécharger l'extension F&O et les métadonnées ; accepter les invites d'élévation (enregistrement du gestionnaire de protocole et du compilateur).
4. Redémarrer Visual Studio.

**Contrôle visuel de fin de préparation :**
- Menu **Extensions > Dynamics 365** présent avec ses sous-menus (Model Management, Deploy, Build models, Launch debugger, Request Credentials for Database Access).
- **View > Application Explorer** s'ouvre et affiche l'arbre AOT (Data Model, User Interface, Code...).
- **Tools > Options > Power Platform Tools** montre l'environnement connecté et le dossier local des métadonnées.

## 3. Pas à pas

### Étape 1 : Vérifier la connexion (2 min)

1. Ouvrir Visual Studio (en administrateur).
2. **Tools > Options > Power Platform Tools** : lire l'environnement connecté et le chemin des métadonnées.
3. **View > Application Explorer** : rechercher `CustTable`.

**Contrôle visuel :**
- Application Explorer affiche `CustTable` sous AOT > Data Model > Tables ; un double-clic ouvre le concepteur en lecture (bandeau indiquant que l'élément appartient à un modèle Microsoft).
- La barre d'état / la fenêtre Output indique l'environnement cible.

### Étape 2 : Créer le modèle ARCDelivery (4 min)

1. **Extensions > Dynamics 365 > Model Management > Create model...**
2. Model name `ARCDelivery`, Publisher `ARCHIA365`, Layer (valeur proposée), Description `Fil rouge : priorité de livraison client` > Next.
3. **Create new package** > Next.
4. Références : cocher `ApplicationPlatform`, `ApplicationSuite` (et `ApplicationFoundation`) > Next.
5. Cocher « Create new project » > Finish.

**Contrôle visuel :**
- L'assistant affiche un récapitulatif : modèle ARCDelivery, package ARCDelivery, références listées.
- **Solution Explorer** montre le nouveau projet ; ses propriétés (clic droit > Properties) indiquent Model = ARCDelivery et Company = USMF.
- Dans le dossier local des métadonnées, un sous-dossier `ARCDelivery` est apparu (Descriptor + dossiers d'éléments).

> **Parallèle on-prem :** c'est l'équivalent de « votre couche USR », mais isolée dans un package compilable et déployable séparément.

### Étape 3 : Le projet et la runnable class (4 min)

1. Clic droit projet > **Set as Startup Project**.
2. Clic droit projet > **Add > New Item > Dynamics 365 Items > Code > Runnable Class (Job)** : `ARCHelloRunnable`.

```xpp
internal final class ARCHelloRunnable
{
    public static void main(Args _args)
    {
        CustTable custTable;
        int custCount;

        select count(RecId) from custTable;
        custCount = any2Int(custTable.RecId);

        info(strFmt("ARC Delivery : societe %1, %2 clients.", curExt(), custCount));
    }
}
```

**Contrôle visuel :**
- L'éditeur colore la syntaxe X++ ; en tapant `custTable.` l'IntelliSense propose les champs et méthodes.
- Solution Explorer : `ARCHelloRunnable.xpp` sous le projet, avec l'icône de classe.

### Étape 4 : Build et déploiement vers l'environnement (4 min)

En UDE, builder ne suffit pas : il faut **déployer** vers l'environnement en ligne.

1. Clic droit projet > Properties : mettre **Deploy changes to online environment** = True (déploiement incrémental à chaque build).
   Alternative : **Extensions > Dynamics 365 > Deploy > Deploy models...** en sélectionnant ARCDelivery (cocher la synchronisation de base si le modèle de données change).
2. **Build > Build Solution** (Ctrl+Shift+B).
3. Clic droit sur `ARCHelloRunnable.xpp` > **Set as Startup Object**, puis Ctrl+F5.

**Contrôle visuel :**
- Fenêtre **Output** : `Build started`, compilation du modèle ARCDelivery, puis les lignes de déploiement vers l'environnement en ligne (upload du package, application, état `Succeeded`).
- Le navigateur s'ouvre sur l'URL `...operations.dynamics.com` et affiche l'Infolog : « ARC Delivery : société USMF, xxx clients. »

> **Parallèle on-prem :** le Job AX, exécuté par clic droit sur un AOS local. Ici : compilé en .NET sur votre poste, déployé vers le Cloud, lancé dans le client web.

### Étape 5 : Débogage à distance (3 min)

1. Poser un point d'arrêt (F9) sur la ligne `select count`.
2. **Extensions > Dynamics 365 > Launch debugger**.
3. Dans le navigateur, relancer la runnable (URL de la classe ou Ctrl+F5).

**Contrôle visuel :**
- Visual Studio passe en mode débogage (barre d'outils orange), le point d'arrêt devient une flèche jaune sur la ligne.
- Fenêtres **Locals** (variable `custTable`, `custCount`) et **Call Stack** (`ARCHelloRunnable.main`) renseignées.
- F5 : le message Infolog apparaît dans le navigateur.

### Étape 6 : Premier check-in Azure DevOps (3 min)

1. **View > Git Changes** (dépôt Git) ou **Team Explorer > Pending Changes** (TFVC).
2. Vérifier que les fichiers du modèle (Descriptor, AxClass) sont détectés.
3. Message : `D03 : creation modele ARCDelivery + ARCHelloRunnable` > **Commit All and Push** (ou Check In).

**Contrôle visuel :**
- Git Changes : la liste des fichiers modifiés pointe dans le dossier `ARCDelivery` des métadonnées ; après push, la fenêtre indique « Successfully pushed ».
- Dans Azure DevOps (navigateur) > Repos > Commits : le commit apparaît avec son message.

## 4. Récapitulatif des acquis

- UDE : développement local, exécution Cloud ; le déploiement fait partie du cycle de build.
- Modèle = espace de personnalisation ; nouveau package = règle d'or.
- Chaîne à retenir : modèle > projet > élément > build + déploiement > check-in.
- Débogage à distance via Launch debugger : le débogueur MorphX est remplacé.

## 5. Dépannage

| Problème | Solution |
|---|---|
| Menu Dynamics 365 absent | Power Platform Tools non installé ou assets non téléchargés : refaire Tools > Download Dynamics 365 FinOps assets |
| « Download assets » grisé | L'environnement est de type Trial : il faut un Sandbox |
| « Type CustTable introuvable » | Référence ApplicationSuite manquante : Model Management > Update model parameters |
| Déploiement échoué | Lire les logs dans la fenêtre Output (ou télécharger les logs d'opération) ; vérifier le rôle System Administrator |
| Point d'arrêt non atteint | Launch debugger non lancé, ou build non déployé ; vérifier la version déployée dans l'Output |
| Push refusé | Dépôt non initialisé ou branche protégée : créer une branche de travail |
