{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (import ../../../lib/mk-media-service.nix {inherit config lib pkgs;}) mkMediaService;
in
  mkMediaService {
    name = "sonarr";
    description = "Sonarr TV show management";
    port = 8989;
    image = "lscr.io/linuxserver/sonarr:latest";
    supportsPostgresql = true;
    extraVolumes = [
      "/nix/store:/nix/store:ro"
      "${pkgs.ffmpeg-headless}/bin/ffprobe:/usr/bin/ffprobe:ro"
    ];
  }
