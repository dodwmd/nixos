{pkgs, ...}: {
  users.users.linuxmobile.packages = with pkgs; [
    fzf
  ];

  xdg.configFile = {
    "fish/conf.d/fzf.fish".source = pkgs.runCommand "fzf-fish-init" {} ''
      ${pkgs.fzf}/bin/fzf --fish > $out
    '';
    configFile."fish/conf.d/fzf-extra.fish".text = ''
      set -gx FZF_DEFAULT_OPTS "--reverse --height 40% --border"
    '';
  };
}
