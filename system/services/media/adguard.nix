{ config, lib, pkgs, ... }:

with lib;

{
  options.homelab.media.adguard = {
    enable = mkEnableOption "Enable AdGuard DNS filtering";
    
    dnsPort = mkOption {
      type = types.int;
      default = 53;
      description = "DNS port";
    };
    
    setupPort = mkOption {
      type = types.int;
      default = 3000;
      description = "Initial setup web UI port";
    };
    
    webPort = mkOption {
      type = types.int;
      default = 8053;
      description = "Web UI port (after setup)";
    };
    
    configPath = mkOption {
      type = types.str;
      default = "/tank/config/adguard";
      description = "Path to AdGuard configuration";
    };
  };

  config = mkIf config.homelab.media.adguard.enable {
    virtualisation.oci-containers.containers.adguard = {
      image = "adguard/adguardhome:latest";
      autoStart = true;
      
      environment = {
        TZ = config.time.timeZone;
      };
      
      volumes = [
        "${config.homelab.media.adguard.configPath}/work:/opt/adguardhome/work"
        "${config.homelab.media.adguard.configPath}/conf:/opt/adguardhome/conf"
      ];
      
      ports = [
        "${toString config.homelab.media.adguard.dnsPort}:53/tcp"
        "${toString config.homelab.media.adguard.dnsPort}:53/udp"
        "${toString config.homelab.media.adguard.setupPort}:3000/tcp"
        "${toString config.homelab.media.adguard.webPort}:80/tcp"
      ];
      
      extraOptions = [
        "--network=host"
        "--dns=192.168.1.1"
        "--cap-add=NET_ADMIN"
        "--cap-add=NET_RAW"
      ];
    };

    # Create config directory structure
    systemd.tmpfiles.rules = [
      "d ${config.homelab.media.adguard.configPath} 0755 root root -"
      "d ${config.homelab.media.adguard.configPath}/work 0755 root root -"
      "d ${config.homelab.media.adguard.configPath}/conf 0755 root root -"
    ];

    networking.firewall = {
      allowedTCPPorts = [ 
        config.homelab.media.adguard.dnsPort 
        config.homelab.media.adguard.setupPort 
        config.homelab.media.adguard.webPort 
      ];
      allowedUDPPorts = [ config.homelab.media.adguard.dnsPort ];
    };
  };
}
