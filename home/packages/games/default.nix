{pkgs, ...}: {
  users.users.dodwmd.packages = with pkgs; [
    lutris
    gamemode
    bottles  # alternative to lutris if needed
  ];
}
