{ config, lib, pkgs, ... }:

with lib;

{
  options.homelab.media.jellyseerr = {
    enable = mkEnableOption "Enable Jellyseerr request management";
    
    port = mkOption {
      type = types.int;
      default = 5055;
      description = "Jellyseerr web UI port";
    };
    
    configPath = mkOption {
      type = types.str;
      default = "/tank/config/jellyseerr";
      description = "Path to Jellyseerr configuration";
    };
    
    uid = mkOption {
      type = types.int;
      default = 3000;
      description = "User ID for Jellyseerr";
    };
    
    gid = mkOption {
      type = types.int;
      default = 3000;
      description = "Group ID for Jellyseerr";
    };
  };

  config = mkIf config.homelab.media.jellyseerr.enable {
    virtualisation.oci-containers.containers.jellyseerr = {
      image = "docker.io/fallenbagel/jellyseerr:latest";
      autoStart = true;
      
      environment = {
        PUID = toString config.homelab.media.jellyseerr.uid;
        PGID = toString config.homelab.media.jellyseerr.gid;
        TZ = config.time.timeZone;
        LOG_LEVEL = "info";
      };
      
      volumes = [
        "${config.homelab.media.jellyseerr.configPath}:/app/config"
      ];
      
      ports = [
        "${toString config.homelab.media.jellyseerr.port}:5055"
      ];
      
      extraOptions = [
        "--network=host"
        "--dns=192.168.1.1"
      ];
    };

    networking.firewall.allowedTCPPorts = [ config.homelab.media.jellyseerr.port ];
  };
}
