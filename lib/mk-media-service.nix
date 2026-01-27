{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption mkEnableOption mkIf types;

  # Generator function for media services
  mkMediaService = {
    name, # Service name (e.g., "sonarr")
    description, # Human-readable description
    port, # External port
    internalPort ? port, # Internal container port (defaults to external port)
    image, # Docker image URL
    extraVolumes ? [], # Additional volume mounts beyond standard config/data/downloads
    extraEnvironment ? {}, # Additional environment variables
  }: {
    options.homelab.media.${name} = {
      enable = mkEnableOption "Enable ${description}";

      port = mkOption {
        type = types.int;
        default = port;
        description = "${description} web UI port";
      };

      configPath = mkOption {
        type = types.str;
        default = "/tank/config/${name}";
        description = "Path to ${description} configuration";
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
        description = "User ID for ${description}";
      };

      gid = mkOption {
        type = types.int;
        default = 3000;
        description = "Group ID for ${description}";
      };
    };

    config = mkIf config.homelab.media.${name}.enable {
      virtualisation.oci-containers.containers.${name} = {
        inherit image;
        autoStart = true;

        environment =
          {
            PUID = toString config.homelab.media.${name}.uid;
            PGID = toString config.homelab.media.${name}.gid;
            TZ = config.time.timeZone;
          }
          // extraEnvironment;

        volumes =
          [
            "${config.homelab.media.${name}.configPath}:/config"
            "${config.homelab.media.${name}.dataPath}:/data"
            "${config.homelab.media.${name}.downloadsPath}:/downloads"
          ]
          ++ extraVolumes;

        ports = [
          "${toString config.homelab.media.${name}.port}:${toString internalPort}"
        ];

        extraOptions = [
          "--network=host"
          "--dns=192.168.1.1"
        ];
      };

      networking.firewall.allowedTCPPorts = [config.homelab.media.${name}.port];
    };
  };
in {
  inherit mkMediaService;
}
