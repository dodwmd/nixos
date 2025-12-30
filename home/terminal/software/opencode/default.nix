{pkgs, ...}: let
  languages = import ./_languages.nix {inherit pkgs;};
  providers = import ./_providers.nix;
  skills = import ./_skills.nix {inherit pkgs;};

  opencodeEnv = pkgs.buildEnv {
    name = "opencode-env";
    paths =
      languages.packages
      ++ skills.packages;
  };

  opencodeInitScript = pkgs.writeShellScript "opencode-init" ''
    mkdir -p "$HOME/.local/cache/opencode/node_modules/@opencode-ai"
    mkdir -p "$HOME/.config/opencode/node_modules/@opencode-ai"

    if [ -d "$HOME/.config/opencode/node_modules/@opencode-ai/plugin" ]; then
      if [ ! -L "$HOME/.local/cache/opencode/node_modules/@opencode-ai/plugin" ]; then
        ln -sf "$HOME/.config/opencode/node_modules/@opencode-ai/plugin" \
               "$HOME/.local/cache/opencode/node_modules/@opencode-ai/plugin"
      fi
    fi

    exec ${pkgs.opencode}/bin/opencode "$@"
  '';

  opencodeWrapped =
    pkgs.runCommand "opencode-wrapped" {
      buildInputs = [pkgs.makeWrapper];
    } ''
      mkdir -p $out/bin
      makeWrapper ${opencodeInitScript} $out/bin/opencode \
        --prefix PATH : ${opencodeEnv}/bin \
        --set OPENCODE_LIBC ${pkgs.glibc}/lib/libc.so.6
    '';

  configFile = "opencode/config.json";
in {
  users.users.linuxmobile.packages = [
    opencodeWrapped
  ];

  xdg.configFile = {
    "${configFile}".text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      plugin = ["opencode-antigravity-auth@1.2.6"];
      small_model = "google/gemma-3n-e4b-it:free";
      autoupdate = false;
      share = "disabled";

      disabled_providers = [
        "amazon-bedrock"
        "anthropic"
        "azure-openai"
        "azure-cognitive-services"
        "baseten"
        "cerebras"
        "cloudflare-ai-gateway"
        "cortecs"
        "deepseek"
        "deep-infra"
        "fireworks-ai"
        "github-copilot"
        "google-vertex-ai"
        "groq"
        "hugging-face"
        "helicone"
        "llama.cpp"
        "io-net"
        "lmstudio"
        "moonshot-ai"
        "nebius-token-factory"
        "ollama"
        "ollama-cloud"
        "openai"
        "opencode-zen"
        "sap-ai-core"
        "ovhcloud-ai-endpoints"
        "together-ai"
        "venice-ai"
        "xai"
        "zai"
        "zenmux"
      ];

      enabled_providers = ["openrouter" "google"];

      mcp = {
        gh_grep = {
          type = "remote";
          url = "https://mcp.grep.app/";
          enabled = true;
          timeout = 10000;
        };
        exa = {
          enabled = true;
          type = "local";
          command = ["bunx" "exa-mcp-server"];
          timeout = 10000;
        };
        deepwiki = {
          type = "remote";
          url = "https://mcp.deepwiki.com/mcp";
          enabled = true;
          timeout = 10000;
        };
        context7 = {
          type = "remote";
          url = "https://mcp.context7.com/mcp";
          enabled = true;
          timeout = 10000;
        };
      };

      formatter = languages.formatter;
      lsp = languages.lsp;
      provider = providers.config;
    };

    "opencode/skill".source = skills.skillsSource + "/skill";
  };
}
