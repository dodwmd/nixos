{pkgs, ...}: {
  users.users.dodwmd.packages = [pkgs.fuzzel];
  
  xdg.configFile."fuzzel/fuzzel.ini".text = ''
    [main]
    terminal = ${pkgs.foot}/bin/foot
    layer = overlay
    width = 40
    horizontal-pad = 20
    vertical-pad = 10
    inner-pad = 10
    
    [colors]
    background = 1a1b26ff
    text = c0caf5ff
    match = 7aa2f7ff
    selection = 414868ff
    selection-text = c0caf5ff
    border = 7aa2f7ff
    
    [border]
    width = 2
    radius = 10
  '';
}
