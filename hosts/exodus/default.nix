{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../system/services/tdarr-node.nix
    ../../system/services/ollama.nix
    ../../home/profiles/desktop/packages.nix
    ../../home/packages/wayland/niri
  ];

  # Allow unfree packages (needed for NVIDIA drivers)
  nixpkgs.config.allowUnfree = true;

  # Enable desktop user
  homelab.users.desktopUser.enable = true;

  boot = {
    # load modules on boot
    kernelModules = ["kvm-intel" "v4l2loopback" "i2c-dev" "efivarfs"];
    kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
    extraModulePackages = with config.boot.kernelPackages; [v4l2loopback];
    kernelParams = [
      "intel_pstate=active" # Enable Intel P-state CPU scaling driver
      "intel_iommu=on" # Enable Intel IOMMU for better DMA protection
      "iommu=pt" # Use passthrough mode for better performance
      "mitigations=off" # Disable CPU security mitigations (improves performance, reduces security)
      "nvidia-drm.modeset=1" # Enable NVIDIA modesetting
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1" # Preserve VRAM for suspend/resume
      "preempt=voluntary"
      "nowatchdog"
      "psi=1"

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

      # Additional security hardening for HSI compliance (validated)
      "init_on_alloc=1" # Initialize allocated memory
      "init_on_free=1" # Initialize freed memory
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

      "kernel.sysrq" = 0; # Disable magic SysRq key (prevents low-level system commands)
      "kernel.kptr_restrict" = 2; # Hide kernel pointers from unprivileged users (security)
      "kernel.ftrace_enabled" = false; # Disable kernel function tracing (security, disables debugging)
      "kernel.dmesg_restrict" = 1; # Restrict access to dmesg for non-root users (security)
      "fs.protected_fifos" = 2; # Fully restrict writing to FIFOs not owned by the writer (security)
      "fs.protected_regular" = 2; # Fully restrict writing to regular files not owned by the writer (security)
      "fs.suid_dumpable" = 0; # Disable core dumps for setuid programs (security)
      "net.core.bpf_jit_harden" = 2; # Harden BPF JIT compiler for all users

      # Additional security hardening
      "kernel.core_uses_pid" = 1; # Append PID to core filenames
      "kernel.randomize_va_space" = 2; # Full ASLR
      "vm.mmap_rnd_bits" = 32; # Increase ASLR entropy for mmap
      "vm.mmap_rnd_compat_bits" = 16; # Increase ASLR entropy for compat mmap
      "dev.tty.ldisc_autoload" = 0; # Disable TTY line discipline autoloading
      "vm.unprivileged_userfaultfd" = 0; # Disable unprivileged userfaultfd
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
      # NVIDIA power management
      options nvidia NVreg_PreserveVideoMemoryAllocations=1
    '';

    # LUKS configuration from old exodus config
    initrd.luks.devices = {
      root = {
        name = "root";
        device = "/dev/disk/by-uuid/3282c8a5-72fc-4793-92be-d44599051f4e";
        preLVM = true;
        allowDiscards = true;
      };
    };

    # Boot loader configuration - override systemd-boot from core/boot.nix
    loader = {
      systemd-boot.enable = lib.mkForce false; # Disable systemd-boot
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
      };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
    };
  };

  networking.hostName = "exodus";

  # Override keyboard and locale for Australia
  console.keyMap = lib.mkForce "us";
  
  time.timeZone = lib.mkForce "Australia/Brisbane";
  
  i18n.extraLocaleSettings = lib.mkForce {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };
  
  # X11 and Wayland keyboard layout
  # Enable xserver for proper xwayland wrapping with NVIDIA, but don't start a display manager
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
    # Don't start any display manager - we use niri/Wayland only
    displayManager.startx.enable = lib.mkForce false;
    autorun = false; # Prevent X server from starting automatically
  };

  # User configuration is now handled by homelab.users.desktopUser

  security.tpm2.enable = true;

  # Additional security hardening for HSI compliance
  security = {
    forcePageTableIsolation = true;
    protectKernelImage = true;
    apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
    };
    # Enable PAM authentication for swaylock
    pam.services.swaylock = {};
  };

  services = {
    # for SSD/NVME
    fstrim.enable = true;

    # QEMU guest services
    spice-vdagentd.enable = true;
    qemuGuest.enable = true;

    # NFS client support
    rpcbind.enable = true;
  };

  # NFS filesystem support
  boot.supportedFilesystems = ["nfs" "ntfs"];

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;

    # NVIDIA configuration
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = false; # Use proprietary driver for RTX 4080
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    graphics = {
      enable = true;
      enable32Bit = true; # For Steam and 32-bit games
    };
  };

  # Enable Steam with performance optimizations
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
    # Performance optimizations
    extraPackages = with pkgs; [
      gamescope
      mangohud
    ];
  };
  
  # XWayland is provided by xwayland-satellite service (see home/services/wayland/xwayland-satellite.nix)

  # Enable NVIDIA driver
  services.xserver.videoDrivers = ["nvidia"];
  
  # Override xwayland to disable glamor (EGL) to prevent crashes
  nixpkgs.overlays = [(final: prev: {
    xwayland = prev.xwayland.overrideAttrs (old: {
      mesonFlags = (old.mesonFlags or []) ++ ["-Dglamor=false"];
    });
  })];


  # NVIDIA environment variables for Wayland
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    
    # Unset EGL_PLATFORM to prevent Xwayland from trying to use EGL
    # which causes crashes when EGL providers are not available
    EGL_PLATFORM = lib.mkForce null;
    
    # Gaming performance optimizations
    __GL_SHADER_DISK_CACHE = "1";
    __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
    __GL_THREADED_OPTIMIZATIONS = "1";
    PROTON_ENABLE_NVAPI = "1";
    DXVK_HUD = "fps,memory,gpuload";
    MANGOHUD = "1";
  };

  # Additional systemd hardening
  systemd = {
    coredump.extraConfig = ''
      Storage=none
      ProcessSizeMax=0
    '';
  };

  # udev rules from old exodus config
  services.udev.extraRules = ''
    # Ignore the MSI Optix fake USB CD-ROM device
    SUBSYSTEM=="block", ENV{ID_VENDOR_ID}=="1462", ENV{ID_MODEL_ID}=="3fa4", OPTIONS+="nowatch"
    SUBSYSTEM=="block", ENV{ID_VENDOR_ID}=="1462", ENV{ID_MODEL_ID}=="3fa4", ENV{UDISKS_IGNORE}="1"
    
    # Ignore non-existent SATA devices to prevent boot delays
    SUBSYSTEM=="block", KERNEL=="sd[a-z]", ENV{ID_PATH}=="", OPTIONS+="nowatch"
    SUBSYSTEM=="block", KERNEL=="sd[a-z]", ENV{ID_PATH}=="", ENV{UDISKS_IGNORE}="1"
  '';

  environment.systemPackages = with pkgs; [
    cryptsetup
    lvm2
    nfs-utils
    brave
    wine 
    winetricks
  ];

  # nix-index-database configuration
  programs = {
    nix-index = {
      enable = true;
      enableFishIntegration = true;
    };
    nix-index-database.comma.enable = true;
  };
}
