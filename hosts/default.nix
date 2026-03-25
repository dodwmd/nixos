{
  self,
  inputs,
  ...
}: let
  inherit (inputs.nixpkgs.lib) nixosSystem;
  mod = "${self}/system";
  home = "${self}/home";

  inherit (import "${self}/system") desktop laptop;

  specialArgs = {inherit inputs self;};
in {
  aesthetic = nixosSystem {
    inherit specialArgs;
    modules =
      desktop
      ++ laptop
      ++ [
        ./aesthetic
        "${mod}/services/gnome-services.nix"
        "${mod}/core/limine.nix"
        "${home}"

        inputs.agenix.nixosModules.default
      ];
  };
}
