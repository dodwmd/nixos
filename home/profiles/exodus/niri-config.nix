{pkgs, lib, ...}: {
  # Override Niri settings for exodus desktop (vs aesthetic laptop)
  programs.niri.settings = {
    # Configure dual monitors for desktop
    # Detected: DP-1 and HDMI-A-1 connected
    outputs = lib.mkForce {
      # Left monitor (DP-1)
      "DP-1" = {
        mode = {
          width = 1920;
          height = 1080;
          refresh = 60.0;
        };
        scale = 1.0;
        position = {
          x = 0;
          y = 0;
        };
      };
      # Right monitor (HDMI-A-1)
      "HDMI-A-1" = {
        mode = {
          width = 1920;
          height = 1080;
          refresh = 60.0;
        };
        scale = 1.0;
        position = {
          x = 1920;
          y = 0;
        };
      };
    };
  };
  
}
