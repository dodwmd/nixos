let
  linuxmobile = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII4yBZ4lp16p5JjKYdXovi3zrR4T+3IuRnh3prIUs1oZ bdiez19@gmail.com";
  system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKKCFIvfZjqyRQ1Jqb0wPcw8z/asqfhc93d81SxRHIhy root@aesthetic";
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
}
