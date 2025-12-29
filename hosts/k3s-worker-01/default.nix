{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # System identification
  networking.hostName = "k3s-worker-01";
  
  # Network configuration - use DHCP
  networking.useDHCP = true;
  networking.dhcpcd.enable = true;
  networking.nameservers = [ "192.168.1.1" "192.168.1.4" ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # K3s worker configuration
  homelab.k3s-worker = {
    enable = true;
    serverAddr = "https://192.168.1.20:6443";
    nodeLabels = [
      "worker=true"
      "hardware=nuc"
      "storage=local-ssd"
    ];
    maxPods = 110;
  };

  homelab.k3s-cluster = {
    # nodeIP will be auto-detected from DHCP
  };

  # Storage configuration for KubeVirt
  fileSystems."/mnt/vms/roblox-dev" = {
    device = "/dev/disk/by-uuid/your-uuid-here";  # Update with actual UUID
    fsType = "ext4";
    options = [ "defaults" ];
  };

  # Users
  users.users.admin = {
    isNormalUser = true;
    createHome = true;
    extraGroups = [ "wheel" "docker" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOaqAx711E4IolsUvuE/JTv4CJNXL7e9ulZsZZN/XWVx michael@dodwell.us"
    ];
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

  # Hardware-specific
  hardware.cpu.intel.updateMicrocode = true;
  
  # System packages
  environment.systemPackages = with pkgs; [
    nvme-cli
    vim
    git
    tmux
    wget
    curl
    jq
    yq
    dig
    traceroute
    iperf3
  ];

  # Performance tuning
  powerManagement.cpuFreqGovernor = "ondemand";

  # Containerd overlayfs optimization
  virtualisation.containerd.settings.plugins."io.containerd.snapshotter.v1.overlayfs".root = "/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs";

  # Auto-upgrade with reboot
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    dates = "03:00";
  };

  # Disable nh cleanup to avoid conflict with manual nix.gc
  programs.nh.clean.enable = lib.mkForce false;

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };



  # System state version
  system.stateVersion = "25.11";
}
