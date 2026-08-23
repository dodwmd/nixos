{
  # Laptop-only additions on top of the blanket `home/default.nix` module
  # (editors, services/*, terminal/*, xdg-compat) that every niri host already
  # gets via hosts/default.nix's `"${home}"` module entry. Only import things
  # here that are NOT already covered by that tree, namely home/software/*
  # (not swept by home/default.nix's import-tree) and the laptop app list.
  imports = [
    ./packages.nix
    ../../software/browsers/brave.nix
    ../../software/wayland/fuzzel.nix
    ../../software/wayland/swaylock.nix
  ];
}
