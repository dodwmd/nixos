{pkgs, ...}: {
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # iHD driver for VAAPI (Broadwell+, Arc)
      libva
      libva-vdpau-driver
      libvdpau-va-gl
      libGL
      mesa
      intel-compute-runtime # OpenCL support for Intel GPUs
    ];
  };
}
