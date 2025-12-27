{ config, lib, pkgs, ... }:

with lib;

{
  options.homelab.media.jellyfin = {
    enable = mkEnableOption "Enable Jellyfin media server";
    
    port = mkOption {
      type = types.int;
      default = 8096;
      description = "Jellyfin web UI port";
    };
    
    configPath = mkOption {
      type = types.str;
      default = "/tank/config/jellyfin";
      description = "Path to Jellyfin configuration";
    };
    
    dataPath = mkOption {
      type = types.str;
      default = "/tank/data";
      description = "Path to media data";
    };
    
    publishedServerUrl = mkOption {
      type = types.str;
      default = "https://jellyfin.home.dodwell.us";
      description = "Published server URL";
    };
    
    enableHardwareAccel = mkOption {
      type = types.bool;
      default = true;
      description = "Enable hardware acceleration";
    };
    
    uid = mkOption {
      type = types.int;
      default = 3000;
      description = "User ID for Jellyfin";
    };
    
    gid = mkOption {
      type = types.int;
      default = 3000;
      description = "Group ID for Jellyfin";
    };
  };

  config = mkIf config.homelab.media.jellyfin.enable {
    virtualisation.oci-containers.containers.jellyfin = {
      image = "docker.io/jellyfin/jellyfin:latest";
      autoStart = true;
      
      environment = {
        PUID = toString config.homelab.media.jellyfin.uid;
        PGID = toString config.homelab.media.jellyfin.gid;
        TZ = config.time.timeZone;
        JELLYFIN_PublishedServerUrl = config.homelab.media.jellyfin.publishedServerUrl;
      } // optionalAttrs config.homelab.media.jellyfin.enableHardwareAccel {
        # Hardware acceleration
        JELLYFIN_FFmpeg__hwaccel = "vaapi";
        JELLYFIN_FFmpeg__hwaccel_output_format = "vaapi";
        LIBVA_DRIVER_NAME = "iHD";
        # Performance optimizations
        JELLYFIN_FFmpeg__timeout = "60000";
        JELLYFIN_FFmpeg__probesize = "50000000";
        JELLYFIN_FFmpeg__analyzeduration = "20000000";
        # Increase buffer sizes to prevent stuttering
        JELLYFIN_FFmpeg__max_muxing_queue_size = "2048";
        JELLYFIN_FFmpeg__thread_queue_size = "1024";
        # Intel GPU optimizations
        INTEL_MEDIA_RUNTIME = "ONEVPL";
        GST_VAAPI_ALL_DRIVERS = "1";
      };
      
      volumes = [
        "${config.homelab.media.jellyfin.configPath}:/config"
        "${config.homelab.media.jellyfin.dataPath}:/data"
      ];
      
      ports = [
        "${toString config.homelab.media.jellyfin.port}:8096"
      ];
      
      extraOptions = [
        "--network=host"
        "--dns=192.168.1.1"
      ] ++ optionals config.homelab.media.jellyfin.enableHardwareAccel [
        "--device=/dev/dri:/dev/dri"
        "--group-add=26"   # Video group
        "--group-add=303"  # Render group
      ];
    };

    # Open ports for Jellyfin web UI and auto-discovery
    networking.firewall.allowedTCPPorts = [ config.homelab.media.jellyfin.port ];
    networking.firewall.allowedUDPPorts = [ 1900 7359 ];  # SSDP and client discovery
  };
}
