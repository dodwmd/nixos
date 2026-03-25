{pkgs, ...}: {
  # instant repl with automatic flake loading
  repl = pkgs.callPackage ./repl {};

  apple-fonts = pkgs.callPackage ./Apple-Fonts {};
}
