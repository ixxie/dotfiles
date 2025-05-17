{ lib, ... }:

{
  home-manager.users.ixxie = {
    programs.waybar = {
      enable = true;
      systemd = {
        enable = true;
      };
      settings = [
        {
          "layer" = "top";
          "position" = "top";
          modules-left = [
            "custom/launcher"
            "niri/workspaces"
          ];
          modules-center = [
            "clock"
          ];
          modules-right = [
            "pulseaudio"
            "memory"
            "temperature"
            "cpu"
            "network"
            "battery"
            "custom/powermenu"
            #"tray"
          ];
          "niri/workspaces" = {
            disable-markup = true;
            format = "{icon}";
            format-icons = {
              default = "";
              focused = "";
              active = "";
            };
          };
          "custom/launcher" = {
            "format" = " ";
            "on-click" = "fuzzel";
            "on-click-middle" = "exec default_wall";
            "on-click-right" = "exec wallpaper_random";
            "tooltip" = false;
          };
          "pulseaudio" = {
            "scroll-step" = 1;
            "format" = "{icon} {volume}%";
            "format-muted" = "󰖁 Muted";
            "format-icons" = {
              "default" = [
                ""
                ""
                ""
              ];
            };
            "on-click" = "pamixer -t";
            "tooltip" = false;
          };
          "clock" = {
            "interval" = 1;
            "format" = "{:%H:%M}";
            "format-alt" = "{:%H:%M:%S}";
            "timezone" = "Europe/Paris";
            "tooltip" = true;
            "tooltip-format" = ''
              <tt>
                <b>{:%a %d %b %H:%M:%S}</b>
                {calendar}
              </tt>
            '';
            "calendar" = {
              "mode" = "month";
              "mode-mon-col" = 3;
              "weeks-pos" = "right";
              "on-scroll" = 1;
              "format" = {
                "months" = "<span><b>{}</b></span>";
                "days" = "<span><b>{}</b></span>";
                "weeks" = "<span><b>W{}</b></span>";
                "weekdays" = "<span><b>{}</b></span>";
                "today" = "<span><b><u>{}</u></b></span>";
              };
            };
            "actions" = {
              "on-click-right" = "mode";
              "on-click-forward" = "tz_up";
              "on-click-backward" = "tz_down";
              "on-scroll-up" = "shift_up";
              "on-scroll-down" = "shift_down";
            };
          };
          "memory" = {
            "interval" = 1;
            "format" = "󰻠 {percentage}%";
            "states" = {
              "warning" = 85;
            };
          };
          "cpu" = {
            "interval" = 1;
            "format" = "󰍛 {usage}%";
          };
          "network" = {
            "format-disconnected" = "󰯡 Disconnected";
            "format-ethernet" = "󰒢 Connected!";
            "format-linked" = "󰖪 {essid} (No IP)";
            "format-wifi" = "󰖩 {essid}";
            "interval" = 1;
            "tooltip" = true;
          };
          "custom/powermenu" = {
            "format" = "";
            "on-click" = "pkill rofi || ~/.config/rofi/powermenu/type-3/powermenu.sh";
            "tooltip" = false;
          };
          "tray" = {
            "icon-size" = 15;
            "spacing" = 5;
          };
        }
      ];
      style = builtins.readFile ./waybar.css;
    };
  };

  # settings = [
  #   {
  #     layer = "top";
  #     modules-left = [
  #       "niri/workspaces"
  #       "niri/window"
  #       # "mpd"
  #     ];
  #     modules-center = [ "clock" ];
  #     modules-right = [
  #       "network"
  #       "cpu"
  #       "memory"
  #       "temperature"
  #       "pulseaudio"
  #       "battery"
  #       "tray"
  #     ];
  #     "niri/workspaces" = {
  #       "all-outputs" = false;
  #     };
  #     mpd = {
  #       "max-length" = 30;
  #       "format" = "<span foreground='#1da0c3'></span>  {artist} - {title}";
  #       "format-paused" = "  {artist} - {title}";
  #       "format-stopped" = "";
  #       "format-disconnected" = "";
  #       "on-click" = "mpc --quiet toggle";
  #       "on-click-right" = "mpc ls | mpc add";
  #       "on-scroll-up" = "mpc --quiet prev";
  #       "on-scroll-down" = "mpc --quiet next";
  #       "smooth-scrolling-threshold" = 5;
  #       "tooltip" = false;
  #     };
  #     wireplumber = {
  #       "tooltip" = false;
  #       "format" = "VOL {volume}%";
  #       "format-muted" = "VOL mute";
  #     };
  #     pulseaudio = {
  #       "tooltip" = false;
  #       "scroll-step" = 5;
  #       "on-click" = "";
  #       "format" = "VOL {volume}%";
  #       "format-muted" = "VOL mute";
  #     };
  #     battery = {
  #       "format" = "BAT {capacity}%  ";
  #       "on-click" = "";
  #       "states" = {
  #         "warning" = 30;
  #         "critical" = 15;
  #       };
  #       "tooltip-format" = "{timeTo} ({power}W, {health}%)";
  #     };
  #     clock = {
  #       "interval" = 1;
  #       "format" = "{:%a %d %b %H:%M:%S}";
  #       "format-alt" = "{:%H:%M}";
  #       "locale" = "fr_FR.UTF-8";
  #       "timezone" = "Europe/Paris";
  #       "tooltip-format" = "<tt><small>{calendar}</small></tt>";
  #       "calendar" = {
  #         "mode" = "year";
  #         "mode-mon-col" = 3;
  #         "weeks-pos" = "right";
  #         "on-scroll" = 1;
  #         "format" = {
  #           "months" = "<span color='#ffead3'><b>{}</b></span>";
  #           "days" = "<span color='#ecc6d9'><b>{}</b></span>";
  #           "weeks" = "<span color='#99ffdd'><b>W{}</b></span>";
  #           "weekdays" = "<span color='#ffcc66'><b>{}</b></span>";
  #           "today" = "<span color='#ff6699'><b><u>{}</u></b></span>";
  #         };
  #       };
  #       "actions" = {
  #         "on-click-right" = "mode";
  #         "on-click-forward" = "tz_up";
  #         "on-click-backward" = "tz_down";
  #         "on-scroll-up" = "shift_up";
  #         "on-scroll-down" = "shift_down";
  #       };
  #     };
  #     cpu = {
  #       "format" = "CPU {usage}%";
  #       "on-click" = "";
  #       "tooltip" = false;
  #     };
  #     memory = {
  #       "on-click" = "";
  #       "format" = "RAM {}%";
  #     };
  #     temperature = {
  #       "on-click" = "";
  #       "format" = " {temperatureC}°C";
  #     };
  #     network = {
  #       "tooltip" = true;
  #       "interval" = 5;
  #       "format" = "DOWN {bandwidthDownOctets} | UP {bandwidthUpOctets}";
  #       "on-click" = "";
  #       "tooltip-format" = "{ifname} via {gwaddr}";
  #     };
  #     tray = {
  #       "icon-size" = 12;
  #       "spacing" = 10;
  #     };
  #   }
  # ];
}
