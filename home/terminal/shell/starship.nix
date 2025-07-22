{config, ...}: {
  home.sessionVariables = {
    STARSHIP_CACHE = "${config.xdg.cacheHome}/starship";
  };
  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
    enableTransience = true;
    settings = {
      format = "$directory$nix_shell$fill$git_branch$git_status$cmd_duration$line_break$character";
      add_newline = false;
      c.disabled = true;
      cmake.disabled = true;
      haskell.disabled = true;
      python.disabled = true;
      ruby.disabled = true;
      rust.disabled = true;
      perl.disabled = true;
      package.disabled = true;
      lua.disabled = true;
      nodejs.disabled = true;
      java.disabled = true;
      golang.disabled = true;

      fill = {
        symbol = " ";
      };
      conda = {
        format = " [ $symbol$environment ] (dimmed green) ";
      };
      character = {
        success_symbol = "[ ](gray bold)";
        error_symbol = "[ ](red bold)";
        vicmd_symbol = "[ ](white)";
      };
      directory = {
        format = "[█]($style)[ ](bg:black fg:bright-black)[$path](bg:black fg:bright-black bold)[█ ]($style)";
        style = "fg:black bg:none";
        truncation_length = 0;
        truncate_to_repo = false;
      };
      git_branch = {
        format = "[█]($style)[[ ](bg:black fg:yellow bold)$branch](bg:black fg:bright-black bold)[█ ]($style)";
        style = "fg:black";
      };
      git_status = {
        format = "[█]($style)[$all_status$ahead_behind](bg:black fg:orange bold)[█ ]($style)";
        style = "fg:black bg:none";
        conflicted = "=";
        ahead = "[⇡\${count} ](fg:green bg:black) ";
        behind = "[⇣\${count} ](fg:red bg:black)";
        diverged = "↑\${ahead_count} ⇣\${behind_count} ";
        up_to_date = "[](fg:green bg:black)";
        untracked = "[?\${count} ](fg:orange bg:black) ";
        stashed = "";
        modified = "[~\${count} ](fg:orange bg:black)";
        staged = "[+\${count} ](fg:green bg:black) ";
        renamed = "[󰑕\${count} ](fg:yellow bg:black)";
        deleted = "[ \${count} ](fg:red bg:black) ";
      };
      cmd_duration = {
        min_time = 1;
        # duration & style ;
        format = "[█]($style)[[ ](bg:black fg:red bold)$duration](bg:black fg:bright-black bold)[█]($style)";
        disabled = false;
        style = "fg:black bg:none";
      };
      nix_shell = {
        disabled = false;
        heuristic = false;
        format = "[█]($style)[ ](bg:black fg:bright-black bold)[█]($style)";
        style = "fg:black bg:none";
        impure_msg = "";
        pure_msg = "";
        unknown_msg = "";
      };
    };
  };
}
