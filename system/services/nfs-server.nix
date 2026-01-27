{ config, lib, pkgs, ... }:

with lib;

{
  options.homelab.nfs-server = {
    enable = mkEnableOption "Enable NFS server";
    
    exports = mkOption {
      type = types.lines;
      default = "";
      description = "NFS exports configuration";
    };
    
    lockdPort = mkOption {
      type = types.int;
      default = 4001;
      description = "NFS lockd port";
    };
    
    mountdPort = mkOption {
      type = types.int;
      default = 4002;
      description = "NFS mountd port";
    };
    
    statdPort = mkOption {
      type = types.int;
      default = 4000;
      description = "NFS statd port";
    };
    
    enableRmtcalls = mkOption {
      type = types.bool;
      default = true;
      description = "Enable rpcbind remote calls (needed for Kodi NFS broadcast discovery)";
    };
  };

  config = mkIf config.homelab.nfs-server.enable {
    # NFS server
    services.nfs.server = {
      enable = true;
      exports = config.homelab.nfs-server.exports;
      lockdPort = config.homelab.nfs-server.lockdPort;
      mountdPort = config.homelab.nfs-server.mountdPort;
      statdPort = config.homelab.nfs-server.statdPort;
    };

    # Enable UDP for NFSv3 (needed by Kodi/Shield clients)
    services.nfs.settings.nfsd.udp = true;

    # Override rpcbind to enable remote calls if requested
    nixpkgs.config.packageOverrides = mkIf config.homelab.nfs-server.enableRmtcalls (pkgs: {
      rpcbind = pkgs.rpcbind.overrideAttrs (oldAttrs: {
        configureFlags = (oldAttrs.configureFlags or []) ++ [ "--enable-rmtcalls" ];
      });
    });

    # Open firewall for NFS
    networking.firewall = {
      allowedTCPPorts = [ 
        111 
        2049 
        config.homelab.nfs-server.statdPort
        config.homelab.nfs-server.lockdPort
        config.homelab.nfs-server.mountdPort
      ];
      allowedUDPPorts = [ 
        111 
        2049 
        config.homelab.nfs-server.statdPort
        config.homelab.nfs-server.lockdPort
        config.homelab.nfs-server.mountdPort
      ];
    };

    # Install NFS utilities
    environment.systemPackages = with pkgs; [
      nfs-utils
    ];
  };
}
