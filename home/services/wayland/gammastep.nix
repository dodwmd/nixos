{pkgs, ...}: {
  services.gammastep = {
    enable = true;
    package = pkgs.gammastep.override {
      withRandr = false;
      withDrm = false;
      withVidmode = false;
      withAppIndicator = false;
    };

    latitude = "-34.58";
    longitude = "-58.64";
    provider = "manual";
    temperature = {
      day = 5500;
      night = 3500;
    };
    settings = {
      general = {
        brightness-day = 1.0;
        brightness-night = 0.5;
        adjustment-method = "wayland";
      };
    };
  };
}
