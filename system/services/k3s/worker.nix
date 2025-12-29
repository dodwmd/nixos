# K3s worker node configuration module
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.homelab.k3s-worker;
in
{
  imports = [ ./common.nix ];

  options.homelab.k3s-worker = {
    enable = mkEnableOption "K3s worker node";
    
    serverAddr = mkOption {
      type = types.str;
      description = "Address of K3s server to join";
    };
    
    nodeLabels = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Node labels to apply";
      example = [ "worker=true" "storage=nvme-ssd" ];
    };
    
    nodeTaints = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Node taints to apply";
      example = [ "gpu=true:NoSchedule" ];
    };
    
    enableGPU = mkOption {
      type = types.bool;
      default = false;
      description = "Enable GPU support with container runtime";
    };
    
    gpuVendor = mkOption {
      type = types.enum [ "nvidia" "amd" "none" ];
      default = "none";
      description = "GPU vendor for this node";
    };
    
    maxPods = mkOption {
      type = types.int;
      default = 110;
      description = "Maximum number of pods per node";
    };
    
    kubeletArgs = mkOption {
      type = types.attrs;
      default = {
        "eviction-hard" = "memory.available<1Gi,nodefs.available<10%";
        "system-reserved" = "cpu=1,memory=2Gi";
        "kube-reserved" = "cpu=1,memory=2Gi";
      };
      description = "Additional kubelet arguments";
    };
  };
  
  config = mkIf cfg.enable {
    homelab.k3s-cluster.enable = true;
    
    # Enable LVM support for Ceph storage
    services.lvm.enable = true;
    
    # Load kernel modules required for Ceph/Rook
    boot.kernelModules = [ "rbd" "ceph" ];
    
    # K3s agent (worker) service configuration
    services.k3s = mkMerge [
      {
        enable = true;
        role = "agent";
        serverAddr = cfg.serverAddr;
        
        extraFlags = lib.concatStringsSep " " (
          []
          ++ (optional (config.homelab.k3s-cluster.nodeIP != null) "--node-ip=${config.homelab.k3s-cluster.nodeIP}")
          ++ (map (label: "--node-label=${label}") cfg.nodeLabels)
          ++ (map (taint: "--node-taint=${taint}") cfg.nodeTaints)
          ++ (mapAttrsToList (k: v: "--kubelet-arg=${k}=${v}") (cfg.kubeletArgs // { "max-pods" = toString cfg.maxPods; }))
          ++ (optional cfg.enableGPU "--container-runtime-endpoint=/run/containerd/containerd.sock")
        );
      }
      {
        tokenFile = "/etc/k3s/token";
      }
    ];
    
    # GPU support configuration
    hardware.nvidia = mkIf (cfg.enableGPU && cfg.gpuVendor == "nvidia") {
      modesetting.enable = true;
      powerManagement.enable = true;
      open = false;
      nvidiaPersistenced = true;
    };

    virtualisation.docker.enableNvidia = mkIf (cfg.enableGPU && cfg.gpuVendor == "nvidia") true;
    
    # NVIDIA container toolkit for GPU workloads
    virtualisation.containerd = mkIf (cfg.enableGPU && cfg.gpuVendor == "nvidia") {
      enable = true;
      settings = {
        plugins."io.containerd.grpc.v1.cri" = {
          containerd.runtimes.nvidia = {
            privileged_without_host_devices = false;
            runtime_engine = "";
            runtime_root = "";
            runtime_type = "io.containerd.runc.v2";
            options = {
              BinaryName = "${pkgs.nvidia-container-toolkit}/bin/nvidia-container-runtime";
            };
          };
        };
      };
    };
    
    # Worker-specific packages
    environment.systemPackages = with pkgs; [
      iotop
      htop
    ]
    ++ (optional (cfg.enableGPU && cfg.gpuVendor == "nvidia") nvtop)
    ++ (optional (cfg.enableGPU && cfg.gpuVendor == "nvidia") nvidia-container-toolkit);
    
    # Higher limits for worker nodes
    systemd.services.k3s.serviceConfig = {
      LimitNOFILE = mkForce 2097152;
      LimitMEMLOCK = mkForce "infinity";
    };
    
    # Additional firewall rules for worker nodes
    networking.firewall.allowedTCPPorts = [
      10250 10255 30000 32767 9100
      8443 8080 8843 8880 6789  # UniFi
      8123  # Home Assistant
    ];

    networking.firewall.allowedUDPPorts = [
      3478 10001  # UniFi
    ];
    
    # Container image cleanup
    systemd.services.k3s-image-cleanup = {
      description = "Clean up unused container images";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeScript "image-cleanup.sh" ''
          #!/bin/sh
          USAGE=$(df /var/lib/rancher/k3s | tail -1 | awk '{print $5}' | sed 's/%//')
          if [ "$USAGE" -gt 80 ]; then
            crictl rmi --prune
          fi
        '';
      };
    };
    
    systemd.timers.k3s-image-cleanup = {
      description = "Timer for container image cleanup";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
    };
  };
}
