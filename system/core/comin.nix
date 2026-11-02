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
    remotes = [
      {
        name = "origin";
        url = "https://github.com/dodwmd/nixos.git";
        branches.main.name = "master";
      }
    ];
  };
}
