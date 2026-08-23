{pkgs, ...}: let
  pointer = "Bibata-Original-Ice";
in {
  # Don't include noctalia.kdl - use direct configuration instead
  environment = {
    # DISPLAY will be set automatically by niri's xwayland-satellite integration
    # Force the Wayland EGL platform for native clients so they don't fall back
    # to the X11 platform (which has no EGL provider, since XWayland is built
    # with -Dglamor=false — see hosts/exodus/default.nix).
    EGL_PLATFORM = "wayland";
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
    ["${pkgs.wl-clip-persist}/bin/wl-clip-persist" "--clipboard" "primary"]
    ["${pkgs.waybar}/bin/waybar"]
    # Polkit auth agent: installed (polkit-agent.nix) but never previously
    # started, so graphical auth prompts (mount, NetworkManager, etc.) had
    # nowhere to appear.
    ["${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"]
    ["swayidle" "-w" "timeout" "600" "${pkgs.swaylock}/bin/swaylock -f -c 000000" "timeout" "1200" "niri msg action power-off-monitors" "before-sleep" "${pkgs.swaylock}/bin/swaylock -f -c 000000" "after-resume" "sleep 2; ${pkgs.swaylock}/bin/swaylock -f -c 000000"]
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

  # output is supplied per-host via homelab.niri.outputs (see hosts/*/default.nix)

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
