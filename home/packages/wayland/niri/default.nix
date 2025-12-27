{
  lib,
  pkgs,
  ...
}: let
  niriLib = import ./_lib.nix {inherit lib;};
  settings = import ./_settings.nix {inherit pkgs;};
  binds = import ./_binds.nix {inherit pkgs;};
  rules = import ./_rules.nix;

  renderedBinds = niriLib.toNiriBinds binds;
  renderedStartup = niriLib.toNiriSpawnAtStartup settings.spawn-at-startup;
  renderedEnv = niriLib.toNiriEnv settings.extraVariables;

  finalConfigText = ''
    environment {
      ${renderedEnv}
    }

    ${renderedStartup}

    binds {
      ${renderedBinds}
    }

    ${settings.config}
    ${rules}
  '';
in {
  imports = [
    niriLib.flake.nixosModules.core
  ];

  users.users.linuxmobile.packages = [pkgs.niri];

  environment.sessionVariables = {
    NIRI_CONFIG = "$HOME/.config/niri/config.kdl";
  };

  custom.programs.niri.settings = {
    inherit (settings) extraVariables spawn-at-startup;
    inherit binds;
    config = finalConfigText;
  };

  xdg.configFile."niri/config.kdl".text = finalConfigText;
}
