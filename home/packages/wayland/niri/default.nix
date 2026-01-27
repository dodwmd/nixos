{
  lib,
  pkgs,
  ...
}: let
  toKDL = import ./_to-KDL.nix {inherit lib pkgs;};
  settings = import ./_settings.nix {inherit pkgs;};
  binds = import ./_binds.nix {inherit pkgs;};
  rules = import ./_rules.nix;

  finalConfig = toKDL.generate "niri-config.kdl" (settings // {binds = binds;} // rules);
in {
  environment.sessionVariables = {
    NIRI_CONFIG = "/etc/niri/config.kdl";
  };

  users.users.dodwmd.packages = with pkgs; [niri swaylock-effects swayidle];

  environment.etc."niri/config.kdl".source = finalConfig;
}
