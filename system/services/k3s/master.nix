# K3s master node configuration module
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.homelab.k3s-master;
in
{
  imports = [ ./common.nix ];

  options.homelab.k3s-master = {
    enable = mkEnableOption "K3s master node";
    
    clusterInit = mkOption {
      type = types.bool;
      default = false;
      description = "Whether this is the first master node (cluster init)";
    };
    
    serverAddr = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Address of the first master node (for subsequent masters)";
    };
    
    tlsSan = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Additional hostnames or IPs for the API server certificate";
    };
    
    disableComponents = mkOption {
      type = types.listOf types.str;
      default = [ "traefik" "servicelb" ];
      description = "K3s components to disable";
    };
    
    datastoreEndpoint = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "External datastore endpoint (for HA with external DB)";
    };
  };
  
  config = mkIf cfg.enable {
    homelab.k3s-cluster.enable = true;
    
    # K3s master service configuration
    services.k3s =
      ({
        enable = true;
        role = "server";

        extraFlags = lib.concatStringsSep " " (
          [
            "--debug"
            "--node-ip=${config.homelab.k3s-cluster.nodeIP}"
            "--cluster-cidr=${config.homelab.k3s-cluster.clusterCIDR}"
            "--service-cidr=${config.homelab.k3s-cluster.serviceCIDR}"
            "--cluster-dns=${config.homelab.k3s-cluster.clusterDNS}"
            "--cluster-domain=${config.homelab.k3s-cluster.clusterDomain}"
            "--flannel-backend=vxlan"
            "--kube-controller-manager-arg=bind-address=0.0.0.0"
            "--kube-proxy-arg=metrics-bind-address=0.0.0.0"
            "--kube-scheduler-arg=bind-address=0.0.0.0"
            "--etcd-expose-metrics=true"
            "--node-taint=node-role.kubernetes.io/master=true:NoSchedule"
          ]
          ++ (map (component: "--disable=${component}") cfg.disableComponents)
          ++ (map (san: "--tls-san=${san}") cfg.tlsSan)
          ++ (optional cfg.clusterInit "--cluster-init")
          ++ (optional (cfg.serverAddr != null) "--server=${cfg.serverAddr}")
          ++ (optional (cfg.datastoreEndpoint != null) "--datastore-endpoint=${cfg.datastoreEndpoint}")
        );
      }
      // (optionalAttrs (config ? age && config.age ? secrets && config.age.secrets ? k3s-token) {
        tokenFile = config.age.secrets.k3s-token.path;
      }));
    
    # Create kubeconfig symlink for easier access
    system.activationScripts.k3s-kubeconfig = ''
      mkdir -p /root/.kube
      if [ -f /etc/rancher/k3s/k3s.yaml ]; then
        ln -sf /etc/rancher/k3s/k3s.yaml /root/.kube/config
      fi
    '';
    
    # Additional firewall rules for master nodes
    networking.firewall.allowedTCPPorts = [
      6443 2379 2380 10257 10259
    ];
    
    # Backup script for etcd
    systemd.services.etcd-backup = {
      description = "Backup K3s etcd database";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeScript "etcd-backup.sh" ''
          #!/bin/sh
          mkdir -p /var/backups/k3s
          k3s etcd-snapshot save --name="etcd-snapshot-$(date +%Y%m%d-%H%M%S)"
          find /var/backups/k3s -name "etcd-snapshot-*.db" -mtime +7 -delete
        '';
      };
    };
    
    systemd.timers.etcd-backup = {
      description = "Timer for etcd backup";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
    };
  };
}
