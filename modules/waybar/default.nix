{
  home-manager.users.ixxie = {
    programs.waybar = {
      enable = true;
      systemd = {
        enable = true;
      };
      settings = [
        {
          layer = "top";
          position = "top";
          height = 10;
          spacing = 0;
          margin-top = 0;
          margin-left = 0;
          margin-right = 0;

          "modules-left" = [
            "niri/workspaces"
            "niri/window"
          ];

          "niri/workspaces" = {
            "format" = " ";
          };

          "niri/window" = {
            "format" = "{title}";
          };

          # center

          "modules-center" = [
            "clock"
          ];

          "clock" = {
            interval = 1;
            format = "{:%H:%M}";
            timezone = "Europe/Paris";
            tooltip = false;
          };

          # RIGHT SIDE

          "modules-right" = [
            "group/session"
            "cpu"
            "memory"
            "temperature"
            "disk"
            "wireplumber#sink"
            "backlight"
            "network"
            "power-profiles-daemon"
            "battery"
          ];

          # session

          "custom/session-wrap" = {
            "format" = "󰒘 ";
            "tooltip-format" = "Session";
          };
          "group/session" = {
            "orientation" = "horizontal";
            "drawer" = {
              "transition-duration" = 500;
              "transition-left-to-right" = false;
            };
            "modules" = [
              "custom/session-wrap"
              "custom/lock"
              "custom/reboot"
              "custom/power"
            ];
          };
          "custom/lock" = {
            "format" = "  ";
            "on-click" = "swaylock -c 000000";
            "tooltip" = true;
            "tooltip-format" = "Lock screen";
          };
          "custom/reboot" = {
            "format" = "  ";
            "on-click" = "systemctl reboot";
            "tooltip" = true;
            "tooltip-format" = "Reboot";
          };
          "custom/power" = {
            "format" = "   ";
            "on-click" = "systemctl poweroff";
            "tooltip" = true;
            "tooltip-format" = "Power Off";
          };

          # hardware

          "cpu" = {
            "format" = "{icon} ";
            "format-icons" = [
              ""
              ""
              " "
            ];
            "states" = {
              "critical" = 80;
            };
            "tooltip" = true;
            "interval" = 1;
            "on-click" = "ghostty -e htop";
          };

          "memory" = {
            "format" = "{icon} ";
            "format-icons" = [
              ""
              ""
              " "
            ];
            "states" = {
              "critical" = 85;
            };
            "tooltip" = true;
            "interval" = 1;
            "on-click" = "ghostty -e htop";
          };

          "temperature" = {
            "critical-threshold" = 80;
            "format" = "{icon}";
            "states" = {
              "critical" = 80;
            };
            "tooltip-format" = "Temperature {temperatureC}°C";
            "format-icons" = [
              ""
              ""
              "󱃂"
            ];
          };

          "disk" = {
            "format" = "{icon} ";
            "format-icons" = [
              ""
              ""
              "󱛟 "
            ];
            "states" = {
              "critical" = 70;
            };
          };

          # levels

          "network" = {
            "format-wifi" = "󰖩 ";
            "format-ethernet" = "󰈀 ";
            "format-linked" = "󰈀 ";
            "format-disconnected" = "󰖪 ";
            "tooltip-format" = "Network {essid} {signalStrength}%";
          };

          "wireplumber#sink" = {
            "format" = "{icon} ";
            "tooltip-format" = "Volume {volume}%";
            "format-muted" = " ";
            "format-icons" = [
              ""
              ""
              ""
            ];
            "on-click" = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            "on-scroll-down" = "wpctl set-volume @DEFAULT_SINK@ 1%-";
            "on-scroll-up" = "wpctl set-volume @DEFAULT_SINK@ 1%+";
          };

          "backlight" = {
            "format" = "{icon} ";
            "tooltip-format" = "Brightness {percent}%";
            "format-icons" = [
              "󰃞"
              "󰃟"
              "󰃠"
            ];
            "on-scroll-up" = "brightnessctl set +5%";
            "on-scroll-down" = "brightnessctl set 5%-";
          };

          # power

          "power-profiles-daemon" = {
            "format" = "{icon}";
            "tooltip-format" = "{profile}";
            "tooltip" = true;
            "format-icons" = {
              "default" = " ";
              "performance" = " ";
              "balanced" = " ";
              "power-saver" = " ";
            };
          };

          "battery" = {
            "states" = {
              "good" = 95;
              "warning" = 30;
              "critical" = 15;
            };
            "format" = "{icon}";
            "format-charging" = "󰂄";
            "format-plugged" = "󰚥";
            "tooltip-format" = "Battery {capacity}%";
            "format-alt" = "{icon} {time}";
            "format-icons" = [
              "󰂎"
              "󰁺"
              "󰁻"
              "󰁼"
              "󰁽"
              "󰁾"
              "󰁿"
              "󰂀"
              "󰂁"
              "󰂂"
              "󰁹"
            ];
          };
        }
      ];
      style = builtins.readFile ./waybar.css;
    };
  };
}
