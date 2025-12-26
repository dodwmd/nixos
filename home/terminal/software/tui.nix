{
  inputs,
  pkgs,
  ...
}: {
  users.users.linuxmobile.packages = with pkgs;
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
      opencode
    ]
    ++ (with inputs.mynixpkgs.packages.${stdenv.hostPlatform.system}; [
      bmm
      dawn
      dfft
      lightview
      nekot
      omm
      orchat
      prs
    ]);
}
