{pkgs, ...}: {
  environment = {
    shells = [pkgs.fish];
    pathsToLink = ["/share/fish"];
  };

  programs = {
    less.enable = true;

    fish = {
      enable = true;
    };
  };
}
