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
    hostname = "k3s-master-02";
    upgradeTime = "02:30"; # Stagger from master-01
    allowReboot = false;
    cpuGovernor = "ondemand"; # Thermal management priority for fanless N95
    showBootMessages = true; # Show boot messages for this master
  };

  # K3s master configuration (joining existing cluster)
  homelab.k3s-master = {
    enable = true;
    clusterInit = false; # Join existing cluster
    serverAddr = "https://192.168.1.20:6443";
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

  # System state version
  system.stateVersion = "25.11";
}
