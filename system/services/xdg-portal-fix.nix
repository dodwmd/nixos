{ config, lib, ... }: {
  options.homelab.xdgPortalFix.enable = lib.mkEnableOption "XDG desktop portal fix" // { default = true; };

  config = lib.mkIf config.homelab.xdgPortalFix.enable {
    systemd.user.services.xdg-desktop-portal = {
      serviceConfig = {
        UnsetEnvironment = "NIX_XDG_DESKTOP_PORTAL_DIR";
      };
    };
  };
}
