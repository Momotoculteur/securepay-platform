#!/usr/bin/env bash
# ==============================================================================
# SECUREPAY PLATFORM - CRÉATION DU CLUSTER k3d
# ==============================================================================
# 1 server + 2 agents : la perte d'un agent est un scénario de chaos du jalon J4.
# L'API Kubernetes écoute sur <IP de la VM>:6443 pour être pilotée depuis le poste.
# Le load balancer k3d publie les ports 80 et 443 de la VM vers l'Ingress Traefik.
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=bootstrap/versions.env
source "${SCRIPT_DIR}/versions.env"

log() { echo "[create-cluster] $*"; }

if k3d cluster list -o json | jq -e --arg name "${CLUSTER_NAME}" 'any(.[]; .name == $name)' >/dev/null; then
  log "Cluster ${CLUSTER_NAME} déjà présent"
else
  VM_IP="$(hostname -I | awk '{print $1}')"
  log "Création du cluster ${CLUSTER_NAME} (${K3S_IMAGE}), API exposée sur ${VM_IP}:6443"
  k3d cluster create "${CLUSTER_NAME}" \
    --image "${K3S_IMAGE}" \
    --servers 1 \
    --agents 2 \
    --api-port "0.0.0.0:6443" \
    --k3s-arg "--tls-san=${VM_IP}@server:*" \
    -p "80:80@loadbalancer" \
    -p "443:443@loadbalancer" \
    --wait
fi

# kubeconfig pour root (scripts de bootstrap) et pour l'utilisateur ubuntu (multipass shell)
# L'adresse écrite par k3d varie selon l'environnement (0.0.0.0, host.docker.internal) :
# dans la VM, on vise toujours 127.0.0.1, présent dans le certificat de l'API k3s.
install -d -m 0700 /root/.kube
k3d kubeconfig get "${CLUSTER_NAME}" \
  | sed -E 's|server: https://[^:]+:6443|server: https://127.0.0.1:6443|' > /root/.kube/config
chmod 0600 /root/.kube/config

if id ubuntu >/dev/null 2>&1; then
  install -d -m 0700 -o ubuntu -g ubuntu /home/ubuntu/.kube
  install -m 0600 -o ubuntu -g ubuntu /root/.kube/config /home/ubuntu/.kube/config
fi

kubectl get nodes -o wide
