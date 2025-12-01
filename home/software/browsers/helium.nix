{
  inputs,
  pkgs,
  ...
}: let
  chromiumFlags = import ./chromium-flags.nix {inherit pkgs;};

  helium-with-desktop = pkgs.symlinkJoin {
    name = "helium-with-desktop";
    paths = [inputs.helium.packages."${pkgs.system}".helium];
    buildInputs = [pkgs.makeWrapper];
    postBuild = ''
      mkdir -p $out/share/applications
      cat > $out/share/applications/helium.desktop << EOF
      [Desktop Entry]
      Name=Helium
      Comment=Helium Browser
      Exec=$out/bin/helium %U
      Terminal=false
      Type=Application
      Icon=helium
      Categories=Network;WebBrowser;
      MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;
      StartupNotify=true
      EOF

      rm $out/bin/helium
      makeWrapper ${inputs.helium.packages."${pkgs.system}".helium}/bin/helium $out/bin/helium \
        ${pkgs.lib.concatMapStrings (flag: "--add-flags '${flag}' ") chromiumFlags.flagsList} \
        --add-flags "--widevine-path=${pkgs.widevine-cdm}/share/google/chrome/WidevineCdm/_platform_specific/linux_x64/libwidevinecdm.so"
    '';
  };
in {
  home.packages = with pkgs; [
    helium-with-desktop
    widevine-cdm
  ];

  home.sessionVariables = chromiumFlags.sessionVariables;
}
