# ==============================================================================
# SECUREPAY PLATFORM - COMMANDES DU POSTE ÉTUDIANT
# ==============================================================================
# make help pour la liste des cibles. Prérequis : multipass, kubectl, helm, docker.
# ==============================================================================
VM_NAME             ?= securepay-prod
VM_CPUS             ?= 4
VM_MEMORY           ?= 8G
VM_DISK             ?= 40G
SSH_PUBLIC_KEY_FILE ?= $(HOME)/.ssh/id_ed25519.pub
REMOTE_DIR          := /home/ubuntu/securepay-platform
BUILD_DIR           := .build
VM_IP                = $(shell multipass info $(VM_NAME) 2>/dev/null | awk '/IPv4/ {print $$2; exit}')

.DEFAULT_GOAL := help
.PHONY: help vm bootstrap sync kubeconfig hosts argocd-password shell lint destroy

help: ## Affiche cette aide
	@awk 'BEGIN {FS = ":.*## "} /^[a-zA-Z_-]+:.*## / {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

vm: $(BUILD_DIR)/cloud-init.yaml ## Crée la VM Multipass de production (idempotent)
	@if multipass info $(VM_NAME) >/dev/null 2>&1; then \
		echo "VM $(VM_NAME) déjà présente"; \
	else \
		multipass launch 24.04 --name $(VM_NAME) --cpus $(VM_CPUS) --memory $(VM_MEMORY) \
			--disk $(VM_DISK) --cloud-init $(BUILD_DIR)/cloud-init.yaml --timeout 900; \
	fi

$(BUILD_DIR)/cloud-init.yaml: bootstrap/cloud-init.yaml
	@test -f $(SSH_PUBLIC_KEY_FILE) || { echo "Clé publique introuvable : $(SSH_PUBLIC_KEY_FILE) (SSH_PUBLIC_KEY_FILE=...)"; exit 1; }
	@mkdir -p $(BUILD_DIR)
	@sed "s|__SSH_PUBLIC_KEY__|$$(cat $(SSH_PUBLIC_KEY_FILE))|" $< > $@

sync: ## Copie bootstrap/ et apps/ dans la VM
	multipass exec $(VM_NAME) -- mkdir -p $(REMOTE_DIR)
	COPYFILE_DISABLE=1 tar -czf - bootstrap apps | multipass exec $(VM_NAME) -- tar -xzf - -C $(REMOTE_DIR)

bootstrap: sync ## Installe outils, cluster k3d, Argo CD et application racine (idempotent)
	multipass exec $(VM_NAME) -- sudo bash $(REMOTE_DIR)/bootstrap/bootstrap.sh

kubeconfig: ## Exporte un kubeconfig utilisable depuis le poste dans .build/kubeconfig
	@mkdir -p $(BUILD_DIR)
	@multipass exec $(VM_NAME) -- sudo k3d kubeconfig get securepay \
		| sed -E "s|server: https://[^:]+:6443|server: https://$(VM_IP):6443|" > $(BUILD_DIR)/kubeconfig
	@chmod 600 $(BUILD_DIR)/kubeconfig
	@echo "export KUBECONFIG=$(CURDIR)/$(BUILD_DIR)/kubeconfig"

hosts: ## Affiche les lignes à ajouter à /etc/hosts
	@echo "$(VM_IP) api.securepay.local argocd.securepay.local grafana.securepay.local prometheus.securepay.local alertmanager.securepay.local"

argocd-password: ## Affiche le mot de passe initial de l'utilisateur admin d'Argo CD
	@multipass exec $(VM_NAME) -- sudo kubectl -n argocd get secret argocd-initial-admin-secret \
		-o jsonpath='{.data.password}' | base64 --decode; echo

shell: ## Ouvre un shell dans la VM
	multipass shell $(VM_NAME)

lint: ## Rejoue localement les contrôles de la CI (Docker requis)
	docker run --rm -v "$(CURDIR)":/w -w /w python:3.13-slim \
		sh -c 'pip install --quiet --root-user-action=ignore yamllint==1.38.0 && yamllint --strict .'
	helm lint charts/securepay-api -f charts/securepay-api/values-production.yaml
	@mkdir -p rendered
	helm template securepay-api charts/securepay-api --namespace securepay \
		-f charts/securepay-api/values.yaml -f charts/securepay-api/values-production.yaml > rendered/securepay-api.yaml
	docker run --rm -v "$(CURDIR)":/w -w /w ghcr.io/yannh/kubeconform:v0.8.0 \
		-strict -summary -schema-location default \
		-schema-location 'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json' \
		-ignore-missing-schemas rendered/ apps/ observability/rules/ chaos/experiments/ policies/disallow-latest-tag.yaml
	docker run --rm -v "$(CURDIR)":/w -w /w ghcr.io/kyverno/kyverno-cli:v1.19.2 test policies/tests/
	k6 inspect tests/robustness/nominal-load.js > /dev/null

destroy: ## Supprime définitivement la VM (demande confirmation)
	@read -p "Supprimer définitivement la VM $(VM_NAME) et son cluster ? [y/N] " answer; \
		[ "$$answer" = "y" ] && multipass delete --purge $(VM_NAME) || echo "Abandon"
