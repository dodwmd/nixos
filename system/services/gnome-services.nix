{ config, lib, pkgs, ... }: {
  options.homelab.gnomeServices.enable = lib.mkEnableOption "GNOME keyring and related services";

  config = lib.mkIf config.homelab.gnomeServices.enable {
    services = {
      # needed for GNOME services outside of GNOME Desktop
      dbus = {
        implementation = "broker";
        packages = with pkgs; [
          gcr
          gnome-settings-daemon
          libsecret
        ];
      };
      gnome.gnome-keyring.enable = true;

      gvfs.enable = true;
    };
  };
}
