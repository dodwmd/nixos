{pkgs, ...}: let
  port = 6001;
  nodeAddress = "192.168.1.32"; # herdr-node; must be a fixed address (DHCP reservation)
in {
  # herdr-node pushes a foot window running herdr into this Wayland session.
  # The node's waypipe server connects (via a socat hop) to the TCP bridge below,
  # which feeds a waypipe client. Both only run while a graphical session is up,
  # so the node sees the port appear at login and vanish at logout.
  #
  # --secctx makes niri treat everything from the node as a sandboxed client
  # (wp_security_context): no screencopy, layer-shell, virtual keyboard etc.
  #
  # There is no authentication or encryption on this link: the firewall rule
  # below (node's address only) is the access control. Keep the node on a
  # reserved address.
  systemd.user.services = {
    waypipe-receiver = {
      description = "waypipe client for windows pushed from herdr-node";
      bindsTo = ["graphical-session.target"];
      partOf = ["graphical-session.target"];
      after = ["graphical-session.target"];
      wantedBy = ["graphical-session.target"];
      serviceConfig = {
        ExecStartPre = "${pkgs.coreutils}/bin/rm -f %t/waypipe-herdr.sock";
        ExecStart = "${pkgs.waypipe}/bin/waypipe --secctx herdr-node --socket %t/waypipe-herdr.sock client";
        Restart = "on-failure";
      };
    };

    herdr-display-bridge = {
      description = "TCP ${toString port} -> waypipe client socket for herdr-node";
      bindsTo = ["waypipe-receiver.service"];
      partOf = ["waypipe-receiver.service"];
      after = ["waypipe-receiver.service"];
      wantedBy = ["waypipe-receiver.service"];
      serviceConfig = {
        ExecStart = "${pkgs.socat}/bin/socat TCP-LISTEN:${toString port},fork,reuseaddr UNIX-CONNECT:%t/waypipe-herdr.sock";
        Restart = "on-failure";
      };
    };
  };

  networking.firewall.extraInputRules = ''
    ip saddr ${nodeAddress} tcp dport ${toString port} accept
  '';
}
