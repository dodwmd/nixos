{pkgs, ...}: let
  toYAML = (pkgs.formats.yaml {}).generate;
  
  ghConfig = toYAML "config.yml" {
    version = 1;
    git_protocol = "https";
    editor = "nvim";
    prompt = "enabled";
    prefer_editor_prompt = "disabled";
    pager = "less -FR";
    aliases = {
      co = "pr checkout";
    };
    http_unix_socket = "";
    browser = "brave";
  };
  
  ghHosts = pkgs.writeText "gh-hosts.yml" ''
    github.com:
      git_protocol: https
      user: dodwmd
  '';
in {
  users.users.dodwmd.packages = with pkgs; [
    gh
  ];

  # Create gh config files using activation script
  system.activationScripts.gh-config = ''
    mkdir -p /home/dodwmd/.config/gh
    cp ${ghConfig} /home/dodwmd/.config/gh/config.yml
    cp ${ghHosts} /home/dodwmd/.config/gh/hosts.yml
    chown -R dodwmd:users /home/dodwmd/.config/gh
    chmod 644 /home/dodwmd/.config/gh/*.yml
  '';
}
