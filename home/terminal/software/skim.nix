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

  xdg.configFile."${configFile}".text = ''
    preview-window: "right:60%"
    # General settings
    multi: true
    tiebreak: "index,begin,end,length"
  '';

  xdg.configFile."fish/conf.d/skim.fish".text = ''
    # Skim keybindings for Fish
    function fish_user_key_bindings
      bind \cf sk-tmux
      bind \cr skim_cd
    end

    # Skim functions
    function sk-tmux
      ${skimDefault}/bin/sk --multi | read -l line
      and tmux neww $line
    end

    function skim_cd
      ${skimCd}/bin/sk-cd | read -l dir
      and cd "$dir"
    end
  '';
}
