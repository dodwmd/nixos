{pkgs, ...}: let
  configFile = "gh/config.yml";
  hostsFile = "gh/hosts.yml";
  toYAML = (pkgs.formats.yaml {}).generate;
in {
  users.users.linuxmobile.packages = with pkgs; [
    gh
  ];

  xdg.configFile."${configFile}".source = toYAML "config.yml" {
    version = 1;
    git_protocol = "https";
    editor = "hx";
    prompt = "enabled";
    prefer_editor_prompt = "disabled";
    pager = "less -FR";
    aliases = {
      co = "pr checkout";
    };
    http_unix_socket = "";
    browser = "helium";
  };

  # Create hosts.yml with placeholder for OAuth token
  xdg.configFile."${hostsFile}".text = ''
    github.com:
      git_protocol: https
      users:
        linuxmobile:
          oauth_token: "REPLACE_WITH_YOUR_TOKEN"
      user: linuxmobile
      oauth_token: "REPLACE_WITH_YOUR_TOKEN"
  '';
}
