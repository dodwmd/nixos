{pkgs, ...}: let
  lspPackages = with pkgs; [
    # Language Server Protocol
    astro-language-server
    biome
    marksman
    nil
    tailwindcss-language-server
    vue-language-server

    # Formatters
    alejandra
    oxfmt
    shfmt
  ];

  lspBinPath = pkgs.buildEnv {
    name = "zed-lsp-env";
    paths = lspPackages;
    pathsToLink = ["/bin"];
  };

  zedWithLSP =
    pkgs.runCommand "zed-with-lsp" {
      buildInputs = [pkgs.makeWrapper];
    } ''
      mkdir -p $out/bin
      makeWrapper ${pkgs.zed-editor}/bin/zeditor $out/bin/zeditor \
        --prefix PATH : ${lspBinPath}/bin


      for bin in ${pkgs.zed-editor}/bin/*; do
        if [ "$(basename $bin)" != "zeditor" ]; then
          ln -s $bin $out/bin/$(basename $bin)
        fi
      done
    '';
in {
  home.packages = [
    zedWithLSP
  ];
}
