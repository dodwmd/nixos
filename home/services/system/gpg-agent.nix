{
  config,
  pkgs,
  ...
}: {
  # GPG agent is typically handled by the system's gpg configuration
  # Enable GPG agent system-wide
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gnome3;
  };
  
  # Set GNUPGHOME environment variable
  environment.sessionVariables = {
    GNUPGHOME = "${config.xdg.dataHome}/gnupg";
  };
}
