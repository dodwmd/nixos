{
  inputs,
  pkgs,
  ...
}: {
  # greetd display manager

  services.greetd = {
    enable = true;
    settings = {
      terminal.vt = 1;
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --cmd ${inputs.mynixpkgs.packages.${pkgs.stdenv.hostPlatform.system}.niri}/bin/niri-session";
        user = "greeter";
      };
      initial_session = {
        command = "${inputs.mynixpkgs.packages.${pkgs.stdenv.hostPlatform.system}.niri}/bin/niri-session";
        user = "linuxmobile";
      };
    };
  };
}
