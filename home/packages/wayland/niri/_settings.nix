_: let
  pointer = "Bibata-Modern-Ice";
in {
  environment = {
    CLUTTER_BACKEND = "wayland";
    DISPLAY = null;
    GTK_IM_MODULE = "simple";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_QPA_PLATFORMTHEME = "qt6ct";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    SDL_VIDEODRIVER = "wayland";
    WLR_NO_HARDWARE_CURSORS = "1";
    WLR_RENDERER = "vulkan";
  };

  spawn-at-startup = [
    ["wl-paste" "--watch" "cliphist" "store"]
    ["wl-paste" "--type" "text" "--watch" "cliphist" "store"]
    ["qs" "-c" "noctalia"]
  ];

  input = {
    keyboard = {
      xkb = {
        layout = "latam";
        model = "";
        rules = "";
        variant = "";
      };
      repeat-delay = 600;
      repeat-rate = 25;
      track-layout = "global";
    };

    touchpad = {
      tap = true;
      dwt = true;
      dwtp = true;
      natural-scroll = true;
      middle-emulation = true;
      accel-profile = "adaptive";
      scroll-method = "two-finger";
      click-method = "button-areas";
      tap-button-map = "left-right-middle";
    };

    warp-mouse-to-focus = true;
    focus-follows-mouse.max-scroll-amount = "90%";
    workspace-auto-back-and-forth = true;
  };

  screenshot-path = "~/Pictures/Screenshots/Screenshot-from-%Y-%m-%d-%H-%M-%S.png";

  output."eDP-1" = {
    scale = 1.0;
    transform = "normal";
    position.x = 0;
    position.y = 0;
  };

  output."HDMI-A-1" = {
    scale = 1.0;
    transform = "normal";
    mode = "1920x1080";
    position.x = 0;
    position.y = -1080;
  };

  overview = {
    backdrop-color = "transparent";
    workspace-shadow.enable = false;
  };

  gestures.hot-corners = true;

  cursor = {
    xcursor-size = 20;
    xcursor-theme = pointer;
  };

  layout = {
    focus-ring.enable = false;

    border = {
      width = 2;
      active-color = "#0d5ba5";
      inactive-color = "#204c78";
    };

    shadow.enable = false;

    preset-column-widths = [
      {proportion = 0.25;}
      {proportion = 0.5;}
      {proportion = 0.75;}
      {proportion = 1.0;}
    ];

    default-column-width.proportion = 0.5;
    always-center-single-column = true;

    gaps = 6;

    struts = {
      left = 0;
      right = 0;
      top = 0;
      bottom = 0;
    };

    tab-indicator = {
      hide-when-single-tab = true;
      place-within-column = true;
      position = "left";
      corner-radius = 20.0;
      gap = -12.0;
      gaps-between-tabs = 10.0;
      width = 4.0;
      length.total-proportion = 0.1;
    };

    background-color = "transparent";
  };

  prefer-no-csd = true;
  hotkey-overlay.skip-at-startup = true;
}
