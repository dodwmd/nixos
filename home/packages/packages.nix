{
  inputs,
  pkgs,
  ...
}: {
  users.users.linuxmobile.packages = with pkgs; [
    # messaging
    telegram-desktop

    # misc
    pciutils
    nixos-icons
    ffmpegthumbnailer
    imagemagick
    bun

    # gnome
    file-roller
    gnome-control-center
    nautilus
    (papers.override {supportNautilus = true;})
    pwvucontrol
    (celluloid.override {youtubeSupport = true;})
    loupe
    packet
    fractal
    gnome-text-editor
    amberol
    inputs.mynixpkgs.packages.${stdenv.hostPlatform.system}.camoverlay

    inkscape
    scrcpy
    android-tools
    (inputs.mynixpkgs.packages.${stdenv.hostPlatform.system}.multiviewer.overrideAttrs (old: {
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
    fprintd
    kdePackages.qt6ct
    libsForQt5.qt5ct
    kdePackages.breeze
    kdePackages.breeze.qt5
  ];
}
