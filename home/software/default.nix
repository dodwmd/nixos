{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./anyrun
    ./browsers/chromium.nix
    ./browsers/edge.nix
    ./browsers/zen.nix
    ./gtk.nix
    ./media
  ];

  home.packages = with pkgs; [
    # messaging
    telegram-desktop
    vesktop
    discord

    # misc
    ps_mem
    pciutils
    nixos-icons
    colord
    ffmpegthumbnailer
    imagemagick
    cliphist
    nodejs
    nodePackages.pnpm
    bun

    fastfetch
    netscanner

    # gnome
    dconf-editor
    file-roller
    nautilus
    amberol
    # blanket
    cavalier
    (celluloid.override {youtubeSupport = true;})
    # contrast
    # eyedropper
    # gnome-solanum
    keypunch
    # kooha
    letterpress
    loupe
    # paleta
    # paper-plane
    (papers.override {supportNautilus = true;})
    parabolic
    # planify
    pwvucontrol
    resources
    gnome-control-center
    newsflash

    # inkscape
    # gimp
    scrcpy

    swww
    inputs.ghostty.packages.${pkgs.system}.default
  ];
}
