{pkgs, ...}: {
  users.users.dodwmd.packages = with pkgs; [
    polkit_gnome
  ];

  # Enable polkit system-wide
  security.polkit.enable = true;
  
  # Create a script to start polkit agent manually
  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "start-polkit-agent" ''
      ${polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &
    '')
  ];
}
