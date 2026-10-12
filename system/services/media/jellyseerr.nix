{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (import ../../../lib/mk-media-service.nix {inherit config lib pkgs;}) mkMediaService;
in
  mkMediaService {
    name = "jellyseerr";
    description = "Jellyseerr media request management";
    port = 5055;
    image = "docker.io/fallenbagel/jellyseerr:latest";
    configMountPath = "/app/config";
    supportsPostgresql = false; # Jellyseerr is SQLite only
  }
