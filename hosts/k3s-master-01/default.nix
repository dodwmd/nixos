{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # System identification
  networking.hostName = "k3s-master-01";
  
  # Network configuration - use DHCP
  networking.useDHCP = true;
  networking.dhcpcd.enable = true;
  networking.nameservers = [ "192.168.1.1" "192.168.1.4" ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # K3s master configuration
  homelab.k3s-master = {
    enable = true;
    clusterInit = true;
    tlsSan = [
      "192.168.1.20"
      "192.168.1.21"
      "k3s-master-01"
      "k3s-master-02"
      "k3s.home.dodwell.us"
    ];
  };

  homelab.k3s-cluster = {
    # nodeIP will be auto-detected from DHCP
    enableTraefik = false;
    enableServiceLB = false;
  };

  # Users - using homelab common user configuration
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

  # Performance tuning
  powerManagement.cpuFreqGovernor = "performance";

  # Auto-upgrade
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    dates = "02:00";
  };

  # Disable nh cleanup to avoid conflict with manual nix.gc
  programs.nh.clean.enable = lib.mkForce false;

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };


  # System packages
  environment.systemPackages = with pkgs; [
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

  # System state version
  system.stateVersion = "25.11";
}
