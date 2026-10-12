{config, ...}: let
  # Authelia forward-auth for nexus's standalone nginx (services.nginx, not
  # k8s ingress-nginx). nexus isn't part of the k3s cluster, so Authelia is
  # reached over its public hostname rather than an in-cluster service name.
  # See ~/code/homelab/k3s/apps/authelia for the Authelia deployment itself.
  autheliaAuthRequestConfig = ''
    auth_request /internal/authelia/authz;

    auth_request_set $user $upstream_http_remote_user;
    auth_request_set $groups $upstream_http_remote_groups;
    auth_request_set $name $upstream_http_remote_name;
    auth_request_set $email $upstream_http_remote_email;

    proxy_set_header Remote-User $user;
    proxy_set_header Remote-Groups $groups;
    proxy_set_header Remote-Name $name;
    proxy_set_header Remote-Email $email;

    auth_request_set $redirection_url $upstream_http_location;
    error_page 401 =302 $redirection_url;
  '';

  autheliaInternalLocation = {
    extraConfig = ''
      internal;
      resolver 192.168.1.1 valid=30s;
      set $upstream_authelia https://auth.home.dodwell.us/api/authz/auth-request;
      proxy_pass $upstream_authelia;

      # Required so the (SNI-routed) k3s ingress-nginx sends us Authelia's
      # vhost instead of whatever the default backend happens to be.
      proxy_ssl_server_name on;

      proxy_set_header X-Original-Method $request_method;
      proxy_set_header X-Original-URL $scheme://$host$request_uri;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header Content-Length "";
      proxy_set_header Connection "";

      proxy_pass_request_body off;
      proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
      proxy_redirect http:// $scheme://;
      proxy_http_version 1.1;
    '';
  };
in {
  # NGINX reverse proxy with ACME
  homelab.nginx-proxy = {
    enable = true;
    email = "michael@dodwell.us";
    dnsProvider = "cloudflare";
    credentialFiles."CF_DNS_API_TOKEN_FILE" = "/var/lib/acme/cloudflare-dns-api-token";

    virtualHosts = {
      "sonarr.home.dodwell.us" = {
        proxyPass = "http://127.0.0.1:8989";
        extraConfig =
          ''
            proxy_read_timeout 300s;
            proxy_connect_timeout 300s;
            proxy_send_timeout 300s;
            proxy_buffers 16 256k;
            proxy_buffer_size 256k;
            proxy_busy_buffers_size 512k;
            client_max_body_size 0;
          ''
          + autheliaAuthRequestConfig;
        extraLocations."/internal/authelia/authz" = autheliaInternalLocation;
      };
      "radarr.home.dodwell.us" = {
        proxyPass = "http://127.0.0.1:7878";
        extraConfig =
          ''
            proxy_read_timeout 300s;
            proxy_connect_timeout 300s;
            proxy_send_timeout 300s;
            proxy_buffers 16 256k;
            proxy_buffer_size 256k;
            proxy_busy_buffers_size 512k;
            client_max_body_size 0;
          ''
          + autheliaAuthRequestConfig;
        extraLocations."/internal/authelia/authz" = autheliaInternalLocation;
      };
      "prowlarr.home.dodwell.us" = {
        proxyPass = "http://127.0.0.1:9696";
        extraConfig = autheliaAuthRequestConfig;
        extraLocations."/internal/authelia/authz" = autheliaInternalLocation;
      };
      "lidarr.home.dodwell.us" = {
        proxyPass = "http://127.0.0.1:8686";
        extraConfig = autheliaAuthRequestConfig;
        extraLocations."/internal/authelia/authz" = autheliaInternalLocation;
      };
      "bazarr.home.dodwell.us" = {
        proxyPass = "http://127.0.0.1:6767";
        extraConfig = autheliaAuthRequestConfig;
        extraLocations."/internal/authelia/authz" = autheliaInternalLocation;
      };
      "cleanuparr.home.dodwell.us" = {
        proxyPass = "http://127.0.0.1:11011";
        extraConfig = autheliaAuthRequestConfig;
        extraLocations."/internal/authelia/authz" = autheliaInternalLocation;
      };
      "tdarr.home.dodwell.us" = {
        proxyPass = "http://127.0.0.1:8265";
        extraConfig = autheliaAuthRequestConfig;
        extraLocations."/internal/authelia/authz" = autheliaInternalLocation;
      };
      "download.home.dodwell.us" = {
        proxyPass = "http://127.0.0.1:8090";
        extraConfig =
          ''
            client_max_body_size 0;
          ''
          + autheliaAuthRequestConfig;
        extraLocations."/internal/authelia/authz" = autheliaInternalLocation;
      };
      "jellyfin.home.dodwell.us" = {
        proxyPass = "http://127.0.0.1:8096";
        extraConfig = ''
          proxy_buffering off;
          client_max_body_size 0;

          # Jellyfin-specific headers
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $host;

          # Disable buffering for SSE
          proxy_set_header Connection "";
          chunked_transfer_encoding on;
        '';
      };
      "jellyseerr.home.dodwell.us" = {
        proxyPass = "http://127.0.0.1:5055";
      };
      "adguard.home.dodwell.us" = {
        proxyPass = "http://127.0.0.1:8053";
      };
      "netdata.home.dodwell.us" = {
        proxyPass = "http://127.0.0.1:19999";
      };
      "nexus.home.dodwell.us" = {
        proxyPass = "http://127.0.0.1:3000";
      };
    };
  };

  # Redirect requests.home.dodwell.us -> jellyseerr.home.dodwell.us
  security.acme.certs."requests.home.dodwell.us" = {
    dnsProvider = config.homelab.nginx-proxy.dnsProvider;
    webroot = null;
  };
  services.nginx.virtualHosts."requests.home.dodwell.us" = {
    forceSSL = true;
    enableACME = true;
    locations."/".return = "301 https://jellyseerr.home.dodwell.us$request_uri";
  };
}
