{
  inputs,
  lib,
  ...
}: {
  imports = [inputs.comin.nixosModules.comin];

  # GitOps self-update: poll the public repo and switch to new commits on master.
  # The nixosConfigurations attribute must match the host's networking.hostName.
  services.comin = {
    enable = lib.mkDefault true;
    # The module can't disable the Prometheus exporter; keep it off the network.
    exporter.listen_address = "127.0.0.1";
    remotes = [
      {
        name = "origin";
        url = "https://github.com/dodwmd/nixos.git";
        branches.main.name = "master";
        poller.period = 3600;
      }
    ];
  };
}
