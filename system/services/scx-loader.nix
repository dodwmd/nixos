{
  inputs,
  pkgs,
  ...
}: let
  scx-loader-pkg = inputs.mynixpkgs.packages.${pkgs.stdenv.hostPlatform.system}.scx-loader;
in {
  environment.etc."scx_loader/config.toml".text = ''
    default_sched = "scx_bpfland"
    default_mode = "Auto"
  '';

  services.dbus.packages = [scx-loader-pkg];
  environment.systemPackages = [scx-loader-pkg];

  systemd.services.scx_loader = {
    description = "D-Bus loader for sched_ext schedulers";
    unitConfig.ConditionPathIsDirectory = "/sys/kernel/sched_ext";
    after = ["dbus.service"];
    requires = ["dbus.service"];
    wantedBy = ["graphical.target"];

    path = [pkgs.scx.full];

    serviceConfig = {
      Type = "dbus";
      BusName = "org.scx.Loader";
      ExecStart = "${scx-loader-pkg}/bin/scx_loader";
      KillSignal = "SIGINT";
      Restart = "on-failure";
    };
  };
}
