{pkgs, ...}: let
  braveWrapped = pkgs.symlinkJoin {
    name = "brave-wrapped";
    paths = [pkgs.brave];
    buildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/brave \
        --add-flags "--ignore-gpu-blocklist" \
        --add-flags "--enable-zero-copy" \
        --add-flags "--ozone-platform-hint=auto" \
        --add-flags "--enable-wayland-ime" \
        --add-flags "--enable-features=VaapiVideoDecodeLinuxGL,VaapiVideoDecoder,WebRTCPipeWireCapturer,WaylandWindowDecorations"
    '';
  };
in {
  users.users.dodwmd.packages = [braveWrapped];
}
