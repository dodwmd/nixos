{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Use LTS kernel for ZFS compatibility
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages;  # Use latest stable kernel compatible with ZFS

  # System identification
  networking.hostName = "nexus";
  networking.hostId = "8425e349";  # Required for ZFS
  
  # Network configuration (using DHCP like original)
  networking = {
    networkmanager.enable = false;
    useDHCP = false;
    interfaces.enp42s0.useDHCP = true;
  };

  # Bootloader configuration (matching original boot.nix)
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
  };
  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/boot";
  };

  # ZFS boot configuration is handled by the ZFS module

  # ZFS configuration
  homelab.zfs = {
    enable = true;
    arcMaxGB = 4;
    pools = [ "tank" ];
    autoScrub = true;
    scrubInterval = "monthly";
  };

  # NFS server configuration
  homelab.nfs-server = {
    enable = true;
    exports = ''
      /tank 192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash)
      /tank/data 192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash)
      /tank/config 192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash)
    '';
    lockdPort = 4001;
    mountdPort = 4002;
    statdPort = 4000;
    enableRmtcalls = true;
  };

  # Podman for containers
  homelab.podman.enable = true;

  # Media services
  homelab.media = {
    enable = true;
    mediaUser = "media";
    mediaGroup = "media";
    uid = 3000;
    gid = 3000;
  };

  homelab.media.sonarr.enable = true;
  homelab.media.radarr.enable = true;
  homelab.media.prowlarr.enable = true;
  homelab.media.lidarr.enable = true;
  homelab.media.readarr.enable = true;
  homelab.media.bazarr.enable = true;
  
  homelab.media.jellyfin = {
    enable = true;
    publishedServerUrl = "https://jellyfin.home.dodwell.us";
    enableHardwareAccel = true;
  };
  
  homelab.media.jellyseerr.enable = true;
  
  homelab.media.tdarr = {
    enable = true;
    transcodePath = "/mnt/nvme/tdarr-transcode";
    enableGPU = true;
  };
  
  homelab.media.aria2.enable = true;
  
  homelab.media.adguard.enable = true;
  
  homelab.media.homepage = {
    enable = true;
    allowedHosts = "nexus.home.dodwell.us,localhost,127.0.0.1";
  };

  # Netdata monitoring
  homelab.netdata = {
    enable = true;
    bindAddress = "127.0.0.1";
    historySeconds = 86400;
    enableZFSMonitoring = true;
  };

  # NGINX reverse proxy with ACME
  homelab.nginx-proxy = {
    enable = true;
    email = "michael@dodwell.us";
    dnsProvider = "cloudflare";
    credentialsFile = "/var/lib/acme/cloudflare-credentials";
    
    virtualHosts = {
      "sonarr.home.dodwell.us" = {
        proxyPass = "http://127.0.0.1:8989";
      };
      "radarr.home.dodwell.us" = {
        proxyPass = "http://127.0.0.1:7878";
      };
      "prowlarr.home.dodwell.us" = {
        proxyPass = "http://127.0.0.1:9696";
      };
      "lidarr.home.dodwell.us" = {
        proxyPass = "http://127.0.0.1:8686";
      };
      "readarr.home.dodwell.us" = {
        proxyPass = "http://127.0.0.1:8787";
      };
      "bazarr.home.dodwell.us" = {
        proxyPass = "http://127.0.0.1:6767";
      };
      "tdarr.home.dodwell.us" = {
        proxyPass = "http://127.0.0.1:8265";
      };
      "download.home.dodwell.us" = {
        proxyPass = "http://127.0.0.1:6880";
        extraLocations = {
          "/jsonrpc/radarr" = {
            proxyPass = "http://127.0.0.1:6800/jsonrpc";
            proxyWebsockets = true;
          };
          "/jsonrpc/sonarr" = {
            proxyPass = "http://127.0.0.1:6801/jsonrpc";
            proxyWebsockets = true;
          };
          "/jsonrpc/lidarr" = {
            proxyPass = "http://127.0.0.1:6802/jsonrpc";
            proxyWebsockets = true;
          };
          "/jsonrpc/readarr" = {
            proxyPass = "http://127.0.0.1:6803/jsonrpc";
            proxyWebsockets = true;
          };
        };
      };
      "jellyfin.home.dodwell.us" = {
        proxyPass = "http://127.0.0.1:8096";
        extraConfig = ''
          proxy_buffering off;
          client_max_body_size 0;
          
          # Jellyfin-specific headers
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $host;
          
          # Disable buffering for SSE
          proxy_set_header Connection "";
          chunked_transfer_encoding on;
        '';
      };
      "adguard.home.dodwell.us" = {
        proxyPass = "http://127.0.0.1:8053";
      };
      "netdata.home.dodwell.us" = {
        proxyPass = "http://127.0.0.1:19999";
      };
      "nexus.home.dodwell.us" = {
        proxyPass = "http://127.0.0.1:3000";
      };
    };
  };

  # User configuration - use centralized server user
  homelab.users.serverUser = {
    enable = true;
    username = "dodwmd";
    description = "Michael Dodwell";
  };

  users.users.root.extraGroups = [ "wheel" ];

  # Allow wheel group to use sudo without password (matching original)
  security.sudo.wheelNeedsPassword = false;

  # Nix configuration (matching original)
  nix = {
    extraOptions = ''
        experimental-features = nix-command flakes
    '';
  };

  # Allow unfree packages (matching original)
  nixpkgs.config.allowUnfree = true;

  # SSH configuration (matching original)
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = false;
    };
  };

  # System monitoring (matching original)
  services.sysstat = {
    enable = true;
    collect-frequency = "*:00/1"; # Collect every 1 minute (standard)
  };

  # Locale and timezone (matching original)
  time.timeZone = lib.mkForce "Australia/Brisbane";
  i18n.defaultLocale = lib.mkForce "en_US.UTF-8";

  # System packages
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    vim
    htop
    nfs-utils
    zfs
    smartmontools
    acl
    podman-compose
    sysstat
  ];

  # System state version (matching original)
  system.stateVersion = "25.11";
}
