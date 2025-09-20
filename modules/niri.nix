{
  pkgs,
  inputs,
  ...
}:

let
  niri = pkgs.niri-unstable;

  # Utility to convert command string to noctalia-shell IPC format
  noctalia =
    cmd:
    [
      "noctalia-shell"
      "ipc"
      "call"
    ]
    ++ (pkgs.lib.splitString " " cmd);
in
{
  nixpkgs.overlays = [
    inputs.niri.overlays.niri
  ];
  environment.systemPackages = with pkgs; [
    xwayland-satellite-unstable
    playerctl
    libinput
    wl-clipboard-rs
  ];

  programs.niri = {
    enable = true;
    package = niri;
  };

  # screensharing
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
  };

  hardware.opengl.enable = true;

  home-manager.users.ixxie =
    { config, lib, ... }:
    {
      imports = [
        inputs.niri.homeModules.config
        inputs.niri.homeModules.stylix
      ];
      programs = {
        niri = {
          package = niri;
          settings = {
            environment = {
              NIXOS_OZONE_WL = "1";
              QT_QPA_PLATFORM = "wayland";
            };
            xwayland-satellite = {
              enable = true;
              path = lib.getExe pkgs.xwayland-satellite-unstable;
            };
            outputs = {
              eDP-1 = {
                position = {
                  x = 0;
                  y = 0;
                };
              };
              DP-2 = {
                position = {
                  x = -2560;
                  y = 0;
                };
              };
            };
            # spawn-at-startup = [
            #   {
            #     command = [
            #       "noctalia-shell"
            #     ];
            #   }
            # ];
            input = {
              keyboard = {
                #repeat-delay = 200;
                #repeat-rate = 60;
                xkb = {
                  layout = "us";
                  variant = "altgr-intl";
                  options = "compose:altgr";
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
                  from = "#197145";
                  to = "#195f71";
                  angle = -45;
                };
                width = 1;
              };
              border.enable = false;
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
              "Mod+Space".action.spawn = noctalia "launcher toggle";
              # session
              "Mod+Alt+P".action.spawn = "shutdown now";
              "Mod+Alt+R".action.spawn = "shutdown -r now";
              "Mod+Alt+Q".action = quit;
              "Mod+P".action.spawn = noctalia "powerPanel toggle";
              "Mod+L".action.spawn = noctalia "lockScreen toggle";
              # workspaces
              "Mod+Tab".action = toggle-overview;
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
              "Mod+Left".action = focus-column-left-or-last;
              "Mod+Right".action = focus-column-right-or-first;
              "Mod+Down".action = focus-window-or-workspace-down;
              "Mod+Up".action = focus-window-or-workspace-up;
              "Mod+Alt+Left".action = focus-monitor-left;
              "Mod+Alt+Down".action = focus-monitor-down;
              "Mod+Alt+Up".action = focus-monitor-up;
              "Mod+Alt+Right".action = focus-monitor-right;
              "Mod+WheelScrollUp".action = focus-column-left-or-last;
              "Mod+WheelScrollDown".action = focus-column-right-or-first;
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
              "Mod+T".action = toggle-column-tabbed-display;
              "Mod+BracketLeft".action = consume-or-expel-window-left;
              "Mod+BracketRight".action = consume-or-expel-window-right;
              "Mod+Comma".action = consume-window-into-column;
              "Mod+Period".action = expel-window-from-column;
              # screenshots
              "Print".action.screenshot = { };
              "Shift+Print".action.screenshot-screen = { };
              # fn
              "XF86AudioLowerVolume".action.spawn = noctalia "volume decrease";
              "XF86AudioRaiseVolume".action.spawn = noctalia "volume increase";
              "XF86AudioMute".action.spawn = noctalia "volume muteOutput";
              "XF86MonBrightnessDown".action.spawn = noctalia "brightness decrease";
              "XF86MonBrightnessUp".action.spawn = noctalia "brightness increase";
              "XF86AudioPlay".action.spawn = [
                "playerctl"
                "play-pause"
              ];
              "XF86AudioNext".action.spawn = [
                "playerctl"
                "next"
              ];
              "XF86AudioPrev".action.spawn = [
                "playerctl"
                "previous"
              ];
              # docs
              "Mod+H".action.spawn = [
                "firefox"
                "https://github.com/YaLTeR/niri/wiki/Getting-Started"
                "https://github.com/sodiboo/niri-flake"
                "https://github.com/sodiboo/niri-flake/blob/main/docs.md"
                "https://github.com/noctalia-dev/noctalia-shell"
              ];
            };
            hotkey-overlay.skip-at-startup = true;
          };
        };
      };
    };
}
