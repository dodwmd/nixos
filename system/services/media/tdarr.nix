{ config, lib, pkgs, ... }:

with lib;

{
  options.homelab.media.tdarr = {
    enable = mkEnableOption "Enable Tdarr media transcoding";
    
    webUIPort = mkOption {
      type = types.int;
      default = 8265;
      description = "Tdarr web UI port";
    };
    
    serverPort = mkOption {
      type = types.int;
      default = 8266;
      description = "Tdarr server port";
    };
    
    configPath = mkOption {
      type = types.str;
      default = "/tank/config/tdarr";
      description = "Path to Tdarr configuration";
    };
    
    dataPath = mkOption {
      type = types.str;
      default = "/tank/data";
      description = "Path to media data";
    };
    
    transcodePath = mkOption {
      type = types.str;
      default = "/tmp/tdarr-transcode";
      description = "Path to transcode temp directory (should be on fast storage)";
    };
    
    enableGPU = mkOption {
      type = types.bool;
      default = true;
      description = "Enable GPU hardware acceleration";
    };
    
    uid = mkOption {
      type = types.int;
      default = 3000;
      description = "User ID for Tdarr";
    };
    
    gid = mkOption {
      type = types.int;
      default = 3000;
      description = "Group ID for Tdarr";
    };
  };

  config = mkIf config.homelab.media.tdarr.enable {
    virtualisation.oci-containers.containers.tdarr = {
      image = "ghcr.io/haveagitgat/tdarr:latest";
      autoStart = true;
      
      environment = {
        PUID = toString config.homelab.media.tdarr.uid;
        PGID = toString config.homelab.media.tdarr.gid;
        TZ = config.time.timeZone;
        serverIP = "0.0.0.0";
        serverPort = toString config.homelab.media.tdarr.serverPort;
        webUIPort = toString config.homelab.media.tdarr.webUIPort;
        internalNode = "true";
        inContainer = "true";
        ffmpegVersion = "7";
        nodeName = "tdarr-server";
      };
      
      volumes = [
        "${config.homelab.media.tdarr.configPath}/configs:/app/configs"
        "${config.homelab.media.tdarr.configPath}/server:/app/server"
        "${config.homelab.media.tdarr.dataPath}:/media"
        "${config.homelab.media.tdarr.transcodePath}:/temp"
      ];
      
      ports = [
        "${toString config.homelab.media.tdarr.webUIPort}:${toString config.homelab.media.tdarr.webUIPort}"
        "${toString config.homelab.media.tdarr.serverPort}:${toString config.homelab.media.tdarr.serverPort}"
      ];
      
      extraOptions = [
        "--network=host"
      ] ++ optionals config.homelab.media.tdarr.enableGPU [
        "--device=/dev/dri:/dev/dri"
        "--group-add=26"   # Video group
        "--group-add=303"  # Render group
      ];
    };

    # Create transcode temp directory
    systemd.tmpfiles.rules = [
      "d ${config.homelab.media.tdarr.transcodePath} 0755 ${toString config.homelab.media.tdarr.uid} ${toString config.homelab.media.tdarr.gid} -"
    ];
    
    # Increase stop timeout to allow graceful shutdown
    systemd.services.podman-tdarr = {
      serviceConfig = {
        TimeoutStopSec = mkForce 300;  # 5 minutes
      };
    };
    
    networking.firewall.allowedTCPPorts = [ 
      config.homelab.media.tdarr.webUIPort 
      config.homelab.media.tdarr.serverPort 
    ];
  };
}
