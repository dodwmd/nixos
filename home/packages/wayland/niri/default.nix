{
  pkgs,
  lib,
  ...
}: let
  toKDL = import ./_to-kdl.nix {inherit lib;};

  settings = import ./_settings.nix {inherit pkgs;};
  binds = import ./_binds.nix {inherit pkgs;};
  rules = import ./_rules.nix;

  niriConfig = settings // {binds = binds;} // rules;
in {
  users.users.linuxmobile.packages = [
    pkgs.niri
  ];
  xdg.configFile."niri/config.kdl".text = toKDL.toKDL niriConfig;
}
