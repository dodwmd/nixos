{
  pkgs,
  ...
}: {
  imports = [
    ./anyrun
    ./browsers/chromium.nix
    ./browsers/edge.nix
    # ./browsers/qutebrowser.nix
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
    cliphist
    ffmpegthumbnailer
    imagemagick
    nodejs
    nodePackages.pnpm
    bun

    fastfetch

    # gnome
    amberol
    cavalier
    (celluloid.override {youtubeSupport = true;})
    dconf-editor
    eyedropper
    file-roller
    gnome-control-center
    gnome-text-editor
    keypunch
    loupe
    nautilus
    (papers.override {supportNautilus = true;})
    pwvucontrol
    resources

    inkscape
    gimp
    # krita
    scrcpy
    multiviewer-for-f1

    swww
    ghostty
    mods
  ];
}
