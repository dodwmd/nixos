{ config, lib, pkgs, ... }:

with lib;

{
  options.homelab.media.prowlarr = {
    enable = mkEnableOption "Enable Prowlarr indexer management";
    
    port = mkOption {
      type = types.int;
      default = 9696;
      description = "Prowlarr web UI port";
    };
    
    configPath = mkOption {
      type = types.str;
      default = "/tank/config/prowlarr";
      description = "Path to Prowlarr configuration";
    };
    
    uid = mkOption {
      type = types.int;
      default = 3000;
      description = "User ID for Prowlarr";
    };
    
    gid = mkOption {
      type = types.int;
      default = 3000;
      description = "Group ID for Prowlarr";
    };
  };

  config = mkIf config.homelab.media.prowlarr.enable {
    virtualisation.oci-containers.containers.prowlarr = {
      image = "lscr.io/linuxserver/prowlarr:latest";
      autoStart = true;
      
      environment = {
        PUID = toString config.homelab.media.prowlarr.uid;
        PGID = toString config.homelab.media.prowlarr.gid;
        TZ = config.time.timeZone;
      };
      
      volumes = [
        "${config.homelab.media.prowlarr.configPath}:/config"
      ];
      
      ports = [
        "${toString config.homelab.media.prowlarr.port}:9696"
      ];
      
      extraOptions = [
        "--network=host"
        "--dns=192.168.1.1"
      ];
    };

    networking.firewall.allowedTCPPorts = [ config.homelab.media.prowlarr.port ];
  };
}
