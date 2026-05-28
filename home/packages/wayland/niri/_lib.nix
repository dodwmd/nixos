{lib, ...}: let
  inherit (lib) pipe mapAttrsToList concatStringsSep concatMapStringsSep mapAttrs isBool boolToString isInt;
  inherit (lib.types) listOf attrsOf anything str lines submodule nullOr;

  toNiriEnv = vars: let
    renderVal = v:
      if v == null
      then "null"
      else ''"${toString v}"'';
  in
    concatStringsSep "\n" (mapAttrsToList (n: v: ''${n} ${renderVal v}'') vars);

  toNiriSpawn = commands: concatMapStringsSep " " (arg: "\"${arg}\"") commands;

  toNiriBinds = binds:
    concatStringsSep "\n" (
      mapAttrsToList (
        bind: bindOptions: let
          params =
            if bindOptions ? parameters
            then bindOptions.parameters
            else {};
          renderedParams = pipe params [
            (mapAttrs (
              _: value:
                if isBool value
                then boolToString value
                else if isInt value
                then toString value
                else if value == null
                then "null"
                else ''"${toString value}"''
            ))
            (mapAttrsToList (name: value: "${name}=${value}"))
            (concatStringsSep " ")
          ];
          action = let
            spawnDefined = bindOptions ? spawn && bindOptions.spawn != null;
            actionDefined = bindOptions ? action && bindOptions.action != null;
          in
            if !spawnDefined && !actionDefined
            then throw "Bind ${bind} missing action/spawn"
            else if spawnDefined && actionDefined
            then throw "Bind ${bind} has both action and spawn"
            else if actionDefined
            then bindOptions.action
            else "spawn " + toNiriSpawn bindOptions.spawn;
          paramSpace =
            if renderedParams != ""
            then " "
            else "";
        in ''"${bind}"${paramSpace}${renderedParams} { ${action}; }''
      )
      binds
    );

  toNiriSpawnAtStartup = spawn: concatMapStringsSep "\n" (commands: "spawn-at-startup " + (toNiriSpawn commands)) spawn;

  mkNiriOptions = pkgs: {
    binds = lib.mkOption {
      type = attrsOf (submodule {
        options = {
          spawn = lib.mkOption {
            type = nullOr (listOf str);
            default = null;
          };
          action = lib.mkOption {
            type = nullOr str;
            default = null;
          };
          parameters = lib.mkOption {
            type = attrsOf anything;
            default = {};
          };
        };
      });
      default = {};
    };
    spawn-at-startup = lib.mkOption {
      type = listOf (listOf str);
      default = [];
    };
    extraVariables = lib.mkOption {
      type = attrsOf anything;
      default = {};
    };
    config = lib.mkOption {
      type = lines;
      default = "";
    };
  };
in {
  inherit toNiriBinds toNiriSpawnAtStartup toNiriEnv;
  flake.nixosModules.core = {pkgs, ...}: {
    options.custom.programs.niri.settings = mkNiriOptions pkgs;
  };
}
