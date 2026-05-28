{ pkgs ? import <nixpkgs> {} }:

let
  claude-code-flake = builtins.getFlake "github:sadjow/claude-code-nix";
  claude-code = claude-code-flake.packages.${pkgs.stdenv.hostPlatform.system}.default;
in

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Additional development tools
    git
    curl
    jq

    # Claude Code from flake
    claude-code

    # TTS dependencies (for AgentVibes/Piper)
    stdenv.cc.cc.lib  # Provides libstdc++.so.6 for Python packages like numpy
    zlib              # Provides libz.so.1 for numpy
  ];

  shellHook = ''
    export GIT_AUTHOR_NAME="Michael Dodwell"
    export GIT_AUTHOR_EMAIL="1372930+dodwmd@users.noreply.github.com"
    export GIT_COMMITTER_NAME="Michael Dodwell"
    export GIT_COMMITTER_EMAIL="1372930+dodwmd@users.noreply.github.com"
    export PATH="$(pwd)/node_modules/.bin:$PATH"
    # export EXA_API_KEY="..."  # Get from https://dashboard.exa.ai/api-keys (do not commit)
  '';
}
