{ config, lib, pkgs, ... }:

with lib;

{
  options.homelab.media.lidarr = {
    enable = mkEnableOption "Enable Lidarr music management";
    
    port = mkOption {
      type = types.int;
      default = 8686;
      description = "Lidarr web UI port";
    };
    
    configPath = mkOption {
      type = types.str;
      default = "/tank/config/lidarr";
      description = "Path to Lidarr configuration";
    };
    
    dataPath = mkOption {
      type = types.str;
      default = "/tank/data";
      description = "Path to media data";
    };
    
    downloadsPath = mkOption {
      type = types.str;
      default = "/tank/data/downloads/music";
      description = "Path to downloads directory";
    };
    
    uid = mkOption {
      type = types.int;
      default = 3000;
      description = "User ID for Lidarr";
    };
    
    gid = mkOption {
      type = types.int;
      default = 3000;
      description = "Group ID for Lidarr";
    };
  };

  config = mkIf config.homelab.media.lidarr.enable {
    virtualisation.oci-containers.containers.lidarr = {
      image = "lscr.io/linuxserver/lidarr:latest";
      autoStart = true;
      
      environment = {
        PUID = toString config.homelab.media.lidarr.uid;
        PGID = toString config.homelab.media.lidarr.gid;
        TZ = config.time.timeZone;
      };
      
      volumes = [
        "${config.homelab.media.lidarr.configPath}:/config"
        "${config.homelab.media.lidarr.dataPath}:/data"
        "${config.homelab.media.lidarr.downloadsPath}:/downloads"
      ];
      
      ports = [
        "${toString config.homelab.media.lidarr.port}:8686"
      ];
      
      extraOptions = [
        "--network=host"
        "--dns=192.168.1.1"
      ];
    };

    networking.firewall.allowedTCPPorts = [ config.homelab.media.lidarr.port ];
  };
}
