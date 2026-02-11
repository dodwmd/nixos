{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.xdg;
  username = "dodwmd";
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
      force = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to force overwrite existing files (default: true since these are declaratively managed)";
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
    if [ -e "${fullPath}" ] || [ -L "${fullPath}" ]; then
      currentTarget=$(readlink -f "${fullPath}" 2>/dev/null || echo "")
      newTarget=$(readlink -f "${target}" 2>/dev/null || echo "${target}")
      if [ "$currentTarget" = "$newTarget" ]; then
        : # already correct, skip
      elif [ "${lib.boolToString file.force}" = "true" ]; then
        echo "xdg-compat: replacing ${fullPath} -> ${target}"
        rm -f "${fullPath}"
        ln -s "${target}" "${fullPath}"
      else
        echo "xdg-compat: WARNING: ${fullPath} exists and differs from managed source, set force=true to overwrite" >&2
      fi
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

    # Add user packages to system packages so they're actually installed
    environment.systemPackages = config.users.users.${username}.packages or [];

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
