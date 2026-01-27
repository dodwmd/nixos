{
  # Server profile for headless machines (K3s, media server, etc)
  # Minimal CLI-only configuration

  imports = [
    # Server-specific packages
    ./packages.nix
  ];
}
