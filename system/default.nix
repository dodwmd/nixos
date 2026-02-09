let
  # Base system configuration
  base = [
    ./core/default.nix
  ];

  # Desktop workstation profile
  desktop = base ++ [
    ./core/boot-desktop.nix

    ./hardware/graphics.nix
    ./hardware/fwupd.nix

    ./network/default.nix

    ./programs

    ./services
    ./services/greetd.nix
    ./services/pipewire.nix
    ./services/xdg-portal-fix.nix
  ];

  # Laptop profile (extends desktop)
  laptop =
    desktop
    ++ [
      ./hardware/bluetooth.nix
      ./services/power.nix
    ];

  # Server profile (minimal, no desktop)
  server = base ++ [
    ./core/boot-server.nix
    ./core/podman.nix
    # Note: network/default.nix is for desktop NetworkManager, servers configure networking directly
  ];

  # Media server profile (extends server)
  media-server = server ++ [
    ./services/zfs.nix
    ./services/nfs-server.nix
    ./services/nginx-proxy.nix
    ./services/netdata.nix
    ./services/media
  ];

  # K3s master profile (extends server)
  k3s-master = server ++ [
    ./services/k3s
    ./services/netboot
  ];

  # K3s worker profile (extends server)
  k3s-worker = server ++ [
    ./services/k3s
    ./services/voip/cisco-phone-provisioning.nix
  ];
in {
  inherit desktop laptop server media-server k3s-master k3s-worker;
}
