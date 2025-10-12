{
  pkgs,
  inputs,
  config,
  ...
}:

let
  homeDir = config.home-manager.users.ixxie.home.homeDirectory;
  directory = "${homeDir}/Pictures/Wallpapers";
  wallpaper = directory + "/" + "kukai-art-xS_lI4mtyzs-unsplash.jpg";
in
{
  # pacakge
  environment.systemPackages = with pkgs; [
    inputs.noctalia.packages.${system}.default
  ];

  # systemd
  imports = [
    inputs.noctalia.nixosModules.default
  ];

  services.noctalia-shell.enable = true;

  # home
  home-manager.users.ixxie = {
    imports = [
      inputs.noctalia.homeModules.default
    ];

    programs.noctalia-shell = {
      enable = true;
      colors = {
        mError = "#dddddd";
        mOnError = "#111111";
        mOnPrimary = "#111111";
        mOnSecondary = "#111111";
        mOnSurface = "#828282";
        mOnSurfaceVariant = "#5d5d5d";
        mOnTertiary = "#111111";
        mOutline = "#3c3c3c";
        mPrimary = "#aaaaaa";
        mSecondary = "#a7a7a7";
        mShadow = "#000000";
        mSurface = "#111111";
        mSurfaceVariant = "#191919";
        mTertiary = "#cccccc";
      };
      settings = {
        osd = {
          alwaysOnTop = false;
          location = "right";
        };
        bar = {
          density = "compact";
          position = "right";
          showCapsule = false;
          widgets = {
            left = [
              {
                id = "ControlCenter";
                useDistroLogo = false;
                icon = "skull";
                customIconPath = "";
              }
              {
                id = "WiFi";
              }
              {
                id = "Bluetooth";
              }
              {
                id = "Brightness";
                displayMode = "alwaysHide";
              }
              {
                id = "Volume";
                displayMode = "alwaysHide";
              }
            ];
            center = [
              {
                id = "Workspace";
                labelMode = "none";
                hideUnoccupied = false;
              }
            ];
            right = [
              {
                id = "Battery";
                displayMode = "alwaysHide";
                warningThreshold = 30;
              }
              {
                id = "NotificationHistory";
                hideWhenZero = false;
                showUnreadBadge = false;
              }
              {
                id = "ScreenRecorder";
              }
              {
                id = "Clock";
                formatHorizontal = "HH:mm";
                formatVertical = "HH mm";
                useMonospacedFont = true;
                usePrimaryColor = true;
              }
            ];
          };
        };
        appLauncher.useApp2Unit = true;
        colorSchemes.predefinedScheme = "Monochrome";
        general = {
          avatarImage = "${homeDir}/.face";
          #radiusRatio = 0.2;
        };
        location = {
          monthBeforeDay = true;
          name = "Oraison, France";
        };
        notifications = {
          lastSeenTs = 1757777327000;
        };
        screenRecorder.directory = "/home/ixxie/Videos";
        ui = {
          fontBillboard = "MonaspiceNe Nerd Font";
          fontDefault = "MonaspiceNe Nerd Font";
          fontFixed = "MonaspiceNe Nerd Font";
          monitorsScaling = [ ];
        };
        wallpaper = {
          directory = directory;
          monitors = [
            {
              name = "DP-2";
              directory = directory;
              wallpaper = wallpaper;
            }
            {
              name = "eDP-1";
              directory = directory;
              wallpaper = wallpaper;
            }
          ];
        };
      };
    };
  };
}
