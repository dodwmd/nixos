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
    paths = [pkgs.zed-editor] ++ lspPackages;
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      rm $out/bin/zeditor
      makeWrapper ${pkgs.zed-editor}/bin/zeditor $out/bin/zeditor \
        --prefix PATH : ${pkgs.lib.makeBinPath lspPackages}
    '';
  };
in {
  users.users.linuxmobile.packages = [
    zedWithLSP
  ];
}
