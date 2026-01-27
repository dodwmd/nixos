{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: {
  # Noctalia-shell is disabled due to crashes - use waybar instead
  # Enable noctalia-shell using the proper NixOS module
  services.noctalia-shell = {
    enable = false;  # Disabled - crashing on startup with EGLConfig errors
    package = inputs.noctalia-shell.packages.${pkgs.system}.default;
    target = "graphical-session.target";
  };
}
