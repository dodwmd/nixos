{pkgs, ...}: let
  makoConfig = ''
    # Position and size
    anchor=top-right
    output=HDMI-A-1
    width=350
    height=150
    margin=10
    padding=15
    
    # Appearance
    background-color=#1a1b26
    text-color=#c0caf5
    border-color=#7aa2f7
    border-size=2
    border-radius=10
    
    # Behavior
    default-timeout=5000
    ignore-timeout=0
    
    # Font
    font=SF Mono 11
    
    # Icons
    icon-path=${pkgs.whitesur-icon-theme}/share/icons/WhiteSur
    max-icon-size=48
    
    # Grouping
    group-by=app-name
    
    # Urgency levels
    [urgency=low]
    border-color=#414868
    default-timeout=3000
    
    [urgency=normal]
    border-color=#7aa2f7
    default-timeout=5000
    
    [urgency=critical]
    border-color=#f7768e
    default-timeout=0
    ignore-timeout=1
  '';
in {
  users.users.dodwmd.packages = with pkgs; [mako];
  
  xdg.configFile."mako/config".text = makoConfig;
}
