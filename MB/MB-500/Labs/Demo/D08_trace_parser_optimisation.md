# Démo D08 : Trace Parser : tracer, lire, optimiser (row-based vs set-based)

**Formation :** Dynamics 365 F&O, du On-Premises au Cloud (ARCHIA365)
**Demi-journée :** DJ4, Slot 2 (mercredi 26/08, après-midi)
**Durée :** 20 minutes
**Alignement MB-500 :** Implement security and optimize performance : capture and analyze traces with Trace Parser ; set-based vs row-based ; optimize performance

---

## 1. Objectif

Dérouler la méthode complète de diagnostic de performance :

1. Exécuter une version volontairement inefficace d'un traitement (row-based).
2. Capturer une trace, l'ouvrir dans **Trace Parser**, identifier le motif fautif.
3. Réécrire en **set-based**, retracer, **comparer les chiffres** : la preuve avant/après.

## 2. Prérequis

- Tier-1 à l'état D06+ (modèle ARCDelivery).
- Trace Parser présent sur l'environnement de développement (installé par défaut sur les images de dev ; sinon installable depuis les outils de la VM).
- Société USMF (jeu Contoso : quelques centaines de clients ; le contraste est déjà visible ; il explose sur de plus grosses volumétries).

## 3. Pas à pas

### Étape 1 : Le traitement inefficace (4 min)

1. **Add > New Item > Code > Runnable Class**. Nom : `ARCPerfDemo`.

```xpp
internal final class ARCPerfDemo
{
    public static void main(Args _args)
    {
        // VERSION 1 : row-based (volontairement inefficace).
        // Passe tous les clients du groupe '30' en priorite Haute.
        CustTable custTable;
        int updated;
        System.Diagnostics.Stopwatch sw =
            System.Diagnostics.Stopwatch::StartNew();

        ttsbegin;
        while select forupdate custTable
            where custTable.CustGroup == '30'
        {
            custTable.ARCDeliveryPriority = ARCDeliveryPriority::High;
            custTable.update();     // 1 UPDATE par ligne + logique table
            updated++;
        }
        ttscommit;

        sw.Stop();
        info(strFmt("Row-based : %1 clients en %2 ms.",
            updated, sw.ElapsedMilliseconds));
    }
}
```

2. **Build**, exécuter une fois (Ctrl+F5) : noter le temps affiché.

### Étape 2 : Capturer la trace (4 min)

1. Client web > **Administration système > Liens > Suivi > Capture de suivi** (Trace) : ou icône Paramètres > Trace.
2. Nommer la trace `ARC_rowbased`, **démarrer la capture**.
3. Exécuter `ARCPerfDemo` (relancer l'URL du runnable ou Ctrl+F5 depuis VS).
4. **Arrêter la capture** ; télécharger le fichier de trace (ou le récupérer dans le dossier de traces de la VM).

### Étape 3 : Lire dans Trace Parser (5 min)

1. Ouvrir **Trace Parser** sur la VM ; créer/choisir la base locale de traces ; **importer** le fichier.
2. Onglet **Call Tree / X++** : trier par durée : repérer `ARCPerfDemo.main` et la répétition de `CustTable.update`.
3. Onglet **SQL** : observer la même requête UPDATE exécutée N fois (une par client) : LE motif N+1 en écriture.
4. Noter deux chiffres : durée totale, nombre de requêtes SQL.

> **Parallèle on-prem :** la lecture est celle d'un SQL Profiler couplé au code X++ : requêtes, durées, pile d'appel : l'instrument change, le raisonnement est celui que vous pratiquez depuis vingt ans.

### Étape 4 : La version set-based (4 min)

1. Modifier `main` (ou créer `ARCPerfDemoSet`) :

```xpp
        // VERSION 2 : set-based : un seul UPDATE ensembliste.
        CustTable custTable;
        System.Diagnostics.Stopwatch sw =
            System.Diagnostics.Stopwatch::StartNew();

        ttsbegin;
        update_recordset custTable
            setting ARCDeliveryPriority = ARCDeliveryPriority::High
            where custTable.CustGroup == '30';
        ttscommit;

        sw.Stop();
        info(strFmt("Set-based : execution en %1 ms.",
            sw.ElapsedMilliseconds));
```

2. **Build**, capturer une seconde trace `ARC_setbased` pendant l'exécution.
3. Importer dans Trace Parser : **un seul UPDATE**, durée divisée (facteur 10 à 100 selon volumétrie).

> **Point d'attention à commenter :** `update_recordset` court-circuite la logique applicative ligne à ligne (update(), events Inserted/Updated, CoC sur update) sauf si la table exige le fallback ligne à ligne : c'est un arbitrage à faire consciemment. Notre event handler de D05 porte sur Inserted : il n'est pas concerné ici : mais la question DOIT être posée à chaque passage en set-based : c'est la marque du senior.

### Étape 5 : Conclure (3 min)

1. Mettre côte à côte les chiffres des deux traces (durée, nombre de requêtes) : la preuve avant/après, votre argumentaire client.
2. Remettre les données en état si souhaité (repasser le groupe '30' en Normale).
3. Check-in : `D08 : demo perf row-based vs set-based`.

## 4. Récapitulatif des acquis

- Méthode : reproduire > tracer > lire (tri par durée, motifs N+1) > corriger > retracer > comparer.
- Set-based : gain massif, mais arbitrage conscient sur la logique court-circuitée.
- Sans SQL de production, la trace applicative est l'instrument de première intention ; le monitoring LCS complète en continu.

## 5. Dépannage

| Problème | Solution |
|---|---|
| Trace Parser absent de la VM | L'installer depuis les outils de la plateforme (PerfSDK/outillage) ; à défaut, faire la lecture sur les captures du support |
| La capture ne contient rien | La capture a été arrêtée avant l'exécution ; rejouer en gardant la fenêtre de trace ouverte |
| update_recordset refuse (fallback) | Certaines tables avec logique déléguée forcent le ligne-à-ligne : c'est justement le point pédagogique : discuter du pourquoi |
| Temps trop courts pour être parlants | Élargir le filtre (tous les groupes) ou boucler la version 1 plusieurs fois pour amplifier le contraste |
