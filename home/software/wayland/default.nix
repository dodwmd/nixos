{pkgs, ...}:
# Wayland config
{
  imports = [
    ./dms
    ./niri
  ];

  home.packages = with pkgs; [
    # utils
    wl-clipboard-rs
  ];

  # make stuff work on wayland
  home.sessionVariables = {
    QT_QPA_PLATFORM = "wayland";
    QT_QPA_PLATFORMTHEME = "gtk3";
    SDL_VIDEODRIVER = "wayland";
    XDG_SESSION_TYPE = "wayland";
  };
}
