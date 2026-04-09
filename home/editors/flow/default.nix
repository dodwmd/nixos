{
  pkgs,
  ...
}: let
  lspPackages = with pkgs; [
    # Language Server Protocol
    astro-language-server
    biome
    marksman
    nil
    tailwindcss-language-server
    vue-language-server
    zls

    # Formatters
    alejandra
    oxfmt
    shfmt

    # Node.js (often required for LSP node integration)
    nodejs
  ];

  lspBinPath = pkgs.buildEnv {
    name = "flow-lsp-env";
    paths = lspPackages;
    pathsToLink = ["/bin"];
  };

  flowWithLSP = pkgs.symlinkJoin {
    name = "flow-with-lsp";
    paths = [pkgs.flow-control];
    buildInputs = [pkgs.makeWrapper];
    postBuild = ''
      rm -rf $out/bin
      mkdir -p $out/bin
      makeWrapper ${pkgs.flow-control}/bin/flow $out/bin/flow \
        --prefix PATH : ${lspBinPath}/bin

      for bin in ${pkgs.flow-control}/bin/*; do
        if [ "$(basename $bin)" != "flow" ]; then
          ln -s $bin $out/bin/$(basename $bin)
        fi
      done
    '';
  };
in {
  users.users.linuxmobile.packages = [
    flowWithLSP
  ];
}
