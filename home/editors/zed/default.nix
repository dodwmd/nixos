{inputs, pkgs, ...}: {
  home.packages = with pkgs; [
    nodejs
    biome
    vue-language-server
    vscode-langservers-extracted
    nil
    typescript-language-server
    typescript
    inputs.zed.packages.${pkgs.system}.zed-editor-bin-fhs
    astro-language-server
  ];
}
