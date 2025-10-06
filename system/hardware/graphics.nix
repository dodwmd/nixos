{pkgs, ...}: {
  # graphics drivers / HW accel
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      libva
      vaapiVdpau
      libvdpau-va-gl
      # amdvlk deprecated & replaced with radv
      mesa
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      vaapiVdpau
      libvdpau-va-gl
      # amdvlk deprecated & replaced with radv
    ];
  };
}
