{
  pkgs,
  lib,
  ...
}: let
  chromiumFlags = import ./_chromium-flags.nix;

  chromiumWrapped =
    pkgs.runCommand "ungoogled-chromium-wrapped" {
      nativeBuildInputs = [pkgs.makeWrapper];
    } ''
      mkdir -p $out/bin
      chromiumBin=$(find ${pkgs.ungoogled-chromium} -type f -executable -name "*chromium*" | head -n 1)
      cp "$chromiumBin" $out/bin/ungoogled-chromium
      chmod +x $out/bin/ungoogled-chromium
      wrapProgram $out/bin/ungoogled-chromium \
        ${lib.concatMapStringsSep " \\\n        " (flag: "--add-flags '${flag}'") chromiumFlags.flags}
    '';
in {
  users.users.linuxmobile.packages = [chromiumWrapped];
  environment.sessionVariables = chromiumFlags.sessionVariables;
}
