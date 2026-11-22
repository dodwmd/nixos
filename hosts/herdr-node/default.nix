{
  inputs,
  lib,
  pkgs,
  ...
}: let
  herdr = inputs.herdr-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;

  # Pushes a foot window running herdr into exodus's Wayland session whenever
  # exodus has a graphical session up. exodus never connects here.
  # Receiving side: home/services/wayland/herdr-display-listener.nix on exodus.
  displayPush = pkgs.writeShellScript "herdr-display-push" ''
    set -u
    export PATH=${lib.makeBinPath [pkgs.bash pkgs.coreutils pkgs.socat pkgs.waypipe pkgs.foot herdr]}
    target=exodus
    port=6001
    sock="$XDG_RUNTIME_DIR/herdr-display.sock"

    # exodus only listens on $port while someone is logged in.
    session_up() {
      timeout 3 bash -c "exec 3<>/dev/tcp/$target/$port" 2>/dev/null
    }

    shown=0
    while true; do
      if session_up; then
        if [ "$shown" = 0 ]; then
          shown=1
          rm -f "$sock"
          # local unix socket for waypipe -> exodus's TCP bridge
          socat UNIX-LISTEN:"$sock",fork TCP:"$target":"$port" &
          hop=$!
          sleep 1
          waypipe --socket "$sock" --oneshot server -- foot --app-id=herdr-node -e herdr || true
          kill "$hop" 2>/dev/null
        fi
      else
        # logged out (or exodus away): re-arm for the next login
        shown=0
      fi
      sleep 10
    done
  '';
in {
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  networking = {
    hostName = "herdr-node";
    useDHCP = true;
    nameservers = ["192.168.1.1" "192.168.1.4"];
  };

  homelab.users.serverUser = {
    enable = true;
    username = "dodwmd";
    description = "Michael Dodwell";
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  # Prebuilt herdr binary; use their cachix to avoid rebuilding from source.
  nix.settings = {
    extra-substituters = ["https://herdr.cachix.org"];
    extra-trusted-public-keys = ["herdr.cachix.org-1:3nH7IStRsS0ASfdonA0DCRR2ZrSCeWitZ7Kwew0cR4I="];
  };

  # Keep dodwmd's user manager (and so herdr and the display push) alive without
  # a login, so sessions survive exodus logging out/rebooting.
  users.users.dodwmd.linger = true;

  systemd.user.services.herdr-server = {
    description = "herdr persistent session server";
    wantedBy = ["default.target"];
    # herdr spawns shells and agents; the user-unit default PATH has no git, node, claude...
    path = ["/run/current-system/sw"];
    serviceConfig = {
      ExecStart = "${herdr}/bin/herdr server";
      Restart = "always";
      RestartSec = 2;
    };
  };

  systemd.user.services.herdr-display = {
    description = "push a herdr foot window to exodus's Wayland session";
    wantedBy = ["default.target"];
    after = ["herdr-server.service"];
    wants = ["herdr-server.service"];
    serviceConfig = {
      ExecStart = "${displayPush}";
      Restart = "always";
      RestartSec = 5;
    };
  };

  # foot renders on this node, so fonts and config live here (not on exodus).
  fonts.packages = [pkgs.nerd-fonts.jetbrains-mono];
  environment.etc."xdg/foot/foot.ini".text = ''
    [main]
    font=JetBrainsMono Nerd Font:size=14
    term=xterm-256color
  '';

  # Containers: rootless podman for dodwmd (subuid/subgid come with isNormalUser).
  # Enables podman + docker compat + podman-compose via system/core/podman.nix.
  homelab.podman.enable = true;

  # checkov pulls in python-ecdsa (CVE-2024-23342, a timing side-channel in ECDSA
  # signing). checkov only scans files and never signs with it. Pinned to the exact
  # version so a bump fails the build and gets re-reviewed.
  nixpkgs.config.permittedInsecurePackages = ["python3.14-ecdsa-0.19.2"];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  environment.systemPackages = with pkgs; [
    herdr
    foot
    waypipe
    inputs.claude-code-nix.packages.${stdenv.hostPlatform.system}.default

    # Languages / runtimes
    nodejs # ships npm, npx, corepack
    yarn
    pnpm
    (python3.withPackages (ps: [ps.pip ps.virtualenv]))
    uv
    go

    # Infra
    opentofu
    terramate

    # Cloud providers + cluster access (AWS, GCP, Cloudflare, k3s)
    awscli2
    google-cloud-sdk
    wrangler
    cloudflared
    kubectl
    kubernetes-helm
    k9s
    kubectx
    kustomize
    tflint

    # Secrets
    sops
    age
    ssh-to-age

    # Git + forge CLIs
    git
    gh
    tea

    # Build + everyday tooling
    gnumake
    gcc
    tmux
    htop
    ripgrep
    fd
    jq
    yq-go
    curl
    wget
    unzip
    rsync
    dig
    openssl
    shellcheck

    # IaC / container security scanning
    trivy
    checkov
  ];

  system.stateVersion = "25.11";
}
