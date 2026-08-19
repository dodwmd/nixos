{ config, pkgs, lib, ... }:

{
  # Enable bash system-wide
  programs.bash = {
    completion.enable = true;
    interactiveShellInit = ''
      # Configure byobu to use tmux
      export BYOBU_BACKEND=tmux
      
      # History settings
      export HISTCONTROL=ignoredups:ignorespace
      export HISTSIZE=10000
      export HISTFILESIZE=100000
      
      # Aliases
      alias ls='eza --icons'
      alias ll='eza -l --icons'
      alias la='eza -la --icons'
      alias cat='bat'
      alias firefox='librewolf'
      alias k='kubectl'
    '';
  };

  # Add tmux package
  users.users.dodwmd.packages = with pkgs; [
    tmux
    byobu
  ];
}
