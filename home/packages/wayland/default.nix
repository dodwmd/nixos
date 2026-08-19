{pkgs, ...}: {
  users.users.dodwmd.packages = with pkgs; [wl-clipboard wl-clip-persist];
  environment.sessionVariables = {
    SDL_VIDEODRIVER = "wayland";
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "niri:GNOME";
    XDG_SESSION_DESKTOP = "niri";
    QT_QPA_PLATFORMTHEME = "qt6ct";
    WLR_RENDERER = "vulkan";
    # Set default browser for applications like Zoom
    BROWSER = "brave";
  };
}
