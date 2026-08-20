{ config, lib, pkgs, modulesPath, ... }:

let
  # Authelia forward-auth for nexus's standalone nginx (services.nginx, not
  # k8s ingress-nginx). nexus isn't part of the k3s cluster, so Authelia is
  # reached over its public hostname rather than an in-cluster service name.
  # See ~/code/homelab/k3s/apps/authelia for the Authelia deployment itself.
  autheliaAuthRequestConfig = ''
    auth_request /internal/authelia/authz;

    auth_request_set $user $upstream_http_remote_user;
    auth_request_set $groups $upstream_http_remote_groups;
    auth_request_set $name $upstream_http_remote_name;
    auth_request_set $email $upstream_http_remote_email;

    proxy_set_header Remote-User $user;
    proxy_set_header Remote-Groups $groups;
    proxy_set_header Remote-Name $name;
    proxy_set_header Remote-Email $email;

    auth_request_set $redirection_url $upstream_http_location;
    error_page 401 =302 $redirection_url;
  '';

  autheliaInternalLocation = {
    extraConfig = ''
      internal;
      resolver 192.168.1.1 valid=30s;
      set $upstream_authelia https://auth.home.dodwell.us/api/authz/auth-request;
      proxy_pass $upstream_authelia;

      # Required so the (SNI-routed) k3s ingress-nginx sends us Authelia's
      # vhost instead of whatever the default backend happens to be.
      proxy_ssl_server_name on;

      proxy_set_header X-Original-Method $request_method;
      proxy_set_header X-Original-URL $scheme://$host$request_uri;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header Content-Length "";
      proxy_set_header Connection "";

      proxy_pass_request_body off;
      proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
      proxy_redirect http:// $scheme://;
      proxy_http_version 1.1;
    '';
  };
