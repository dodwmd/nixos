{
  pkgs,
  self,
  ...
}: let
  direnvConfigFile = "direnv/direnv.toml";
  direnvRcFile = "direnv/direnvrc";
in {
  users.users.dodwmd.packages = with pkgs; [
    alejandra
    deadnix
    statix
    self.packages.${stdenv.hostPlatform.system}.repl
    direnv
    nix-direnv
    gnumake  # For Makefile support
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
      '';

      "fish/conf.d/direnv.fish".source = pkgs.runCommand "direnv-fish-hook" {} ''
        ${pkgs.direnv}/bin/direnv hook fish > $out
      '';
    };
  };

  environment.sessionVariables = {
    DIRENV_LOG_FORMAT = "";
  };
}
