# Rapport de résilience - SecurePay Platform

> Jalons J3 et J4. Ce rapport est la preuve de la compétence B5C3 : la plateforme résiste (ou se dégrade de façon maîtrisée) à des scénarios de stress, de surcharge et de défaillance réels.

## 1. État stable de référence

| SLI | SLO | Mesure sous charge nominale | Preuve |
| :--- | :--- | :---: | :--- |
| Taux de succès des paiements | ≥ 99,5 % | | |
| Latence p95 des paiements | < 300 ms | | |

Charge nominale : `tests/robustness/nominal-load.js` (débit : ... req/s).

## 2. Stress & surcharge (J3)

| Test | Paramètres | Résultat | Point de rupture / comportement | Preuve |
| :--- | :--- | :--- | :--- | :--- |
| Stress par paliers | | | Débit maximal tenu sous SLO : ... req/s | |
| Pic soudain | | | Délai de scale-out du HPA : ... | |
| Endurance | | | | |
| Surcharge machine (`stress-ng`) | | | | |
| Surcharge pod (limite mémoire) | | | | |

**Goulot d'étranglement identifié :** ...

## 3. Expériences de chaos (J4)

Une fiche par expérience, dans l'ordre du catalogue `chaos/experiments/`.

### EXP-01 - Perte d'un pod de l'API

| Rubrique | Contenu |
| :--- | :--- |
| Hypothèse | La perte d'un pod de l'API ne dégrade pas l'état stable |
| Rayon d'impact | Un pod, namespace `securepay` |
| Condition d'arrêt | |
| Date et heure | |
| Résultat mesuré | |
| Impact sur les SLO | |
| Alerte déclenchée (composant / cause) | |
| Remédiation automatique observée | |
| Temps de rétablissement | |
| Hypothèse | Validée / Réfutée |
| Action corrective | |
| Preuves | |

TODO [J4] : une fiche par expérience (au moins 5).

## 4. SPOF identifiés

| Composant | Pourquoi c'est un SPOF | Correction | Expérience rejouée | Preuve |
| :--- | :--- | :--- | :--- | :--- |
| | | | | |
