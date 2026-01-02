{pkgs, ...}: {
  users.users.dodwmd.packages = with pkgs; [
    alsa-utils
    easyeffects
  ];
}
