{pkgs, ...}: {
  users.users.linuxmobile.packages = with pkgs; [
    television
    nix-search-tv
  ];

  xdg.configFile."fish/conf.d/television.fish".source = pkgs.runCommand "tv-fish-init" {} ''
    ${pkgs.television}/bin/tv init fish > $out
  '';
}
