{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations = let
    # shorten paths
    inherit (inputs.nixpkgs.lib) nixosSystem;
    mod = "${self}/system";
    home = "${self}/home";

    # get the basic config to build on top of
    inherit (import "${self}/system") desktop laptop server media-server k3s-master k3s-worker;

    # get these into the module system
    specialArgs = {inherit inputs self;};
  in {
    # Desktop workstation
    exodus = nixosSystem {
      inherit specialArgs;
      modules =
        desktop
        ++ [
          ./exodus
          "${home}"

          inputs.agenix.nixosModules.default
          inputs.chaotic.nixosModules.default
          inputs.noctalia-shell.nixosModules.default
        ];
    };

    # K3s master nodes
    k3s-master-01 = nixosSystem {
      inherit specialArgs;
      modules =
        k3s-master
        ++ [
          ./k3s-master-01
          inputs.agenix.nixosModules.default
        ];
    };

    k3s-master-02 = nixosSystem {
      inherit specialArgs;
      modules =
        k3s-master
        ++ [
          ./k3s-master-02
          inputs.agenix.nixosModules.default
        ];
    };

    # K3s worker nodes
    k3s-worker-01 = nixosSystem {
      inherit specialArgs;
      modules =
        k3s-worker
        ++ [
          ./k3s-worker-01
          inputs.agenix.nixosModules.default
        ];
    };

    k3s-worker-02 = nixosSystem {
      inherit specialArgs;
      modules =
        k3s-worker
        ++ [
          ./k3s-worker-02
          inputs.agenix.nixosModules.default
        ];
    };

    k3s-worker-03 = nixosSystem {
      inherit specialArgs;
      modules =
        k3s-worker
        ++ [
          ./k3s-worker-03
          inputs.agenix.nixosModules.default
        ];
    };

    # Media server
    nexus = nixosSystem {
      inherit specialArgs;
      modules =
        media-server
        ++ [
          ./nexus
          inputs.agenix.nixosModules.default
        ];
    };
  };
}
