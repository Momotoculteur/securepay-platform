# Runbook - <NomDeLAlerte>

> Un runbook par alerte, référencé par l'annotation `runbook_url` de la règle. Il doit pouvoir être exécuté par une personne extérieure à l'équipe, sans aide (c'est testé lors de l'audit croisé).

| Champ | Valeur |
| :--- | :--- |
| Alerte | `<NomDeLAlerte>` |
| Sévérité | warning / critical |
| Composant (`component`) | |
| Cause (`cause`) | |
| Règle | `observability/rules/<fichier>.yaml` |
| Dernière mise à jour | AAAA-MM-JJ |

## Symptôme

Ce que voit l'utilisateur et ce que dit l'alerte.

## Impact

Effet sur les SLO et sur les clients.

## Diagnostic

1. Vérification et commande ou requête exacte :

```bash
kubectl -n securepay get pods
```

2. ...

## Remédiation

1. Action, et commande exacte.
2. Ce que la remédiation automatique a déjà fait (le vérifier avant d'agir).

## Retour à la normale

Critères objectifs : alerte résolue, SLO revenus dans la cible, ...

## Escalade

Qui prévenir, et quand, si la remédiation échoue.

Aucun secret dans ce document : indiquez où et comment l'obtenir.
