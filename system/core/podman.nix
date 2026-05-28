{ config, lib, pkgs, ... }:

with lib;

{
  options.homelab.podman = {
    enable = mkEnableOption "Enable Podman for OCI containers";
  };

  config = mkIf config.homelab.podman.enable {
    # Enable Podman for containers
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    # Set OCI containers backend
    virtualisation.oci-containers.backend = "podman";

    # Install podman-compose
    environment.systemPackages = with pkgs; [
      podman-compose
    ];
  };
}
