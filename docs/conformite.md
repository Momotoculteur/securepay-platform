# Matrice de conformité PSSI - SecurePay Platform

> Jalon J2, complétée jusqu'au J5. Elle relie chaque exigence de sécurité à son contrôle technique, à l'outil qui le vérifie et à la preuve horodatée.

**Référentiels :** CIS Benchmark Ubuntu Linux 24.04 LTS (niveau 1), guide ANSSI BP-028, CIS Kubernetes Benchmark et guide de durcissement k3s, Pod Security Standards (`restricted`), OWASP Kubernetes Top 10.

## Matrice

| ID | Exigence | Référentiel | Risque couvert | Contrôle | Outil de vérification | Preuve | Statut |
| :---: | :--- | :--- | :---: | :--- | :--- | :--- | :---: |
| C01 | Aucun secret en clair dans les dépôts | PSSI | R01 | Gitleaks bloquant en CI | Pipeline securepay-api | `docs/preuves/...` | À faire |
| C02 | | | | | | | |
| C03 | | | | | | | |

## Scores d'audit avant / après

| Couche | Outil | Avant | Après | Preuves |
| :--- | :--- | :---: | :---: | :--- |
| Machine | Lynis (indice de durcissement) | | | |
| Cluster | kube-bench (profil k3s) | | | |
| Cluster | Kubescape ou `trivy k8s --compliance` | | | |

## Dérogations

Une recommandation non appliquée n'est acceptable que justifiée, compensée et revue.

| ID | Recommandation non appliquée | Référence | Justification | Mesure compensatoire | Validée par | Revue le |
| :---: | :--- | :--- | :--- | :--- | :--- | :--- |
| D01 | `net.ipv4.ip_forward = 0` | CIS Ubuntu 24.04 | Requis par Docker et k3s pour router le trafic des conteneurs | TODO [J2] | | |
