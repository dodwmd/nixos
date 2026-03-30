{
  config,
  lib,
  pkgs,
  self,
  ...
}: {
  imports = [./hardware-configuration.nix];

  age = {
    identityPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
    ];

    secrets = {
      discordo = {
        file = "${self}/secrets/discordo.age";
        owner = "linuxmobile";
        group = "users";
        mode = "0400";
      };
      github = {
        file = "${self}/secrets/github.age";
        owner = "linuxmobile";
        group = "users";
        mode = "0400";
      };
      openrouter = {
        file = "${self}/secrets/openrouter.age";
        owner = "linuxmobile";
        group = "users";
        mode = "0400";
      };
      twt = {
        file = "${self}/secrets/twt.age";
        owner = "linuxmobile";
        group = "users";
        mode = "0400";
      };
      context7 = {
        file = "${self}/secrets/context7.age";
        owner = "linuxmobile";
        group = "users";
        mode = "0400";
      };
      exa = {
        file = "${self}/secrets/exa.age";
        owner = "linuxmobile";
        group = "users";
        mode = "0400";
      };
      obs = {
        file = "${self}/secrets/obs.age";
        owner = "linuxmobile";
        group = "users";
        mode = "0400";
      };
    };
  };

  nixpkgs.overlays = [self.inputs.nix-cachyos-kernel.overlays.pinned];

  boot = {
    # load modules on boot
    kernelPackages = lib.mkForce pkgs.cachyosKernels.linuxPackages-cachyos-latest;
    extraModulePackages = with config.boot.kernelPackages; [v4l2loopback];
    kernelModules = ["i2c-dev" "v4l2loopback"];
    kernelParams = [
      "amd_pstate=active" # Enable AMD P-state CPU scaling driver
      "amd_iommu=force" # Force AMD IOMMU for better DMA protection
      "ideapad_laptop" # Allow Lenovo IdeaPad v4 Dynamic Thermal Control
      # "nvme_core.default_ps_max_latency_us=0" # Set NVMe power state latency to minimum (max performance)
      "preempt=voluntary"
      "nowatchdog"
      "psi=1"

      "rootflags=noatime" # Mount root filesystem with noatime (improves performance, disables file access time updates)
      "fbcon=nodefer" # Do not defer kernel messages to framebuffer console (shows messages immediately)
    ];
    kernel.sysctl = {
      "vm.swappiness" = 10; # Lower tendency to swap (default is 60)
      "vm.vfs_cache_pressure" = 50; # Reduce cache pressure (default is 100)
      "vm.dirty_ratio" = 10; # Lower max % of dirty memory before writeback (default is 20)
      "vm.dirty_background_ratio" = 5; # Lower % of dirty memory to start background writeback (default is 10)

      "kernel.nmi_watchdog" = 0; # Disable NMI watchdog (slightly improves performance)

      # Network performance optimizations
      "net.core.netdev_budget" = 600;
      "net.core.netdev_max_backlog" = 16384;
      "net.ipv4.tcp_no_metrics_save" = 1;
      "net.ipv4.tcp_moderate_rcvbuf" = 1;
    };

    blacklistedKernelModules = [
      # Obscure network protocols.
      "af_802154" # IEEE 802.15.4
      "appletalk" # Appletalk
      "atm" # ATM
      "ax25" # Amatuer X.25
      "decnet" # DECnet
      "econet" # Econet
      "ipx" # Internetwork Packet Exchange
      "n-hdlc" # High-level Data Link Control
      "netrom" # NetRom
      "p8022" # IEEE 802.3
      "p8023" # Novell raw IEEE 802.3
      "psnap" # SubnetworkAccess Protocol
      "rds" # Reliable Datagram Sockets
      "rose" # ROSE
      "tipc" # Transparent Inter-Process Communication
      "x25" # X.25

      # Old or rare or insufficiently audited filesystems.
      "adfs" # Active Directory Federation Services
      "affs" # Amiga Fast File System
      "befs" # "Be File System"
      "bfs" # BFS, used by SCO UnixWare OS for the /stand slice
      "cramfs" # compressed ROM/RAM file system
      "efs" # Extent File System
      "erofs" # Enhanced Read-Only File System
      "exofs" # EXtended Object File System
      "f2fs" # Flash-Friendly File System
      "freevxfs" # Veritas filesystem driver
      "gfs2" # Global File System 2
      "hfs" # Hierarchical File System (Macintosh)
      "hfsplus" # Same as above, but with extended attributes.
      "hpfs" # High Performance File System (used by OS/2)
      "jffs2" # Journalling Flash File System (v2)
      "jfs" # Journaled File System - only useful for VMWare sessions
      "ksmbd" # SMB3 Kernel Server
      "minix" # minix fs - used by the minix OS
      "nilfs2" # New Implementation of a Log-structured File System
      "omfs" # Optimized MPEG Filesystem
      "qnx4" # Extent-based file system used by the QNX4 OS.
      "qnx6" # Extent-based file system used by the QNX6 OS.
      "squashfs" # compressed read-only file system (used by live CDs)
      "sysv" # implements all of Xenix FS, SystemV/386 FS and Coherent FS.
      "udf" # https://docs.kernel.org/5.15/filesystems/udf.html
      "vivid" # Virtual Video Test Driver (unnecessary)

      # Disable Thunderbolt and FireWire to prevent DMA attacks
      "firewire-core"
      "thunderbolt"
    ];

    extraModprobeConfig = ''
      options v4l2loopback exclusive_caps=1 card_label="OBS Virtual Output"
      options rtw88_core disable_lps_deep=y
      options rtw88_pci disable_aspm=y
    '';
  };

  networking.hostName = "aesthetic";

  security.tpm2.enable = true;

  # Additional security hardening for HSI compliance
  security = {
    apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
    };
  };

  services = {
    # for SSD/NVME
    fstrim.enable = true;
  };

  hardware = {
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = true;
    i2c.enable = true;
  };

  # Additional systemd hardening
  systemd = {
    coredump.extraConfig = ''
      Storage=none
      ProcessSizeMax=0
    '';
  };

  environment.systemPackages = [pkgs.cryptsetup];
}
