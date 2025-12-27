{pkgs, ...}: {
  users.users.linuxmobile.packages = with pkgs; [wl-clipboard];
  environment.sessionVariables = {
    SDL_VIDEODRIVER = "wayland";
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "niri:GNOME";
    XDG_SESSION_DESKTOP = "niri";
    QT_QPA_PLATFORMTHEME = "qt6ct";
    WLR_RENDERER = "vulkan";
    GTK_USE_PORTAL = 1;
  };
}
