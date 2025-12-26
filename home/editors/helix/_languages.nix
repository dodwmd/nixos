{pkgs, ...}: let
  formatters = {
    alejandra = "${pkgs.alejandra}/bin/alejandra";
    biome = "biome";
    goimports = "${pkgs.gosimports}/bin/goimports";
    nushell = "${pkgs.nushell}/bin/nu";
    prettier = "${pkgs.nodePackages.prettier}/bin/prettier";
    shfmt = "${pkgs.shfmt}/bin/shfmt";
    stylua = "${pkgs.stylua}/bin/stylua";
  };

  languageServers = {
    astro-ls = "${pkgs.astro-language-server}/bin/astro-ls";
    biome-lsp = "biome";
    css-languageserver = "${pkgs.vscode-langservers-extracted}/bin/css-languageserver";
    emmet-ls = "${pkgs.emmet-ls}/bin/emmet-ls";
    gopls = "${pkgs.gopls}/bin/gopls";
    lua-language-server = "${pkgs.lua-language-server}/bin/lua-language-server";
    marksman = "${pkgs.marksman}/bin/marksman";
    nil = "${pkgs.nil}/bin/nil";
    yaml-language-server = "${pkgs.yaml-language-server}/bin/yaml-language-server";
  };
in
  (pkgs.formats.toml {}).generate "languages.toml" {
    language = [
      {
        name = "bash";
        auto-format = true;
        formatter = {
          command = formatters.shfmt;
          args = ["-i" "2"];
        };
      }
      {
        name = "go";
        auto-format = true;
        formatter = {
          command = formatters.goimports;
        };
        language-servers = ["gopls"];
      }
      {
        name = "yaml";
        auto-format = true;
        formatter = {
          command = formatters.prettier;
          args = ["--parser" "yaml"];
        };
        language-servers = ["yaml-language-server"];
      }
      {
        name = "astro";
        auto-format = true;
        formatter = {
          command = formatters.prettier;
          args = ["--parser" "astro"];
        };
        language-servers = ["astro-ls"];
      }
      {
        name = "javascript";
        auto-format = true;
        formatter = {
          command = formatters.biome;
          args = ["format" "--stdin-file-path" "a.js"];
        };
        language-servers = [
          {
            name = "typescript-language-server";
            except-features = ["format"];
          }
          "biome-lsp"
        ];
      }
      {
        name = "json";
        formatter = {
          command = formatters.biome;
          args = ["format" "json"];
        };
        language-servers = [
          {
            name = "typescript-language-server";
            except-features = ["format"];
          }
          "biome-lsp"
        ];
      }
      {
        name = "jsx";
        auto-format = true;
        formatter = {
          command = formatters.biome;
          args = ["format" "--stdin-file-path" "a.jsx"];
        };
        language-servers = [
          {
            name = "typescript-language-server";
            except-features = ["format"];
          }
          "biome-lsp"
        ];
      }
      {
        name = "markdown";
        auto-format = true;
        formatter = {
          command = formatters.prettier;
          args = ["--parser" "markdown"];
        };
        language-servers = ["marksman"];
      }
      {
        name = "typescript";
        auto-format = true;
        formatter = {
          command = formatters.biome;
          args = ["format" "--stdin-file-path" "a.ts"];
        };
        language-servers = [
          {
            name = "typescript-language-server";
            except-features = ["format"];
          }
          "biome-lsp"
        ];
      }
      {
        name = "tsx";
        auto-format = true;
        formatter = {
          command = formatters.biome;
          args = ["format" "--stdin-file-path" "a.tsx"];
        };
        language-servers = [
          {
            name = "typescript-language-server";
            except-features = ["format"];
          }
          "biome-lsp"
        ];
      }
      {
        name = "lua";
        auto-format = true;
        formatter = {
          command = formatters.stylua;
          args = ["-"];
        };
        language-servers = ["lua-language-server"];
      }
      {
        name = "nu";
        auto-format = true;
        formatter = {
          command = formatters.nushell;
          args = ["--format"];
        };
      }
      {
        name = "nix";
        auto-format = true;
        formatter = {
          command = formatters.alejandra;
          args = ["-q"];
        };
        language-servers = ["nil"];
      }
    ];

    language-server = {
      astro-ls = {
        command = languageServers.astro-ls;
        args = ["--stdio"];
      };
      biome-lsp = {
        command = languageServers.biome-lsp;
        args = ["lsp-proxy"];
      };
      emmet-ls = {
        command = languageServers.emmet-ls;
        args = ["--stdio"];
      };
      nil = {
        command = languageServers.nil;
        config.nil.formatting.command = [formatters.alejandra "-q"];
      };
      vscode-css-language-server = {
        command = languageServers.css-languageserver;
        args = ["--stdio"];
        config = {
          provideFormatter = true;
          css.validate.enable = true;
          scss.validate.enable = true;
        };
      };
      lua-language-server = {
        command = languageServers.lua-language-server;
        config = {
          runtime = {
            version = "LuaJIT";
            path = [
              "?.lua"
              "?/init.lua"
            ];
          };
          diagnostics = {
            globals = ["vim"];
          };
          workspace = {
            library = {};
            maxPreload = 2000;
            preloadFileSize = 1000;
            checkThirdParty = false;
          };
          telemetry = {
            enable = false;
          };
          format = {
            enable = true;
            defaultConfig = {
              indent_style = "space";
              indent_size = "2";
            };
          };
        };
      };
      gopls = {
        command = languageServers.gopls;
      };
      yaml-language-server = {
        command = languageServers.yaml-language-server;
        args = ["--stdio"];
      };
      marksman = {
        command = languageServers.marksman;
      };
    };
  }
