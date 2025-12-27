{inputs, ...}: {
  imports = [
    (inputs.import-tree ./editors)
    (inputs.import-tree ./packages)
    (inputs.import-tree ./services)
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
