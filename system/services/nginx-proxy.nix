{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.homelab.nginx-proxy;
in
{
  options.homelab.nginx-proxy = {
    enable = mkEnableOption "Enable NGINX reverse proxy with ACME";
    
    email = mkOption {
      type = types.str;
      default = "michael@dodwell.us";
      description = "Email for ACME/Let's Encrypt";
    };
    
    dnsProvider = mkOption {
      type = types.str;
      default = "cloudflare";
      description = "DNS provider for ACME DNS-01 challenge";
    };
    
    credentialsFile = mkOption {
      type = types.str;
      default = "/var/lib/acme/cloudflare-credentials";
      description = "Path to DNS provider credentials file";
    };
    
    virtualHosts = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          proxyPass = mkOption {
            type = types.str;
            description = "Backend URL to proxy to";
          };
          
          extraLocations = mkOption {
            type = types.attrsOf types.attrs;
            default = {};
            description = "Additional location blocks";
          };
          
          extraConfig = mkOption {
            type = types.lines;
            default = "";
            description = "Extra location configuration";
          };
        };
      });
      default = {};
      description = "Virtual hosts configuration";
    };
  };

  config = mkIf cfg.enable {
    # ACME configuration for Let's Encrypt with DNS-01
    security.acme = {
      acceptTerms = true;
      defaults = {
        email = cfg.email;
        dnsProvider = cfg.dnsProvider;
        credentialsFile = cfg.credentialsFile;
        dnsResolver = "1.1.1.1:53";
      };
    };

    # Override each certificate to use DNS challenge
    security.acme.certs = mapAttrs (name: _: {
      dnsProvider = cfg.dnsProvider;
      webroot = null;
    }) cfg.virtualHosts;

    # Create credentials directory
    systemd.tmpfiles.rules = [
      "d /var/lib/acme 0755 root root - -"
    ];

    services.nginx = {
      enable = true;
      
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;

      virtualHosts = mapAttrs (hostname: hostCfg: {
        forceSSL = true;
        enableACME = true;
        locations = {
          "/" = {
            proxyPass = hostCfg.proxyPass;
            proxyWebsockets = true;
            extraConfig = hostCfg.extraConfig;
          };
        } // hostCfg.extraLocations;
      }) cfg.virtualHosts;
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };
}
