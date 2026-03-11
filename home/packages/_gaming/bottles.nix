{pkgs, ...}: {
  users.users.linuxmobile.packages = with pkgs; [
    bottles
    wineWow64Packages.wayland
    winetricks
    gamescope
    mangohud
  ];

  environment.sessionVariables = {
    GDK_BACKEND = "wayland";
  };
}
