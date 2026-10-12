{
  # System monitoring (matching original)
  services.sysstat = {
    enable = true;
    collect-frequency = "*:00/1"; # Collect every 1 minute (standard)
  };
}
