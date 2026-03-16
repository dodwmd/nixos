{pkgs, ...}: {
  users.users.linuxmobile.packages = with pkgs; [
    alsa-utils
    easyeffects
  ];
}
