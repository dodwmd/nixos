{ pkgs ? import <nixpkgs> {} }:

let
  claude-code-flake = builtins.getFlake "github:sadjow/claude-code-nix";
  claude-code = claude-code-flake.packages.${pkgs.system}.default;
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
    export EXA_API_KEY="6a29d3cc-c865-4fb8-98c4-efe391549b1b"  # Get from https://dashboard.exa.ai/api-keys
    #export CLAUDE_CODE_OAUTH_TOKEN="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"
  '';
}
