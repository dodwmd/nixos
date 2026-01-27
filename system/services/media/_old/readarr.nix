{ config, lib, pkgs, ... }:

with lib;

{
  options.homelab.media.readarr = {
    enable = mkEnableOption "Enable Readarr book management";
    
    port = mkOption {
      type = types.int;
      default = 8787;
      description = "Readarr web UI port";
    };
    
    configPath = mkOption {
      type = types.str;
      default = "/tank/config/readarr";
      description = "Path to Readarr configuration";
    };
    
    dataPath = mkOption {
      type = types.str;
      default = "/tank/data";
      description = "Path to media data";
    };
    
    downloadsPath = mkOption {
      type = types.str;
      default = "/tank/data/downloads/books";
      description = "Path to downloads directory";
    };
    
    uid = mkOption {
      type = types.int;
      default = 3000;
      description = "User ID for Readarr";
    };
    
    gid = mkOption {
      type = types.int;
      default = 3000;
      description = "Group ID for Readarr";
    };
  };

  config = mkIf config.homelab.media.readarr.enable {
    virtualisation.oci-containers.containers.readarr = {
      image = "ghcr.io/hotio/readarr:latest";
      autoStart = true;
      
      environment = {
        PUID = toString config.homelab.media.readarr.uid;
        PGID = toString config.homelab.media.readarr.gid;
        TZ = config.time.timeZone;
        UMASK = "002";
      };
      
      volumes = [
        "${config.homelab.media.readarr.configPath}:/config"
        "${config.homelab.media.readarr.dataPath}:/data"
        "${config.homelab.media.readarr.downloadsPath}:/downloads"
      ];
      
      ports = [
        "${toString config.homelab.media.readarr.port}:8787"
      ];
      
      extraOptions = [
        "--network=host"
        "--dns=192.168.1.1"
      ];
    };

    networking.firewall.allowedTCPPorts = [ config.homelab.media.readarr.port ];
  };
}
