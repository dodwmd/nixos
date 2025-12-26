{pkgs, ...}: let
  obsWrapped = pkgs.symlinkJoin {
    name = "obs-studio-wrapped";
    paths = [
      (pkgs.obs-studio.override {
        pipewireSupport = true;
        browserSupport = true;
      })
      pkgs.obs-studio-plugins.obs-gstreamer
      pkgs.obs-studio-plugins.obs-pipewire-audio-capture
      pkgs.obs-studio-plugins.obs-vaapi
    ];
    buildInputs = [pkgs.makeWrapper];

    postBuild = ''
      wrapProgram $out/bin/obs \
        --add-flags "--ozone-platform=wayland"
    '';
  };
in {
  users.users.linuxmobile.packages = [
    obsWrapped
  ];
}
