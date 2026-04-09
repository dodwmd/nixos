{pkgs, ...}: {
  users.users.linuxmobile.packages = with pkgs; [
    fish
    grc
    (writeShellScriptBin "hx" ''
      ${pkgs.helix}/bin/hx "$@"
    '')
  ];

  xdg.configFile = {
    "fish/config.fish" = {
      text = ''
        for secret in discordo openrouter github twt
          if test -f /run/agenix/$secret
            set -l val (cat /run/agenix/$secret)
            set -l up (string upper $secret)
            switch $secret
              case discordo
                set -gx DISCORDO_TOKEN $val
                set -gx OXICORD_TOKEN $val
              case openrouter context7 exa
                set -gx "$up"_API_KEY $val
              case '*'
                set -gx "$up"_TOKEN $val
            end
          end
        end

        set -gx NIXPKGS_ALLOW_UNFREE 1
        set -gx NIXPKGS_ALLOW_INSECURE 1
        set -gx EDITOR hx
        set -gx VISUAL hx

        set -g fish_greeting

        # Vi keybindings
        fish_vi_key_bindings

        # Custom key bindings function (REQUIRED to properly unbind keys)
        function fish_user_key_bindings
          # Custom bindings
          for mode in insert default
            bind -M $mode ctrl-backspace backward-kill-word
            bind -M $mode ctrl-z undo
            bind -M $mode ctrl-b beginning-of-line
            bind -M $mode ctrl-e end-of-line
          end

          bind -M insert \cx\ce edit_command_buffer
          bind -M default \cx\ce edit_command_buffer

          # History search with prefix (like nushell)
          bind -M insert up history-prefix-search-backward
          bind -M insert down history-prefix-search-forward
          bind -M default up history-prefix-search-backward
          bind -M default down history-prefix-search-forward
        end

        # Cursor shapes per mode
        set fish_cursor_default block
        set fish_cursor_insert line
        set fish_cursor_replace_one underscore
        set fish_cursor_visual block

        # Syntax colors
        set -g fish_color_autosuggestion brblack
        set -g fish_color_command blue
        set -g fish_color_error red
        set -g fish_color_param normal

        # Search highlight
        set -g fish_color_search_match --background=normal

        # Plugin settings
        set -Ux fifc_editor hx
        set -U fifc_keybinding \cv
        set -g __done_min_cmd_duration 10000
      '';
    };

    "fish/functions/fcd.fish" = {
      text = ''
        function fcd
          set -l dir (fd --type d | sk | string trim)
          if test -n "$dir"
            z $dir
          end
        end
      '';
    };

    "fish/functions/installed.fish" = {
      text = ''
        function installed
          nix-store --query --requisites /run/current-system/ | string replace -r '.*?-(.*)' '$1' | sort | uniq | sk
        end
      '';
    };

    "fish/functions/installedall.fish" = {
      text = ''
        function installedall
          nix-store --query --requisites /run/current-system/ | sk | wl-copy
        end
      '';
    };

    "fish/functions/fm.fish" = {
      text = ''
        function fm
          set -l tmp (mktemp -t "yazi-cwd.XXXXX")
          yazi $argv --cwd-file $tmp
          set -l cwd (cat $tmp)
          if test -n "$cwd" -a "$cwd" != "$PWD"
            cd $cwd
          end
          rm -f $tmp
        end
      '';
    };

    "fish/functions/gitgrep.fish" = {
      text = ''
        function gitgrep
          git ls-files | rg $argv
        end
      '';
    };

    "fish/conf.d/aliases.fish" = {
      text = ''
      '';
    };
  };
}
