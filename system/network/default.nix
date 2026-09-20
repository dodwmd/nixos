{pkgs, ...}: {
  networking = {
    # Use DNS from DHCP instead of hardcoded Cloudflare
    # nameservers = ["1.1.1.1" "1.0.0.1"];

    nftables.enable = true;

    networkmanager = {
      enable = true;
      # systemd-resolved lets per-connection search domains be marked "routing-only"
      # (leading "~"), which plain resolv.conf (dns="default") can't express. Needed
      # so home.dodwell.us's search domain doesn't hijack unrelated external lookups
      # (e.g. steamcontent.com) via its public wildcard record. See exodus's Ethernet
      # NM profile (hosts/exodus/default.nix) for the routing-only dns-search config.
      dns = "systemd-resolved";
      wifi.powersave = false;
      plugins = with pkgs; [
        networkmanager-openvpn
      ];
    };

    useDHCP = false;
    dhcpcd.enable = false;
  };

  services = {
    resolved.enable = true;

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
