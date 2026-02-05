{ config, pkgs, ... }:

{
  # Mount nexus NFS data share
  fileSystems."/mnt/nexus-data" = {
    device = "192.168.1.7:/tank/data";
    fsType = "nfs";
    options = [ "vers=3" "rsize=1048576" "wsize=1048576" "hard" "x-systemd.automount" "noauto" ];
  };

  # Mount nexus config share
  fileSystems."/mnt/nexus-config" = {
    device = "192.168.1.7:/tank/config";
    fsType = "nfs";
    options = [ "vers=3" "rsize=1048576" "wsize=1048576" "hard" "x-systemd.automount" "noauto" ];
  };

  # Enable NVIDIA Container Toolkit for Podman
  hardware.nvidia-container-toolkit.enable = true;

  virtualisation.oci-containers.containers.tdarr-node = {
    image = "ghcr.io/haveagitgat/tdarr_node:latest";
    autoStart = true;
    
    environment = {
      PUID = "1000";
      PGID = "100";
      TZ = "Australia/Brisbane";
      serverIP = "nexus.home.dodwell.us";
      serverPort = "8266";
      nodeName = "exodus-gpu";
      inContainer = "true";
      ffmpegVersion = "7";
      NVIDIA_VISIBLE_DEVICES = "all";
      NVIDIA_DRIVER_CAPABILITIES = "compute,video,utility";
    };
    
    volumes = [
      "/home/dodwmd/.config/tdarr-node:/app/configs"
      "/mnt/nexus-data:/media"
      "/tmp/tdarr-transcode-exodus:/temp"
      "/mnt/nexus-config/tdarr/server:/app/server:ro"  # Mount server plugins read-only
    ];
    
    extraOptions = [
      "--network=host"
      "--device=/dev/dri:/dev/dri"
      "--device=nvidia.com/gpu=all"  # Use CDI for NVIDIA GPU access
      "--security-opt=label=disable"
      "--group-add=26"   # Video group
      "--group-add=303"  # Render group
    ];
  };

  # Create required directories
  systemd.tmpfiles.rules = [
    "d /tmp/tdarr-transcode-exodus 0755 1000 100 -"
    "d /home/dodwmd/.config/tdarr-node 0755 1000 100 -"
  ];
}
