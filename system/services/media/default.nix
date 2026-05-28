{ config, lib, pkgs, ... }:

with lib;

{
  imports = [
    # PostgreSQL for media services
    ./postgresql.nix

    # Generated media services (*arr stack + jellyseerr)
    ./services.nix

    # Complex services with unique configuration
    ./jellyfin.nix
    ./tdarr.nix
    ./aria2.nix
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
  };

  config = mkIf config.homelab.media.enable {
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
    services.udev.packages = [ pkgs.acl ];
  };
}
