{
  config,
  pkgs,
  ...
}: let
  configFile = "gammastep/config.ini";
  toINI = (pkgs.formats.ini {}).generate;
in {
  home.packages = with pkgs; [
    (gammastep.override {
      withRandr = false;
      withDrm = false;
      withVidmode = false;
      withAppIndicator = false;
    })
  ];

  systemd.user.services.gammastep = {
    Unit = {
      Description = "Gammastep colour temperature adjuster";
      Documentation = ["https://gitlab.com/chinstrap/gammastep/"];
      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.gammastep}/bin/gammastep -c ${config.xdg.configHome}/${configFile}";
      Restart = "on-failure";
      RestartSec = "3";
    };
  };

  xdg.configFile."${configFile}".source = toINI "config.ini" {
    manual = {
      lat = "-34.58";
      lon = "-58.64";
    };

    general = {
      brightness-day = "1.0";
      brightness-night = "0.5";
      adjustment-method = "wayland";
      location-provider = "manual";
      temp-day = "5500";
      temp-night = "3500";
    };
  };
}
