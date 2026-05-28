{pkgs, lib, ...}: {
  # Server packages - minimal CLI tools for headless systems
  environment.systemPackages = with pkgs; [
    # Essential system tools
    vim
    git
    tmux
    byobu
    htop
    iotop
    iftop

    # Network tools
    wget
    curl
    dig
    traceroute
    iperf3
    nmap

    # System utilities
    jq
    yq
    gnumake
    gnupg
    bc
    p7zip
    unzip

    # Container/orchestration tools
    kubectl

    # Monitoring
    lm_sensors
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
      alias ll='ls -lh'
      alias la='ls -lah'
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

  # Override EDITOR to use neovim
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
}
