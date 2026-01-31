{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkEnableOption mkIf types;
  cfg = config.homelab.media.postgresql;

  # Migration script as a derivation
  migrationScript = pkgs.writeShellApplication {
    name = "arr-migrate-to-postgres";
    runtimeInputs = with pkgs; [ pgloader sqlite postgresql_16 coreutils gnugrep ];
    text = builtins.readFile ./scripts/migrate-to-postgres.sh;
  };
in {
  options.homelab.media.postgresql = {
    enable = mkEnableOption "PostgreSQL for media services";

    port = mkOption {
      type = types.port;
      default = 5432;
      description = "PostgreSQL port";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.postgresql_16;
      description = "PostgreSQL package to use";
    };

    configBase = mkOption {
      type = types.str;
      default = "/tank/config";
      description = "Base path where *arr config directories are located";
    };
  };

  config = mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      package = cfg.package;
      settings.port = cfg.port;

      # Create all media databases (main + log for each app)
      ensureDatabases = [
        "radarr-main" "radarr-log"
        "sonarr-main" "sonarr-log"
        "lidarr-main" "lidarr-log"
        "readarr-main" "readarr-log"
      ];

      ensureUsers = [{
        name = "media";
        ensureDBOwnership = false;
      }];

      # Trust auth for localhost (containers use host network)
      authentication = lib.mkForce ''
        # TYPE  DATABASE        USER            ADDRESS                 METHOD
        local   all             all                                     peer
        local   all             postgres                                peer
        host    all             media           127.0.0.1/32            trust
        host    all             media           ::1/128                 trust
      '';
    };

    # Grant media user access to all databases after creation
    systemd.services.postgresql-media-grants = {
      description = "Grant PostgreSQL permissions for media services";
      after = [ "postgresql.service" ];
      requires = [ "postgresql.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        User = "postgres";
        RemainAfterExit = true;
      };
      script = ''
        for db in radarr-main radarr-log sonarr-main sonarr-log lidarr-main lidarr-log readarr-main readarr-log; do
          ${cfg.package}/bin/psql -c "GRANT ALL PRIVILEGES ON DATABASE \"$db\" TO media;" 2>/dev/null || true
          ${cfg.package}/bin/psql -d "$db" -c "GRANT ALL ON SCHEMA public TO media;" 2>/dev/null || true
          ${cfg.package}/bin/psql -d "$db" -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO media;" 2>/dev/null || true
          ${cfg.package}/bin/psql -d "$db" -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO media;" 2>/dev/null || true
        done
      '';
    };

    # Install migration tools
    environment.systemPackages = [
      migrationScript
      pkgs.pgloader
      pkgs.sqlite
    ];

    # Open firewall for local network (for external DB tools)
    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
