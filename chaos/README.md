# Chaos Engineering

## Règles du jeu

- **Jamais de synchronisation automatique des expériences** : Argo CD ne déploie que l'opérateur Chaos Mesh. Une expérience se lance à la main, sous charge, quand l'équipe observe.
- **Pas de chaos sans observabilité** : l'état stable (SLO) est mesuré avant chaque expérience.
- **Rayon d'impact minimal** : le contrôleur n'agit que sur les namespaces annotés `chaos-mesh.org/inject=enabled`. Annotez uniquement `securepay` (TODO [J4], via l'Application `securepay-api`).
- **Condition d'arrêt écrite avant l'injection**, et moyen d'arrêt immédiat : `kubectl delete -f <expérience>`.
- **Une hypothèse invalidée est un résultat** : on mesure, on corrige, on rejoue.

## Fourni

- `chaos-mesh-values.yaml` : valeurs adaptées à k3s (runtime containerd et socket k3s) et filtre par namespace.
- `experiments/01-api-pod-kill.yaml` : exemple commenté (état stable, hypothèse, condition d'arrêt, procédure).

## Catalogue à compléter (jalon J4)

Au moins 5 expériences, chacune avec le même en-tête que l'exemple :

- [ ] TODO [J4] Perte de pods de l'API (fourni, à rejouer après correction)
- [ ] TODO [J4] Perte d'un nœud : `k3d node stop k3d-securepay-agent-1` depuis la VM (hors Chaos Mesh, à scripter)
- [ ] TODO [J4] Coupure d'un service critique (DNS du cluster ou dépendance de l'API)
- [ ] TODO [J4] Dégradation réseau : `NetworkChaos` latence puis perte de paquets
- [ ] TODO [J4] Stress de ressources : `StressChaos` mémoire ou CPU
- [ ] TODO [J4] Réponses en erreur : `HTTPChaos` sur une fraction du trafic
- [ ] TODO [J4] GameDay rejouable : `Workflow` enchaînant les expériences

Résultats, impacts sur les SLO et actions correctives : `docs/resilience.md`.
