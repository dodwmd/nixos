{
  inputs,
  pkgs,
  ...
}: {
  home.packages = with pkgs;
    [
      # archives
      zip
      unzip
      unrar

      # misc
      libnotify
      fontconfig

      # utils
      du-dust
      duf
      fd
      file
      jaq
      ripgrep
      killall
      jq
      ps_mem

      discordo
      fum
      glow
      gtt
      meteor-git
      reddit-tui
      scope-tui
      tuicam
      wiremix
      zfxtop
      nix-search-tv
      television
    ]
    ++ (with inputs.mynixpkgs.packages.${pkgs.system}; [
      bmm
      crush
      dfft
      omm
      opencode
      prs
      toney
    ]);

  programs = {
    eza.enable = true;
    dircolors = {
      enable = true;
    };
    autojump = {
      enable = true;
    };
  };
}
