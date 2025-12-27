{pkgs, ...}: {
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 32;
        spacing = 8;

        modules-left = [];
        modules-center = ["clock"];
        modules-right = ["cpu" "memory" "temperature" "custom/gpu" "tray"];

        clock = {
          format = "{:%a %b %d  %H:%M:%S}";
          interval = 1;
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "month";
            format = {
              months = "<span color='#c0caf5'><b>{}</b></span>";
              days = "<span color='#c0caf5'>{}</span>";
              today = "<span color='#f7768e'><b><u>{}</u></b></span>";
            };
          };
        };

        cpu = {
          format = "CPU {usage}%";
          interval = 2;
          tooltip = true;
          on-click = "${pkgs.foot}/bin/foot -e ${pkgs.btop}/bin/btop";
        };

        memory = {
          format = "RAM {percentage}%";
          interval = 2;
          tooltip-format = "Used: {used:0.1f}G / {total:0.1f}G";
          on-click = "${pkgs.foot}/bin/foot -e ${pkgs.btop}/bin/btop";
        };

        temperature = {
          hwmon-path = "/sys/class/hwmon/hwmon2/temp1_input";
          critical-threshold = 80;
          format = "SYS {temperatureC}°C";
          format-critical = "SYS {temperatureC}°C ";
          interval = 2;
          on-click = "${pkgs.foot}/bin/foot -e ${pkgs.btop}/bin/btop";
        };

        tray = {
          icon-size = 16;
          spacing = 8;
        };

        "custom/gpu" = {
          exec = "${pkgs.bash}/bin/bash -c \"nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total,temperature.gpu --format=csv,noheader,nounits | awk -F, '{printf \\\"GPU %s%% %d%%%s°C\\\", \\$1, (\\$2/\\$3)*100, \\$4}'\"";
          interval = 2;
          format = "{}";
          on-click = "${pkgs.foot}/bin/foot -e ${pkgs.nvtopPackages.nvidia}/bin/nvtop";
          tooltip = false;
        };
      };
    };

    style = ''
      * {
        font-family: "SF Mono", monospace;
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background-color: #1a1b26;
        color: #c0caf5;
      }

      #clock {
        color: #c0caf5;
        padding: 0 15px;
      }

      #cpu {
        color: #7aa2f7;
        padding: 0 10px;
      }

      #memory {
        color: #9ece6a;
        padding: 0 10px;
      }

      #temperature {
        color: #f7768e;
        padding: 0 10px;
      }

      #temperature.critical {
        color: #ff0000;
        font-weight: bold;
      }

      #custom-gpu {
        color: #bb9af7;
        padding: 0 10px;
      }

      #tray {
        padding: 0 10px;
      }

      tooltip {
        background: #1a1b26;
        border: 1px solid #414868;
        border-radius: 5px;
      }

      tooltip label {
        color: #c0caf5;
      }
    '';
  };
}
