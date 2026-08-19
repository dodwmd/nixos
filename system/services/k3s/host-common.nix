{
  config,
  lib,
  pkgs,
  ...
}: {
  options.homelab.k3s-host = {
    enable = lib.mkEnableOption "Enable K3s host common configuration";

    hostname = lib.mkOption {
      type = lib.types.str;
      description = "Hostname for this K3s node";
    };

    upgradeTime = lib.mkOption {
      type = lib.types.str;
      default = "02:00";
      description = "Time for auto-upgrades (stagger across cluster)";
    };

    allowReboot = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Allow automatic reboots during upgrades";
    };

    cpuGovernor = lib.mkOption {
      type = lib.types.str;
      default = "ondemand";
      description = "CPU frequency governor (performance for masters, ondemand for workers)";
    };

    showBootMessages = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Show verbose boot messages (recommended for servers)";
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional packages specific to this node";
    };
  };

  config = lib.mkIf config.homelab.k3s-host.enable {
    # Hostname
    networking.hostName = config.homelab.k3s-host.hostname;

    # Network configuration - DHCP with homelab DNS
    networking = {
      useDHCP = true;
      dhcpcd.enable = true;
      nameservers = ["192.168.1.1" "192.168.1.4"];
    };

    # Boot configuration (already handled by boot-server.nix, but can override for verbose)
    boot = lib.mkIf config.homelab.k3s-host.showBootMessages {
      kernelParams = [
        "systemd.show_status=true"
        "rd.systemd.show_status=true"
        "rd.udev.log_level=info"
      ];
    };

    # User configuration - use centralized user management
    homelab.users.serverUser = {
      enable = true;
      username = "dodwmd";
      description = "Michael Dodwell";
    };

    # SSH configuration
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = false;
      };
    };

    programs.ssh = {
      extraConfig = ''
        Host *
          ForwardAgent yes
          AddKeysToAgent yes
      '';
    };

    # Mosh for better remote shell
    programs.mosh.enable = true;

    # Performance tuning
    powerManagement.cpuFreqGovernor = config.homelab.k3s-host.cpuGovernor;

    # Containerd overlayfs optimization (if using containerd)
    virtualisation.containerd.settings.plugins."io.containerd.snapshotter.v1.overlayfs".root =
      "/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs";

    # Auto-upgrade with staggered timing
    system.autoUpgrade = {
      enable = true;
      allowReboot = config.homelab.k3s-host.allowReboot;
      dates = config.homelab.k3s-host.upgradeTime;
      flake = "github:dodwmd/nixos";
    };

    # Disable nh cleanup to avoid conflict with manual nix.gc
    programs.nh.clean.enable = lib.mkForce false;

    # Garbage collection
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    # Common K3s node packages
    environment.systemPackages =
      with pkgs;
      [
        vim
        git
        tmux
        wget
        curl
        htop
        jq
        yq
        dig
        traceroute
        iperf3
      ]
      ++ config.homelab.k3s-host.extraPackages;

    # Intel CPU microcode updates (common for NUCs)
    hardware.cpu.intel.updateMicrocode = lib.mkDefault true;
  };
}