in
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  # Use LTS kernel for ZFS compatibility
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages;

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
      /tank 192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash,insecure)
      /tank/data 192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash,insecure)
      /tank/config 192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash,insecure)
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

  # PostgreSQL for media services (Step 1: enable this first, migrate, then enable usePostgresql)
  homelab.media.postgresql.enable = true;

  # Core *arr services with PostgreSQL (migrated)
  # downloadsPath must match the corresponding aria2 container's download directory
  # so that paths reported by aria2 resolve correctly inside the *arr container
  homelab.media.sonarr = {
    enable = true;
    usePostgresql = true;
    downloadsPath = "/tank/data/downloads/tv";
  };
  homelab.media.radarr = {
    enable = true;
    usePostgresql = true;
    downloadsPath = "/tank/data/downloads/movies";
  };

  # Prowlarr stays on SQLite (doesn't support env var config)
  homelab.media.prowlarr.enable = true;

  # Other services on SQLite (can migrate later if needed)
  homelab.media.lidarr = {
    enable = true;
    downloadsPath = "/tank/data/downloads/music";
  };
  homelab.media.readarr = {
    enable = true;
    downloadsPath = "/tank/data/downloads/books";
  };
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
    credentialFiles."CF_DNS_API_TOKEN_FILE" = "/var/lib/acme/cloudflare-dns-api-token";
    
    virtualHosts = {
      "sonarr.home.dodwell.us" = {
        proxyPass = "http://127.0.0.1:8989";
        extraConfig = ''
          proxy_read_timeout 300s;
          proxy_connect_timeout 300s;
          proxy_send_timeout 300s;
          proxy_buffers 16 256k;
          proxy_buffer_size 256k;
          proxy_busy_buffers_size 512k;
          client_max_body_size 0;
        '' + autheliaAuthRequestConfig;
        extraLocations."/internal/authelia/authz" = autheliaInternalLocation;
      };
      "radarr.home.dodwell.us" = {
        proxyPass = "http://127.0.0.1:7878";
        extraConfig = ''
          proxy_read_timeout 300s;
          proxy_connect_timeout 300s;
          proxy_send_timeout 300s;
          proxy_buffers 16 256k;
          proxy_buffer_size 256k;
          proxy_busy_buffers_size 512k;
          client_max_body_size 0;
        '' + autheliaAuthRequestConfig;
        extraLocations."/internal/authelia/authz" = autheliaInternalLocation;
      };
      "prowlarr.home.dodwell.us" = {
        proxyPass = "http://127.0.0.1:9696";
        extraConfig = autheliaAuthRequestConfig;
        extraLocations."/internal/authelia/authz" = autheliaInternalLocation;
      };
      "lidarr.home.dodwell.us" = {
        proxyPass = "http://127.0.0.1:8686";
        extraConfig = autheliaAuthRequestConfig;
        extraLocations."/internal/authelia/authz" = autheliaInternalLocation;
      };
      "readarr.home.dodwell.us" = {
        proxyPass = "http://127.0.0.1:8787";
        extraConfig = autheliaAuthRequestConfig;
        extraLocations."/internal/authelia/authz" = autheliaInternalLocation;
      };
      "bazarr.home.dodwell.us" = {
        proxyPass = "http://127.0.0.1:6767";
        extraConfig = autheliaAuthRequestConfig;
        extraLocations."/internal/authelia/authz" = autheliaInternalLocation;
      };
      "tdarr.home.dodwell.us" = {
        proxyPass = "http://127.0.0.1:8265";
        extraConfig = autheliaAuthRequestConfig;
        extraLocations."/internal/authelia/authz" = autheliaInternalLocation;
      };
      "download.home.dodwell.us" = {
        proxyPass = "http://127.0.0.1:6880";
        # Pre-seed AriaNg's localStorage (on a browser's first visit only) with all
        # 4 aria2 RPC backends, routed same-origin through the /jsonrpc/* locations
        # below, so a fresh browser never needs the RPC settings entered by hand.
        extraConfig = ''
          proxy_set_header Accept-Encoding "";
          sub_filter_types text/html;
          sub_filter_once on;
          sub_filter '<head>' '<head><script>(function(){try{if(localStorage.getItem("AriaNg.Options")){return;}var mk=function(id,alias,secret){return {rpcId:id,rpcAlias:alias,rpcHost:"download.home.dodwell.us",rpcPort:"443",rpcInterface:"jsonrpc/"+id,protocol:"https",httpMethod:"POST",rpcRequestHeaders:"",secret:btoa(secret)};};var servers=[mk("radarr","Radarr","aria2-radarr-secret"),mk("sonarr","Sonarr","aria2-sonarr-secret"),mk("lidarr","Lidarr","aria2-lidarr-secret"),mk("readarr","Readarr","aria2-readarr-secret")];var primary=servers[0];var options={rpcAlias:primary.rpcAlias,rpcHost:primary.rpcHost,rpcPort:primary.rpcPort,rpcInterface:primary.rpcInterface,protocol:primary.protocol,httpMethod:primary.httpMethod,rpcRequestHeaders:primary.rpcRequestHeaders,secret:primary.secret,extendRpcServers:servers.slice(1)};localStorage.setItem("AriaNg.Options",JSON.stringify(options));}catch(e){}})();</script>';
        '' + autheliaAuthRequestConfig;
        # Only the AriaNg UI itself ("/") is gated. /jsonrpc/* stays open so
        # Radarr/Sonarr/etc's own programmatic RPC calls, and AriaNg's
        # in-page RPC calls after login, don't get blocked by auth_request.
        extraLocations = {
          "/internal/authelia/authz" = autheliaInternalLocation;
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
      "jellyseerr.home.dodwell.us" = {
        proxyPass = "http://127.0.0.1:5055";
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

  # Redirect requests.home.dodwell.us -> jellyseerr.home.dodwell.us
  security.acme.certs."requests.home.dodwell.us" = {
    dnsProvider = config.homelab.nginx-proxy.dnsProvider;
    webroot = null;
  };
  services.nginx.virtualHosts."requests.home.dodwell.us" = {
    forceSSL = true;
    enableACME = true;
    locations."/".return = "301 https://jellyseerr.home.dodwell.us$request_uri";
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
    age
  ];

  # System state version (matching original)
  system.stateVersion = "25.11";
}
