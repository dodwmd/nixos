.PHONY: help switch test build boot check update clean gc list-generations diff hosts

# Default host (can be overridden: make switch HOST=k3s-master-01)
HOST ?= exodus

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
	@echo "Available hosts:"
	@echo "  exodus, k3s-master-01, k3s-master-02, k3s-worker-01,"
	@echo "  k3s-worker-02, k3s-worker-03, nexus"
	@echo ""
	@echo "Examples:"
	@echo "  make switch                    # Build and switch exodus (default)"
	@echo "  make switch HOST=k3s-master-01 # Build and switch k3s-master-01"
	@echo "  make build HOST=nexus          # Build nexus configuration"

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
