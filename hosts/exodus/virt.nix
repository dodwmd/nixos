# Windows Gaming VM with single GPU passthrough (RTX 4080)
#
# Workflow (single GPU — Linux and VM share one card):
#   1. Save work and log out to greeter (or stay at a TTY)
#   2. Start VM via virt-manager or: virsh start windows-gaming
#   3. Hook stops greetd, hands GPU to Windows
#   4. Use the VM (direct monitor output or Looking Glass on a second display)
#   5. Shut down VM → hook reclaims GPU → greetd restarts
#
# First-time setup:
#   Find GPU PCI slots: lspci | grep -i nvidia
#   Then update gpuPciSlot / gpuAudioPciSlot below.
{
  config,
  lib,
  pkgs,
  ...
}: let
  # RTX 4080 (AD103) PCI slots — confirmed via lspci
  # 01:00.0 NVIDIA Corporation AD103 [GeForce RTX 4080] [10de:2704]
  # 01:00.1 NVIDIA Corporation AD103 High Definition Audio [10de:22bb]
  gpuPciSlot = "0000:01:00.0";
  gpuAudioPciSlot = "0000:01:00.1";

  # PCI slot → libvirt node-device name (colons and dots → underscores)
  toNodeDev = slot: "pci_" + (lib.replaceStrings [":" "."] ["_" "_"] slot);

  hookScript = pkgs.writeShellScript "qemu-vfio-hook" ''
    export PATH="${lib.makeBinPath [pkgs.libvirt pkgs.kmod config.systemd.package]}:$PATH"

    DOMAIN="$1"
    OPERATION="$2"
    SUB_OPERATION="$3"

    if [ "$DOMAIN" != "windows-gaming" ]; then
      exit 0
    fi

    # State file tracks whether we actually detached the GPU so we know to reattach it.
    STATE_FILE="/run/libvirt/vfio-''${DOMAIN}-active"

    case "$OPERATION/$SUB_OPERATION" in
      prepare/begin)
        # Only detach the GPU if it is actually passed through in the VM's XML.
        # During Windows installation the VM uses virtual QXL graphics with no PCI
        # hostdev, so bus='0x01' won't appear — we skip the detach and the screen
        # stays on. Once you add the GPU hostdev to the VM config the check passes
        # and passthrough works normally.
        #
        # Read the XML file directly — calling virsh here would deadlock because
        # libvirtd is blocked waiting for this hook to return.
        DOMAIN_XML="/var/lib/libvirt/qemu/''${DOMAIN}.xml"
        if ! grep -q "bus='0x01'" "$DOMAIN_XML" 2>/dev/null; then
          echo "[vfio-hook] GPU not in $DOMAIN device list — skipping passthrough"
          exit 0
        fi
        echo "[vfio-hook] Handing GPU to $DOMAIN"
        systemctl stop greetd.service
        sleep 3
        virsh nodedev-detach ${toNodeDev gpuPciSlot}
        virsh nodedev-detach ${toNodeDev gpuAudioPciSlot}
        touch "$STATE_FILE"
        ;;
      release/end)
        if [ ! -f "$STATE_FILE" ]; then
          echo "[vfio-hook] No active GPU passthrough for $DOMAIN — nothing to reattach"
          exit 0
        fi
        echo "[vfio-hook] Reclaiming GPU from $DOMAIN"
        rm -f "$STATE_FILE"
        virsh nodedev-reattach ${toNodeDev gpuPciSlot}
        virsh nodedev-reattach ${toNodeDev gpuAudioPciSlot}
        sleep 3
        systemctl start greetd.service
        ;;
    esac
  '';
in {
  # VFIO modules loaded at boot so dynamic driver-switching works
  # (module.sig_enforce=1 means they must be present at boot, not loaded ad-hoc)
  boot.kernelModules = ["vfio_pci" "vfio" "vfio_iommu_type1"];

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = false;
        swtpm.enable = true; # TPM 2.0 — required for Windows 11
        # OVMF (UEFI) is bundled with QEMU in NixOS — no separate option needed
      };
      # Runs before/after every QEMU domain to hand the GPU over and back
      hooks.qemu."10-vfio-passthrough" = hookScript;
    };

    spiceUSBRedirection.enable = true; # USB passthrough via SPICE protocol
  };

  programs.virt-manager.enable = true;

  # libvirtd group for VM management (kvm already in user-roles.nix)
  users.users.dodwmd.extraGroups = ["libvirtd"];

  # swtpm_setup (run as qemu-libvirtd) needs to write TPM state and logs.
  # libvirt creates /var/lib/libvirt/swtpm as 0711/root — not writable by the
  # QEMU user. The log directory isn't created at all. Fix both.
  systemd.tmpfiles.rules = [
    "d /var/lib/libvirt/swtpm        0755 qemu-libvirtd qemu-libvirtd -"
    "d /var/log/swtpm                0755 qemu-libvirtd qemu-libvirtd -"
    "d /var/log/swtpm/libvirt        0755 qemu-libvirtd qemu-libvirtd -"
    "d /var/log/swtpm/libvirt/qemu   0755 qemu-libvirtd qemu-libvirtd -"
  ];

  environment.systemPackages = with pkgs; [
    virt-viewer # SPICE/VNC client for VM display
    swtpm # TPM 2.0 daemon (used by QEMU)
    virtio-win # VirtIO drivers ISO — attach to VM during Windows install
    looking-glass-client # Optional: view GPU-passthrough VM on a second display
  ];
}
