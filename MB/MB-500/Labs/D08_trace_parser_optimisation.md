# Démo D08 : Trace en environnement unifié, Trace Parser, row-based vs set-based

**Formation :** Dynamics 365 F&O, du On-Premises au Cloud (ARCHIA365)
**Séquence :** DJ4, partie 2
**Durée :** 20 minutes
**Alignement MB-500 :** Implement security and optimize performance : capture and analyze traces with Trace Parser ; set-based vs row-based ; optimize performance
**Environnement :** Visual Studio 2022 (UDE) ; client web (capture de trace) ; Trace Parser installé sur le poste local.

---

## 1. Objectif

1. Exécuter un traitement volontairement inefficace (row-based).
2. **Capturer une trace depuis le client web** (menu ? > Trace), la télécharger.
3. L'ouvrir dans **Trace Parser** sur le poste local, identifier le motif fautif.
4. Réécrire en **set-based**, redéployer, retracer, comparer les chiffres.

## 2. Prérequis et repères d'environnement

| Élément | Détail |
|---|---|
| Rôle F&O | L'utilisateur doit avoir le rôle **System tracing user** (Administration système > Utilisateurs > Utilisateurs > Affecter des rôles) |
| Trace Parser | Le fichier `TraceParser.msi` est téléchargé automatiquement avec les métadonnées de l'application (dossier des assets téléchargés par Visual Studio) ; l'installer sur le poste ; au premier lancement, indiquer un nom de base locale (ex. `Traces`) |
| SQL local | Trace Parser stocke les traces dans une base SQL locale (LocalDB ou instance locale) ; utiliser la même que la base de références croisées |
| Données | USMF ; groupe de clients `30` (quelques dizaines de clients) |

> **Repère UDE :** la trace n'est plus capturée depuis une VM de dev, mais depuis le client web de l'environnement Cloud, puis téléchargée (fichier .etl) et analysée sur le poste. Le geste « SQL Profiler sur le serveur » n'existe plus ; la trace applicative est l'instrument de première intention.

## 3. Pas à pas

### Étape 1 : Le traitement inefficace (3 min)

1. **Add > New Item > Code > Runnable Class** : `ARCPerfDemo`.

```xpp
internal final class ARCPerfDemo
{
    public static void main(Args _args)
    {
        // VERSION 1 : row-based (volontairement inefficace)
        CustTable custTable;
        int updated;
        System.Diagnostics.Stopwatch sw = System.Diagnostics.Stopwatch::StartNew();

        ttsbegin;
        while select forupdate custTable
            where custTable.CustGroup == '30'
        {
            custTable.ARCDeliveryPriority = ARCDeliveryPriority::High;
            custTable.update();
            updated++;
        }
        ttscommit;

        sw.Stop();
        info(strFmt("Row-based : %1 clients en %2 ms.", updated, sw.ElapsedMilliseconds));
    }
}
```

2. Ctrl+Shift+B (build + déploiement).

**Contrôle visuel :**
- Output : déploiement `Succeeded`.
- Exécution (Ctrl+F5) : Infolog « Row-based : N clients en X ms. » : noter X.

### Étape 2 : Capturer la trace depuis le client web (4 min)

