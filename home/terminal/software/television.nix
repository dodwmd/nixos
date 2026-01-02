{pkgs, ...}: {
  home.packages = with pkgs; [
    television
    nix-search-tv
  ];

  xdg.configFile."fish/completions/tv.fish".source = "${pkgs.television}/share/fish/vendor_completions.d/tv.fish";
}
