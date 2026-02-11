{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ../../system/services/llama-cpp.nix
  ];

  # K3s host common configuration
  homelab.k3s-host = {
    enable = true;
    hostname = "k3s-worker-03";
    upgradeTime = "04:00"; # Stagger from other workers
    allowReboot = true; # Workers can reboot
    cpuGovernor = "performance"; # High-performance node
    showBootMessages = true; # Show boot messages
  };

  # K3s worker configuration
  homelab.k3s-worker = {
    enable = true;
    serverAddr = "https://192.168.1.20:6443";
    nodeLabels = [
      "worker=true"
      "hardware=ms-a01"
      "storage=nvme-ssd"
      "compute=high-performance"
      "gpu=amd-radv"
    ];
    maxPods = 150;
    kubeletArgs = {
      "eviction-hard" = "memory.available<1Gi,nodefs.available<10%";
      "system-reserved" = "cpu=2,memory=4Gi";
      "kube-reserved" = "cpu=2,memory=4Gi";
    };
  };

  homelab.k3s-cluster = {
    # nodeIP will be auto-detected from DHCP
  };


  # AMD GPU support (Rembrandt iGPU)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    # RADV (Mesa) is enabled by default for AMD GPUs
    # ROCm packages can be added later if needed for compute workloads
  };


  # llama-cpp inference server (CPU-only, 96GB RAM)
  homelab.llama-cpp = {
    enable = true;
    contextSize = 8192;
  };

  # Network optimizations for high-performance workloads
  boot.kernel.sysctl = {
    "net.core.rmem_max" = lib.mkDefault 134217728;
    "net.core.wmem_max" = lib.mkDefault 134217728;
    "net.ipv4.tcp_rmem" = lib.mkDefault "4096 87380 67108864";
    "net.ipv4.tcp_wmem" = lib.mkDefault "4096 65536 67108864";
    "net.core.netdev_max_backlog" = lib.mkDefault 5000;
  };


  # System state version
  system.stateVersion = "25.11";
}
