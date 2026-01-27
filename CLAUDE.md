# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a NixOS configuration repository forked from [linuxmobile/kaku](https://github.com/linuxmobile/kaku), extended with comprehensive homelab infrastructure management. It manages 7 hosts including a desktop workstation (exodus) and a 5-node K3s cluster, with extensive media server and infrastructure services.

## Building and Switching Configurations

### Using the Makefile (Recommended)

```bash
# Build and switch configuration
make switch                    # Default: exodus
make switch HOST=k3s-master-01 # Specific host
make switch HOST=nexus

# Other operations
make build HOST=exodus         # Build without switching
make test HOST=exodus          # Test without bootloader update
make boot HOST=exodus          # Set as boot default
make diff HOST=exodus          # Show what would change

# Maintenance
make check                     # Check flake for errors
make update                    # Update flake inputs
make fmt                       # Format nix files with alejandra
make gc                        # Garbage collect (7+ days old)
make gc-all                    # Garbage collect all old
make list-generations          # List system generations
make hosts                     # List available hosts
```

### Using nixos-rebuild directly

```bash
nixos-rebuild switch --flake .#exodus
nixos-rebuild switch --flake .#k3s-master-01
```

### Using nh (Alternative)

```bash
nh os switch .#exodus
nh os switch .#k3s-master-01
```

### Home Manager

```bash
# For homelab desktop setup
home-manager switch --flake .#exodus@exodus

# For original aesthetic profile
home-manager switch --flake .#linudev@aesthetic
```

## Available Hosts

- **exodus** - Desktop workstation (Intel + NVIDIA RTX 4080, Niri WM, LUKS encryption)
- **k3s-master-01, k3s-master-02** - K3s master nodes
- **k3s-worker-01, k3s-worker-02, k3s-worker-03** - K3s worker nodes
- **nexus** - Additional host

## Architecture

### Configuration Structure

The repository uses a modular Nix flake structure with profile-based system composition and code generation patterns:

```
flake.nix                    # Root flake, imports hosts/ and pkgs/
├── hosts/                   # Host-specific configurations
│   ├── default.nix         # Defines nixosConfigurations
│   ├── exodus/             # Desktop workstation config
│   ├── k3s-master-01/02/   # K3s master nodes (minimal config using host-common)
│   ├── k3s-worker-01/02/03/# K3s worker nodes (minimal config using host-common)
│   └── nexus/              # Media server
├── system/                  # NixOS system modules
│   ├── default.nix         # Exports profile compositions (desktop, laptop, server, k3s-master, k3s-worker, media-server)
│   ├── core/               # Base system config
│   │   ├── default.nix    # Base imports
│   │   ├── security.nix   # Security hardening
│   │   ├── user-roles.nix # Centralized user management (desktopUser, serverUser)
│   │   ├── ssh-keys.nix   # Centralized SSH key definitions
│   │   ├── boot-desktop.nix # Desktop boot config (quiet, plymouth)
│   │   └── boot-server.nix  # Server boot config (verbose messages)
│   ├── hardware/           # Hardware modules (graphics, bluetooth, fwupd)
│   ├── network/            # Network configuration (NetworkManager for desktop)
│   ├── programs/           # System programs
│   └── services/           # System services
│       ├── k3s/           # K3s cluster modules
│       │   ├── host-common.nix  # Common config for all K3s nodes (SSH, network, packages, auto-upgrade)
│       │   ├── common.nix       # K3s service common config
│       │   ├── master.nix       # K3s master-specific config
│       │   └── worker.nix       # K3s worker-specific config
│       └── media/         # Media stack
│           ├── services.nix     # Generated *arr services using mkMediaService
│           ├── jellyfin.nix     # Complex service with hardware accel
│           ├── tdarr.nix        # Media transcoding
│           ├── aria2.nix        # Download manager
│           ├── adguard.nix      # DNS/ad-blocking
│           └── homepage.nix     # Dashboard
├── home/                   # Home-Manager configurations
│   ├── default.nix        # Imports editors, packages, services, terminal
│   ├── editors/           # Editor configurations
│   ├── packages/          # User packages (browsers, wayland, gtk, media)
│   ├── profiles/          # Machine type profiles
│   │   ├── desktop/       # Desktop profile (Wayland, GUI apps, editors)
│   │   └── server/        # Server profile (minimal CLI tools)
│   ├── services/          # User services
│   └── terminal/          # Terminal configuration
├── pkgs/                   # Custom package overlays
└── lib/                    # Utility functions
    └── mk-media-service.nix # Generator function for media services
```