1. Dans le client web, cliquer sur **?** (barre de navigation) > **Trace**.
2. Nom de la trace : `ARC_rowbased` ; laisser « Inclure la valeur des paramètres SQL » sur Non ; **Démarrer la trace**.
3. Exécuter `ARCPerfDemo` (recharger l'URL de la runnable).
4. **Arrêter la trace** > **Télécharger la trace**.

**Contrôle visuel :**
- Le volet Trace s'ouvre à droite avec le champ Nom, la bascule des paramètres SQL et le bouton Démarrer.
- Pendant la capture, le volet indique « Trace en cours » ; après l'arrêt, trois boutons : Télécharger la trace, Charger la trace, Revenir au menu.
- Un fichier `.etl` apparaît dans le dossier Téléchargements du poste.

> Si le menu Trace est absent : le rôle System tracing user n'est pas affecté (se déconnecter / reconnecter après affectation).

### Étape 3 : Analyser dans Trace Parser (5 min)

1. Lancer **Trace Parser** ; à la première ouverture, saisir le nom de base `Traces`.
2. **Open trace** > sélectionner le `.etl` ; laisser l'import s'exécuter.
3. Onglet **Call Tree** : développer `ARCPerfDemo.main`.
4. Onglet **X++** : trier par durée inclusive ; onglet **SQL** : observer la répétition de l'UPDATE.

**Contrôle visuel :**
- Barre de progression d'import, puis l'onglet Timeline avec les sessions et utilisateurs.
- Call Tree : `ARCPerfDemo.main` en racine, avec N occurrences de `CustTable.update` en dessous.
- Onglet SQL : la même instruction `UPDATE CUSTTABLE SET ARCDELIVERYPRIORITY=... WHERE RECID=...` répétée N fois ; colonne Duration cumulée.
- Noter deux chiffres : durée totale et nombre d'instructions SQL.

> **Parallèle on-prem :** lecture identique à SQL Profiler couplé au code X++ : requêtes, durées, pile d'appels. L'instrument change, le raisonnement est le vôtre.

### Étape 4 : La version set-based (4 min)

1. Remplacer le corps de `main` (ou créer `ARCPerfDemoSet`) :

```xpp
        CustTable custTable;
        System.Diagnostics.Stopwatch sw = System.Diagnostics.Stopwatch::StartNew();

        ttsbegin;
        update_recordset custTable
            setting ARCDeliveryPriority = ARCDeliveryPriority::High
            where custTable.CustGroup == '30';
        ttscommit;

        sw.Stop();
        info(strFmt("Set-based : execution en %1 ms.", sw.ElapsedMilliseconds));
```

2. Ctrl+Shift+B ; capturer une seconde trace `ARC_setbased` pendant l'exécution ; télécharger ; ouvrir dans Trace Parser.

**Contrôle visuel :**
- Infolog : « Set-based : exécution en Y ms. » avec Y très inférieur à X.
- Trace Parser, onglet SQL : **une seule** instruction UPDATE avec la clause WHERE sur CUSTGROUP ; Call Tree sans boucle de `CustTable.update`.

> **Point d'attention :** `update_recordset` court-circuite la logique ligne à ligne (update(), événements Updated, CoC sur update) sauf si la table force le repli ligne à ligne. L'event handler de D05 porte sur Inserted : non concerné ici, mais la question doit être posée à chaque passage en set-based.

### Étape 5 : Conclure (3 min)

1. Mettre côte à côte les deux jeux de chiffres (durée, nombre de requêtes).
2. Remettre les données en état si souhaité (repasser le groupe 30 en Normale).
3. Supprimer les traces locales sensibles après usage ; Commit + Push : `D08 : demo perf row-based vs set-based`.

**Contrôle visuel :**
- Deux captures Trace Parser côte à côte : N requêtes vs 1 requête ; X ms vs Y ms.

## 4. Récapitulatif des acquis

- En UDE : capture depuis le client web (? > Trace), téléchargement, analyse locale dans Trace Parser.
- Méthode : reproduire > tracer > lire (tri par durée, motif N+1) > corriger > retracer > comparer.
- Set-based : gain massif, arbitrage conscient sur la logique court-circuitée.

## 5. Dépannage

| Problème | Solution |
|---|---|
| Menu Trace absent dans ? | Affecter le rôle System tracing user, se reconnecter |
| TraceParser.msi introuvable | Le relancer via Tools > Download Dynamics 365 FinOps assets (il accompagne les métadonnées) |
| Trace Parser : erreur de base | Indiquer une instance SQL locale valide (LocalDB) ; base `Traces` |
| Fichier .etl vide | Trace arrêtée avant l'exécution : recommencer en gardant le volet Trace ouvert |
| update_recordset se replie en ligne à ligne | Table avec logique déléguée : point pédagogique, expliquer pourquoi |
| Écart de temps peu parlant | Élargir le filtre (plusieurs groupes) ou boucler la version 1 pour amplifier |
