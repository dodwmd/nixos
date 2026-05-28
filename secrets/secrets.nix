let
  linuxmobile = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPBcbiAvxkajtnODnfhsW+EjxqcJytkf5yuzRXH1LNVA bdiez19@gmail.com";
  system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEdNa3TQar/1PtLci+pODvVU4FCNvElVkOQG4RDJ/TUH root@aesthetic";
in {
  "openrouter.age".publicKeys = [
    linuxmobile
    system
  ];
  "github.age".publicKeys = [
    linuxmobile
    system
  ];
  "twt.age".publicKeys = [
    linuxmobile
    system
  ];
}
