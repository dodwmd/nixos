{pkgs, ...}: {
  environment = {
    shells = with pkgs; [nushell];
    systemPackages = with pkgs; [carapace fish zsh inshellisense];
  };
}
