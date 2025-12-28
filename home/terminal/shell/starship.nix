{
  config,
  pkgs,
  ...
}: let
  configFile = "starship/starship.toml";
  toTOML = (pkgs.formats.toml {}).generate;
in {
  environment.sessionVariables = {
    STARSHIP_CONFIG = "${config.xdg.configHome}/${configFile}";
    STARSHIP_LOG = "error";
  };
  users.users.linuxmobile.packages = [pkgs.starship];
  xdg.configFile = {
    "${configFile}".source = toTOML "starship.toml" {
      add_newline = true;
      scan_timeout = 5;
      command_timeout = 500;

      format = ''
        [┌───](bold bright-blue) $hostname $os
        [│](bold bright-blue) $directory$git_branch$git_status$nix_shell
        [└─>](bold bright-blue) $character
      '';

      os = {
        format = "on [($name $codename$version $symbol )]($style)";
        style = "bold bright-blue";
        disabled = false;
      };

      hostname = {
        ssh_only = false;
        format = "[$hostname]($style)";
        style = "bold bright-red";
        disabled = false;
      };

      character = {
        format = "$symbol";
        success_symbol = "[❯](bold bright-green) ";
        error_symbol = "[✗](bold bright-red) ";
        vicmd_symbol = "[](bold yellow) ";
        disabled = false;
      };

      nix_shell = {
        disabled = false;
        heuristic = false;
        format = "[   ](fg:bright-blue bold)";
        impure_msg = "";
        pure_msg = "";
        unknown_msg = "";
      };

      aws.disabled = true;
      gcloud.disabled = true;
      nodejs.disabled = true;
      ruby.disabled = true;
      python.disabled = true;
      rust.disabled = true;
      golang.disabled = true;
      java.disabled = true;
      kotlin.disabled = true;
      lua.disabled = true;
      perl.disabled = true;
      php.disabled = true;
      swift.disabled = true;
      terraform.disabled = true;
      zig.disabled = true;
      package.disabled = true;
      conda.disabled = true;
      docker_context.disabled = true;
      kubernetes.disabled = true;
      helm.disabled = true;
      battery.disabled = true;
      time.disabled = true;
      cmd_duration.disabled = true;
    };
    "fish/conf.d/starship.fish".text = ''
      starship init fish | source
    '';

    "fish/completions/starship.fish".source = "${pkgs.starship}/share/fish/vendor_completions.d/starship.fish";
  };
}
