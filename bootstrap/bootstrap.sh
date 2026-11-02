#!/usr/bin/env bash
# ==============================================================================
# SECUREPAY PLATFORM - BOOTSTRAP DE BOUT EN BOUT (exécuté dans la VM, en root)
# ==============================================================================
# Lancé depuis le poste par `make bootstrap`. Rejouable sans effet de bord.
#   1. Outils (Docker, k3d, kubectl, helm)
#   2. Cluster k3d
#   3. Argo CD
#   4. Application racine (app-of-apps) : à partir de là, Git est la source de vérité
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPS_DIR="$(cd "${SCRIPT_DIR}/../apps" && pwd)"

"${SCRIPT_DIR}/install-tools.sh"
"${SCRIPT_DIR}/create-cluster.sh"
"${SCRIPT_DIR}/install-argocd.sh"

if grep -rq '<groupe>' "${APPS_DIR}"; then
  cat >&2 <<'EOF'
[bootstrap] Les Applications Argo CD contiennent encore le placeholder <groupe>.
[bootstrap] Remplacez-le par votre groupe GitLab dans apps/, committez, puis relancez `make bootstrap`.
EOF
  exit 1
fi

echo "[bootstrap] Application racine Argo CD"
kubectl apply -f "${APPS_DIR}/root.yaml"

cat <<'EOF'
[bootstrap] Terminé. Depuis le poste :
  make hosts             # lignes à ajouter dans /etc/hosts
  make argocd-password   # mot de passe initial de l'utilisateur admin d'Argo CD
EOF
