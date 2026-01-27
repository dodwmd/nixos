{pkgs, ...}: let
  pointer = "Bibata-Original-Ice";
in {
  # Don't include noctalia.kdl - use direct configuration instead
  environment = {
    # DISPLAY will be set automatically by niri's xwayland-satellite integration
    # EGL_PLATFORM is explicitly unset to prevent Xwayland from trying to use EGL
    # which causes crashes when EGL providers are not available
    EGL_PLATFORM = null;
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    SDL_VIDEODRIVER = "wayland";
    WLR_RENDERER = "vulkan";
    WLR_NO_HARDWARE_CURSORS = "1";
    QT_QPA_PLATFORMTHEME = "qt6ct";
    GTK_IM_MODULE = "simple";
  };

  spawn-at-startup = [
    # ["wl-paste" "--watch" "cliphist" "store"]  # Disabled - interferes with simple vim paste
    # ["wl-paste" "--type" "text" "--watch" "cliphist" "store"]  # Disabled - interferes with simple vim paste
    ["${pkgs.waybar}/bin/waybar"]
    ["swayidle" "-w" "timeout" "600" "${pkgs.swaylock-effects}/bin/swaylock -f -c 000000" "timeout" "1200" "systemctl suspend" "before-sleep" "${pkgs.swaylock-effects}/bin/swaylock -f -c 000000"]
    # xwayland-satellite is managed by systemd user service
  ];

  input = {
    keyboard.xkb.layout = "us";
    touchpad = {
      click-method = "button-areas";
      dwt = {};
      dwtp = {};
      natural-scroll = {};
      scroll-method = "two-finger";
      tap = {};
      tap-button-map = "left-right-middle";
      middle-emulation = {};
      accel-profile = "adaptive";
    };
    focus-follows-mouse._props = {max-scroll-amount = "90%";};
    warp-mouse-to-focus = {};
    workspace-auto-back-and-forth = {};
  };

  screenshot-path = "~/Pictures/Screenshots/Screenshot-from-%Y-%m-%d-%H-%M-%S.png";

  output = [
    {
      _args = ["DP-1"];
      mode = "1920x1080@60.000";
      scale = 1.0;
      position._props = {
        x = 0;
        y = 0;
      };
    }
    {
      _args = ["HDMI-A-1"];
      mode = "1920x1080@60.000";
      scale = 1.0;
      position._props = {
        x = 1920;
        y = 0;
      };
    }
  ];

  overview = {
    workspace-shadow.off = {};
    backdrop-color = "transparent";
  };

  gestures.hot-corners = {};

  cursor = {
    xcursor-size = 20;
    xcursor-theme = pointer;
  };

  layout = {
    background-color = "transparent";
    focus-ring.off = {};
    border = {
      width = 2;
    };
    shadow.off = {};
    preset-column-widths.proportion = [0.25 0.5 0.75 1.0];
    default-column-width.proportion = 0.5;
    always-center-single-column = {};
    gaps = 6;
    struts = {
      left = 0;
      right = 0;
      top = 0;
      bottom = 0;
    };
    tab-indicator = {
      hide-when-single-tab = {};
      place-within-column = {};
      position = "left";
      corner-radius = 20.0;
      gap = -12.0;
      gaps-between-tabs = 10.0;
      width = 4.0;
      length._props = {total-proportion = 0.1;};
    };
  };

  prefer-no-csd = {};
  hotkey-overlay.skip-at-startup = {};
}
