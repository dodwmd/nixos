{
  pkgs,
  lib,
  ...
}: let
  configFile = "swayimg/config";
  toINI = lib.generators.toINI {
    mkKeyValue = lib.generators.mkKeyValueDefault {} " = ";
  };
in {
  users.users.linuxmobile.packages = with pkgs; [swayimg];

  xdg.configFile."${configFile}".text = toINI {
    info = {show = "no";};
    list = {all = "yes";};
    "keys.viewer" = {
      h = "prev_file";
      l = "next_file";
      k = "step_up 10";
      j = "step_down 10";
      n = "next_file";
      p = "prev_file";
    };
    "keys.gallery" = {
      h = "step_left";
      l = "step_right";
      k = "step_up";
      j = "step_down";
    };
  };
}
