{pkgs, ...}: {
  users.users.dodwmd.packages = [pkgs.autojump];

  xdg.configFile."fish/conf.d/autojump.fish".source = "${pkgs.autojump}/share/autojump/autojump.fish";
}
