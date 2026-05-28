{
  config,
  pkgs,
  ...
}: let
  configFile = "cliphist/cliphistrc";
in {
  users.users.dodwmd.packages = with pkgs; [
    cliphist
    wl-clipboard
  ];

  # Create a simple script to start cliphist - user can run manually or add to their session
  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "start-cliphist" ''
      ${wl-clipboard}/bin/wl-paste --watch ${cliphist}/bin/cliphist -max-dedupe-search 10 -max-items 500 store &
    '')
  ];

  xdg.configFile."${configFile}".text = ''
    allow_images=true
    max_entries=500
    database=${config.xdg.dataHome}/cliphist/db
  '';
}
