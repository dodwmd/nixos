{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (import ./ssh-keys.nix) sshKeys;
in {
  options.homelab.users = {
    desktopUser = {
      enable = lib.mkEnableOption "Enable desktop user (dodwmd) with full desktop groups";
    };

    serverUser = {
      enable = lib.mkEnableOption "Enable server user (minimal groups)";
      username = lib.mkOption {
        type = lib.types.str;
        default = "dodwmd";
        description = "Username for server user";
      };
      description = lib.mkOption {
        type = lib.types.str;
        default = "Michael Dodwell";
        description = "Full name for server user";
      };
    };
  };

  config = lib.mkMerge [
    # Desktop user configuration (for exodus)
    (lib.mkIf config.homelab.users.desktopUser.enable {
      users.users.dodwmd = {
        isNormalUser = true;
        createHome = true;
        description = "Michael Dodwell";
        shell = pkgs.bash;
        extraGroups = [
          "wheel"
          "networkmanager"
          "video"
          "input"
          "docker"
          "kvm"
          "adbusers"
          "plugdev"
        ];
        openssh.authorizedKeys.keys =
          (import ./ssh-keys.nix).sshKeys.dodwmd;
      };
    })

    # Server admin user (for K3s, nexus, etc)
    (lib.mkIf config.homelab.users.serverUser.enable {
      users.users.${config.homelab.users.serverUser.username} = {
        isNormalUser = true;
        createHome = true;
        description = config.homelab.users.serverUser.description;
        extraGroups = [ "wheel" "docker" ];
        shell = pkgs.bash;
        openssh.authorizedKeys.keys =
          (import ./ssh-keys.nix).sshKeys.dodwmd;
      };
    })
  ];
}
