# home/xdg-compat.nix
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.xdg;
  username = "linuxmobile";
  userConfig = config.users.users.${username};
  homeDir = userConfig.home;

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
    users.users = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule userOpts);
    };

    xdg = {
      configHome = lib.mkOption {
        type = lib.types.path;
        default = "${homeDir}/.config";
        description = "XDG config home directory";
      };

      cacheHome = lib.mkOption {
        type = lib.types.path;
        default = "${homeDir}/.cache";
        description = "XDG cache home directory";
      };

      dataHome = lib.mkOption {
        type = lib.types.path;
        default = "${homeDir}/.local/share";
        description = "XDG data home directory";
      };

      stateHome = lib.mkOption {
        type = lib.types.path;
        default = "${homeDir}/.local/state";
        description = "XDG state home directory";
      };

      runtimeDir = lib.mkOption {
        type = lib.types.path;
        default = "/run/user/${toString userConfig.uid}";
        readOnly = true;
        description = "XDG runtime directory";
      };

      configFile = lib.mkOption {
        type = lib.types.attrsOf fileType;
        default = {};
        description = "Files to place in XDG_CONFIG_HOME";
      };

      cacheFile = lib.mkOption {
        type = lib.types.attrsOf fileType;
        default = {};
        description = "Files to place in XDG_CACHE_HOME";
      };

      dataFile = lib.mkOption {
        type = lib.types.attrsOf fileType;
        default = {};
        description = "Files to place in XDG_DATA_HOME";
      };

      stateFile = lib.mkOption {
        type = lib.types.attrsOf fileType;
        default = {};
        description = "Files to place in XDG_STATE_HOME";
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
      XDG_RUNTIME_DIR = cfg.runtimeDir;
    };

    systemd.tmpfiles.rules = lib.flatten (
      lib.mapAttrsToList (
        user: userCfg: let
          mkRules = baseDir: files:
            lib.mapAttrsToList (
              name: file:
                if file.text != null
                then "f+ ${baseDir}/${name} 0644 ${user} users - ${pkgs.writeText name file.text}"
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
