#!/usr/bin/env bash
# ==============================================================================
# SECUREPAY PLATFORM - INSTALLATION DES OUTILS DANS LA VM
# ==============================================================================
# Installe Docker Engine, k3d, kubectl et helm.
# Idempotent : un outil déjà présent dans la bonne version n'est pas réinstallé.
# Chaque binaire téléchargé est vérifié par sa somme de contrôle SHA-256.
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=bootstrap/versions.env
source "${SCRIPT_DIR}/versions.env"

if [[ ${EUID} -ne 0 ]]; then
  echo "Ce script doit être exécuté en root (sudo)." >&2
  exit 1
fi

ARCH="$(dpkg --print-architecture)" # amd64 | arm64
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

log() { echo "[install-tools] $*"; }

# Vérifie qu'un fichier correspond à l'empreinte SHA-256 attendue
verify_sha256() {
  local file="$1" expected="$2" actual
  actual="$(sha256sum "${file}" | awk '{print $1}')"
  if [[ "${actual}" != "${expected}" ]]; then
    echo "Somme de contrôle invalide pour ${file} (attendu ${expected}, obtenu ${actual})" >&2
    exit 1
  fi
}

install_docker() {
  if command -v docker >/dev/null 2>&1; then
    log "Docker déjà installé : $(docker --version)"
    return
  fi
  log "Installation de Docker Engine depuis le dépôt APT officiel"
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc
  # shellcheck source=/dev/null
  . /etc/os-release
  echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${VERSION_CODENAME} stable" \
    > /etc/apt/sources.list.d/docker.list
  apt-get update -q
  DEBIAN_FRONTEND=noninteractive apt-get install -yq docker-ce docker-ce-cli containerd.io docker-buildx-plugin
  systemctl enable --now docker
}

install_k3d() {
  if command -v k3d >/dev/null 2>&1 && k3d version | grep -q "k3d version ${K3D_VERSION}"; then
    log "k3d ${K3D_VERSION} déjà installé"
    return
  fi
  log "Installation de k3d ${K3D_VERSION}"
  local base="https://github.com/k3d-io/k3d/releases/download/${K3D_VERSION}"
  curl -fsSLo "${TMP_DIR}/k3d" "${base}/k3d-linux-${ARCH}"
  curl -fsSLo "${TMP_DIR}/k3d-checksums.txt" "${base}/checksums.txt"
  # Les entrées du fichier de sommes sont préfixées par _dist/
  local expected
  expected="$(awk -v f="k3d-linux-${ARCH}" '$2 == f || $2 ~ ("/" f "$") {print $1}' "${TMP_DIR}/k3d-checksums.txt")"
  verify_sha256 "${TMP_DIR}/k3d" "${expected}"
  install -m 0755 "${TMP_DIR}/k3d" /usr/local/bin/k3d
}

install_kubectl() {
  if command -v kubectl >/dev/null 2>&1 && kubectl version --client 2>/dev/null | grep -q "${KUBECTL_VERSION}"; then
    log "kubectl ${KUBECTL_VERSION} déjà installé"
    return
  fi
  log "Installation de kubectl ${KUBECTL_VERSION}"
  local base="https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${ARCH}"
  curl -fsSLo "${TMP_DIR}/kubectl" "${base}/kubectl"
  verify_sha256 "${TMP_DIR}/kubectl" "$(curl -fsSL "${base}/kubectl.sha256")"
  install -m 0755 "${TMP_DIR}/kubectl" /usr/local/bin/kubectl
}

install_helm() {
  if command -v helm >/dev/null 2>&1 && helm version --short | grep -q "${HELM_VERSION}"; then
    log "helm ${HELM_VERSION} déjà installé"
    return
  fi
  log "Installation de helm ${HELM_VERSION}"
  local archive="helm-${HELM_VERSION}-linux-${ARCH}.tar.gz"
  curl -fsSLo "${TMP_DIR}/${archive}" "https://get.helm.sh/${archive}"
  verify_sha256 "${TMP_DIR}/${archive}" "$(curl -fsSL "https://get.helm.sh/${archive}.sha256sum" | awk '{print $1}')"
  tar -xzf "${TMP_DIR}/${archive}" -C "${TMP_DIR}"
  install -m 0755 "${TMP_DIR}/linux-${ARCH}/helm" /usr/local/bin/helm
}

install_docker
install_k3d
install_kubectl
install_helm
log "Outils prêts"
