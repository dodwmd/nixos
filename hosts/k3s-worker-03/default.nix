{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # System identification
  networking.hostName = "k3s-worker-03";
  
  # Network configuration (matching original with systemd-networkd)
  networking.useNetworkd = true;
  networking.dhcpcd.enable = false;
  networking.useDHCP = false;
  networking.interfaces.enp3s0 = {
    useDHCP = false;
    ipv4.addresses = [{
      address = "192.168.1.32";
      prefixLength = 24;
    }];
  };
  networking.defaultGateway = {
    address = "192.168.1.1";
    interface = "enp3s0";
  };
  networking.nameservers = [ "192.168.1.1" "192.168.1.4" ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # K3s worker configuration (high-performance node)
  homelab.k3s-worker = {
    enable = true;
    serverAddr = "https://192.168.1.20:6443";
    nodeLabels = [
      "worker=true"
      "hardware=ms-a01"
      "storage=nvme-ssd"
      "compute=high-performance"
    ];
    maxPods = 150;
    kubeletArgs = {
      "eviction-hard" = "memory.available<1Gi,nodefs.available<10%";
      "system-reserved" = "cpu=2,memory=4Gi";
      "kube-reserved" = "cpu=2,memory=4Gi";
    };
  };

  homelab.k3s-cluster = {
    nodeIP = "192.168.1.32";
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

  # Hardware-specific - MS-A01 Mini PC with AMD Ryzen
  hardware.cpu.amd.updateMicrocode = true;
  hardware.cpu.intel.updateMicrocode = true;  # Some MS-A01 variants
  
  # AMD GPU support (Rembrandt iGPU)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    # RADV (Mesa) is enabled by default for AMD GPUs
    # ROCm packages can be added later if needed for compute workloads
  };

  # Thermal management
  services.thermald.enable = true;

  # Performance tuning
  powerManagement.cpuFreqGovernor = "performance";

  # Network optimizations (use mkDefault to allow security.nix to override)
  boot.kernel.sysctl = {
    "net.core.rmem_max" = lib.mkDefault 134217728;
    "net.core.wmem_max" = lib.mkDefault 134217728;
    "net.ipv4.tcp_rmem" = lib.mkDefault "4096 87380 67108864";
    "net.ipv4.tcp_wmem" = lib.mkDefault "4096 65536 67108864";
    "net.core.netdev_max_backlog" = lib.mkDefault 5000;
  };

  # Enhanced containerd settings for high-performance workloads
  virtualisation.containerd.settings = {
    plugins."io.containerd.grpc.v1.cri" = {
      containerd = {
        default_runtime_name = "runc";
        runtimes.runc = {
          runtime_type = "io.containerd.runc.v2";
          options = {
            SystemdCgroup = true;
          };
        };
      };
    };
  };

  # Auto-upgrade with reboot (staggered time)
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    dates = "04:00";
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
