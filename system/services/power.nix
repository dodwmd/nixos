{
  inputs,
  pkgs,
  ...
}: {
  services = {
    logind.settings.Login = {
      powerKey = "suspend";
      lidSwitch = "suspend";
      lidSwitchExternalPower = "lock";
    };

    power-profiles-daemon = {
      enable = true;
      package = inputs.mynixpkgs.packages.${pkgs.stdenv.hostPlatform.system}.power-profiles-daemon;
    };

    # battery info
    upower = {
      enable = true;
      percentageLow = 30;
      percentageCritical = 20;
      percentageAction = 10;
      criticalPowerAction = "PowerOff";
    };
  };

  # Configure systemd sleep settings for security (based on Arch documentation)
  systemd.sleep.settings.Sleep = {
    AllowSuspend = true;
    AllowHibernation = false;
    AllowSuspendThenHibernate = false;
    AllowHybridSleep = true;
  };
}
