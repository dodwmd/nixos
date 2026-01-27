{
  config,
  lib,
  pkgs,
  ...
}: let
  # Import the media service generator
  mkMediaService = (import ../../../lib/mk-media-service.nix {inherit config lib pkgs;}).mkMediaService;

  # Define all media services with their specific configuration
  services = [
    (mkMediaService {
      name = "sonarr";
      description = "Sonarr TV show management";
      port = 8989;
      image = "lscr.io/linuxserver/sonarr:latest";
    })

    (mkMediaService {
      name = "radarr";
      description = "Radarr movie management";
      port = 7878;
      image = "lscr.io/linuxserver/radarr:latest";
    })

    (mkMediaService {
      name = "prowlarr";
      description = "Prowlarr indexer management";
      port = 9696;
      image = "lscr.io/linuxserver/prowlarr:latest";
    })

    (mkMediaService {
      name = "lidarr";
      description = "Lidarr music management";
      port = 8686;
      image = "lscr.io/linuxserver/lidarr:latest";
    })

    (mkMediaService {
      name = "readarr";
      description = "Readarr ebook management";
      port = 8787;
      image = "lscr.io/linuxserver/readarr:latest";
    })

    (mkMediaService {
      name = "bazarr";
      description = "Bazarr subtitle management";
      port = 6767;
      image = "lscr.io/linuxserver/bazarr:latest";
    })

    (mkMediaService {
      name = "jellyseerr";
      description = "Jellyseerr media request management";
      port = 5055;
      image = "fallenbagel/jellyseerr:latest";
    })
  ];
in {
  imports = services;
}
