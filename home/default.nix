{inputs, self, ...}: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit inputs self;};
    users.dodwmd = {
      imports = [
        ./editors
        ./packages  
        ./services
        ./terminal
      ];

      programs = {
        nix-index = {
          enable = true;
          enableFishIntegration = true;
        };
      };

      # Basic home-manager settings
      home = {
        username = "dodwmd";
        homeDirectory = "/home/dodwmd";
        stateVersion = "24.11";
      };
    };
  };
}
