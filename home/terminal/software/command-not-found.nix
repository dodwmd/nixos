_: {
  xdg.configFile."fish/functions/__fish_command_not_found_handler.fish".text = ''
    function __fish_command_not_found_handler --on-event fish_command_not_found
        /run/current-system/sw/bin/command-not-found $argv
    end
  '';
}
