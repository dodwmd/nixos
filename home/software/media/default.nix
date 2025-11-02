{pkgs, ...}: {
  imports = [
    ./obs.nix
    ./rnnoise.nix
    ./mpv.nix
  ];

  home.packages = with pkgs; [
    # audio control
    pamixer
    alsa-utils
    easyeffects
  ];
}
