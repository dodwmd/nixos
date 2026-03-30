{ config, lib, pkgs, ... }: {
  options.homelab.greetd.enable = lib.mkEnableOption "greetd display manager" // { default = true; };

  config = lib.mkIf config.homelab.greetd.enable {
    services = {
      greetd = let
        session = {
          command = "${pkgs.niri}/bin/niri-session";
          user = "dodwmd";
        };
      in {
        enable = true;
        settings = {
          terminal.vt = 1;
          default_session = session;
          initial_session = session;
        };
      };
      displayManager.autoLogin = {
        user = "dodwmd";
        enable = true;
      };
    };
  };
}
