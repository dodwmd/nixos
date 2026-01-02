{pkgs, ...}: {
  home.packages = with pkgs; [
    polkit_gnome
  ];

  systemd.user.services.polkit-gnome = {
    Unit = {
      Description = "GNOME PolicyKit Agent";
      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
    };
  };
}
