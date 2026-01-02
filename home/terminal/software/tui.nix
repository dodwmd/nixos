{
  inputs,
  pkgs,
  lib,
  ...
}: {
  users.users.dodwmd.packages = with pkgs;
    [
      # archives
      zip
      unzip
      unrar
      ouch

      # misc
      libnotify
      fontconfig

      # utils
      dust
      duf
      fd
      file
      killall
      jq
      ps_mem
      inshellisense

      fum
      gtt
      meteor-git
      nix-search-tv
      reddit-tui
      scope-tui
      tuicam
      wiremix
      zfxtop
    ]
    ++ (let
      mynixpkgs = inputs.mynixpkgs.packages.${pkgs.stdenv.hostPlatform.system};
    in
      lib.filter (pkg: pkg != null) [
        (mynixpkgs.bmm or null)
        (mynixpkgs.dawn or null)
        (mynixpkgs.dfft or null)
        (mynixpkgs.lightview or null)
        (mynixpkgs.nekot or null)
        (mynixpkgs.omm or null)
        (mynixpkgs.orchat or null)
        (mynixpkgs.prs or null)
      ]);
}
