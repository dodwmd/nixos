{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  # K3s host common configuration
  homelab.k3s-host = {
    enable = true;
    hostname = "k3s-worker-02";
    upgradeTime = "03:30"; # Stagger from other workers
    allowReboot = true; # Workers can reboot
    cpuGovernor = "ondemand"; # Workers can scale
    showBootMessages = true; # Show boot messages
  };

  # K3s worker configuration
  homelab.k3s-worker = {
    enable = true;
    serverAddr = "https://192.168.1.20:6443";
    nodeLabels = [
      "worker=true"
      "hardware=nuc"
      "storage=local-ssd"
      "gpu=intel-xe" # i5-1240P iGPU (i915), used for VAAPI decode by Frigate
    ];
    maxPods = 110;
  };

  homelab.k3s-cluster = {
    # nodeIP will be auto-detected from DHCP
  };

  # RTP media for the fusionpbx pod (hostNetwork, pinned here via nodeSelector
  # in k3s/apps/fusionpbx) - without this, this node's firewall silently dropped every
  # inbound RTP packet before it ever reached FreeSWITCH's socket, while
  # tcpdump on "any" still showed the packets arriving (netfilter INPUT
  # DROP happens after tcpdump's capture point). Confirmed live: the
  # phone's own streaming stats showed real Sender Packets/Octets leaving
  # it but zero Rcvr Packets back, and `strace`'ing FreeSWITCH's bound RTP
  # socket showed nothing but EAGAIN despite those same packets being
  # visible on the wire - this was the actual root cause of "no audio"
  # across the old Asterisk setup AND both the custom-compiled and
  # official-package FreeSWITCH builds, none of which were ever the real
  # problem. FreeSWITCH's rtp-start-port/rtp-end-port are pinned to this
  # exact range in the fusionpbx image's switch.conf.xml to match.
  networking.firewall.allowedUDPPortRanges = [
    { from = 16384; to = 16584; }
  ];

  # SNAT the fusionpbx internal sip_profile's outbound-initiated SIP
  # signaling (inbound-call INVITEs, NOTIFYs) so LAN phones see it coming
  # from the FusionPBX MetalLB VIP (192.168.1.202) instead of this node's
  # real address. Confirmed live: the Cisco CP-9971 registers fine and
  # answers calls it originates, but silently drops (zero response, not
  # even a courtesy 100 Trying, despite `ping` and tcpdump both confirming
  # the INVITE physically arrives) any FreeSWITCH-initiated INVITE sourced
  # from 192.168.1.32 - the phone's SIP stack only accepts unsolicited
  # requests from its configured registrar/proxy address, which is the
  # VIP it registered against, not this node's real IP.
  #
  # Deliberately NOT pinning the VIP itself to this node (e.g. via a
  # node-scoped L2Advertisement) - that would sacrifice MetalLB's failover
  # for this one service. This SNAT only rewrites the source of packets
  # this node itself originates toward the LAN; inbound routing to the
  # VIP is completely untouched and keeps working through whichever node
  # MetalLB currently elects, exactly like the phone's own REGISTER
  # traffic already does today. Scoped to the LAN subnet only so it never
  # touches the Superloop trunk leg, which already correctly sources from
  # the public IP via vars.xml.
  #
  # Uses networking.firewall.extraCommands (plain iptables, run through
  # the iptables-nft compat shim) rather than networking.nftables.tables -
  # confirmed live via `nft list tables` that this node's actual firewall
  # implementation is entirely the legacy iptables-based one (only
  # "filter"/"mangle"/"nat" compat tables exist, no systemd unit for a
  # native nftables ruleset at all), so a networking.nftables.tables entry
  # would silently never get loaded.
  networking.firewall.extraCommands = ''
    iptables -t nat -A POSTROUTING -d 192.168.1.0/24 -p udp --dport 5060 -j SNAT --to-source 192.168.1.202
  '';
  networking.firewall.extraStopCommands = ''
    iptables -t nat -D POSTROUTING -d 192.168.1.0/24 -p udp --dport 5060 -j SNAT --to-source 192.168.1.202 2>/dev/null || true
  '';

  # Note: Static IP configuration available if needed
  # networking.interfaces.enp114s0 = {
  #   useDHCP = false;
  #   ipv4.addresses = [{
  #     address = "192.168.1.31";
  #     prefixLength = 24;
  #   }];
  # };
  # networking.defaultGateway = {
  #   address = "192.168.1.1";
  #   interface = "enp114s0";
  # };

  # System state version
  system.stateVersion = "25.11";
}
