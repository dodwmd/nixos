{
  config,
  pkgs,
  ...
}: {
  users.users.linuxmobile.packages = with pkgs; [
    carapace
    carapace-bridge
    zsh
    bash
    inshellisense
  ];

  xdg.configFile."carapace/carapace.toml".text = ''
    [integrations.fish]
    enabled = true
  '';

  environment.sessionVariables = {
    CARAPACE_BRIDGES = "fish,zsh,bash,inshellisense";
    CARAPACE_CACHE_DIR = "${config.xdg.cacheHome}/carapace";
  };

  xdg.configFile."fish/conf.d/carapace.fish".text = ''
    set -Ux CARAPACE_BRIDGES 'zsh,fish,bash,inshellisense'

    if status --is-interactive
      ${pkgs.carapace}/bin/carapace _carapace | source
    end
  '';
}
