{...}: {
  systemd.user.services.xdg-desktop-portal = {
    serviceConfig = {
      UnsetEnvironment = "NIX_XDG_DESKTOP_PORTAL_DIR";
    };
  };
}
