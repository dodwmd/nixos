{pkgs, ...}: let
  configFile = "skim/skimrc";

  skimDefault = pkgs.symlinkJoin {
    name = "sk-default";
    paths = [pkgs.skim];
    buildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/sk \
        --add-flags "--cmd '${pkgs.ripgrep}/bin/rg --files --hidden'"
    '';
  };

  skimCd = pkgs.writeShellScriptBin "sk-cd" ''
    exec ${pkgs.skim}/bin/sk \
      --preview "${pkgs.eza}/bin/eza --icons --git --color always -T -L 3 {} | head -200" \
      --exact \
      "$@"
  '';
in {
  users.users.linuxmobile.packages = with pkgs; [
    skim
    ripgrep
    eza
    skimDefault
    skimCd
  ];

  xdg.configFile = {
    "${configFile}".text = ''
      preview-window: "right:60%"
      # General settings
      multi: true
      tiebreak: "index,begin,end,length"
    '';
    "fish/conf.d/skim.fish".text = ''
      source ${pkgs.skim}/share/skim/key-bindings.fish
    '';
  };
}
