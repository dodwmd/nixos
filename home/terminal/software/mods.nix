{pkgs, ...}: let
  configFile = "mods/mods.yml";
  toYAML = (pkgs.formats.yaml {}).generate;
in {
  users.users.dodwmd.packages = with pkgs; [
    mods
  ];

  xdg.configFile = {
    "${configFile}".source = toYAML "mods.yml" {
      default-model = "google/gemma-3n-e4b-it:free";
      default-api = "openrouter";
      format-text = {
        markdown = "{{ index .Config.FormatText \"markdown\" }}";
        json = "{{ index .Config.FormatText \"json\" }}";
      };
      roles = {
        default = [];
      };
      format = false;
      role = "default";
      raw = false;
      quiet = false;
      temp = 1.0;
      topp = 1.0;
      topk = 50;
      no-limit = false;
      word-wrap = 80;
      include-prompt-args = false;
      include-prompt = 0;
      max-retries = 5;
      fanciness = 10;
      status-text = "Generating";
      theme = "charm";
      max-input-chars = 12250;
      max-completion-tokens = 100;
      apis = {
        openrouter = {
          base-url = "https://openrouter.ai/api/v1";
          api-key = "";
          api-key-env = "OPENROUTER_API_KEY";
          models = {
            "kwaipilot/kat-coder-pro:free" = {
              aliases = ["kat-coder"];
              max-input-chars = 256000;
            };
            "openrouter/polaris-alpha" = {
              aliases = ["polaris"];
              max-input-chars = 256000;
            };
            "deepseek/deepseek-chat-v3.1:free" = {
              aliases = ["deepseek"];
              max-input-chars = 164000;
            };
            "openai/gpt-oss-20b:free" = {
              aliases = ["gpt"];
              max-input-chars = 131000;
            };
            "qwen/qwen3-coder:free" = {
              aliases = ["qwen"];
              max-input-chars = 256000;
            };
            "google/gemma-3n-e4b-it:free" = {
              aliases = ["gemma"];
              max-input-chars = 8000;
            };
            "meta-llama/llama-4-maverick:free" = {
              aliases = ["maverick"];
              max-input-chars = 128000;
            };
            "moonshotai/kimi-k2:free" = {
              aliases = ["kimi"];
              max-input-chars = 33000;
            };
          };
        };
      };
    };
    "fish/completions/mods.fish".source = "${pkgs.mods}/share/fish/vendor_completions.d/mods.fish";
  };
}
