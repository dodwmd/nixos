{pkgs, ...}: {
  virtualisation.docker.enable = true;
  # programs.adb removed in systemd 258; add android-tools to system packages instead
  environment.systemPackages = [pkgs.android-tools];
}
