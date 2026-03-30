{ config, lib, ... }: {
  options.homelab.location.enable = lib.mkEnableOption "geoclue2 location service";

  config = lib.mkIf config.homelab.location.enable {
    location.provider = "geoclue2";

    services.geoclue2 = {
      enable = true;
      geoProviderUrl = "https://beacondb.net/v1/geolocate";
      submissionUrl = "https://beacondb.net/v2/geosubmit";
      submissionNick = "geoclue";

      appConfig.gammastep = {
        isAllowed = true;
        isSystem = false;
      };
    };
  };
}
