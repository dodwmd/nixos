{ config, pkgs, lib, ... }:

{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    historyControl = [ "ignoredups" "ignorespace" ];
    historySize = 10000;
    historyFileSize = 100000;
    
    bashrcExtra = ''
      # Configure byobu to use tmux
      export BYOBU_BACKEND=tmux
      
      # Aliases
      alias ls='eza --icons'
      alias ll='eza -l --icons'
      alias la='eza -la --icons'
      alias cat='bat'
      alias firefox='librewolf'
      alias k='kubectl'
    '';
  };

  # Tmux configuration (for when using tmux directly)
  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    historyLimit = 10000;
  };

}
