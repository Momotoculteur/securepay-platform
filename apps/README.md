# Applications Argo CD

```text
apps/
├── root.yaml        # Application racine, appliquée une seule fois par le bootstrap
├── children/        # Applications ACTIVES, synchronisées par l'application racine
│   └── securepay-api.yaml
└── catalog/         # Applications PRÊTES, à activer jalon par jalon
    ├── sealed-secrets.yaml     # J2
    ├── kyverno.yaml            # J2
    ├── kyverno-policies.yaml   # J2 (après kyverno.yaml)
    ├── monitoring.yaml         # J3
    ├── chaos-mesh.yaml         # J4
    └── argo-rollouts.yaml      # J4
```

**Activer un composant** : déplacer son manifeste de `catalog/` vers `children/` dans une Merge Request. L'application racine le synchronise après le merge. Aucune installation par `helm install` ou `kubectl apply` à la main.

**Placeholder** : remplacer `<groupe>` par le groupe GitLab du trinôme dans tous les fichiers de ce dossier avant le premier bootstrap.

Les versions de charts sont épinglées. Une montée de version est un changement comme un autre : Merge Request, pipeline, revue.
