{pkgs, ...}: {
  networking = {
    # Use DNS from DHCP instead of hardcoded Cloudflare
    # nameservers = ["1.1.1.1" "1.0.0.1"];

    nftables.enable = true;

    networkmanager = {
      enable = true;
      dns = "default";  # Let NetworkManager handle DNS from DHCP
      wifi.powersave = true;
      plugins = with pkgs; [
        networkmanager-openvpn
      ];
    };

    useDHCP = false;
    dhcpcd.enable = false;
  };

  services = {
    openssh = {
      enable = true;
      settings.UseDns = true;
    };
  };

  # Don't wait for network startup
  systemd.services.NetworkManager-wait-online.serviceConfig.ExecStart = ["" "${pkgs.networkmanager}/bin/nm-online -q"];
  # Editable /etc/hosts for htb machines
  environment.etc.hosts.enable = false;
}
