{pkgs, ...}: {
  # Provides an X11 socket (and $DISPLAY) inside the niri Wayland session, for
  # clients that still need Xwayland (Steam's update UI, some game launchers).
  # The xwayland-satellite package ships its own systemd user unit, but
  # installing the package (system/services/xwayland-satellite.nix) only puts
  # that unit on the search path - nothing ever enables it, so it never
  # actually starts. Redeclaring it here (mirroring the vendored unit) is what
  # gets it wanted by graphical-session.target.
  systemd.user.services.xwayland-satellite = {
    description = "Xwayland outside your Wayland";
    bindsTo = ["graphical-session.target"];
    partOf = ["graphical-session.target"];
    after = ["graphical-session.target"];
    requisite = ["graphical-session.target"];
    wantedBy = ["graphical-session.target"];
    serviceConfig = {
      Type = "notify";
      NotifyAccess = "all";
      ExecStart = "${pkgs.xwayland-satellite}/bin/xwayland-satellite";
      StandardOutput = "journal";
    };
  };
}
