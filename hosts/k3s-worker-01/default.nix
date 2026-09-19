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
    hostname = "k3s-worker-01";
    upgradeTime = "03:00"; # Stagger from masters
    allowReboot = true; # Workers can reboot
    cpuGovernor = "ondemand"; # Workers can scale
    showBootMessages = true; # Show boot messages
    extraPackages = with pkgs; [nvme-cli]; # This worker has NVMe storage
  };

  # K3s worker configuration
  homelab.k3s-worker = {
    enable = true;
    serverAddr = "https://192.168.1.20:6443";
    nodeLabels = [
      "worker=true"
      "hardware=nuc"
      "storage=local-ssd"
    ];
    maxPods = 110;
  };

  homelab.k3s-cluster = {
    # nodeIP will be auto-detected from DHCP
  };

  # Cisco IP phone TFTP provisioning
  age.secrets.sip-password = {
    file = ../../secrets/sip-password.age;
  };

  homelab.voip.cisco-provisioning = {
    enable = true;
    asteriskAddr = "192.168.1.202";
    # sipPort dropped (was 5062, chan_sip's dedicated port) - Asterisk
    # upgraded to 22.x, which doesn't have chan_sip at all (removed
    # upstream as of Asterisk 21). The phone now points at the default
    # 5060/PJSIP, registering unauthenticated (no auth= on the [1000]
    # endpoint) rather than needing chan_sip's simpler digest handling -
    # the actual limitation was always that this firmware never sends an
    # Authorization header on REGISTER at all, not a specific digest
    # flavor, so dropping auth entirely on the PJSIP side works too.
    # Old 9-2-2SR1-9 firmware always demanded a CTL/ITL trust list and a
    # persistent CUCM TCP session regardless of deviceSecurityMode - phone's
    # own status screen showed "No Trust List installed" / "CUCM closed TCP
    # connection" on every boot, causing an endless reboot loop. Upgrading
    # to 9-4-1-9 to test whether newer firmware actually honors
    # deviceSecurityMode=1 and skips CUCM enrollment, per third-party-SIP
    # guides that worked on 9.4.x loads.
    firmwareVersion = "sip9971.9-4-1-9";
    phones = {
      "office" = {
        mac = "F47F35A342D1";
        extension = "1000";
        displayName = "Cisco Phone";
        authPasswordFile = config.age.secrets.sip-password.path;
        speedDials = [
          {
            label = "Michael";
            number = "0402093606";
          }
          {
            label = "Damien";
            number = "0493047784";
          }
          {
            label = "Mum";
            number = "0451771305";
          }
        ];
      };
    };
  };

  # System state version
  system.stateVersion = "25.11";
}
