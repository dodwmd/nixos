_: {
  imports = [
    ./fonts.nix
    ./xdg.nix
  ];

  programs = {
    dconf.enable = true;
    seahorse.enable = true;
    adb.enable = true;
  };
}
