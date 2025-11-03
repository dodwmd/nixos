{inputs, ...}: {
  imports = [
    ./terminal
    inputs.nix-index-db.homeModules.nix-index
    inputs.stylix.homeModules.stylix
  ];
  home = {
    username = "linuxmobile";
    homeDirectory = "/home/linuxmobile";
    stateVersion = "24.05";
  };

  # disable manuals as nmd fails to build often
  manual = {
    html.enable = false;
    json.enable = false;
    manpages.enable = false;
  };

  # let HM manage itself when in standalone mode
  programs.home-manager.enable = true;

  programs.nix-index = {
    enable = true;
    # enableNushellIntegration = true;
  };

  stylix = {
    enable = true;
    autoEnable = false;
    polarity = "dark";
    opacity = {
      popups = 1.0;
      terminal = 1.0;
    };

    base16Scheme = "${inputs.self}/home/shared/colors/oxocarbon-dark.yml";

    targets = {
      starship.enable = true;
      vesktop.enable = true;
      yazi.enable = true;
    };
  };
}
