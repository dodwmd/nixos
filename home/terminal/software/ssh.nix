{
  config,
  pkgs,
  ...
}: let
  sshConfigFile = "ssh/config";
in {
  users.users.dodwmd.packages = with pkgs; [
    openssh
  ];

  xdg.configFile."${sshConfigFile}".text = ''
    AddKeysToAgent yes
    CheckHostIP yes
    Compression no
    ControlMaster no
    ControlPath ~/.ssh/master-%r@%n:%p
    ControlPersist no
    HashKnownHosts yes
    IdentitiesOnly yes
    PasswordAuthentication no
    ForwardAgent no
    ForwardX11 no
    ForwardX11Trusted no
    ServerAliveInterval 60
    ServerAliveCountMax 3
    UserKnownHostsFile ~/.ssh/known_hosts

    Include ~/.ssh/config.d/*
  '';

  # Enable SSH agent system-wide
  programs.ssh = {
    startAgent = true;
    agentTimeout = "1h";
  };

  # SSH_AUTH_SOCK is managed by programs.ssh.startAgent above
}
