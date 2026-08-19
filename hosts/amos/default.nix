{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ../../system/hardware/bluetooth.nix
    ../../home/profiles/laptop/packages.nix
    ../../home/packages/wayland/niri
  ];

  nixpkgs.config.allowUnfree = true;

  homelab.users.desktopUser.enable = true;

  # ── Kernel ─────────────────────────────────────────────────────────────
  boot = {
    kernelModules = ["kvm-intel"];

    kernelParams = [
      "intel_pstate=active"
      "intel_iommu=on"
      "iommu=pt"
      "preempt=voluntary"
      "nowatchdog"
      "psi=1"

      # Security hardening
      "randomize_kstack_offset=on"
      "vsyscall=none"
      "slab_nomerge"
      "module.sig_enforce=1"
      "lockdown=confidentiality"
      "page_poison=1"
      "page_alloc.shuffle=1"
      "sysrq_always_enabled=0"
      "rootflags=noatime"
      "lsm=landlock,lockdown,yama,integrity,apparmor,bpf,tomoyo,selinux"
      "fbcon=nodefer"
      "init_on_alloc=1"
      "init_on_free=1"
    ];

    kernel.sysctl = {
      "vm.swappiness" = 10;
      "vm.vfs_cache_pressure" = 50;
      "vm.dirty_ratio" = 10;
      "vm.dirty_background_ratio" = 5;
      "kernel.nmi_watchdog" = 0;
      "kernel.sysrq" = 0;
      "kernel.kptr_restrict" = 2;
      "kernel.ftrace_enabled" = false;
      "kernel.dmesg_restrict" = 1;
      "fs.protected_fifos" = 2;
      "fs.protected_regular" = 2;
      "fs.suid_dumpable" = 0;
      "net.core.bpf_jit_harden" = 2;
      "kernel.core_uses_pid" = 1;
      "kernel.randomize_va_space" = 2;
      "vm.mmap_rnd_bits" = 32;
      "vm.mmap_rnd_compat_bits" = 16;
      "dev.tty.ldisc_autoload" = 0;
      "vm.unprivileged_userfaultfd" = 0;
    };

    blacklistedKernelModules = [
      # Obscure network protocols
      "af_802154" "appletalk" "atm" "ax25" "decnet" "econet"
      "ipx" "n-hdlc" "netrom" "p8022" "p8023" "psnap"
      "rds" "rose" "tipc" "x25"

      # Rare/unaudited filesystems
      "adfs" "affs" "befs" "bfs" "cramfs" "efs" "erofs" "exofs"
      "f2fs" "freevxfs" "gfs2" "hfs" "hfsplus" "hpfs" "jffs2"
      "jfs" "ksmbd" "minix" "nilfs2" "omfs" "qnx4" "qnx6"
      "squashfs" "sysv" "udf" "vivid"

      # DMA attack vectors — disable unless you use these
      "firewire-core"
      # thunderbolt intentionally NOT blacklisted (USB-C docks)
    ];

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking.hostName = "amos";

  # ── Locale / timezone ──────────────────────────────────────────────────
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

  # ── Keyboard / display ─────────────────────────────────────────────────
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
    displayManager.startx.enable = lib.mkForce false;
    autorun = false;
  };

  # ── Security ───────────────────────────────────────────────────────────
  security.tpm2.enable = true;

  security = {
    forcePageTableIsolation = true;
    protectKernelImage = true;
    apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
    };
    pam.services.swaylock = {};
  };

  # ── Hardware ───────────────────────────────────────────────────────────
  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
  };

  # ── Services ───────────────────────────────────────────────────────────
  services = {
    fstrim.enable = true;

    # Laptop-specific: better thermal/fan control
    thermald.enable = true;

    printing = {
      enable = true;
      drivers = [pkgs.brlaser];
    };

    avahi = {
      enable = true;
      nssmdns4 = true;
    };
  };

  # zram swap — better than a swap partition on a laptop
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
  };

  # ── System packages ────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    cryptsetup
    lvm2
    powertop
  ];

  # ── Session variables ──────────────────────────────────────────────────
  environment.sessionVariables = {
    BROWSER = "brave";
  };

  # ── Systemd ────────────────────────────────────────────────────────────
  systemd.coredump.settings.Coredump = {
    Storage = "none";
    ProcessSizeMax = 0;
  };

  # ── Nix-index ─────────────────────────────────────────────────────────
  programs = {
    nix-index = {
      enable = true;
      enableFishIntegration = true;
    };
    nix-index-database.comma.enable = true;
  };
}
