{
  config,
  pkgs,
  ...
}: let
  sshConfigFile = "ssh/config";
in {
  home.packages = with pkgs; [
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

  home.sessionVariables = {
    SSH_AUTH_SOCK = "/run/user/1000/gnupg/S.gpg-agent.ssh";
  };

  systemd.user.services.ssh-agent = {
    Unit = {
      Description = "SSH agent service";
    };
    Install = {
      WantedBy = ["default.target"];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.openssh}/bin/ssh-agent -D -a /run/user/1000/ssh-agent.socket";
      Restart = "on-failure";
    };
  };
}
