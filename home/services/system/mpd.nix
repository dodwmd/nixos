{
  config,
  pkgs,
  ...
}: let
  configFile = "mpd/mpd.conf";
in {
  users.users.linuxmobile.packages = with pkgs; [mpd];

  systemd.user.services.mpd = {
    description = "Music Player Daemon";
    documentation = ["https://www.musicpd.org/doc/"];
    wantedBy = ["default.target"];
    after = ["sound.target"];
    serviceConfig = {
      ExecStartPre = [
        "${pkgs.coreutils}/bin/mkdir -p ${config.xdg.dataHome}/mpd/playlists"
        "${pkgs.coreutils}/bin/mkdir -p ${config.xdg.stateHome}/mpd"
        "${pkgs.coreutils}/bin/mkdir -p ${config.xdg.runtimeDir}/mpd"
      ];
      ExecStart = "${pkgs.mpd}/bin/mpd ${config.xdg.configHome}/mpd/mpd.conf --no-daemon";
      Restart = "on-failure";
      RestartSec = "3";
    };
  };

  xdg.configFile."${configFile}".text = ''
    music_directory    "$HOME/Music"
    playlist_directory "${config.xdg.dataHome}/mpd/playlists"
    state_file         "${config.xdg.stateHome}/mpd/state"
    bind_to_address    "${config.xdg.runtimeDir}/mpd/socket"
    auto_update        "yes"
    restore_paused     "yes"
    audio_output {
      type "pulse"
      name "pulseaudio"
    }
    audio_output {
      type   "fifo"
      name   "visualizer"
      format "44100:16:2"
      path   "/tmp/mpd.fifo"
    }
    audio_output {
      type       "httpd"
      name       "lossless"
      encoder    "flac"
      port       "8000"
      max_client "8"
      mixer_type "software"
      format     "44100:16:2"
    }
  '';
}
