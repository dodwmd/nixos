{pkgs, ...}: {
  imports = [
    ./fonts.nix
    ./xdg.nix
  ];

  programs = {
    dconf.enable = true;
    seahorse.enable = true;
  };

  # programs.adb removed in systemd 258; add android-tools to system packages instead
  environment.systemPackages = [pkgs.android-tools];
}
