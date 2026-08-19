{ config, lib, pkgs, ... }:

with lib;

{
  options.homelab.media.homepage = {
    enable = mkEnableOption "Enable Homepage dashboard";
    
    port = mkOption {
      type = types.int;
      default = 3000;
      description = "Homepage web UI port";
    };
    
    configPath = mkOption {
      type = types.str;
      default = "/tank/config/homepage";
      description = "Path to Homepage configuration";
    };
    
    allowedHosts = mkOption {
      type = types.str;
      default = "nexus.home.dodwell.us,localhost,127.0.0.1";
      description = "Allowed hosts for Homepage";
    };
    
    uid = mkOption {
      type = types.int;
      default = 3000;
      description = "User ID for Homepage";
    };
    
    gid = mkOption {
      type = types.int;
      default = 3000;
      description = "Group ID for Homepage";
    };
  };

  config = mkIf config.homelab.media.homepage.enable {
    virtualisation.oci-containers.containers.homepage = {
      image = "ghcr.io/gethomepage/homepage:latest";
      autoStart = true;
      
      environment = {
        PUID = toString config.homelab.media.homepage.uid;
        PGID = toString config.homelab.media.homepage.gid;
        TZ = config.time.timeZone;
        HOMEPAGE_ALLOWED_HOSTS = config.homelab.media.homepage.allowedHosts;
      };
      
      environmentFiles = [
        "${config.homelab.media.homepage.configPath}/.env"
      ];
      
      volumes = [
        "${config.homelab.media.homepage.configPath}:/app/config"
        "/var/run/podman/podman.sock:/var/run/docker.sock:ro"
      ];
      
      ports = [
        "${toString config.homelab.media.homepage.port}:3000"
      ];
      
      extraOptions = [
        "--network=host"
        "--dns=192.168.1.1"
      ];
    };

    networking.firewall.allowedTCPPorts = [ config.homelab.media.homepage.port ];
  };
}
