{ config, lib, ... }: {
  options.homelab.power.enable = lib.mkEnableOption "power management services" // { default = true; };

  config = lib.mkIf config.homelab.power.enable {
    services = {
      logind.settings.Login = {
        powerKey = "suspend";
        lidSwitch = "suspend";
        lidSwitchExternalPower = "lock";
      };

      power-profiles-daemon.enable = true;

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
    systemd.sleep.extraConfig = ''
      AllowSuspend=yes
      AllowHibernation=no
      AllowSuspendThenHibernate=no
      AllowHybridSleep=no
    '';
  };
}
