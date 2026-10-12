{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (import ../../../lib/mk-media-service.nix {inherit config lib pkgs;}) mkMediaService;
in
  mkMediaService {
    name = "lidarr";
    description = "Lidarr music management";
    port = 8686;
    image = "lscr.io/linuxserver/lidarr:latest";
    supportsPostgresql = true;
  }
