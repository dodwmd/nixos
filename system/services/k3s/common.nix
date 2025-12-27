# Common K3s configuration module for all nodes
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.homelab.k3s-cluster;
in
{
  options.homelab.k3s-cluster = {
    enable = mkEnableOption "K3s cluster configuration";
    
    clusterDomain = mkOption {
      type = types.str;
      default = "cluster.local";
      description = "Kubernetes cluster domain";
    };
    
    clusterCIDR = mkOption {
      type = types.str;
      default = "10.42.0.0/16";
      description = "Pod network CIDR";
    };
    
    serviceCIDR = mkOption {
      type = types.str;
      default = "10.43.0.0/16";
      description = "Service network CIDR";
    };
    
    clusterDNS = mkOption {
      type = types.str;
      default = "10.43.0.10";
      description = "Cluster DNS service IP";
    };
    
    storageBackend = mkOption {
      type = types.enum [ "etcd" "sqlite" "postgres" "mysql" ];
      default = "etcd";
      description = "K3s datastore backend";
    };
    
    tokenFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to file containing the shared secret token (managed by agenix)";
    };
    
    nodeIP = mkOption {
      type = types.str;
      description = "IP address for this node";
    };
    
    enableMetrics = mkOption {
      type = types.bool;
      default = true;
      description = "Enable metrics server";
    };
    
    enableTraefik = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Traefik ingress controller";
    };
    
    enableServiceLB = mkOption {
      type = types.bool;
      default = false;
      description = "Enable K3s service load balancer";
    };
  };
  
  config = mkIf cfg.enable {
    # Base system packages needed for K3s
    environment.systemPackages = with pkgs; [
      kubectl
      k9s
      helm
      nfs-utils
      openiscsi
      util-linux
      curl
      python3
      python3Packages.kubernetes
      lsof
      strace
      tcpdump
      iperf3
      dig
      nmap
    ];
    
    # Kernel modules for storage
    boot.kernelModules = [
      "overlay"
      "br_netfilter"
    ];
    
    # Enable required filesystems
    boot.supportedFilesystems = [ "nfs" "nfs4" ];
    
    # Network configuration
    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = mkDefault 1;
      "net.ipv6.conf.all.forwarding" = mkDefault 1;
      "net.bridge.bridge-nf-call-iptables" = mkDefault 1;
      "net.bridge.bridge-nf-call-ip6tables" = mkDefault 1;
      # inotify settings are already set by NixOS defaults, no need to duplicate
    };
    
    # Firewall configuration
    networking.firewall = {
      allowedTCPPorts = [
        6443 10250 2379 2380
        80 443 3000 53 3128
        25 465 587 143 993 4190
        12525 10465 10587 10143 10993 11334 14190
        7946
      ];
      allowedUDPPorts = [
        8472 51820 51821 53 5060 7946
      ];
      trustedInterfaces = [ "cni0" "flannel.1" ];
    };

    # Storage services
    services.rpcbind.enable = true;
    services.openiscsi = mkIf (cfg.enable) {
      enable = true;
      name = "${config.networking.hostName}-initiatorhost";
    };
    
    # Ensure kubelet can find iSCSI binaries
    systemd.tmpfiles.rules = [
      "L+ /sbin/iscsiadm - - - - ${pkgs.openiscsi}/bin/iscsiadm"
      "L+ /usr/sbin/iscsiadm - - - - ${pkgs.openiscsi}/bin/iscsiadm"
      "L+ /sbin/iscsid - - - - ${pkgs.openiscsi}/bin/iscsid"
      "L+ /usr/sbin/iscsid - - - - ${pkgs.openiscsi}/bin/iscsid"
      "L+ /bin/iscsiadm - - - - ${pkgs.openiscsi}/bin/iscsiadm"
      "L+ /usr/bin/iscsiadm - - - - ${pkgs.openiscsi}/bin/iscsiadm"
      "L+ /bin/iscsid - - - - ${pkgs.openiscsi}/bin/iscsid"
      "L+ /usr/bin/iscsid - - - - ${pkgs.openiscsi}/bin/iscsid"
    ];
    
    # Ensure kubelet has open-iscsi in PATH
    systemd.services.k3s.path = [ pkgs.openiscsi pkgs.util-linux pkgs.e2fsprogs ];
    systemd.services.k3s-agent.path = [ pkgs.openiscsi pkgs.util-linux pkgs.e2fsprogs ];

    # System limits for K3s
    systemd.services.k3s.serviceConfig = {
      LimitNOFILE = 1048576;
      LimitNPROC = "infinity";
      LimitCORE = "infinity";
      TasksMax = "infinity";
    };
    
    # Ensure time synchronization
    services.chrony.enable = true;
    
    # DNS configuration
    services.resolved = {
      enable = true;
      dnssec = "false";
      extraConfig = ''
        DNSStubListener=no
      '';
    };
  };
}
