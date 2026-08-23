{
  pkgs,
  lib,
  ...
}: let
  chromiumFlags = import ../../packages/browsers/_chromium-flags.nix;
in {
  # programs.chromium is a NixOS module (managed policies), not home-manager's
  # variant, so it has no `package` option — the browser itself must be
  # installed separately.
  users.users.dodwmd.packages = [pkgs.brave];

  programs.chromium = {
    enable = true;
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # Ublock Origin
      "jhnleheckmknfcgijgkadoemagpecfol" # Auto-Tab-Discard
      "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
    ];
  };

  # Brave reads extra launch flags from ~/.config/brave-flags.conf
  xdg.configFile."brave-flags.conf".text = lib.concatStringsSep "\n" chromiumFlags.flags;
}
