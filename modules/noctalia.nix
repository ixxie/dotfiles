{
  pkgs,
  inputs,
  ...
}:

let
  directory = "/home/ixxie/Pictures/Wallpapers";
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
        settingsVersion = 2;
        bar = {
          density = "compact";
          position = "right";
          showCapsule = false;
          widgets = {
            left = [
              {
                id = "SidePanelToggle";
                useDistroLogo = true;
              }
              {
                id = "WiFi";
              }
              {
                id = "Bluetooth";
              }
              {
                alwaysShowPercentage = false;
                id = "Brightness";
              }
              {
                alwaysShowPercentage = false;
                id = "Volume";
              }
            ];
            center = [
              {
                hideUnoccupied = false;
                id = "Workspace";
                labelMode = "none";
              }
            ];
            right = [
              {
                alwaysShowPercentage = false;
                id = "Battery";
                warningThreshold = 30;
              }
              {
                hideWhenZero = false;
                id = "NotificationHistory";
                showUnreadBadge = false;
              }
              {
                id = "ScreenRecorderIndicator";
              }
              {
                formatHorizontal = "HH:mm";
                formatVertical = "HH mm";
                id = "Clock";
                useMonospacedFont = true;
                usePrimaryColor = true;
              }
            ];
          };
        };
        colorSchemes.predefinedScheme = "Monochrome";
        general = {
          avatarImage = "/home/ixxie/.face";
          radiusRatio = 0.2;
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
