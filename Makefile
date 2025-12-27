.PHONY: help switch test build boot check update clean gc list-generations diff

# Default target
help:
	@echo "NixOS Kaku Configuration Management"
	@echo ""
	@echo "Available targets:"
	@echo "  switch           - Build and switch to new configuration"
	@echo "  test             - Build and test configuration (no bootloader update)"
	@echo "  build            - Build configuration without activating"
	@echo "  boot             - Build and set as boot default (activate on reboot)"
	@echo "  check            - Check flake for errors"
	@echo "  update           - Update flake inputs"
	@echo "  clean            - Clean build artifacts"
	@echo "  gc               - Garbage collect old generations (7 days)"
	@echo "  gc-all           - Garbage collect all old generations"
	@echo "  list-generations - List all system generations"
	@echo "  diff             - Show diff between current and new config"
	@echo "  fmt              - Format nix files with alejandra"

# Main operations
switch:
	sudo nixos-rebuild switch --flake path:$(PWD)#exodus

test:
	sudo nixos-rebuild test --flake path:$(PWD)#exodus

build:
	nixos-rebuild build --flake path:$(PWD)#exodus

boot:
	sudo nixos-rebuild boot --flake path:$(PWD)#exodus

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
	nixos-rebuild build --flake .#exodus
	nix store diff-closures /run/current-system ./result

# Format nix files
fmt:
	nix fmt
