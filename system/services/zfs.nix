{ config, lib, pkgs, ... }:

with lib;

{
  options.homelab.zfs = {
    enable = mkEnableOption "Enable ZFS configuration";
    
    arcMaxGB = mkOption {
      type = types.int;
      default = 4;
      description = "Maximum ZFS ARC size in GB";
    };
    
    pools = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Additional ZFS pools to import";
    };
    
    autoScrub = mkOption {
      type = types.bool;
      default = true;
      description = "Enable automatic ZFS scrubbing";
    };
    
    scrubInterval = mkOption {
      type = types.str;
      default = "monthly";
      description = "ZFS scrub interval";
    };
  };

  config = mkIf config.homelab.zfs.enable {
    # Boot configuration
    boot.supportedFilesystems = [ "zfs" ];
    boot.zfs.forceImportRoot = false;
    boot.zfs.extraPools = config.homelab.zfs.pools;
    
    # Limit ZFS ARC to prevent memory pressure
    boot.kernelParams = [ 
      "zfs.zfs_arc_max=${toString (config.homelab.zfs.arcMaxGB * 1024 * 1024 * 1024)}"
    ];

    # ZFS services configuration
    services.zfs = {
      autoScrub = {
        enable = config.homelab.zfs.autoScrub;
        interval = config.homelab.zfs.scrubInterval;
      };
      trim = {
        enable = false; # HDDs don't need TRIM
      };
    };

    # Ensure ZFS datasets are mounted at boot
    systemd.services."wait-for-zfs-mounts" = {
      description = "Wait for ZFS datasets to mount";
      after = [ "zfs-mount.service" ];
      before = [ "multi-user.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.coreutils}/bin/sleep 2";
      };
    };

    # Install ZFS tools
    environment.systemPackages = with pkgs; [
      zfs
    ];
  };
}
