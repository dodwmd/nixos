{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.xdg;
  username = "linuxmobile";

  fileType = lib.types.submodule {
    options = {
      text = lib.mkOption {
        type = lib.types.nullOr lib.types.lines;
        default = null;
      };
      source = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
      };
    };
  };

  userOpts = _: {
    options = {
      configFiles = lib.mkOption {
        type = lib.types.attrsOf fileType;
        default = {};
      };
      cacheFiles = lib.mkOption {
        type = lib.types.attrsOf fileType;
        default = {};
      };
      dataFiles = lib.mkOption {
        type = lib.types.attrsOf fileType;
        default = {};
      };
      stateFiles = lib.mkOption {
        type = lib.types.attrsOf fileType;
        default = {};
      };
    };
  };
in {
  options = {
    users.users = lib.mkOption {type = lib.types.attrsOf (lib.types.submodule userOpts);};
    xdg = {
      configHome = lib.mkOption {
        type = lib.types.path;
        default = "/home/${username}/.config";
      };
      cacheHome = lib.mkOption {
        type = lib.types.path;
        default = "/home/${username}/.cache";
      };
      dataHome = lib.mkOption {
        type = lib.types.path;
        default = "/home/${username}/.local/share";
      };
      stateHome = lib.mkOption {
        type = lib.types.path;
        default = "/home/${username}/.local/state";
      };

      runtimeDir = lib.mkOption {
        type = lib.types.str;
        default = "/run/user/1000";
      };

      configFile = lib.mkOption {
        type = lib.types.attrsOf fileType;
        default = {};
      };
      cacheFile = lib.mkOption {
        type = lib.types.attrsOf fileType;
        default = {};
      };
      dataFile = lib.mkOption {
        type = lib.types.attrsOf fileType;
        default = {};
      };
      stateFile = lib.mkOption {
        type = lib.types.attrsOf fileType;
        default = {};
      };
    };
  };

  config = {
    users.users.${username} = {
      configFiles = cfg.configFile;
      cacheFiles = cfg.cacheFile;
      dataFiles = cfg.dataFile;
      stateFiles = cfg.stateFile;
    };

    environment.sessionVariables = {
      XDG_CONFIG_HOME = cfg.configHome;
      XDG_CACHE_HOME = cfg.cacheHome;
      XDG_DATA_HOME = cfg.dataHome;
      XDG_STATE_HOME = cfg.stateHome;
    };

    systemd.tmpfiles.rules = lib.flatten (
      lib.mapAttrsToList (
        user: userCfg: let
          mkRules = baseDir: files:
            lib.mapAttrsToList (
              name: file:
                if file.text != null
                then "L+ ${baseDir}/${name} - - - - ${pkgs.writeText name file.text}"
                else "L+ ${baseDir}/${name} - - - - ${file.source}"
            )
            files;
        in
          (mkRules cfg.configHome userCfg.configFiles)
          ++ (mkRules cfg.cacheHome userCfg.cacheFiles)
          ++ (mkRules cfg.dataHome userCfg.dataFiles)
          ++ (mkRules cfg.stateHome userCfg.stateFiles)
      )
      config.users.users
    );
  };
}
