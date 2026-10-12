{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (import ../../../lib/mk-media-service.nix {inherit config lib pkgs;}) mkMediaService;
in
  mkMediaService {
    name = "radarr";
    description = "Radarr movie management";
    port = 7878;
    image = "lscr.io/linuxserver/radarr:latest";
    supportsPostgresql = true;
  }
