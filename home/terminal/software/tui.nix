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
      fastfetch

      # utils
      dust
      duf
      fd
      file
      killall
      jq
      ps_mem

      gtt
      meteor-git
      nix-search-tv
      opencode
      gemini-cli
    ]
    ++ (with inputs.mynixpkgs.packages.${stdenv.hostPlatform.system}; [
      nekot
      omm
      prs
      pi-coding-agent
    ]);
}
