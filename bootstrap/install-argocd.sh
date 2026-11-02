#!/usr/bin/env bash
# ==============================================================================
# SECUREPAY PLATFORM - INSTALLATION D'ARGO CD
# ==============================================================================
# Argo CD est le seul composant installé « à la main » (par ce script versionné) :
# tout le reste de la plateforme est ensuite déployé par Argo CD depuis Git.
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=bootstrap/versions.env
source "${SCRIPT_DIR}/versions.env"

log() { echo "[install-argocd] $*"; }

log "Installation du chart argo-cd ${ARGOCD_CHART_VERSION}"
helm repo add argo https://argoproj.github.io/argo-helm --force-update >/dev/null
helm upgrade --install argocd argo/argo-cd \
  --version "${ARGOCD_CHART_VERSION}" \
  --namespace argocd \
  --create-namespace \
  --values "${SCRIPT_DIR}/argocd-values.yaml" \
  --wait \
  --timeout 10m

# ------------------------------------------------------------------------------
# Accès en lecture d'Argo CD au dépôt GitLab privé securepay-platform
# ------------------------------------------------------------------------------
# Secret de bootstrap : c'est le seul secret créé hors de Git, parce qu'aucun
# mécanisme de chiffrement n'existe encore dans le cluster à ce stade.
# TODO [J2] : le remplacer par un SealedSecret (ou SOPS) versionné dans Git.
CREDENTIALS_FILE="${SCRIPT_DIR}/repo-credentials.env"
if [[ -f "${CREDENTIALS_FILE}" ]]; then
  # shellcheck source=/dev/null
  source "${CREDENTIALS_FILE}"
  log "Déclaration du dépôt ${PLATFORM_REPO_URL} dans Argo CD"
  kubectl -n argocd create secret generic repo-securepay-platform \
    --from-literal=type=git \
    --from-literal=url="${PLATFORM_REPO_URL}" \
    --from-literal=username="${GITLAB_DEPLOY_TOKEN_USERNAME}" \
    --from-literal=password="${GITLAB_DEPLOY_TOKEN}" \
    --dry-run=client -o yaml \
    | kubectl label --local -f - argocd.argoproj.io/secret-type=repository -o yaml \
    | kubectl apply -f -
  # Le fichier a été transféré dans la VM : on ne l'y laisse pas traîner
  shred -u "${CREDENTIALS_FILE}"
else
  log "Pas de ${CREDENTIALS_FILE} : dépôt supposé public, aucun identifiant déclaré"
fi
