{ config, lib, pkgs, ... }:

with lib;

{
  options.homelab.netdata = {
    enable = mkEnableOption "Enable Netdata system monitoring";
    
    port = mkOption {
      type = types.int;
      default = 19999;
      description = "Netdata web UI port";
    };
    
    bindAddress = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Bind address (use 127.0.0.1 if behind proxy)";
    };
    
    historySeconds = mkOption {
      type = types.int;
      default = 86400;
      description = "History retention in seconds (default: 24 hours)";
    };
    
    updateEvery = mkOption {
      type = types.int;
      default = 1;
      description = "Update interval in seconds";
    };
    
    pageCacheSizeMB = mkOption {
      type = types.int;
      default = 32;
      description = "Page cache size in MB";
    };
    
    dbengineSpaceMB = mkOption {
      type = types.int;
      default = 2048;
      description = "DBEngine disk space in MB for long-term storage";
    };
    
    enableZFSMonitoring = mkOption {
      type = types.bool;
      default = false;
      description = "Enable ZFS monitoring capabilities";
    };
  };

  config = mkIf config.homelab.netdata.enable {
    services.netdata = {
      enable = true;
      package = pkgs.netdata.override {
        withCloudUi = true;
      };
      
      config = {
        global = {
          "bind to" = config.homelab.netdata.bindAddress;
          "default port" = toString config.homelab.netdata.port;
          "history" = toString config.homelab.netdata.historySeconds;
          "update every" = toString config.homelab.netdata.updateEvery;
          "memory mode" = "dbengine";
          "page cache size" = toString config.homelab.netdata.pageCacheSizeMB;
          "dbengine multihost disk space" = toString config.homelab.netdata.dbengineSpaceMB;
        };
        
        web = {
          "web files owner" = "root";
          "web files group" = "root";
          "mode" = "static-threaded";
        };
      };
      
      python = {
        enable = true;
        extraPackages = ps: [ 
          ps.psutil 
          ps.pyyaml
        ];
      };
    };

    # Ensure netdata can monitor ZFS if enabled
    systemd.services.netdata = mkIf config.homelab.netdata.enableZFSMonitoring {
      path = [ pkgs.zfs ];
      serviceConfig = {
        CapabilityBoundingSet = [
          "CAP_DAC_OVERRIDE"
          "CAP_DAC_READ_SEARCH"
          "CAP_FOWNER"
          "CAP_SETPCAP"
          "CAP_SYS_ADMIN"
          "CAP_SYS_PTRACE"
          "CAP_SYS_RESOURCE"
          "CAP_NET_RAW"
        ];
      };
    };
  };
}
