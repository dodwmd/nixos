''
  window-rule {
      geometry-corner-radius 12.0 12.0 12.0 12.0
      clip-to-geometry true
      draw-border-with-background false
  }

  window-rule {
      match is-floating=true
      shadow { }
  }

  window-rule {
      match is-window-cast-target=true
      focus-ring { active-color "#f38ba8"; inactive-color "#7d0d2d"; }
      border { inactive-color "#7d0d2d"; }
      shadow { color "#7d0d2d70"; }
      tab-indicator { active-color "#f38ba8"; inactive-color "#7d0d2d"; }
  }

  window-rule { match app-id="org.telegram.desktop"; block-out-from "screencast"; }
  window-rule { match app-id="app.drey.PaperPlane"; block-out-from "screencast"; }

  window-rule {
      match app-id="zen"
      match app-id="helium"
      match app-id="firefox"
      match app-id="chromium-browser"
      match app-id="xdg-desktop-portal-gtk"
      scroll-factor 0.6
  }

  window-rule {
      match app-id="zen"
      match app-id="helium"
      match app-id="firefox"
      match app-id="chromium-browser"
      match app-id="edge"
      open-maximized true
  }

  window-rule {
      match title="^Picture-in-Picture$"
      open-floating true
      default-floating-position x=32 y=32 relative-to="bottom-right"
      default-column-width { fixed 480; }
      default-window-height { fixed 270; }
  }

  window-rule {
      match title="Discord Popout"
      open-floating true
      default-floating-position x=32 y=32 relative-to="bottom-right"
  }

  window-rule {
      match app-id="Multiviewer" title="^Track Map$"
      open-floating true
      open-on-output "HDMI-A-1"
      default-floating-position x=1426 y=747 relative-to="top-right"
      default-column-width { fixed 490; }
      default-window-height { fixed 330; }
  }

  window-rule { match app-id="pavucontrol"; open-floating true; }
  window-rule { match app-id="pavucontrol-qt"; open-floating true; }
  window-rule { match app-id="com.saivert.pwvucontrol"; open-floating true; }
  window-rule { match app-id="io.github.fsobolev.Cavalier"; open-floating true; }
  window-rule { match app-id="dialog"; open-floating true; }
  window-rule { match app-id="popup"; open-floating true; }
  window-rule { match app-id="task_dialog"; open-floating true; }
  window-rule { match app-id="gcr-prompter"; open-floating true; }
  window-rule { match app-id="file-roller"; open-floating true; }
  window-rule { match app-id="org.gnome.FileRoller"; open-floating true; }
  window-rule { match app-id="nm-connection-editor"; open-floating true; }
  window-rule { match app-id="blueman-manager"; open-floating true; }
  window-rule { match app-id="xdg-desktop-portal-gtk"; open-floating true; }
  window-rule { match app-id="org.kde.polkit-kde-authentication-agent-1"; open-floating true; }
  window-rule { match app-id="pinentry"; open-floating true; }
  window-rule { match title="Progress"; open-floating true; }
  window-rule { match title="File Operations"; open-floating true; }
  window-rule { match title="Confirm"; open-floating true; }
  window-rule { match title="Error"; open-floating true; }

  layer-rule {
      match namespace="^noctalia-wallpaper*"
      place-within-backdrop true
  }
''
