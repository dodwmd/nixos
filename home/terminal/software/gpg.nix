{
  config,
  pkgs,
  ...
}: let
  gpgConfigFile = "gnupg/gpg.conf";
  agentConfigFile = "gnupg/gpg-agent.conf";
in {
  home.packages = with pkgs; [
    gnupg
    pinentry-gnome3
  ];

  xdg.configFile = {
    "${gpgConfigFile}".text = ''
      cert-digest-algo SHA512
      charset utf-8
      default-key 481EFFCF2C7B8C7B
      default-preference-list SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed
      fixed-list-mode
      keyid-format 0xlong
      list-options show-uid-validity
      no-comments
      no-emit-version
      no-symkey-cache
      personal-cipher-preferences AES256 AES192 AES
      personal-compress-preferences ZLIB BZIP2 ZIP Uncompressed
      personal-digest-preferences SHA512 SHA384 SHA256
      require-cross-certification
      s2k-cipher-algo AES256
      s2k-digest-algo SHA512
      use-agent
      verify-options show-uid-validity
      with-fingerprint
    '';
    "${agentConfigFile}".text = ''
      enable-ssh-support
      enable-nushell-integration
      grab
      pinentry-program ${pkgs.pinentry-gnome3}/bin/pinentry
    '';
    "fish/conf.d/gpg.fish".source = pkgs.writeText "gpg.fish" ''
      set -gx GPG_TTY (tty)
      ${pkgs.gnupg}/bin/gpg-connect-agent --quiet updatestartuptty /bye >/dev/null
    '';
  };

  home.sessionVariables = {
    GPG_TTY = "$(tty)";
    SSH_AUTH_SOCK = "/run/user/1000/gnupg/S.gpg-agent.ssh";
  };
}
