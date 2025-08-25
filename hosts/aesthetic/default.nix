{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [./hardware-configuration.nix];

  boot = {
    # load modules on boot
    kernelModules = ["amdgpu" "v4l2loopback" "i2c-dev" "efivarfs"];
    kernelPackages = lib.mkForce pkgs.linuxPackages_cachyos;
    extraModulePackages = with config.boot.kernelPackages; [v4l2loopback];
    kernelParams = [
      "amd_pstate=active" # Enable AMD P-state CPU scaling driver
      "amd_iommu" # Enable AMD IOMMU (for device passthrough/virtualization)
      "mitigations=off" # Disable CPU security mitigations (improves performance, reduces security)
      "ideapad_laptop.allow_v4_dytc=Y" # Allow Lenovo IdeaPad v4 Dynamic Thermal Control
      "nvme_core.default_ps_max_latency_us=0" # Set NVMe power state latency to minimum (max performance)

      "randomize_kstack_offset=on" # Randomize kernel stack offset on each syscall (mitigates some exploits)
      "vsyscall=none" # Disable vsyscall (removes legacy syscall interface, improves security)
      "slab_nomerge" # Disable merging of similar SLAB caches (hardens against some heap attacks)
      "module.sig_enforce=1" # Only allow loading kernel modules with valid signatures (prevents unsigned modules)
      "lockdown=confidentiality" # Enable kernel lockdown in confidentiality mode (restricts kernel access even for root)
      "page_poison=1" # Fill freed memory pages with poison value (helps detect use-after-free bugs)
      "page_alloc.shuffle=1" # Randomize page allocator order (mitigates some memory corruption attacks)
      "sysrq_always_enabled=0" # Disable magic SysRq key entirely (prevents low-level system commands)
      "rootflags=noatime" # Mount root filesystem with noatime (improves performance, disables file access time updates)
      "lsm=landlock,lockdown,yama,integrity,apparmor,bpf,tomoyo,selinux" # Enable and order Linux Security Modules (stacked LSMs for security)
      "fbcon=nodefer" # Do not defer kernel messages to framebuffer console (shows messages immediately)
    ];
    kernel.sysctl = {
      "vm.swappiness" = 10; # Lower tendency to swap (default is 60)
      "vm.vfs_cache_pressure" = 50; # Reduce cache pressure (default is 100)
      "vm.dirty_ratio" = 10; # Lower max % of dirty memory before writeback (default is 20)
      "vm.dirty_background_ratio" = 5; # Lower % of dirty memory to start background writeback (default is 10)

      "kernel.nmi_watchdog" = 0; # Disable NMI watchdog (slightly improves performance)

      "kernel.sysrq" = 0; # Disable magic SysRq key (prevents low-level system commands)
      "kernel.kptr_restrict" = 2; # Hide kernel pointers from unprivileged users (security)
      "kernel.ftrace_enabled" = false; # Disable kernel function tracing (security, disables debugging)
      "kernel.dmesg_restrict" = 1; # Restrict access to dmesg for non-root users (security)
      "fs.protected_fifos" = 2; # Fully restrict writing to FIFOs not owned by the writer (security)
      "fs.protected_regular" = 2; # Fully restrict writing to regular files not owned by the writer (security)
      "fs.suid_dumpable" = 0; # Disable core dumps for setuid programs (security)
      "kernel.perf_event_paranoid" = 3; # Restrict perf events to root only (security)
      "kernel.unprivileged_bpf_disabled" = 1; # Disable unprivileged BPF usage (security)
    };

    blacklistedKernelModules = [
      # Obscure network protocols.
      "af_802154" # IEEE 802.15.4
      "appletalk" # Appletalk
      "atm" # ATM
      "ax25" # Amatuer X.25
      "can" # Controller Area Network
      "dccp" # Datagram Congestion Control Protocol
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
      "sctp" # Stream Control Transmission Protocol
      "tipc" # Transparent Inter-Process Communication
      "x25" # X.25

      # Old or rare or insufficiently audited filesystems.
      "adfs" # Active Directory Federation Services
      "affs" # Amiga Fast File System
      "befs" # "Be File System"
      "bfs" # BFS, used by SCO UnixWare OS for the /stand slice
      "cifs" # Common Internet File System
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
      "nfs" # Network File System
      "nfsv3" # Network File System (v3)
      "nfsv4" # Network File System (v4)
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
    '';
  };

  networking.hostName = "aesthetic";

  security.tpm2.enable = true;

  services = {
    # for SSD/NVME
    fstrim.enable = true;
    scx.enable = true;
    scx.scheduler = "scx_rusty";
  };
}
