{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  # K3s host common configuration
  homelab.k3s-host = {
    enable = true;
    hostname = "k3s-worker-02";
    upgradeTime = "03:30"; # Stagger from other workers
    allowReboot = true; # Workers can reboot
    cpuGovernor = "ondemand"; # Workers can scale
    showBootMessages = true; # Show boot messages
  };

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

  # Note: Static IP configuration available if needed
  # networking.interfaces.enp114s0 = {
  #   useDHCP = false;
  #   ipv4.addresses = [{
  #     address = "192.168.1.31";
  #     prefixLength = 24;
  #   }];
  # };
  # networking.defaultGateway = {
  #   address = "192.168.1.1";
  #   interface = "enp114s0";
  # };

  # System state version
  system.stateVersion = "25.11";
}
