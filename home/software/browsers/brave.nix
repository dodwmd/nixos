{pkgs, ...}: let
  chromiumFlags = import ./chromium-flags.nix {inherit pkgs;};
in {
  programs.chromium = {
    enable = true;
    package = pkgs.brave;
    extensions = [
      {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";} # Ublock Origin
      {id = "jhnleheckmknfcgijgkadoemagpecfol";} # Auto-Tab-Discard
      {id = "nngceckbapebfimnlniiiahkandclblb";} # Bitwarden
    ];
  };

  xdg.configFile = chromiumFlags.configFile;
  environment.sessionVariables = chromiumFlags.sessionVariables;
}
