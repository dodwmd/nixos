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
      dust
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
      nix-search-tv
      reddit-tui
      scope-tui
      television
      tuicam
      undercut-f1
      wiremix
      zfxtop
    ]
    ++ (with inputs.mynixpkgs.packages.${pkgs.system}; [
      bmm
      dfft
      omm
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
