{
  imports = [
    # exodus-specific packages
    ./packages.nix
    ./niri-config.nix
    
    # editors
    ../../editors/helix
    ../../editors/zed

    # services
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
    ../../software/wayland/hyprlock.nix

    # terminal emulator
    ../../terminal/emulators/foot.nix
    # ../../terminal/emulators/ghostty.nix  # Disabled - missing noctalia theme

    # system services
    ../../services/system/gpg-agent.nix
    ../../services/system/cliphist.nix
    ../../services/system/polkit-agent.nix
  ];
}
