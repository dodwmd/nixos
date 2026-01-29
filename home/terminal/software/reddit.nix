{pkgs, ...}: let
  configFile = "reddittui/reddittui.toml";
  toTOML = (pkgs.formats.toml {}).generate;

  mySubreddits = [
    "archlinux"
    "artixlinux"
    "bugbounty"
    "CLI"
    "commandline"
    "esLinux"
    "gnome"
    "google_antigravity"
    "HeliumBrowserHQ"
    "HelixEditor"
    "hyprland"
    "kde"
    "neovim"
    "niri"
    "NixOS"
    "obs"
    "qutebrowser"
    "redteamsec"
    "terminal_porn"
    "unixporn"
    "UsabilityPorn"
    "zellij"
  ];

  redditLauncher = pkgs.writeShellScriptBin "reddit" ''
    exec ${pkgs.reddit-tui}/bin/reddittui --subreddit ${builtins.concatStringsSep "+" mySubreddits} "$@"
  '';
in {
  users.users.linuxmobile.packages = [
    pkgs.reddit-tui
    redditLauncher
  ];

  xdg.configFile = {
    "${configFile}".source = toTOML "reddittui.toml" {
      filter = {
        subreddits = [
          "ArAutos"
          "ArGaming"
          "argentina"
          "AskArgentina"
          "BuenosAires"
          "fulbo"
          "PreguntasReddit"
        ];
        keywords = ["argentina" "futbol" "soccer" "politics" "politica"];
      };
    };
  };
}
