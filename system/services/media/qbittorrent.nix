{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.homelab.media.qbittorrent;
in {
  options.homelab.media.qbittorrent = {
    enable = mkEnableOption "Enable qBittorrent download client";

    port = mkOption {
      type = types.int;
      default = 8090;
      description = "qBittorrent web UI port";
    };

    torrentPort = mkOption {
      type = types.int;
      default = 6881;
      description = "BitTorrent peer listening port (TCP+UDP)";
    };

    configPath = mkOption {
      type = types.str;
      default = "/tank/config/qbittorrent";
      description = "Path to qBittorrent configuration";
    };

    # Shared with sonarr/radarr/lidarr's own downloadsPath (see
    # system/services/media/services.nix default) so the *arr apps and
    # qBittorrent see torrents at the exact same absolute container path,
    # which is what lets Sonarr/Radarr import completed downloads via
    # instant hardlink instead of a slow copy across filesystems.
    downloadsPath = mkOption {
      type = types.str;
      default = "/tank/data/downloads";
      description = "Shared downloads root, mounted identically into every *arr app";
    };

    uid = mkOption {
      type = types.int;
      default = 3000;
      description = "User ID for qBittorrent";
    };

    gid = mkOption {
      type = types.int;
      default = 3000;
      description = "Group ID for qBittorrent";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers.qbittorrent = {
      image = "lscr.io/linuxserver/qbittorrent:latest";
      autoStart = true;
      labels."io.containers.autoupdate" = "registry";

      environment = {
        PUID = toString cfg.uid;
        PGID = toString cfg.gid;
        TZ = config.time.timeZone;
        WEBUI_PORT = toString cfg.port;
        TORRENTING_PORT = toString cfg.torrentPort;
      };

      volumes = [
        "${cfg.configPath}:/config"
        "${cfg.downloadsPath}:/downloads"
      ];

      ports = [
        "${toString cfg.port}:${toString cfg.port}"
        "${toString cfg.torrentPort}:${toString cfg.torrentPort}"
        "${toString cfg.torrentPort}:${toString cfg.torrentPort}/udp"
      ];

      extraOptions = [
        "--network=host"
        "--dns=192.168.1.1"
      ];
    };

    networking.firewall = {
      allowedTCPPorts = [cfg.port cfg.torrentPort];
      allowedUDPPorts = [cfg.torrentPort];
    };
  };
}
