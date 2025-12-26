{pkgs, ...}: let
  lspPackages = with pkgs; [
    astro-language-server
    biome
    emmet-ls
    gopls
    marksman
    nil
    nixd
    nodePackages.typescript-language-server
    typescript
    vscode-langservers-extracted
    yaml-language-server
  ];

  zedWithLSP = pkgs.symlinkJoin {
    name = "zed-with-lsp";
    paths = [pkgs.zed] ++ lspPackages;
    buildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/zeditor \
        --prefix PATH : ${pkgs.symlinkJoin {
        name = "helix-lsp-bin";
        paths = lspPackages;
      }}/bin
    '';
  };
in {
  users.users.linuxmobile.packages = [
    zedWithLSP
  ];
}
