# Politiques d'admission (Policy as Code)

Les politiques de ce dossier sont synchronisées par l'Application `kyverno-policies` (voir `apps/catalog/`). Le sous-dossier `tests/` n'est jamais appliqué au cluster : il contient les tests exécutés par la CI.

## Syntaxe : Kyverno 1.19

`ClusterPolicy` et `Policy` sont obsolètes depuis Kyverno 1.19 et leur suppression est prévue en 1.20. Utilisez les types CEL :

| Besoin | Type Kyverno |
| :--- | :--- |
| Valider une ressource à l'admission | `ValidatingPolicy` (`policies.kyverno.io/v1`) |
| Vérifier signatures et attestations d'images | `ImageValidatingPolicy` |
| Modifier une ressource à l'admission | `MutatingPolicy` |
| Autoriser une exception tracée | `PolicyException` |

`validationActions: [Audit]` laisse passer la ressource et consigne la violation dans un PolicyReport ; `[Deny]` la refuse.

## Fourni

- `disallow-latest-tag.yaml` : exemple en mode Audit, avec son test dans `tests/disallow-latest-tag/`.

## Attendu au jalon J2

Chaque politique doit couvrir un risque du registre (`docs/risques.md`) et apparaître dans la matrice de conformité (`docs/conformite.md`).

- [ ] TODO [J2] Interdire l'exécution en root et le mode privilégié
- [ ] TODO [J2] Exiger requests et limits sur chaque conteneur
- [ ] TODO [J2] Exiger les probes
- [ ] TODO [J2] Passer `disallow-latest-tag` en Deny
- [ ] TODO [J2] N'admettre que les images signées par la pipeline securepay-api (`ImageValidatingPolicy`)
- [ ] TODO [J2] Un test Kyverno CLI par politique, cas conforme et cas non conforme

## Tester localement

```bash
docker run --rm -v "$PWD":/w -w /w ghcr.io/kyverno/kyverno-cli:v1.19.2 test policies/tests/
```

Tester les manifests réellement déployés (chart rendu) :

```bash
helm template securepay-api charts/securepay-api \
  -f charts/securepay-api/values.yaml -f charts/securepay-api/values-production.yaml > rendered.yaml
docker run --rm -v "$PWD":/w -w /w ghcr.io/kyverno/kyverno-cli:v1.19.2 \
  apply policies/*.yaml --resource rendered.yaml
```

Passez les fichiers de politique un par un (glob `policies/*.yaml`) : avec le dossier `policies/`, la CLI parcourt aussi `tests/` et n'y trouve aucune politique exploitable, ce qui donne un faux « 0 règle appliquée ».
