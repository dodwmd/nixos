let
  linuxmobile = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMRwa1U0NMk4/mV5iFv7HjuuFQ6C5L1vD8r6klLXvpN0 bdiez19@gmail.com";
  system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAaxvU13gr2OS84ldB5ubEg9iaXmlYquKE7hdM2lrZsE root@aesthetic";
in {
  "discordo.age".publicKeys = [
    linuxmobile
    system
  ];
  "github.age".publicKeys = [
    linuxmobile
    system
  ];
  "openrouter.age".publicKeys = [
    linuxmobile
    system
  ];
  "twt.age".publicKeys = [
    linuxmobile
    system
  ];
  "context7.age".publicKeys = [
    linuxmobile
    system
  ];
  "exa.age".publicKeys = [
    linuxmobile
    system
  ];
  "obs.age".publicKeys = [
    linuxmobile
    system
  ];
}
