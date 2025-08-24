{config, ...}: {
  programs.starship = with config.lib.stylix.colors; {
    enable = true;
    enableTransience = true;
    settings = {
      format = "$os$directory$character$nix_shell$fill$git_branch$git_status$cmd_duration";
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

      character = {
        success_symbol = "[ 󱐋 ](bold #${base0A})";
        error_symbol = "[ 󱐋 ](bold #${base08})";
        vicmd_symbol = "[  ](bold #${base0B})";
      };

      os = {
        format = "[](#${base0D})[$symbol](bg:#${base0D} fg:#${base00})[](fg:#${base0D} bg:#${base02})";
        symbols.NixOS = " ";
        disabled = false;
      };

      directory = {
        format = "[](fg:#${base02} bg:#${base02})[ ](bg:#${base02} fg:#${base0A})[$path ](bg:#${base02} fg:#${base0A} bold)[](fg:#${base02})";
        truncation_length = 3;
        truncate_to_repo = false;
      };

      git_branch = {
        format = "[](fg:#${base02})[[ ](bg:#${base02} fg:#${base0A} bold)$branch ](bg:#${base02} fg:#${base0A})[ ](fg:#${base02})";
      };

      git_status = {
        format = "[]($style)[$all_status$ahead_behind](bg:#${base02} fg:#${base09} bold)[]($style)";
        style = "bg:none fg:#${base02}";
        conflicted = "=";
        ahead = "[⇡\${count} ](fg:#${base0B} bg:#${base02}) ";
        behind = "[⇣\${count} ](fg:#${base08} bg:#${base02})";
        diverged = "↑\${ahead_count} ⇣\${behind_count} ";
        up_to_date = "[ ](fg:#${base0B} bg:#${base02})";
        untracked = "[?\${count} ](fg:#${base09} bg:#${base02}) ";
        stashed = "";
        modified = "[~\${count} ](fg:#${base09} bg:#${base02})";
        staged = "[+\${count} ](fg:#${base0B} bg:#${base02}) ";
        renamed = "[󰑕 \${count} ](fg:#${base0A} bg:#${base02})";
        deleted = "[ \${count} ](fg:#${base08} bg:#${base02}) ";
      };
      cmd_duration = {
        min_time = 1;
        # duration & style ;
        format = "[]($style)[[ ](bg:#${base02} fg:#${base08} bold)$duration](bg:#${base02} fg:#${base05} bold)[]($style)";
        disabled = false;
        style = "bg:none fg:#${base02}";
      };
      nix_shell = {
        disabled = false;
        heuristic = false;
        format = "[   ](fg:#${base0D} bold)";
        impure_msg = "";
        pure_msg = "";
        unknown_msg = "";
      };
    };
  };
}
