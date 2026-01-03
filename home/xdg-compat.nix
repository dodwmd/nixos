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

  mkLinkScript = baseDir: name: file: let
    target =
      if file.text != null
      then pkgs.writeText name file.text
      else file.source;
    fullPath = "${baseDir}/${name}";
    parentDir = builtins.dirOf fullPath;
  in ''
    mkdir -p "${parentDir}"
    if [ -L "${fullPath}" ]; then
      current_target=$(readlink "${fullPath}")
      if [ "$current_target" != "${target}" ]; then
        rm -f "${fullPath}"
        ln -s "${target}" "${fullPath}"
      fi
    elif [ -e "${fullPath}" ]; then
      # Regular file exists, replace it
      rm -f "${fullPath}"
      ln -s "${target}" "${fullPath}"
    else
      ln -s "${target}" "${fullPath}"
    fi
  '';
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

    system.activationScripts.xdgUserFiles = lib.stringAfter ["users"] ''
      ${lib.concatStringsSep "\n" (
        lib.flatten (
          lib.mapAttrsToList (
            user: userCfg:
              (lib.mapAttrsToList (mkLinkScript cfg.configHome) userCfg.configFiles)
              ++ (lib.mapAttrsToList (mkLinkScript cfg.cacheHome) userCfg.cacheFiles)
              ++ (lib.mapAttrsToList (mkLinkScript cfg.dataHome) userCfg.dataFiles)
              ++ (lib.mapAttrsToList (mkLinkScript cfg.stateHome) userCfg.stateFiles)
          )
          config.users.users
        )
      )}
    '';
  };
}
