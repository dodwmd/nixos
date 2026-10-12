{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (import ../../../lib/mk-media-service.nix {inherit config lib pkgs;}) mkMediaService;
in
  mkMediaService {
    name = "cleanuparr";
    description = "Cleanuparr download queue cleanup";
    port = 11011;
    image = "ghcr.io/cleanuparr/cleanuparr:latest";
    # Cleanuparr supports Postgres, but via plain POSTGRES_HOST/USER/PASS/DB
    # env vars rather than the SONARR__POSTGRES__* convention this generator
    # produces, so leave it on its default SQLite instead of wiring that up.
    supportsPostgresql = false;
  }
