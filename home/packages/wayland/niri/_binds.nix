{pkgs}: {
  "XF86AudioPlay" = {
    _props.allow-when-locked = true;
    spawn._args = ["${pkgs.playerctl}/bin/playerctl" "play-pause"];
  };
  "XF86AudioStop" = {
    _props.allow-when-locked = true;
    spawn._args = ["${pkgs.playerctl}/bin/playerctl" "stop"];
  };
  "XF86AudioNext" = {
    _props.allow-when-locked = true;
    spawn._args = ["${pkgs.playerctl}/bin/playerctl" "next"];
  };
  "XF86AudioPrev" = {
    _props.allow-when-locked = true;
    spawn._args = ["${pkgs.playerctl}/bin/playerctl" "previous"];
  };
  "XF86AudioMute" = {
    _props.allow-when-locked = true;
    spawn._args = ["${pkgs.wireplumber}/bin/wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"];
  };
  "XF86AudioMicMute" = {
    _props.allow-when-locked = true;
    spawn._args = ["${pkgs.wireplumber}/bin/wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"];
  };
  "XF86AudioRaiseVolume" = {
    _props.allow-when-locked = true;
    spawn._args = ["${pkgs.wireplumber}/bin/wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"];
  };
  "XF86AudioLowerVolume" = {
    _props.allow-when-locked = true;
    spawn._args = ["${pkgs.wireplumber}/bin/wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"];
  };
  "XF86MonBrightnessUp" = {
    _props.allow-when-locked = true;
    spawn._args = ["${pkgs.brightnessctl}/bin/brightnessctl" "set" "5%+"];
  };
  "XF86MonBrightnessDown" = {
    _props.allow-when-locked = true;
    spawn._args = ["${pkgs.brightnessctl}/bin/brightnessctl" "set" "5%-"];
  };
  "Ctrl+Alt+L".spawn._args = ["${pkgs.swaylock}/bin/swaylock" "-f" "-c" "000000"];
  "Alt+Space".spawn._args = ["${pkgs.fuzzel}/bin/fuzzel"];
  "Mod+D".spawn._args = ["${pkgs.fuzzel}/bin/fuzzel"];
  "Print".screenshot = {};
  "Mod+Shift+Alt+S".screenshot-window = {};
  "Mod+Shift+S".screenshot-screen = {};
  "Mod+Return".spawn._args = ["${pkgs.foot}/bin/foot"];
  "Mod+Q".close-window = {};
  "Mod+S".switch-preset-column-width = {};
  "Mod+F".maximize-column = {};
  "Mod+1".set-column-width = "25%";
  "Mod+2".set-column-width = "50%";
  "Mod+3".set-column-width = "75%";
  "Mod+4".set-column-width = "100%";
  "Mod+Shift+F".expand-column-to-available-width = {};
  "Mod+Space".toggle-window-floating = {};
  "Mod+W".toggle-column-tabbed-display = {};
  "Mod+Comma".consume-window-into-column = {};
  "Mod+Period".expel-window-from-column = {};
  "Mod+C".center-visible-columns = {};
  "Mod+Tab".switch-focus-between-floating-and-tiling = {};
  "Mod+Minus".set-column-width = "-10%";
  "Mod+Plus".set-column-width = "+10%";
  "Mod+Shift+Minus".set-window-height = "-10%";
  "Mod+Shift+Plus".set-window-height = "+10%";
  "Mod+L".spawn._args = ["${pkgs.swaylock}/bin/swaylock" "-f" "-c" "000000"];
  "Mod+Left".focus-column-left = {};
  "Mod+Right".focus-column-right = {};
  "Mod+Down".focus-workspace-down = {};
  "Mod+Up".focus-workspace-up = {};
  "Mod+Shift+Left".move-column-left = {};
  "Mod+Shift+Right".move-column-right = {};
  "Mod+Shift+Down".move-column-to-workspace-down = {};
  "Mod+Shift+Up".move-column-to-workspace-up = {};
  "Mod+Shift+Ctrl+Down".move-column-to-monitor-down = {};
  "Mod+Shift+Ctrl+Up".move-column-to-monitor-up = {};
  "Mod+Shift+Ctrl+Left".move-column-to-monitor-left = {};
  "Mod+Shift+Ctrl+Right".move-column-to-monitor-right = {};
  "Ctrl+Alt+BackSpace".spawn._args = ["${pkgs.systemd}/bin/systemctl" "--user" "restart" "niri"];
}
