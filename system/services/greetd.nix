{pkgs, ...}: {
  # greetd display manager

  services.greetd = {
    enable = true;
    settings = {
      terminal.vt = 1;
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --cmd ${pkgs.niri}/bin/niri-session";
        user = "greeter";
      };
      initial_session = {
        command = "${pkgs.niri}/bin/niri-session";
        user = "linuxmobile";
      };
    };
  };
}
