{
  config,
  pkgs,
  ...
}: {
  # Server boot configuration - verbose boot messages, no plymouth
  boot = {
    bootspec.enable = true;

    initrd = {
      systemd.enable = true;
    };

    # use latest kernel
    kernelPackages = pkgs.linuxPackages_latest;

    # Verbose boot for servers - need to see what's happening
    consoleLogLevel = 7;
    kernelParams = [
      "systemd.show_status=true"
      "rd.udev.log_level=3"
    ];

    loader = {
      # systemd-boot on UEFI
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # No plymouth on servers - we want boot messages
    plymouth.enable = false;

    tmp = {
      useTmpfs = true;
      cleanOnBoot = true;
    };
  };

  systemd.services.nix-daemon = {
    environment = {
      TMPDIR = "/var/tmp";
    };
  };

  environment.systemPackages = [config.boot.kernelPackages.cpupower];
}
