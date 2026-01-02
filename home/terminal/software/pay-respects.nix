{pkgs, ...}: {
  home.packages = [pkgs.pay-respects];

  xdg.configFile."fish/conf.d/pay-respects.fish".source = pkgs.runCommand "pay-respects-init" {} ''
    ${pkgs.pay-respects}/bin/pay-respects fish --alias > $out
  '';
}
