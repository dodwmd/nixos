{
  config,
  pkgs,
  ...
}: let
  configFile = "gammastep/config.ini";
  toINI = (pkgs.formats.ini {}).generate;
in {
  users.users.dodwmd.packages = with pkgs; [
    (gammastep.override {
      withRandr = false;
      withDrm = false;
      withVidmode = false;
      withAppIndicator = false;
    })
  ];

  # Create a simple script to start gammastep - user can run manually or add to their session
  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "start-gammastep" ''
      ${gammastep}/bin/gammastep -c ${config.xdg.configHome}/${configFile} &
    '')
  ];

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
