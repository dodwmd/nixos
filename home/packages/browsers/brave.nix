{
  inputs,
  lib,
  pkgs,
  ...
}: let
  chromiumFlags = import ./_chromium-flags.nix;

  bravePkg = inputs.mynixpkgs.packages.${pkgs.stdenv.hostPlatform.system}.brave.override {
    enableVideoAcceleration = true;
    vulkanSupport = true;
  };

  braveWrapped = pkgs.symlinkJoin {
    name = "brave-origin-wrapped";
    paths = [bravePkg];
    buildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/brave \
        ${lib.concatMapStringsSep " \\\n        " (flag: "--add-flags \"${flag}\"") chromiumFlags.flags}
    '';
  };
in {
  users.users.linuxmobile.packages = [braveWrapped];
  environment.sessionVariables = chromiumFlags.sessionVariables;
}
