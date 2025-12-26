{pkgs, ...}: {
  users.users.linuxmobile.packages = with pkgs; [wl-clipboard];
  environment.sessionVariables = {
    SDL_VIDEODRIVER = "wayland";
    XDG_SESSION_TYPE = "wayland";
  };
}
