# Robustness testing

## Fourni

- `nominal-load.js` : charge nominale à débit constant, thresholds alignés sur les SLO. C'est l'état stable de référence, rejoué pendant chaque expérience de chaos.

## Scénarios à écrire (jalon J3)

- [ ] TODO [J3] Stress par paliers jusqu'au point de rupture (débit maximal tenu sous SLO)
- [ ] TODO [J3] Pic soudain (élasticité du HPA)
- [ ] TODO [J3] Endurance (30 min minimum, fuite mémoire)
- [ ] TODO [J3] `abortOnFail` sur les scénarios agressifs (condition d'arrêt)

## Preuves

Exportez le résumé de chaque exécution et rangez-le dans `docs/preuves/` :

```bash
k6 run --summary-export docs/preuves/$(date +%Y-%m-%d_%H%M)_nominal-load.json tests/robustness/nominal-load.js
```

Complétez avec des captures Grafana horodatées de la même fenêtre de temps.
