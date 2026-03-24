{
  imports = [
    ./fonts.nix
    ./xdg.nix
  ];

  programs = {
    dconf.enable = true;
    nix-ld.enable = true;
    seahorse.enable = true;
  };
}
