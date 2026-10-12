{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (import ../../../lib/mk-media-service.nix {inherit config lib pkgs;}) mkMediaService;
in
  mkMediaService {
    name = "bazarr";
    description = "Bazarr subtitle management";
    port = 6767;
    image = "lscr.io/linuxserver/bazarr:latest";
    supportsPostgresql = false; # Bazarr is SQLite only
  }
