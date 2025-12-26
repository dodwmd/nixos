{inputs, ...}: {
  imports = [
    (inputs.import-tree ./services)
    (inputs.import-tree ./packages)
    ./terminal
    ./xdg-compat.nix
    inputs.nix-index-db.nixosModules.nix-index
    inputs.hjem.nixosModules.default
  ];

  programs = {
    nix-index = {
      enable = true;
      enableFishIntegration = true;
    };
    nix-index-database.comma.enable = true;
  };

  hjem = {
    extraModules = [
      inputs.hjem-rum.hjemModules.default
    ];
    users = {
      linuxmobile = {
        enable = true;
        user = "linuxmobile";
        directory = "/home/linuxmobile";
      };
    };
  };
}
