{lib, ...}: {
  imports = [
    ./security.nix
    ./user-roles.nix
    ../nix
    ../programs/fish.nix
  ];

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "es_AR.UTF-8";
      LC_IDENTIFICATION = "es_AR.UTF-8";
      LC_MEASUREMENT = "es_AR.UTF-8";
      LC_MONETARY = "es_AR.UTF-8";
      LC_NAME = "es_AR.UTF-8";
      LC_NUMERIC = "es_AR.UTF-8";
      LC_PAPER = "es_AR.UTF-8";
      LC_TELEPHONE = "es_AR.UTF-8";
      LC_TIME = "es_AR.UTF-8";
    };
  };

  console.keyMap = "us";

  # don't touch this
  system = {
    switch.enable = true;
    stateVersion = lib.mkDefault "25.11";
  };

  time = {
    timeZone = lib.mkDefault "America/Argentina/Buenos_Aires";
    hardwareClockInLocalTime = lib.mkDefault true;
  };

  # compresses half the ram for use as swap
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
  };

  # Enable SSH globally to ensure user SSH key setup works
  services.openssh.enable = lib.mkDefault true;
}
