{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: {
  # Noctalia-shell is disabled due to crashes - use waybar instead
  programs.noctalia = {
    enable = false;  # Disabled - crashing on startup with EGLConfig errors
    package = inputs.noctalia-shell.packages.${pkgs.system}.default;
    systemd = {
      enable = false;
      target = "graphical-session.target";
    };
  };
}
