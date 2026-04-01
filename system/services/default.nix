{
  lib,
  pkgs,
  ...
}: {
  services = {
    printing = {
      enable = true;
      drivers = [pkgs.hplip];
    };

    irqbalance.enable = true;
    thermald.enable = true;
    speechd.enable = lib.mkForce false;
  };
}
