{pkgs, ...}: {
  users.users.linuxmobile.packages = with pkgs; [
    fzf
  ];

  xdg.configFile = {
    "fish/conf.d/fzf.fish".source = pkgs.symlinkJoin {
      name = "fzf.fish";
      paths = ["${pkgs.fzf}/share/fzf"];
      target = "key-bindings.fish";
    };

    "fish/conf.d/fzf-extra.fish".text = ''
      set -gx FZF_DEFAULT_OPTS "--reverse --height 40% --border"
    '';
  };
}
