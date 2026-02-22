{pkgs, ...}: {
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      libva
      libva-vdpau-driver
      libvdpau-va-gl
      libGL
      mesa
      # NVIDIA specific packages for better performance
      nvidia-vaapi-driver
      egl-wayland
      # Graphics debugging/monitoring tools
      mesa-demos
      vulkan-tools
      vulkan-validation-layers
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      libva-vdpau-driver
      libvdpau-va-gl
      # 32-bit support for Steam games
      libGL
      mesa
    ];
  };
}
