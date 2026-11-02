# Dashboards Grafana

TODO [J3] : versionner ici les dashboards au format JSON, puis les charger par ConfigMap (sidecar Grafana du chart kube-prometheus-stack, label `grafana_dashboard: "1"`).

Attendus :

- [ ] Dashboard RED de l'API (débit, erreurs, latence par route et par code)
- [ ] Error budget restant et burn rate des SLO
- [ ] Vue d'exploitation : réplicas, HPA, redémarrages, raisons de terminaison

Aucun dashboard créé à la main dans l'interface Grafana : il serait perdu à la prochaine reconstruction de la plateforme.
