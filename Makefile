# Variables
KUBESPRAY_DIR := ./outputs
CONFIG_FILE := config.sh
DOCKERFILE := Dockerfile
BUILD_SCRIPT := igz_make_offline.sh
DEPLOY_SCRIPT := igz_deploy.sh
UPGRADE_SCRIPT := _upgrade
RESET_SCRIPT := _reset
DOCKER_IMG := kubespray-offline

.PHONY: all build_offline build_offline_container deploy upgrade reset clean

# Default Target
all: deploy

# Pattern Rule
%:
	@ if [ -f $@ ]; then echo "Executing $@"; bash $@; else echo "Nothing to be done for $@"; fi

# Build offline
build_offline:
	@echo "Building offline..."
	source $(CONFIG_FILE); \
	bash $(BUILD_SCRIPT)

# Build offline container
build_offline_container: build_offline
	@echo "Building offline container..."
	docker build -t $(DOCKER_IMG) -f $(DOCKERFILE) .

# Deploy
deploy: build_offline_container
	@echo "Deploying..."
	bash $(DEPLOY_SCRIPT)

# Upgrade
upgrade:
	@echo "Upgrading..."
	bash $(UPGRADE_SCRIPT)

# Reset
reset:
	@echo "Resetting..."
	bash $(RESET_SCRIPT)

# Clean
clean:
	@echo "Cleaning up..."
	rm -rf $(KUBESPRAY_DIR)/*
