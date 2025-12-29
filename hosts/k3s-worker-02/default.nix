{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # System identification
  networking.hostName = "k3s-worker-02";
  
  # Network configuration (matching original with systemd-networkd)
  networking.useNetworkd = true;
  networking.dhcpcd.enable = false;
  networking.useDHCP = false;
  networking.interfaces.enp114s0 = {
    useDHCP = false;
    ipv4.addresses = [{
      address = "192.168.1.31";
      prefixLength = 24;
    }];
  };
  networking.defaultGateway = {
    address = "192.168.1.1";
    interface = "enp114s0";
  };
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
    nodeIP = "192.168.1.31";
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

  users.users.dodwmd = {
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

  # Auto-upgrade with reboot (staggered time)
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    dates = "03:30";
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
  system.stateVersion = "25.05";
}
