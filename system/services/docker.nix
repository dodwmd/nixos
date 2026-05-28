{ config, lib, pkgs, ... }: {
  options.homelab.docker.enable = lib.mkEnableOption "Docker and Android tools";

  config = lib.mkIf config.homelab.docker.enable {
    virtualisation.docker.enable = true;
    # programs.adb removed in systemd 258; add android-tools to system packages instead
    environment.systemPackages = [ pkgs.android-tools ];
  };
}
