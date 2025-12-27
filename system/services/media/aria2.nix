{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.homelab.media.aria2;
  
  mkAria2Container = name: port: listenPort: downloadPath: secret: {
    image = "p3terx/aria2-pro:latest";
    autoStart = true;
    
    environment = {
      PUID = toString cfg.uid;
      PGID = toString cfg.gid;
      UMASK_SET = "022";
      RPC_SECRET = secret;
      RPC_PORT = toString port;
      LISTEN_PORT = toString listenPort;
      DISK_CACHE = "64M";
      IPV6_MODE = "false";
      UPDATE_TRACKERS = "true";
      TZ = config.time.timeZone;
      BT_MAX_PEERS = "128";
      MAX_CONCURRENT_DOWNLOADS = "20";
      MAX_CONNECTION_PER_SERVER = "21";
      SPLIT = "21";
      MIN_SPLIT_SIZE = "10M";
      # Seeding configuration
      SEED_RATIO = "0.0";  # Unlimited seeding
      SEED_TIME = "0";     # Unlimited seed time
      BT_ENABLE_LPD = "true";
      BT_SEED_UNVERIFIED = "true";
    };
    
    volumes = [
      "${cfg.configBasePath}/${name}:/config"
      "${downloadPath}:/downloads"
    ];
    
    ports = [
      "${toString port}:${toString port}"
      "${toString listenPort}:${toString listenPort}"
      "${toString listenPort}:${toString listenPort}/udp"
    ];
    
    extraOptions = [
      "--network=host"
      "--dns=192.168.1.1"
    ];
  };
in
{
  options.homelab.media.aria2 = {
    enable = mkEnableOption "Enable Aria2 download clients";
    
    configBasePath = mkOption {
      type = types.str;
      default = "/tank/config";
      description = "Base path for Aria2 configurations";
    };
    
    downloadBasePath = mkOption {
      type = types.str;
      default = "/tank/data/downloads";
      description = "Base path for downloads";
    };
    
    ariangPort = mkOption {
      type = types.int;
      default = 6880;
      description = "AriaNg web UI port";
    };
    
    uid = mkOption {
      type = types.int;
      default = 3000;
      description = "User ID for Aria2";
    };
    
    gid = mkOption {
      type = types.int;
      default = 3000;
      description = "Group ID for Aria2";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      aria2-radarr = mkAria2Container "aria2-radarr" 6800 6888 "${cfg.downloadBasePath}/movies" "aria2-radarr-secret";
      aria2-sonarr = mkAria2Container "aria2-sonarr" 6801 6889 "${cfg.downloadBasePath}/tv" "aria2-sonarr-secret";
      aria2-lidarr = mkAria2Container "aria2-lidarr" 6802 6890 "${cfg.downloadBasePath}/music" "aria2-lidarr-secret";
      aria2-readarr = mkAria2Container "aria2-readarr" 6803 6891 "${cfg.downloadBasePath}/books" "aria2-readarr-secret";
      
      ariang = {
        image = "p3terx/ariang:latest";
        autoStart = true;
        
        environment = {
          PUID = toString cfg.uid;
          PGID = toString cfg.gid;
        };
        
        ports = [
          "${toString cfg.ariangPort}:6880"
        ];
        
        extraOptions = [
          "--network=host"
        ];
      };
    };

    networking.firewall = {
      allowedTCPPorts = [ 6800 6801 6802 6803 cfg.ariangPort 6888 6889 6890 6891 ];
      allowedUDPPorts = [ 6888 6889 6890 6891 ];
    };
  };
}
