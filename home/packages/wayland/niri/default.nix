{
  lib,
  pkgs,
  config,
  ...
}: let
  toKDL = import ./_to-KDL.nix {inherit lib pkgs;};
  settings = import ./_settings.nix {inherit pkgs;} // {output = config.homelab.niri.outputs;};
  binds = import ./_binds.nix {inherit pkgs;};
  rules = import ./_rules.nix {primaryOutput = config.homelab.niri.primaryOutput;};

  finalConfig = toKDL.generate "niri-config.kdl" (settings // {binds = binds;} // rules);
in {
  options.homelab.niri.outputs = lib.mkOption {
    type = lib.types.listOf lib.types.attrs;
    default = [];
    description = ''
      Per-host niri `output {}` KDL blocks (see _to-KDL.nix for the attrset shape).
      Left empty by default so niri auto-detects outputs at their preferred mode
      rather than risking a hardcoded mode/scale that doesn't match the host's
      actual monitor(s).
    '';
  };

  options.homelab.niri.primaryOutput = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    description = ''
      Name of this host's primary/secondary-app output (e.g. "HDMI-A-1"), used
      by window-rules that pin a specific app to a specific monitor (see the
      Multiviewer rule in _rules.nix). Left null on hosts with no such output
      (e.g. a laptop) so those rules don't reference a monitor that doesn't exist.
    '';
  };

  config = {
    environment.sessionVariables = {
      NIRI_CONFIG = "/etc/niri/config.kdl";
    };

    users.users.dodwmd.packages = with pkgs; [niri swaylock swayidle slurp];

    environment.etc."niri/config.kdl".source = finalConfig;
  };
}
