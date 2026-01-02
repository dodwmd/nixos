{pkgs, ...}: {
  home.packages = with pkgs; [
    fish
    grc
    (writeShellScriptBin "hx" ''
      ${pkgs.helix}/bin/hx "$@"
    '')
  ];

  xdg.configFile = {
    "fish/config.fish" = {
      force = true;
      text = ''
        if test -f /run/agenix/openrouter
          set -gx OPENROUTER_API_KEY (cat /run/agenix/openrouter)
        end
        if test -f /run/agenix/github
          set -gx GITHUB_TOKEN (cat /run/agenix/github)
        end
        if test -f /run/agenix/twt
          set -gx TWT_TOKEN (cat /run/agenix/twt)
        end


        set -gx NIXPKGS_ALLOW_UNFREE 1
        set -gx NIXPKGS_ALLOW_INSECURE 1
        set -gx EDITOR hx
        set -gx VISUAL hx

        set -g fish_greeting

        # Vi keybindings
        fish_vi_key_bindings

        # Custom binding
        for mode in insert default
          bind -M $mode ctrl-backspace backward-kill-word
          bind -M $mode ctrl-z undo
          bind -M $mode ctrl-b beginning-of-line
          bind -M $mode ctrl-e end-of-line
        end

        # History search with prefix (like nushell)
        bind -M insert up history-prefix-search-backward
        bind -M insert down history-prefix-search-forward

        # Same for normal mode
        bind -M default up history-prefix-search-backward
        bind -M default down history-prefix-search-forward

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
        set -U fifc_keybinding \cx
        set -g __done_min_cmd_duration 10000
        set -g sudope_sequence \cs
      '';
    };

    "fish/functions/fcd.fish" = {
      force = true;
      text = ''
        function fcd
          set -l dir (fd --type d | sk | string trim)
          if test -n "$dir"
            cd $dir
          end
        end
      '';
    };

    "fish/functions/installed.fish" = {
      force = true;
      text = ''
        function installed
          nix-store --query --requisites /run/current-system/ | string replace -r '.*?-(.*)' '$1' | sort | uniq | sk
        end
      '';
    };

    "fish/functions/installedall.fish" = {
      force = true;
      text = ''
        function installedall
          nix-store --query --requisites /run/current-system/ | sk | wl-copy
        end
      '';
    };

    "fish/functions/fm.fish" = {
      force = true;
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
      force = true;
      text = ''
        function gitgrep
          git ls-files | rg $argv
        end
      '';
    };

    "fish/conf.d/abbreviations.fish" = {
      force = true;
      text = ''
        abbr -a z "zoxide query"
        abbr -a zi "zoxide query -i"
      '';
    };

    "fish/conf.d/aliases.fish" = {
      force = true;
      text = ''
        alias cleanup="sudo nix-collect-garbage --delete-older-than 1d"
        alias listgen="sudo nix-env -p /nix/var/nix/profiles/system --list-generations"
        alias nixremove="nix-store --gc"
        alias bloat="nix path-info -Sh /run/current-system"
        alias cleanram="sudo sh -c 'sync; echo 3 > /proc/sys/vm/drop_caches'"
        alias trimall="sudo fstrim -va"
        alias c="clear"
        alias q="exit"
        alias temp="cd /tmp/"
        alias test-build="sudo nixos-rebuild test --flake .#aesthetic"
        alias switch-build="sudo nixos-rebuild switch --flake .#aesthetic"
        alias add="git add ."
        alias commit="git commit"
        alias push="git push"
        alias pull="git pull"
        alias diff="git diff --staged"
        alias gcld="git clone --depth 1"
        alias koji="meteor"
        alias gitui="lazygit"
        alias l="eza -lF --time-style=long-iso --icons"
        alias ll="eza -h --git --icons --color=auto --group-directories-first -s extension"
        alias tree="eza --tree --icons --tree"
        alias cat="${pkgs.bat}/bin/bat --paging=never"
        alias moon="${pkgs.curlMinimal}/bin/curl -s wttr.in/Moon"
        alias weather="${pkgs.curlMinimal}/bin/curl -s wttr.in"
        alias store-path="${pkgs.coreutils-full}/bin/readlink (${pkgs.which}/bin/which $argv)"
        alias us="systemctl --user"
        alias rs="sudo systemctl"
        alias zed="zeditor"
      '';
    };
  };
}
