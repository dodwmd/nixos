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

    # Declare CA keypair secrets - deployed to /etc/k3s/ca/ by agenix,
    # then seeded into the k3s data dir before k3s starts so certs
    # survive rebuilds and never go out of sync with the cluster token.
    age.secrets = let
      caSecret = path: mode: {
        file = "${self}/secrets/k3s-ca/${path}";
        owner = "root";
        group = "root";
        inherit mode;
      };
    in {
      "k3s-server-ca-crt"         = caSecret "server-ca.crt.age"           "0644";
      "k3s-server-ca-key"         = caSecret "server-ca.key.age"           "0600";
      "k3s-client-ca-crt"         = caSecret "client-ca.crt.age"           "0644";
      "k3s-client-ca-key"         = caSecret "client-ca.key.age"           "0600";
      "k3s-request-header-ca-crt" = caSecret "request-header-ca.crt.age"   "0644";
      "k3s-request-header-ca-key" = caSecret "request-header-ca.key.age"   "0600";
      "k3s-etcd-peer-ca-crt"      = caSecret "etcd-peer-ca.crt.age"        "0644";
      "k3s-etcd-peer-ca-key"      = caSecret "etcd-peer-ca.key.age"        "0600";
      "k3s-etcd-server-ca-crt"    = caSecret "etcd-server-ca.crt.age"      "0644";
      "k3s-etcd-server-ca-key"    = caSecret "etcd-server-ca.key.age"      "0600";
    };

    # Ensure the k3s TLS directory exists before agenix tries to write there
    systemd.tmpfiles.rules = [
      "d /var/lib/rancher/k3s/server/tls      0700 root root -"
      "d /var/lib/rancher/k3s/server/tls/etcd 0700 root root -"
    ];

    # Seed CA keypairs from agenix-managed secrets into the k3s data directory
    # before k3s starts. This ensures the cluster CA is stable across rebuilds.
    systemd.services.k3s-seed-ca-certs = {
      description = "Seed k3s CA certificates from agenix secrets";
      before = [ "k3s.service" ];
      wantedBy = [ "k3s.service" ];
      after = [ "agenix.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script =
        let
          cfg' = config.age.secrets;
          tls = "/var/lib/rancher/k3s/server/tls";
          install = src: dest: mode:
            "install -m ${mode} ${cfg'.${src}.path} ${tls}/${dest}";
        in ''
          mkdir -p ${tls}/etcd
          ${install "k3s-server-ca-crt"         "server-ca.crt"              "0644"}
          ${install "k3s-server-ca-key"         "server-ca.key"              "0600"}
          ${install "k3s-client-ca-crt"         "client-ca.crt"              "0644"}
          ${install "k3s-client-ca-key"         "client-ca.key"              "0600"}
          ${install "k3s-request-header-ca-crt" "request-header-ca.crt"      "0644"}
          ${install "k3s-request-header-ca-key" "request-header-ca.key"      "0600"}
          ${install "k3s-etcd-peer-ca-crt"      "etcd/peer-ca.crt"           "0644"}
          ${install "k3s-etcd-peer-ca-key"      "etcd/peer-ca.key"           "0600"}
          ${install "k3s-etcd-server-ca-crt"    "etcd/server-ca.crt"         "0644"}
          ${install "k3s-etcd-server-ca-key"    "etcd/server-ca.key"         "0600"}
        '';
    };

    # K3s master service configuration
    services.k3s =
      ({
        enable = true;
        role = "server";

        extraFlags = lib.concatStringsSep " " (
          [
            "--debug"
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
          ++ (optional (config.homelab.k3s-cluster.nodeIP != null) "--node-ip=${config.homelab.k3s-cluster.nodeIP}")
          ++ (map (component: "--disable=${component}") cfg.disableComponents)
          ++ (map (san: "--tls-san=${san}") cfg.tlsSan)
          ++ (optional cfg.clusterInit "--cluster-init")
          ++ (optional (cfg.serverAddr != null) "--server=${cfg.serverAddr}")
          ++ (optional (cfg.datastoreEndpoint != null) "--datastore-endpoint=${cfg.datastoreEndpoint}")
        );
      }
      // {
        tokenFile = "/etc/k3s/token";
      });
    
    # Ensure CoreDNS runs 2 replicas for HA — one per worker node.
    # k3s's addon watcher picks up files in the manifests directory and applies them.
    system.activationScripts.k3s-coredns-ha = lib.stringAfter [ "var" ] ''
      mkdir -p /var/lib/rancher/k3s/server/manifests
      cat > /var/lib/rancher/k3s/server/manifests/coredns-ha.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: coredns
  namespace: kube-system
spec:
  replicas: 2
EOF
    '';

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
