{pkgs, ...}: {
  users.users.linuxmobile.packages = [pkgs.direnv];

  xdg.configFile."fish/conf.d/direnv.fish".source = pkgs.runCommand "direnv-fish-hook" {} ''
    ${pkgs.direnv}/bin/direnv hook fish > $out
  '';
}
