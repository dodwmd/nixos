.PHONY: help switch test build boot check update clean gc list-generations diff hosts remote remote-rebuild rekey update-host-key

# Default host (can be overridden: make switch HOST=k3s-master-01)
HOST ?= exodus

# SSH target for remote operations (defaults to HOST if not set)
TARGET ?= $(HOST)

# Default target
help:
	@echo "NixOS Homelab Configuration Management"
	@echo ""
	@echo "Available targets:"
	@echo "  switch [HOST=name] - Build and switch to new configuration"
	@echo "  test [HOST=name]   - Build and test configuration (no bootloader update)"
	@echo "  build [HOST=name]  - Build configuration without activating"
	@echo "  boot [HOST=name]   - Build and set as boot default (activate on reboot)"
	@echo "  diff [HOST=name]   - Show diff between current and new config"
	@echo "  hosts              - List all available hosts"
	@echo "  check              - Check flake for errors"
	@echo "  update             - Update flake inputs"
	@echo "  clean              - Clean build artifacts"
	@echo "  gc                 - Garbage collect old generations (7 days)"
	@echo "  gc-all             - Garbage collect all old generations"
	@echo "  list-generations   - List all system generations"
	@echo "  fmt                - Format nix files with alejandra"
	@echo ""
	@echo "Remote deployment:"
	@echo "  remote HOST=name [TARGET=addr]         - Initial install via nixos-anywhere"
	@echo "  remote-rebuild HOST=name [TARGET=addr] - Rebuild remote host via nixos-rebuild"
	@echo ""
	@echo "Secrets management:"
	@echo "  rekey                                  - Re-encrypt all agenix secrets"
	@echo "  update-host-key HOST=name              - Pull host key from HOST and rekey secrets"
	@echo ""
	@echo "Available hosts:"
	@echo "  exodus, k3s-master-01, k3s-master-02, k3s-worker-01,"
	@echo "  k3s-worker-02, k3s-worker-03, nexus"
	@echo ""
	@echo "Examples:"
	@echo "  make switch                    # Build and switch exodus (default)"
	@echo "  make switch HOST=k3s-master-01 # Build and switch k3s-master-01"
	@echo "  make build HOST=nexus          # Build nexus configuration"
	@echo "  make remote HOST=nexus         # Install nixos on nexus via nixos-anywhere"
	@echo "  make remote-rebuild HOST=nexus TARGET=192.168.1.50 # Rebuild with explicit IP"

# List available hosts
hosts:
	@echo "Available hosts:"
	@ls -1 hosts/ | grep -v default.nix | sort

# Main operations
switch:
	@echo "Building and switching to $(HOST)..."
	sudo nixos-rebuild switch --flake path:$(PWD)#$(HOST)

test:
	@echo "Testing $(HOST) configuration..."
	sudo nixos-rebuild test --flake path:$(PWD)#$(HOST)

build:
	@echo "Building $(HOST) configuration..."
	nixos-rebuild build --flake path:$(PWD)#$(HOST)

boot:
	@echo "Setting $(HOST) as boot default..."
	sudo nixos-rebuild boot --flake path:$(PWD)#$(HOST)

# Remote deployment (requires HOST to be explicitly set)
remote:
ifeq ($(HOST),exodus)
	$(error HOST must be set for remote deployment, e.g. make remote HOST=nexus)
endif
	@echo "Installing NixOS on $(TARGET) with $(HOST) configuration via nixos-anywhere..."
	@# Prepare extra-files with pre-provisioned host key if available
	$(eval EXTRA_FILES_DIR := $(shell mktemp -d))
	@if [ -f "$(PWD)/secrets/host-keys/$(HOST).age" ]; then \
		echo "Decrypting pre-provisioned host key for $(HOST)..."; \
		mkdir -p "$(EXTRA_FILES_DIR)/etc/ssh"; \
		nix-shell -p age --run "age -d -i ~/.ssh/id_ed25519 $(PWD)/secrets/host-keys/$(HOST).age" > "$(EXTRA_FILES_DIR)/etc/ssh/ssh_host_ed25519_key"; \
		chmod 600 "$(EXTRA_FILES_DIR)/etc/ssh/ssh_host_ed25519_key"; \
		cp "$(PWD)/secrets/host-keys/$(HOST).pub" "$(EXTRA_FILES_DIR)/etc/ssh/ssh_host_ed25519_key.pub"; \
		chmod 644 "$(EXTRA_FILES_DIR)/etc/ssh/ssh_host_ed25519_key.pub"; \
	fi
	nix run github:nix-community/nixos-anywhere -- --flake path:$(PWD)#$(HOST) --ssh-option "IdentityFile=~/.ssh/id_ed25519" --extra-files "$(EXTRA_FILES_DIR)" root@$(TARGET)
	@rm -rf "$(EXTRA_FILES_DIR)"

remote-rebuild:
ifeq ($(HOST),exodus)
	$(error HOST must be set for remote rebuild, e.g. make remote-rebuild HOST=nexus)
endif
	@echo "Rebuilding $(HOST) on $(TARGET)..."
	nixos-rebuild switch --flake path:$(PWD)#$(HOST) --target-host $(TARGET) --sudo

# Maintenance
check:
	nix flake check path:$(PWD)

update:
	nix flake update path:$(PWD)

clean:
	rm -f result

gc:
	sudo nix-collect-garbage --delete-older-than 7d

gc-all:
	sudo nix-collect-garbage -d

list-generations:
	sudo nix-env -p /nix/var/nix/profiles/system --list-generations

# Show what would change
diff:
	@echo "Showing diff for $(HOST)..."
	nixos-rebuild build --flake .#$(HOST)
	nix store diff-closures /run/current-system ./result

# Format nix files
fmt:
	nix fmt

# Secrets management
rekey:
	@echo "Re-encrypting all agenix secrets..."
	RULES=./.agenix.nix nix run github:ryantm/agenix -- -r -i ~/.ssh/id_ed25519

update-host-key:
ifeq ($(HOST),exodus)
	$(error HOST must be set, e.g. make update-host-key HOST=k3s-master-01)
endif
	@echo "Pulling host key from $(HOST) and updating secrets..."
	@ssh $(TARGET) 'cat /etc/ssh/ssh_host_ed25519_key.pub' > /tmp/$(HOST)-host-key.pub
	@echo "Public key: $$(cat /tmp/$(HOST)-host-key.pub)"
	@ssh $(TARGET) 'sudo cat /etc/ssh/ssh_host_ed25519_key' > /tmp/$(HOST)-host-key
	@chmod 600 /tmp/$(HOST)-host-key
	@PUB_KEY=$$(awk '{print $$1" "$$2}' /tmp/$(HOST)-host-key.pub); \
	nix-shell -p age --run "age \
		-r 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII1Vk18qExSQM6rksG500xD/mgACFpNyh7mRnrhVVUQx dodwmd@exodus' \
		-r \"$$PUB_KEY\" \
		/tmp/$(HOST)-host-key" > secrets/host-keys/$(HOST).age
	@rm -f /tmp/$(HOST)-host-key /tmp/$(HOST)-host-key.pub
	@echo "Host key encrypted to secrets/host-keys/$(HOST).age"
	@echo "Now update .agenix.nix with the new public key, then run: make rekey"
