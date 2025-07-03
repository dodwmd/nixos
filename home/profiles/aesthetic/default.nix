{
  imports = [
    # editors
    ../../editors/helix
    ../../editors/zed

    # services
    # ../../services/wayland/hypridle.nix
    # ../../services/quickshell

    # media services
    ../../services/media/playerctl.nix

    # software
    ../../software
    ../../software/wayland
    # ../../software/wayland/caido.nix

    # system services
    ../../services/system/gpg-agent.nix
    ../../services/system/polkit-agent.nix
    ../../services/system/power-monitor.nix
    ../../services/system/syncthing.nix

    # terminal emulators
    # ../../terminal/emulators/foot.nix
  ];
}
