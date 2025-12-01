{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.niri.homeModules.niri ./settings.nix ./binds.nix ./rules.nix ./pick-color.nix];

  home = {
    packages = with pkgs; [
      seatd
      jaq
    ];
  };
}
