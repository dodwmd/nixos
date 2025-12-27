{ config, lib, pkgs, ... }:

with lib;

{
  options.homelab.media.sonarr = {
    enable = mkEnableOption "Enable Sonarr TV show management";
    
    port = mkOption {
      type = types.int;
      default = 8989;
      description = "Sonarr web UI port";
    };
    
    configPath = mkOption {
      type = types.str;
      default = "/tank/config/sonarr";
      description = "Path to Sonarr configuration";
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
      description = "User ID for Sonarr";
    };
    
    gid = mkOption {
      type = types.int;
      default = 3000;
      description = "Group ID for Sonarr";
    };
  };

  config = mkIf config.homelab.media.sonarr.enable {
    virtualisation.oci-containers.containers.sonarr = {
      image = "lscr.io/linuxserver/sonarr:latest";
      autoStart = true;
      
      environment = {
        PUID = toString config.homelab.media.sonarr.uid;
        PGID = toString config.homelab.media.sonarr.gid;
        TZ = config.time.timeZone;
      };
      
      volumes = [
        "${config.homelab.media.sonarr.configPath}:/config"
        "${config.homelab.media.sonarr.dataPath}:/data"
        "${config.homelab.media.sonarr.downloadsPath}:/downloads"
      ];
      
      ports = [
        "${toString config.homelab.media.sonarr.port}:8989"
      ];
      
      extraOptions = [
        "--network=host"
        "--dns=192.168.1.1"
      ];
    };

    networking.firewall.allowedTCPPorts = [ config.homelab.media.sonarr.port ];
  };
}
