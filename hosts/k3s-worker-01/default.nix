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
    hostname = "k3s-worker-01";
    upgradeTime = "03:00"; # Stagger from masters
    allowReboot = true; # Workers can reboot
    cpuGovernor = "ondemand"; # Workers can scale
    showBootMessages = true; # Show boot messages
    extraPackages = with pkgs; [nvme-cli]; # This worker has NVMe storage
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

  # System state version
  system.stateVersion = "25.11";
}
