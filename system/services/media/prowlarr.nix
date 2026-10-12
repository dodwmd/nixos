{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (import ../../../lib/mk-media-service.nix {inherit config lib pkgs;}) mkMediaService;
in
  mkMediaService {
    name = "prowlarr";
    description = "Prowlarr indexer management";
    port = 9696;
    image = "lscr.io/linuxserver/prowlarr:latest";
    supportsPostgresql = false; # Prowlarr doesn't support env var config for PostgreSQL
  }
