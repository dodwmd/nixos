{
  # Desktop profile for workstations with full GUI
  imports = [
    # Desktop-specific packages
    ./packages.nix

    # editors
    ../../editors/helix
    ../../editors/zed

    # Wayland services
    ../../services/wayland/gammastep.nix
    ../../services/wayland/waybar.nix
    ../../services/wayland/mako.nix
    ../../services/wayland/swayidle.nix

    # media services
    ../../services/media/playerctl.nix

    # software
    ../../software
    ../../software/wayland
    ../../software/wayland/fuzzel.nix
    ../../software/wayland/swaylock.nix

    # terminal emulator
    ../../terminal/emulators/foot.nix

    # system services
    ../../services/system/gpg-agent.nix
    ../../services/system/polkit-agent.nix
  ];
}
