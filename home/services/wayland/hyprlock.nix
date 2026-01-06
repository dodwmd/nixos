{
  config,
  pkgs,
  ...
}: {
  # Add swaylock as fallback (hyprlock may not be available)
  environment.systemPackages = with pkgs; [
    swaylock-effects
  ];

  # Create hyprlock config file
  environment.etc."hypr/hyprlock.conf".text = ''
    general {
        disable_loading_bar = true
        grace = 300
        hide_cursor = true
        no_fade_in = false
    }

    background {
        path = screenshot
        blur_passes = 3
        blur_size = 8
    }

    input-field {
        size = 300, 60
        position = 0, -80
        monitor =
        dots_center = true
        dots_size = 0.2
        dots_spacing = 0.2
        dots_rounding = -1
        fade_on_empty = true
        fade_timeout = 2000
        font_color = rgba(205, 214, 244, 1.0)
        inner_color = rgba(30, 30, 46, 0.4)
        outer_color = rgba(137, 180, 250, 0.8)
        outline_thickness = 3
        placeholder_text = 
        shadow_passes = 4
        shadow_size = 8
        shadow_color = rgba(0, 0, 0, 0.5)
        rounding = 25
    }

    label {
        monitor =
        text = Hi $USER
        color = rgba(200, 200, 200, 1.0)
        font_size = 55
        font_family = Noto Sans
        position = 0, 160
        halign = center
        valign = center
    }

    label {
        monitor =
        text = $TIME
        color = rgba(200, 200, 200, 1.0)
        font_size = 90
        font_family = Noto Sans
        position = 0, 0
        halign = center
        valign = center
    }
  '';
}
