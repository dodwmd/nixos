{
  config,
  pkgs,
  ...
}: let
  configFile = "yazi/yazi.toml";
  toTOML = (pkgs.formats.toml {}).generate;
in {
  users.users.dodwmd.packages = [pkgs.yazi];
  xdg.configFile."${configFile}".source = toTOML "yazi.toml" {
    mgr = {
      layout = [1 4 3];
      sort_by = "alphabetical";
      sort_sensitive = true;
      sort_reverse = false;
      sort_dir_first = true;
      linemode = "none";
      show_hidden = false;
      show_symlink = true;
    };
    preview = {
      tab_size = 2;
      max_width = 600;
      max_height = 900;
      cache_dir = "${config.xdg.cacheHome}";
    };
    # flavor.dark previously pointed at "noctalia", a flavor that was meant to
    # be generated at runtime by noctalia-shell (disabled — see
    # home/services/wayland/noctalia.nix). No matching
    # ~/.config/yazi/flavors/noctalia.yazi/ was ever checked in, so this
    # resolved to nothing; left unset to use yazi's built-in default instead
    # of a dangling reference. Reintroduce once a real noctalia.yazi flavor
    # is authored (yazi's flavor.toml schema needs verifying against a live
    # yazi, unlike helix's theme format).
  };
}
