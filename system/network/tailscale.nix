{
  networking.firewall = {
    trustedInterfaces = ["tailscale"];
    # required to connect to Tailscale exit nodes
    # checkReversePath = "loose";
  };

  # inter-machine VPN
  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "both";
  };
}
