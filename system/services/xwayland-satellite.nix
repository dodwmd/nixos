{ config, lib, pkgs, ... }: {
  options.homelab.xwaylandSatellite.enable = lib.mkEnableOption "xwayland-satellite package" // { default = true; };

  config = lib.mkIf config.homelab.xwaylandSatellite.enable {
    environment.systemPackages = [ pkgs.xwayland-satellite ];
  };
}
