{
  config,
  ...
}: {
  imports = [
    ./emulators
    ./shell
    ./software
  ];
  environment.sessionVariables = {
    LESSHISTFILE = "${config.xdg.cacheHome}/less/history";
    LESKEY = "${config.xdg.configHome}/less/lesskey";
    XAUTHORITY = "/run/user/1000/Xauthority";

    EDITOR = "hx";
    DIRENV_LOG_FORMAT = "";

    # auto-run programs using nix-index-database
    NIX_AUTO_RUN = "1";
  };
}
