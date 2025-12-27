{pkgs, ...}: let
  edgeWrapped =
    pkgs.runCommand "microsoft-edge-wrapped" {
      nativeBuildInputs = [pkgs.makeWrapper];
    } ''
      mkdir -p $out/bin
      edgeBin=$(find ${pkgs.microsoft-edge} -type f -executable -name "*edge*" | head -n 1)
      cp "$edgeBin" $out/bin/microsoft-edge-stable
      chmod +x $out/bin/microsoft-edge-stable
      wrapProgram $out/bin/microsoft-edge-stable \
        --add-flags "--ignore-gpu-blocklist" \
        --add-flags "--enable-zero-copy" \
        --add-flags "--ozone-platform-hint=auto" \
        --add-flags "--ozone-platform=wayland" \
        --add-flags "--enable-wayland-ime" \
        --add-flags "--process-per-site" \
        --add-flags "--enable-features=WebUIDarkMode,UseOzonePlatform,VaapiVideoDecodeLinuxGL,VaapiVideoDecoder,WebRTCPipeWireCapturer,WaylandWindowDecorations"
    '';
in {
  users.users.linuxmobile.packages = [
    edgeWrapped
  ];
}
