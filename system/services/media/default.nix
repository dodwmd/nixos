{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  imports = [
    # PostgreSQL for media services
    ./postgresql.nix

    # Generated media services (*arr stack + jellyseerr)
    ./services.nix

    # Complex services with unique configuration
    ./jellyfin.nix
    ./tdarr.nix
    ./qbittorrent.nix
    ./adguard.nix
    ./homepage.nix
  ];

  options.homelab.media = {
    enable = mkEnableOption "Enable all media services";

    mediaUser = mkOption {
      type = types.str;
      default = "media";
      description = "Media services user name";
    };

    mediaGroup = mkOption {
      type = types.str;
      default = "media";
      description = "Media services group name";
    };

    uid = mkOption {
      type = types.int;
      default = 3000;
      description = "UID for media user";
    };

    gid = mkOption {
      type = types.int;
      default = 3000;
      description = "GID for media group";
    };

    autoUpdate = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Nightly `podman auto-update` for media containers. Pulls newer images
          for any container labelled io.containers.autoupdate=registry (the whole
          *arr stack, jellyfin, tdarr, qbittorrent, adguard, homepage) and restarts the
          matching systemd unit, rolling back if the new container fails to start.
        '';
      };

      onCalendar = mkOption {
        type = types.str;
        default = "*-*-* 03:30:00";
        description = "systemd OnCalendar expression for the auto-update timer";
      };
    };
  };

  config = mkIf config.homelab.media.enable {
    # Pull + restart updated container images on a schedule.
    # podman-auto-update.{service,timer} ship with the podman package; the timer
    # has no wantedBy by default, so enabling it here is what turns it on.
    systemd.timers.podman-auto-update = mkIf config.homelab.media.autoUpdate.enable {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = config.homelab.media.autoUpdate.onCalendar;
        Persistent = true;
        RandomizedDelaySec = "15m";
      };
    };

    # `podman auto-update` never removes the images it replaces - reclaim the space.
    virtualisation.podman.autoPrune = {
      enable = true;
      dates = "weekly";
      flags = ["--all"];
    };

    # Create media user and group
    users.users.${config.homelab.media.mediaUser} = {
      uid = config.homelab.media.uid;
      group = config.homelab.media.mediaGroup;
      isSystemUser = true;
      description = "Media services user";
    };

    users.groups.${config.homelab.media.mediaGroup} = {
      gid = config.homelab.media.gid;
    };

    # Enable ACL support
    services.udev.packages = [pkgs.acl];
  };
}
