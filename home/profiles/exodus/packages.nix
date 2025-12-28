{pkgs, lib, ...}: {
  # Additional packages for exodus that aren't in the base kaku config
  home.packages = with pkgs; [
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
  
  # Bash configuration (since user shell is bash)
  programs.bash = {
    enable = true;
    enableCompletion = true;
    historyControl = ["ignoredups" "ignorespace"];
    historySize = 10000;
    historyFileSize = 100000;
    
    bashrcExtra = ''
      # Configure byobu to use tmux
      export BYOBU_BACKEND=tmux
      
      # Editor set by programs.neovim.defaultEditor
      
      # Aliases
      alias ls='eza --icons'
      alias ll='eza -l --icons'
      alias la='eza -la --icons'
      alias cat='bat'
      alias k='kubectl'
    '';
  };
  
  # Use neovim as vim/vi
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
  
  # Override EDITOR to use neovim instead of helix
  home.sessionVariables.EDITOR = lib.mkForce "nvim";
  
  # Tmux configuration
  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    historyLimit = 10000;
  };
  
  # Direnv for nix-shell integration
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  
  xdg.configFile."direnv/direnvrc".text = ''
    source ${pkgs.nix-direnv}/share/nix-direnv/direnvrc
  '';
}
