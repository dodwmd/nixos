{
  window-rule = [
    {
      geometry-corner-radius = {
        bottom-left = 12.0;
        bottom-right = 12.0;
        top-left = 12.0;
        top-right = 12.0;
      };
      clip-to-geometry = true;
      draw-border-with-background = false;
    }
    {
      match.is-floating = true;
      shadow.enable = true;
    }
    {
      match.is-window-cast-target = true;
      focus-ring = {
        active-color = "#f38ba8";
        inactive-color = "#7d0d2d";
      };
      border.inactive-color = "#7d0d2d";
      shadow.color = "#7d0d2d70";
      tab-indicator = {
        active-color = "#f38ba8";
        inactive-color = "#7d0d2d";
      };
    }
    {
      match.app-id = "org.telegram.desktop";
      block-out-from = "screencast";
    }
    {
      match.app-id = "app.drey.PaperPlane";
      block-out-from = "screencast";
    }
    {
      match = [
        {app-id = "zen";}
        {app-id = "helium";}
        {app-id = "firefox";}
        {app-id = "chromium-browser";}
        {app-id = "xdg-desktop-portal-gtk";}
      ];
      scroll-factor = 0.6;
    }
    {
      match = [
        {app-id = "zen";}
        {app-id = "helium";}
        {app-id = "firefox";}
        {app-id = "chromium-browser";}
        {app-id = "edge";}
      ];
      open-maximized = true;
    }
    {
      match.title = "^Picture-in-Picture$";
      open-floating = true;
      default-floating-position = {
        x = 32;
        y = 32;
        relative-to = "bottom-right";
      };
      default-column-width.fixed = 480;
      default-window-height.fixed = 270;
    }
    {
      match.title = "Discord Popout";
      open-floating = true;
      default-floating-position = {
        x = 32;
        y = 32;
        relative-to = "bottom-right";
      };
    }
    {
      match = [
        {app-id = "Multiviewer";}
        {title = "^Track Map$";}
      ];
      open-floating = true;
      open-on-output = "HDMI-A-1";
      default-floating-position = {
        x = 1426;
        y = 747;
        relative-to = "top-right";
      };
      default-column-width.fixed = 490;
      default-window-height.fixed = 330;
    }
    {
      match = [
        {app-id = "Multiviewer";}
        {title = "^Replay Radio$";}
      ];
      open-floating = true;
      open-on-output = "HDMI-A-1";
      default-floating-position = {
        x = 1423;
        y = 301;
        relative-to = "top-right";
      };
      default-column-width.fixed = 500;
      default-window-height.fixed = 450;
    }
    {
      match = [
        {app-id = "Multiviewer";}
        {title = "^Franco Colapinto$";}
      ];
      open-floating = true;
      open-on-output = "HDMI-A-1";
      default-floating-position = {
        x = 637;
        y = -2;
        relative-to = "top-right";
      };
      default-column-width.fixed = 640;
      default-window-height.fixed = 360;
    }
    {
      match = [
        {app-id = "Multiviewer";}
        {title = "^Pierre Gasly$";}
      ];
      open-floating = true;
      open-on-output = "HDMI-A-1";
      default-floating-position = {
        x = -2;
        y = -2;
        relative-to = "top-right";
      };
      default-column-width.fixed = 640;
      default-window-height.fixed = 360;
    }
    {
      match = [
        {app-id = "Multiviewer";}
        {title = "^Kimi Antonelli$";}
      ];
      open-floating = true;
      open-on-output = "HDMI-A-1";
      default-floating-position = {
        x = 1278;
        y = -2;
        relative-to = "top-right";
      };
      default-column-width.fixed = 640;
      default-window-height.fixed = 360;
    }
    {
      match = [
        {app-id = "Multiviewer";}
        {title = "^Live Timing$";}
      ];
      open-floating = true;
      open-on-output = "HDMI-A-1";
      default-floating-position = {
        x = 1430;
        y = 710;
        relative-to = "bottom-left";
      };
      default-column-width.fixed = 1430;
      default-window-height.fixed = 710;
    }
    {
      match.app-id = "pavucontrol";
      open-floating = true;
    }
    {
      match.app-id = "pavucontrol-qt";
      open-floating = true;
    }
    {
      match.app-id = "com.saivert.pwvucontrol";
      open-floating = true;
    }
    {
      match.app-id = "io.github.fsobolev.Cavalier";
      open-floating = true;
    }
    {
      match.app-id = "dialog";
      open-floating = true;
    }
    {
      match.app-id = "popup";
      open-floating = true;
    }
    {
      match.app-id = "task_dialog";
      open-floating = true;
    }
    {
      match.app-id = "gcr-prompter";
      open-floating = true;
    }
    {
      match.app-id = "file-roller";
      open-floating = true;
    }
    {
      match.app-id = "org.gnome.FileRoller";
      open-floating = true;
    }
    {
      match.app-id = "nm-connection-editor";
      open-floating = true;
    }
    {
      match.app-id = "blueman-manager";
      open-floating = true;
    }
    {
      match.app-id = "xdg-desktop-portal-gtk";
      open-floating = true;
    }
    {
      match.app-id = "org.kde.polkit-kde-authentication-agent-1";
      open-floating = true;
    }
    {
      match.app-id = "pinentry";
      open-floating = true;
    }
    {
      match.title = "Progress";
      open-floating = true;
    }
    {
      match.title = "File Operations";
      open-floating = true;
    }
    {
      match.title = "Copying";
      open-floating = true;
    }
    {
      match.title = "Moving";
      open-floating = true;
    }
    {
      match.title = "Properties";
      open-floating = true;
    }
    {
      match.title = "Downloads";
      open-floating = true;
    }
    {
      match.title = "file progress";
      open-floating = true;
    }
    {
      match.title = "Confirm";
      open-floating = true;
    }
    {
      match.title = "Authentication Required";
      open-floating = true;
    }
    {
      match.title = "Notice";
      open-floating = true;
    }
    {
      match.title = "Warning";
      open-floating = true;
    }
    {
      match.title = "Error";
      open-floating = true;
    }
  ];

  layer-rule = [
    {
      match.namespace = "^noctalia-wallpaper*";
      place-within-backdrop = true;
    }
  ];
}
