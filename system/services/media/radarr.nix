{ config, lib, pkgs, ... }:

with lib;

{
  options.homelab.media.radarr = {
    enable = mkEnableOption "Enable Radarr movie management";
    
    port = mkOption {
      type = types.int;
      default = 7878;
      description = "Radarr web UI port";
    };
    
    configPath = mkOption {
      type = types.str;
      default = "/tank/config/radarr";
      description = "Path to Radarr configuration";
    };
    
    dataPath = mkOption {
      type = types.str;
      default = "/tank/data";
      description = "Path to media data";
    };
    
    downloadsPath = mkOption {
      type = types.str;
      default = "/tank/data/downloads";
      description = "Path to downloads directory";
    };
    
    uid = mkOption {
      type = types.int;
      default = 3000;
      description = "User ID for Radarr";
    };
    
    gid = mkOption {
      type = types.int;
      default = 3000;
      description = "Group ID for Radarr";
    };
  };

  config = mkIf config.homelab.media.radarr.enable {
    virtualisation.oci-containers.containers.radarr = {
      image = "lscr.io/linuxserver/radarr:latest";
      autoStart = true;
      
      environment = {
        PUID = toString config.homelab.media.radarr.uid;
        PGID = toString config.homelab.media.radarr.gid;
        TZ = config.time.timeZone;
      };
      
      volumes = [
        "${config.homelab.media.radarr.configPath}:/config"
        "${config.homelab.media.radarr.dataPath}:/data"
        "${config.homelab.media.radarr.downloadsPath}:/downloads"
      ];
      
      ports = [
        "${toString config.homelab.media.radarr.port}:7878"
      ];
      
      extraOptions = [
        "--network=host"
        "--dns=192.168.1.1"
      ];
    };

    networking.firewall.allowedTCPPorts = [ config.homelab.media.radarr.port ];
  };
}
