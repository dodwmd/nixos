{
  config,
  pkgs,
  ...
}: let
  configFile = "gammastep/config.ini";
  toINI = (pkgs.formats.ini {}).generate;

  gammastep = pkgs.gammastep.override {
    withRandr = false;
    withDrm = false;
    withVidmode = false;
    withAppIndicator = false;
  };
in {
  users.users.dodwmd.packages = [gammastep];

  # f.lux-style colour-temperature adjustment: warm the display at night,
  # neutral during the day. Runs for the whole graphical session and follows
  # the sunrise/sunset for the manual location below.
  systemd.user.services.gammastep = {
    description = "Gammastep colour temperature adjustment (f.lux-style)";
    documentation = ["man:gammastep(1)"];
    partOf = ["graphical-session.target"];
    after = ["graphical-session.target"];
    wantedBy = ["graphical-session.target"];
    serviceConfig = {
      ExecStart = "${gammastep}/bin/gammastep -c ${config.xdg.configHome}/${configFile}";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };

  xdg.configFile."${configFile}".source = toINI "config.ini" {
    # Brisbane, Australia (matches time.timeZone = Australia/Brisbane).
    manual = {
      lat = "-27.47";
      lon = "153.03";
    };

    general = {
      # 6500K is the neutral point (sRGB D65), so days get no tint at all.
      # Night 4000K is a clear-but-gentle warm shift: lower toward 3500 for a
      # full f.lux feel, raise toward 4500 to make it barely noticeable.
      # Brightness left at 1.0 - dimming via gamma just muddies the picture.
      brightness-day = "1.0";
      brightness-night = "1.0";
      adjustment-method = "wayland";
      location-provider = "manual";
      temp-day = "6500";
      temp-night = "4000";
    };
  };
}
