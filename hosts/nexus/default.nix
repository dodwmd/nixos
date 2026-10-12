{
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ./nginx.nix
    ./openssh.nix
    ./sysstat.nix
  ];

  # Use LTS kernel for ZFS compatibility
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages;

  # System identification
  networking.hostName = "nexus";
  networking.hostId = "8425e349"; # Required for ZFS

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
    pools = ["tank"];
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
  # downloadsPath is left at its shared default (/tank/data/downloads) so it
  # mounts to the exact same container path as qBittorrent's downloadsPath
  # below - each app then filters to its own qBittorrent category (see
  # homelab.media.qbittorrent) rather than being isolated by mount.
  homelab.media.sonarr = {
    enable = true;
    usePostgresql = true;
  };
  homelab.media.radarr = {
    enable = true;
    usePostgresql = true;
  };

  # Prowlarr stays on SQLite (doesn't support env var config)
  homelab.media.prowlarr.enable = true;

  # Other services on SQLite (can migrate later if needed)
  homelab.media.lidarr.enable = true;
  homelab.media.bazarr.enable = true;

  homelab.media.jellyfin = {
    enable = true;
    publishedServerUrl = "https://jellyfin.home.dodwell.us";
    enableHardwareAccel = true;
  };

  homelab.media.jellyseerr.enable = true;

  # Now that the download client is qBittorrent (a Cleanuparr-supported
  # client), the download-client-dependent features - strike system,
  # stalled/slow removal, seeding cleanup, orphaned-download detection - are
  # usable too, in addition to the Arr-only features (failed-import cleanup,
  # missing-item search, quality-upgrade search). Configure the qBittorrent
  # connection in Cleanuparr's UI to enable them.
  homelab.media.cleanuparr.enable = true;

  homelab.media.tdarr = {
    enable = true;
    transcodePath = "/mnt/nvme/tdarr-transcode";
    enableGPU = true;
  };

  homelab.media.qbittorrent.enable = true;

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

  # User configuration - use centralized server user
  homelab.users.serverUser = {
    enable = true;
    username = "dodwmd";
    description = "Michael Dodwell";
  };

  users.users.root.extraGroups = ["wheel"];

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
