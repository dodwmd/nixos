{ config, lib, pkgs, ... }:

with lib;

{
  options.homelab.media.bazarr = {
    enable = mkEnableOption "Enable Bazarr subtitle management";
    
    port = mkOption {
      type = types.int;
      default = 6767;
      description = "Bazarr web UI port";
    };
    
    configPath = mkOption {
      type = types.str;
      default = "/tank/config/bazarr";
      description = "Path to Bazarr configuration";
    };
    
    dataPath = mkOption {
      type = types.str;
      default = "/tank/data";
      description = "Path to media data";
    };
    
    uid = mkOption {
      type = types.int;
      default = 3000;
      description = "User ID for Bazarr";
    };
    
    gid = mkOption {
      type = types.int;
      default = 3000;
      description = "Group ID for Bazarr";
    };
  };

  config = mkIf config.homelab.media.bazarr.enable {
    virtualisation.oci-containers.containers.bazarr = {
      image = "lscr.io/linuxserver/bazarr:latest";
      autoStart = true;
      
      environment = {
        PUID = toString config.homelab.media.bazarr.uid;
        PGID = toString config.homelab.media.bazarr.gid;
        TZ = config.time.timeZone;
      };
      
      volumes = [
        "${config.homelab.media.bazarr.configPath}:/config"
        "${config.homelab.media.bazarr.dataPath}:/data"
      ];
      
      ports = [
        "${toString config.homelab.media.bazarr.port}:6767"
      ];
      
      extraOptions = [
        "--network=host"
        "--dns=192.168.1.1"
      ];
    };

    networking.firewall.allowedTCPPorts = [ config.homelab.media.bazarr.port ];
  };
}
