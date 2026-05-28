{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption mkEnableOption mkIf types optionalAttrs;

  # Generator function for media services
  mkMediaService = {
    name, # Service name (e.g., "sonarr")
    description, # Human-readable description
    port, # External port
    internalPort ? port, # Internal container port (defaults to external port)
    image, # Docker image URL
    extraVolumes ? [], # Additional volume mounts beyond standard config/data/downloads
    extraEnvironment ? {}, # Additional environment variables
    configMountPath ? "/config", # Config mount path inside container (e.g., "/app/config" for jellyseerr)
    supportsPostgresql ? true, # Whether this service supports PostgreSQL
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

      usePostgresql = mkOption {
        type = types.bool;
        default = false;
        description = "Use PostgreSQL instead of SQLite for ${description}";
      };
    };

    config = mkIf config.homelab.media.${name}.enable {
      virtualisation.oci-containers.containers.${name} = let
        serviceCfg = config.homelab.media.${name};
        upperName = lib.toUpper name;

        # PostgreSQL environment variables for *arr apps
        postgresEnv = optionalAttrs (supportsPostgresql && serviceCfg.usePostgresql) {
          "${upperName}__POSTGRES__HOST" = "127.0.0.1";
          "${upperName}__POSTGRES__PORT" = toString config.homelab.media.postgresql.port;
          "${upperName}__POSTGRES__USER" = "media";
          "${upperName}__POSTGRES__PASSWORD" = "";
          "${upperName}__POSTGRES__MAINDB" = "${name}-main";
          "${upperName}__POSTGRES__LOGDB" = "${name}-log";
        };
      in {
        inherit image;
        autoStart = true;

        environment =
          {
            PUID = toString serviceCfg.uid;
            PGID = toString serviceCfg.gid;
            TZ = config.time.timeZone;
          }
          // extraEnvironment
          // postgresEnv;

        volumes =
          [
            "${serviceCfg.configPath}:${configMountPath}"
            "${serviceCfg.dataPath}:/data"
            "${serviceCfg.downloadsPath}:/downloads"
          ]
          ++ extraVolumes;

        ports = [
          "${toString serviceCfg.port}:${toString internalPort}"
        ];

        extraOptions = [
          "--network=host"
          "--dns=192.168.1.1"
        ];
      };

      networking.firewall.allowedTCPPorts = [config.homelab.media.${name}.port];

      # Ensure PostgreSQL is started before this service if using PostgreSQL
      systemd.services."podman-${name}" = mkIf (supportsPostgresql && config.homelab.media.${name}.usePostgresql) {
        after = [ "postgresql.service" "postgresql-media-grants.service" ];
        requires = [ "postgresql.service" ];
      };
    };
  };
in {
  inherit mkMediaService;
}
