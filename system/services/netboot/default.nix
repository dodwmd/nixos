{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.homelab.netboot-server;

  sshKeys = (import ../../core/ssh-keys.nix).sshKeys;

  # Build a minimal NixOS netboot image
  netbootSystem = import "${pkgs.path}/nixos" {
    system = pkgs.stdenv.hostPlatform.system;
    configuration = {modulesPath, ...}: {
      imports = [
        (modulesPath + "/installer/netboot/netboot-minimal.nix")
      ];

      # Enable SSH for remote access after PXE boot
      services.openssh = {
        enable = true;
        settings.PermitRootLogin = "prohibit-password";
      };

      # Authorize dodwmd SSH key for root
      users.users.root.openssh.authorizedKeys.keys = sshKeys.dodwmd;

      # DHCP networking (force over installation-device profile's NetworkManager)
      networking.useDHCP = lib.mkForce true;

      system.stateVersion = "25.11";
    };
  };
  build = netbootSystem.config.system.build;
in {
  options.homelab.netboot-server = {
    enable = mkEnableOption "PXE netboot server using pixiecore";
  };

  config = mkIf cfg.enable {
    services.pixiecore = {
      enable = true;
      openFirewall = true;
      dhcpNoBind = true; # ProxyDHCP mode — MikroTik stays as DHCP server
      mode = "boot";
      kernel = "${build.kernel}/${pkgs.stdenv.hostPlatform.linux-kernel.target}";
      initrd = "${build.netbootRamdisk}/initrd";
      cmdLine = "init=${build.toplevel}/init loglevel=4";
    };

    # Explicit firewall rules for proxyDHCP (port 4011 workaround)
    networking.firewall.allowedUDPPorts = [67 69 4011];
  };
}
