{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  # K3s host common configuration
  homelab.k3s-host = {
    enable = true;
    hostname = "k3s-master-01";
    upgradeTime = "02:00";
    allowReboot = false;
    cpuGovernor = "ondemand"; # Thermal management priority for fanless N95
    showBootMessages = true; # Show boot messages for masters
  };

  # K3s master configuration
  homelab.k3s-master = {
    enable = true;
    clusterInit = true; # This is the primary master that initializes the cluster
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

  # PXE netboot server (primary)
  homelab.netboot-server.enable = true;

  # System state version
  system.stateVersion = "25.11";
}
