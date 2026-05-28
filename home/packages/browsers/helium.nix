{
  pkgs,
  inputs,
  lib,
  ...
}: let
  chromiumFlags = import ./_chromium-flags.nix;

  heliumWrapped = pkgs.symlinkJoin {
    name = "helium-wrapped";
    paths = [inputs.mynixpkgs.packages.${pkgs.stdenv.hostPlatform.system}.helium];
    buildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/helium \
        ${lib.concatMapStringsSep " \\\n        " (flag: "--add-flags '${flag}'") chromiumFlags.flags}
    '';
  };
in {
  users.users.dodwmd.packages = [heliumWrapped];
}
