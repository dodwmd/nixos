{
  config,
  pkgs,
  ...
}: {
  # Add swaylock-effects to system packages
  environment.systemPackages = with pkgs; [
    swaylock-effects
  ];

  # Note: PAM authentication for swaylock must be configured at system level
  # See hosts/exodus/default.nix for the PAM configuration
}