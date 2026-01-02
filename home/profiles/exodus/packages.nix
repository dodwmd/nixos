{pkgs, lib, ...}: {
  # Additional packages for exodus that aren't in the base kaku config
  users.users.dodwmd.packages = with pkgs; [
    # Wayland launcher
    fuzzel
    
    # Applications from old dodwmd config
    bitwarden-desktop
    signal-desktop
    slack
    spotify
    thunderbird
    vscode
    windsurf
    
    # XWayland support for niri
    xwayland-satellite
    
    # Terminal tools
    byobu
    tmux
    gnumake
    kubectl
    bc
    bitwarden-cli
    gnupg
    # curl - already included
    # wget - already included
    python3
    p7zip
    # vim/neovim configured via programs.neovim below
    
    # Steam (already in system config but adding here for completeness)
    # steam is enabled at system level via programs.steam.enable
  ];
  
  # System-wide bash configuration
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
      alias k='kubectl'
    '';
  };
  
  # System-wide neovim configuration
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
  
  # Override EDITOR to use neovim instead of helix
  environment.sessionVariables.EDITOR = lib.mkForce "nvim";
  
  # System-wide tmux configuration
  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    historyLimit = 10000;
  };
  
  # System-wide direnv configuration
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  
  xdg.configFile."direnv/direnvrc".text = ''
    source ${pkgs.nix-direnv}/share/nix-direnv/direnvrc
  '';
}
