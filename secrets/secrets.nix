let
  linuxmobile = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPBcbiAvxkajtnODnfhsW+EjxqcJytkf5yuzRXH1LNVA bdiez19@gmail.com";
in {
  "openrouter.age".publicKeys = [
    linuxmobile
  ];
  "github.age".publicKeys = [
    linuxmobile
  ];
  "twt.age".publicKeys = [
    linuxmobile
  ];
}
