{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./browsers/chromium.nix
    ./browsers/edge.nix
    ./browsers/zen.nix
    ./browsers/helium.nix
    ./gtk.nix
    ./media
  ];

  home.packages = with pkgs; [
    # messaging
    telegram-desktop
    vesktop

    # misc
    pciutils
    nixos-icons
    ffmpegthumbnailer
    imagemagick
    bun

    fastfetch

    # gnome
    amberol
    (celluloid.override {youtubeSupport = true;})
    dconf-editor
    file-roller
    gnome-control-center
    gnome-text-editor
    loupe
    nautilus
    (papers.override {supportNautilus = true;})
    resources

    inkscape
    scrcpy
    (inputs.mynixpkgs.packages.${pkgs.system}.multiviewer.overrideAttrs (old: {
      buildInputs = (old.buildInputs or []) ++ [pkgs.makeWrapper];
      postInstall = ''
        wrapProgram $out/bin/multiviewer \
          --set LD_LIBRARY_PATH "/run/opengl-driver/lib:''${LD_LIBRARY_PATH:-}" \
          --set __EGL_VENDOR_LIBRARY_FILENAMES ${pkgs.mesa}/share/glvnd/egl_vendor.d/50_mesa.json \
          --set LIBGL_ALWAYS_INDIRECT 0 \
          --set ELECTRON_OZONE_PLATFORM_HINT wayland
      '';
    }))

    swww
    openvpn
    # (mangowc.override {enableXWayland = false;})
  ];
}
