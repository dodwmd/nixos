{
  programs.starship = {
    enable = true;
    enableTransience = true;
    settings = {
      add_newline = true;

      format = ''
        [╭──╼](bold bright-blue) $hostname $os
        [┆](bold bright-blue) $directory$git_branch$git_commit$git_state$git_metrics$git_status$nix_shell
        [╰─>](bold bright-blue) $character
      '';

      os = {
        format = "on [($name $codename$version $symbol )]($style)";
        style = "bold bright-blue";
        disabled = false;
      };

      hostname = {
        ssh_only = false;
        format = "[$hostname]($style)";
        style = "bold bright-red";
        disabled = false;
      };

      character = {
        format = "$symbol";
        success_symbol = "[❯](bold bright-green)";
        error_symbol = "[✗](bold bright-red) ";
        disabled = false;
      };

      time = {
        disabled = false;
        format = " [$time]($style)";
        time_format = "%H:%M";
        utc_time_offset = "local";
        style = "pale bright-blue";
      };

      cmd_duration = {
        disabled = false;
        min_time = 250;
        show_milliseconds = false;
        show_notifications = false;
        format = "was [$duration](bold green)";
      };

      nix_shell = {
        disabled = false;
        heuristic = false;
        format = "[   ](fg:bright-blue bold)";
        impure_msg = "";
        pure_msg = "";
        unknown_msg = "";
      };
    };
  };
}
