{
  config,
  pkgs,
  ...
}: {
  systemd.user.services.gpg-agent = {
    description = "GnuPG cryptographic agent and passphrase cache";
    documentation = ["man:gpg-agent(1)"];
    wantedBy = ["default.target"];

    serviceConfig = {
      Environment = "GNUPGHOME=${config.xdg.dataHome}/gnupg";
      ExecStart = "${pkgs.gnupg}/bin/gpg-agent --supervised";
      ExecReload = "${pkgs.gnupg}/bin/gpgconf --reload gpg-agent";
      Type = "simple";
    };
  };
}
