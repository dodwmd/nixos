{
  config,
  pkgs,
  ...
}: {
  systemd.user.services.gpg-agent = {
    Unit = {
      Description = "GnuPG cryptographic agent and passphrase cache";
      Documentation = ["man:gpg-agent(1)"];
    };
    Install = {
      WantedBy = ["default.target"];
    };
    Service = {
      Environment = "GNUPGHOME=${config.xdg.dataHome}/gnupg";
      ExecStart = "${pkgs.gnupg}/bin/gpg-agent --supervised";
      ExecReload = "${pkgs.gnupg}/bin/gpgconf --reload gpg-agent";
      Type = "simple";
    };
  };
}
