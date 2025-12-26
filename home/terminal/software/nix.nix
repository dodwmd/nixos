{
  pkgs,
  self,
  ...
}: let
  direnvConfigFile = "direnv/direnv.toml";
  direnvRcFile = "direnv/direnvrc";
in {
  users.users.linuxmobile.packages = with pkgs; [
    alejandra
    deadnix
    statix
    self.packages.${stdenv.hostPlatform.system}.repl
    direnv
    nix-direnv
  ];

  # Direnv configuration
  xdg = {
    configFile = {
      "${direnvConfigFile}".source = (pkgs.formats.toml {}).generate "direnv.toml" {
        global = {
          log_format = "-";
          log_filter = "^$";
        };
      };
      # Direnv stdlib configuration
      "${direnvRcFile}".text = ''
        # Nix integration
        source ${pkgs.nix-direnv}/share/nix-direnv/direnvrc

        # Custom stdlib
        use flake

        # Shell integration
        layout python3 use python3
        layout node use node
        layout ruby use ruby
      '';

      # Fish shell integration
      "fish/conf.d/direnv.fish".text = ''
        ${pkgs.direnv}/bin/direnv hook fish | source
      '';
    };
  };

  environment.sessionVariables = {
    DIRENV_LOG_FORMAT = "";
  };
}
