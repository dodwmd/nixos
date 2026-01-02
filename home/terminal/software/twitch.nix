{pkgs, ...}: let
  twitchHLSConfig = "twitch-hls-client/config";
  twtConfig = "twt/config.toml";

  toINI = (pkgs.formats.ini {}).generate;
  toTOML = (pkgs.formats.toml {}).generate;

  twitchHLSSettings = {
    General = {
      quality = "best";
      debug = false;
    };
    Player = {
      player = "${pkgs.mpv}/bin/mpv";
      player-args = "- --profile=low-latency";
      quiet = true;
      no-kill = false;
    };
    HLS = {
      servers = "https://eu.luminous.dev/live/[channel],https://eu2.luminous.dev/live/[channel],https://as.luminous.dev/live/[channel]";
      print-streams = false;
      no-low-latency = false;
      codecs = "av1,h265,h264";
    };
    HTTP = {
      force-https = true;
      force-ipv4 = false;
      user-agent = "Mozilla/5.0 (X11; Linux x86_64; rv:143.0) Gecko/20100101 Firefox/143.0";
      http-retries = 3;
      http-timeout = 10;
    };
  };

  twtSettings = {
    twitch = {
      username = "linuxmobile";
      channel = "bunzopy";
      server = "irc.chat.twitch.tv";
    };
    terminal = {
      delay = 30;
      maximum_messages = 500;
      verbose = false;
      first_state = "Dashboard";
    };
    storage = {
      channels = true;
      mentions = false;
    };
    filters = {
      enabled = false;
      reversed = false;
    };
    frontend = {
      show_datetimes = false;
      datetime_format = "%a %b %e %T";
      username_shown = true;
      palette = "vibrant";
      title_shown = true;
      margin = 0;
      badges = false;
      theme = "dark";
      username_highlight = true;
      state_tabs = false;
      cursor_shape = "user";
      blinking_cursor = false;
      inverted_scrolling = false;
      show_scroll_offset = false;
      twitch_emotes = false;
      betterttv_emotes = false;
      seventv_emotes = false;
      frankerfacez_emotes = false;
      favorite_channels = ["oxatani" "roman_pascucci"];
      recent_channel_count = 5;
      border_type = "plain";
      hide_chat_border = false;
      right_align_usernames = false;
      show_unsupported_screen_size = true;
    };
  };
in {
  home.packages = with pkgs; [
    twitch-hls-client
    mpv
  ];

  xdg.configFile."${twitchHLSConfig}".source = toINI "config" twitchHLSSettings;
  xdg.configFile."${twtConfig}".source = toTOML "config.toml" twtSettings;
}
