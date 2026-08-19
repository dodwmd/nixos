{pkgs, ...}: {
  users.users.dodwmd.packages = with pkgs; [
    lutris
    gamemode
  ];
}
