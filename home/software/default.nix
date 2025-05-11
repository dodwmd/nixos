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

    # gnome
    dconf-editor
    file-roller
    nautilus
    amberol
    cavalier
    (celluloid.override {youtubeSupport = true;})
    keypunch
    # kooha
    loupe
    (papers.override {supportNautilus = true;})
    pwvucontrol
    resources
    gnome-control-center
    newsflash

    inkscape
    # gimp
    # krita
    scrcpy
    multiviewer-for-f1

    swww
    ghostty
  ];
}
