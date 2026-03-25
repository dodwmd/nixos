{
  description = "linuxmobile flake configuration based on hjem";

  inputs = {
    systems.url = "github:nix-systems/default";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
      };
    };

    import-tree.url = "github:vic/import-tree";

    mynixpkgs.url = "github:linuxmobile/mynixpkgs";

    nix-index-db = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    systems,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;
    forAllSystems = lib.genAttrs (import systems);
    pkgsFor = system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
  in {
    nixosConfigurations = import ./hosts {inherit self inputs;};

    packages =
      forAllSystems (system:
        import ./pkgs {pkgs = pkgsFor system;});

    devShells = forAllSystems (system: let
      pkgs = pkgsFor system;
    in {
      default = pkgs.mkShell {
        packages = [pkgs.alejandra pkgs.git self.packages.${system}.repl];
        name = "nixland";
        DIRENV_LOG_FORMAT = "";
      };
    });

    formatter = forAllSystems (system: (pkgsFor system).alejandra);
  };
}
