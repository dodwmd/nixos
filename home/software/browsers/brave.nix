{
  pkgs,
  lib,
  ...
}: let
  chromiumFlags = import ../../packages/browsers/_chromium-flags.nix;
in {
  users.users.dodwmd.packages = [pkgs.brave];

  # Brave reads extra launch flags from ~/.config/brave-flags.conf
  xdg.configFile."brave-flags.conf".text = lib.concatStringsSep "\n" chromiumFlags.flags;
}
