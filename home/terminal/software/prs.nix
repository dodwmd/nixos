{pkgs, ...}: let
  configFile = "prs/prs.yml";
  toYAML = (pkgs.formats.yaml {}).generate;
in {
  xdg.configFile."${configFile}".source = toYAML "prs.yml" {
    num = 20;
    repos = [
      "NixOS/nixpkgs"
      "sst/opencode"
      "zed-editor/zed"
      "charmbracelet/crush"
      "YaLTeR/niri"
      "noctalia-dev/noctalia-shell"
    ];
    query = ''
      type:pr repo:NixOS/nixpkgs state:open label:opencode linked:issue
    '';
  };
}
