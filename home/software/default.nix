{pkgs, ...}: {
  imports = [
    ./anyrun
    ./browsers/chromium.nix
    # ./browsers/edge.nix
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
    amberol
    cavalier
    (celluloid.override {youtubeSupport = true;})
    dconf-editor
    file-roller
    gnome-control-center
    gnome-text-editor
    keypunch
    # kooha
    loupe
    nautilus
    newsflash
    (papers.override {supportNautilus = true;})
    pwvucontrol
    resources

    inkscape
    # gimp
    # krita
    scrcpy
    multiviewer-for-f1

    swww
    ghostty
  ];
}
