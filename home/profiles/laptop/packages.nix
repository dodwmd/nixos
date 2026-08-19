{
  pkgs,
  lib,
  ...
}: {
  users.users.dodwmd.packages = with pkgs; [
    # Wayland launcher
    fuzzel

    # Communication / security
    bitwarden-desktop
    bitwarden-cli
    signal-desktop
    thunderbird

    # Cloud CLIs
    google-cloud-sdk
    awscli2
    azure-cli

    # IaC / infrastructure
    opentofu
    terraform-ls
    terragrunt
    ansible
    packer

    # Kubernetes
    kubectl
    kubectx
    helm
    k9s
    kustomize
    fluxcd

    # Dev tools
    vscode
    gnumake
    python3
    nodejs_22
    go
    jq
    yq-go
    direnv

    # Terminal productivity
    byobu
    tmux

    # Utilities
    imv
    evince
    gsimplecal
    pciutils
    gnupg
    p7zip
    ripgrep
    fd
    htop
    iotop
    nethogs
    inetutils

    # Networking / VPN
    openvpn
    wireguard-tools
    nmap
    tcpdump

    # Document handling
    xournalpp
  ];

  programs.bash = {
    completion.enable = true;
    interactiveShellInit = ''
      export BYOBU_BACKEND=tmux
      export HISTCONTROL=ignoredups:ignorespace
      export HISTSIZE=10000
      export HISTFILESIZE=100000

      alias ls='eza --icons'
      alias ll='eza -l --icons'
      alias la='eza -la --icons'
      alias cat='bat'
      alias k='kubectl'
      alias tf='tofu'
      alias kctx='kubectx'
      alias kns='kubens'
    '';
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  environment.sessionVariables.EDITOR = lib.mkForce "nvim";

  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    historyLimit = 10000;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
