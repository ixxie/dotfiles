{
  pkgs,
  inputs,
  ...
}:

{
  nixpkgs.overlays = [
    inputs.niri.overlays.niri
  ];
  environment.systemPackages = with pkgs; [
    xwayland-satellite
    swaybg
    pamixer
    brightnessctl
  ];
  programs.niri.enable = true;

  home-manager.users.ixxie =
    { config, ... }:
    {
      imports = [
        inputs.niri.homeModules.niri
        inputs.niri.homeModules.stylix
      ];
      services.mako = {
        enable = true;
        borderRadius = 5;
        defaultTimeout = 5;
        borderSize = 2;
      };
      programs = {
        niri = {
          enable = true;
          package = pkgs.niri-unstable;
          settings = {
            environment = {
              "NIXOS_OZONE_WL" = "1";
              QT_QPA_PLATFORM = "wayland";
              "DISPLAY" = ":0";
            };
            spawn-at-startup = [
              { command = [ "xwayland-satellite" ]; }
              { command = [ "mako" ]; }
              {
                command = [
                  "systemctl"
                  "--user"
                  "reset-failed"
                  "waybar.service"
                ];
              }
              {
                command = [
                  "swaybg"
                  "-m"
                  "fill"
                  "-i"
                  "${config.stylix.image}"
                ];
              }
            ];
            input = {
              keyboard = {
                #repeat-delay = 200;
                #repeat-rate = 60;
                xkb = {
                  layout = "us";
                  variant = "intl";
                };
              };
              touchpad = {
                tap = true;
                #dwt = true;
                natural-scroll = true;
                #click-method = "clickfinger";
              };
            };
            prefer-no-csd = true;
            layout = {
              gaps = 8;
              preset-column-widths = [
                { proportion = 1. / 5.; }
                { proportion = 2. / 5.; }
                { proportion = 3. / 5.; }
                { proportion = 4. / 5.; }
              ];
              preset-window-heights = [
                { proportion = 1. / 3.; }
                { proportion = 1. / 2.; }
                { proportion = 2. / 3.; }
              ];
              focus-ring = {
                enable = true;
                active.gradient = {
                  from = "#e03961";
                  to = "#c94bb9";
                  angle = 45;
                };
                width = 3;
              };
              border = {
                enable = false;
                active.gradient = {
                  from = "#e03961";
                  to = "#057ff7";
                  angle = 45;
                };
                width = 3;
              };
            };
            window-rules = [
              {
                matches = [ ];
                geometry-corner-radius = {
                  bottom-left = 5.0;
                  bottom-right = 5.0;
                  top-left = 5.0;
                  top-right = 5.0;
                };
                clip-to-geometry = true;
              }
            ];
            binds = with config.lib.niri.actions; {
              # apps
              "Mod+Return".action.spawn = "ghostty";
              "Mod+Space".action.spawn = "firefox";
              "Mod+L".action.spawn = "fuzzel";
              # session
              "Mod+Alt+P".action.spawn = "poweroff";
              "Mod+Alt+R".action.spawn = "reboot";
              "Mod+Alt+Q".action = quit;
              # workspaces
              "Mod+1".action.focus-workspace = 1;
              "Mod+2".action.focus-workspace = 2;
              "Mod+3".action.focus-workspace = 3;
              "Mod+4".action.focus-workspace = 4;
              "Mod+5".action.focus-workspace = 5;
              "Mod+6".action.focus-workspace = 6;
              "Mod+7".action.focus-workspace = 7;
              "Mod+8".action.focus-workspace = 8;
              "Mod+9".action.focus-workspace = 9;
              "Mod+Shift+1".action.move-column-to-workspace = 1;
              "Mod+Shift+2".action.move-column-to-workspace = 2;
              "Mod+Shift+3".action.move-column-to-workspace = 3;
              "Mod+Shift+4".action.move-column-to-workspace = 4;
              "Mod+Shift+5".action.move-column-to-workspace = 5;
              "Mod+Shift+6".action.move-column-to-workspace = 6;
              "Mod+Shift+7".action.move-column-to-workspace = 7;
              "Mod+Shift+8".action.move-column-to-workspace = 8;
              "Mod+Shift+9".action.move-column-to-workspace = 9;
              # sizing
              "Mod+F".action = maximize-column;
              "Mod+Shift+F".action = fullscreen-window;
              "Mod+BackSpace".action = close-window;
              "Mod+C".action = center-column;
              "Mod+Shift+W".action = switch-preset-column-width;
              "Mod+Shift+H".action = switch-preset-window-height;
              "Mod+Ctrl+H".action = reset-window-height;
              "Mod+Minus".action.set-column-width = "-10%";
              "Mod+Equal".action.set-column-width = "+10%";
              "Mod+Shift+Minus".action.set-window-height = "-10%";
              "Mod+Shift+Equal".action.set-window-height = "+10%";
              # focus
              "Mod+Left".action = focus-column-left;
              "Mod+Down".action = focus-window-or-workspace-down;
              "Mod+Up".action = focus-window-or-workspace-up;
              "Mod+Right".action = focus-column-right;
              "Mod+Alt+Left".action = focus-monitor-left;
              "Mod+Alt+Down".action = focus-monitor-down;
              "Mod+Alt+Up".action = focus-monitor-up;
              "Mod+Alt+Right".action = focus-monitor-right;
              "Mod+WheelScrollUp".action = focus-column-left;
              "Mod+WheelScrollDown".action = focus-column-right;
              "Mod+Shift+WheelScrollUp".action = focus-window-or-workspace-up;
              "Mod+Shift+WheelScrollDown".action = focus-window-or-workspace-down;
              "Mod+U".action = focus-workspace-down;
              "Mod+I".action = focus-workspace-up;
              # move
              "Mod+Ctrl+Left".action = move-column-left;
              "Mod+Ctrl+Down".action = move-window-down-or-to-workspace-down;
              "Mod+Ctrl+Up".action = move-window-up-or-to-workspace-up;
              "Mod+Ctrl+Right".action = move-column-right;
              "Mod+Ctrl+Alt+Left".action = move-column-to-monitor-left;
              "Mod+Ctrl+Alt+Down".action = move-column-to-monitor-down;
              "Mod+Ctrl+Alt+Up".action = move-column-to-monitor-up;
              "Mod+Ctrl+Alt+Right".action = move-column-to-monitor-right;
              "Mod+Shift+U".action = move-column-to-workspace-down;
              "Mod+Shift+I".action = move-column-to-workspace-up;
              # float
              "Mod+V".action = toggle-window-floating;
              "Mod+Shift+V".action = switch-focus-between-floating-and-tiling;
              # tabs
              "Mod+W".action = toggle-column-tabbed-display;
              "Mod+BracketLeft".action = consume-or-expel-window-left;
              "Mod+BracketRight".action = consume-or-expel-window-right;
              "Mod+Comma".action = consume-window-into-column;
              "Mod+Period".action = expel-window-from-column;
              # screenshots
              "Print".action.screenshot = { };
              "Shift+Print".action.screenshot-screen = { };
              # fn
              "XF86AudioRaiseVolume".action.spawn = [
                "pamixer"
                "--increase"
                "5"
              ];
              "XF86AudioLowerVolume".action.spawn = [
                "pamixer"
                "--decrease"
                "5"
              ];
              "XF86AudioMute".action.spawn = [
                "pamixer"
                "--toggle-mute"
              ];
              "XF86MonBrightnessDown".action.spawn = [
                "brightnessctl"
                "s"
                "5%-"
              ];
              "XF86MonBrightnessUp".action.spawn = [
                "brightnessctl"
                "s"
                "+5%"
              ];
            };
            hotkey-overlay.skip-at-startup = true;
          };
        };
        fuzzel = {
          enable = true;
        };
      };
    };
}