### Profile System (system/default.nix)

Configurations are built from composable profiles:

- **base** - Core system (security, users, nix settings)
- **desktop** - base + boot + graphics + network + programs + services (greetd, pipewire, xdg-portal)
- **laptop** - desktop + bluetooth + power management
- **server** - base + boot + podman (minimal, no desktop)
- **media-server** - server + zfs + nfs + nginx + netdata + media services
- **k3s-master** - server + k3s modules
- **k3s-worker** - server + k3s modules

Host configurations in `hosts/*/default.nix` select a profile and add host-specific hardware and settings.

### Key Design Patterns

1. **Flake Parts**: Uses `flake-parts` for modular flake organization
2. **Import Tree**: Uses `import-tree` to automatically import nested modules
3. **Profile Composition**: System configurations are built by composing module lists (see system/default.nix)
4. **Separation of Concerns**: System-level configs in `system/`, user configs in `home/`, host-specific in `hosts/`
5. **NixOS + Home-Manager**: System managed via NixOS modules, user environment via Home-Manager
6. **Code Generation**: Services with similar patterns (media stack) use generator functions to reduce duplication
7. **Centralized Management**: SSH keys, user roles, and common host configs centralized to single source of truth

### Important Modules

- **system/core/security.nix** - System security hardening
- **system/core/user-roles.nix** - Centralized user management with `desktopUser` and `serverUser` roles
- **system/core/ssh-keys.nix** - Single source of truth for SSH public keys
- **system/core/boot-{desktop,server}.nix** - Boot configurations for different machine types
- **system/nix/** - Nix daemon and flake configuration
- **system/services/k3s/host-common.nix** - Common configuration shared by all K3s nodes (reduces duplication by 80%)
- **system/services/k3s/** - K3s cluster configuration with HA setup
- **system/services/media/services.nix** - Generated media services using mkMediaService function
- **lib/mk-media-service.nix** - Generator function for media services (reduces 700+ lines to ~100)
- **home/profiles/desktop/** - Desktop machine profile (Wayland, GUI apps, editors)
- **home/profiles/server/** - Server machine profile (minimal CLI tools)
- **home/packages/wayland/niri/** - Niri window manager configuration with keybinds, rules, settings

### Desktop (exodus) Specifics

- **Window Manager**: Niri (scrollable tiling WM)
- **Shell**: Nu (Nushell) with Starship prompt
- **Terminal**: Ghostty
- **Panel**: DMS Quickshell (DankMaterialShell)
- **File Manager**: Yazi
- **Editor**: Helix
- **Security**: Extensive kernel hardening, AppArmor, TPM2, LUKS encryption
- **Graphics**: NVIDIA RTX 4080 (proprietary driver), custom XWayland with glamor disabled
- **Gaming**: Steam with Proton GE, gamescope, mangohud

### Flake Inputs

- **nixpkgs** - NixOS unstable
- **flake-parts** - Modular flake framework
- **import-tree** - Auto-import nested modules
- **agenix** - Secret management
- **chaotic** - Chaotic-AUR packages
- **mynixpkgs** - Custom fork (github:dodwmd/mynixpkgs)
- **nix-index-db** - nix-index database
- **noctalia-shell** - Noctalia shell integration

## Formatter

The repository uses `alejandra` as the Nix formatter:

```bash
nix fmt              # Format all nix files
make fmt             # Same via Makefile
```

## Development Shell

```bash
nix develop          # Enter dev shell with alejandra, git, and repl
direnv allow         # If using direnv (.envrc present)
```

## Homelab Infrastructure

### K3s Cluster

- 5-node HA cluster (2 masters, 3 workers)
- Static IP configuration
- Custom modules: `homelab.k3s-master`, `homelab.k3s-worker`
- TLS SAN certificates for HA
- Configuration in `system/services/k3s/`

### Media Stack

All services configured in `system/services/media/`:

- **Jellyfin** - Media server with hardware acceleration
- **Sonarr, Radarr, Lidarr, Readarr, Bazarr** - Media management
- **Jellyseerr** - Media requests
- **Prowlarr** - Indexer management
- **Tdarr** - Media transcoding
- **Homepage** - Unified dashboard

### Infrastructure Services

- **AdGuard Home** - DNS/ad-blocking
- **Netdata** - System monitoring
- **NFS Server** - Centralized storage
- **Nginx Proxy** - Reverse proxy
- **ZFS** - Advanced storage with snapshots
- **Ollama** - Local LLM inference (on exodus)

## Common Workflows

### Adding a New Host

1. Generate hardware config: `nixos-generate-config --dir hosts/new-host`
2. Create `hosts/new-host/default.nix` importing appropriate profile from `system/default.nix`
3. **For K3s nodes**: Use `homelab.k3s-host` module for common configuration:
   ```nix
   homelab.k3s-host = {
     enable = true;
     hostname = "k3s-worker-04";
     upgradeTime = "04:30";
     allowReboot = true;
     cpuGovernor = "ondemand";
     extraPackages = with pkgs; [ /* node-specific packages */ ];
   };
   ```
4. **For servers**: Enable centralized user management:
   ```nix
   homelab.users.serverUser.enable = true;
   ```
5. **For desktops**: Enable desktop user and profile:
   ```nix
   homelab.users.desktopUser.enable = true;
   imports = [ ../../home/profiles/desktop/packages.nix ];
   ```
6. Add host to `hosts/default.nix` in `nixosConfigurations`
7. Build: `make build HOST=new-host`

### Modifying System Configuration

- System-wide: Edit files in `system/`
- Host-specific: Edit `hosts/HOSTNAME/default.nix`
- User environment: Edit files in `home/`

### Adding a New Service

**For media services** (*arr-style applications):
1. Add entry to `system/services/media/services.nix` using `mkMediaService`:
   ```nix
   (mkMediaService {
     name = "bazarr";
     description = "Bazarr subtitle management";
     port = 6767;
     image = "lscr.io/linuxserver/bazarr:latest";
   })
   ```
2. Enable on host: `homelab.media.bazarr.enable = true;`

**For complex services** (with unique configuration):
1. Create dedicated module in `system/services/` or `home/services/`
2. Import in appropriate profile (system/default.nix) or default.nix
3. Configure service options in module

### Working with Secrets

- Uses agenix for secret management
- Config in `.agenix.nix`
- Secrets stored in `secrets/`

## Important Files to Check Before Changes

- **system/default.nix** - Profile definitions that compose all system configurations
- **hosts/default.nix** - Host configuration registry
- **system/core/security.nix** - Security hardening (changes may affect all hosts)
- **flake.nix** - Input dependencies and flake structure

## Notes

- The exodus host has extensive kernel hardening and security features (see hosts/exodus/default.nix)
- NVIDIA configuration requires specific XWayland patches (glamor disabled)
- Default user/password during installation: nixos/nixos
- State version is now 25.11 across all hosts
- Uses NixOS unstable channel

## Recent Refactoring (2026-01)

Major code deduplication and standardization improvements:

1. **K3s Host Configuration** - Reduced from 600+ lines to ~200 lines across 5 hosts
   - Created `system/services/k3s/host-common.nix` for shared configuration
   - Each host now ~40-84 lines vs 107-149 lines previously
   - Centralized: SSH config, network setup, packages, auto-upgrade, garbage collection

2. **Media Services** - Reduced from 700+ lines to ~100 lines
   - Created `lib/mk-media-service.nix` generator function
   - Seven *arr services + jellyseerr now defined in single file (`system/services/media/services.nix`)
   - Old individual service files moved to `system/services/media/_old/`

3. **User Management** - Consolidated from 4+ locations to 1
   - Created `system/core/user-roles.nix` with `desktopUser` and `serverUser` roles
   - Created `system/core/ssh-keys.nix` for centralized SSH key management
   - All hosts now use correct dodwmd@exodus SSH key

4. **Boot Configuration** - Split by machine type
   - `system/core/boot-desktop.nix` - Quiet boot with plymouth for desktops
   - `system/core/boot-server.nix` - Verbose boot messages for servers
   - Removed all `lib.mkForce` overrides in host configs

5. **Home Profiles** - Machine type-based organization
   - `home/profiles/desktop/` - Full GUI environment for workstations
   - `home/profiles/server/` - Minimal CLI tools for headless servers
   - Replaced ad-hoc `home/profiles/exodus/` structure

**Total Impact**: ~1,300 lines removed while improving maintainability and consistency
