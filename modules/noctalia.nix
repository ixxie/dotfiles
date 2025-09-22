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
        appLauncher = {
          backgroundOpacity = 1;
          enableClipboardHistory = false;
          pinnedExecs = [ ];
          position = "center";
          sortByMostUsed = true;
          useApp2Unit = false;
        };
        audio = {
          cavaFrameRate = 60;
          mprisBlacklist = [ ];
          preferredPlayer = "";
          visualizerType = "linear";
          volumeStep = 5;
        };
        bar = {
          backgroundOpacity = 1;
          density = "compact";
          floating = false;
          marginHorizontal = 0.25;
          marginVertical = 0.25;
          monitors = [ ];
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
        brightness = {
          brightnessStep = 5;
        };
        colorSchemes = {
          darkMode = true;
          predefinedScheme = "Monochrome";
          useWallpaperColors = false;
        };
        dock = {
          autoHide = true;
          backgroundOpacity = 1;
          exclusive = false;
          floatingRatio = 1;
          monitors = [ ];
        };
        general = {
          animationSpeed = 1;
          avatarImage = "/home/ixxie/.face";
          dimDesktop = true;
          forceBlackScreenCorners = false;
          radiusRatio = 0.2;
          screenRadiusRatio = 1;
          showScreenCorners = false;
        };
        hooks = {
          darkModeChange = "";
          enabled = false;
          wallpaperChange = "";
        };
        location = {
          monthBeforeDay = true;
          name = "Oraison, France";
          showWeekNumberInCalendar = false;
          use12hourFormat = false;
          useFahrenheit = false;
        };
        matugen = {
          enableUserTemplates = false;
          foot = false;
          fuzzel = false;
          ghostty = false;
          gtk3 = false;
          gtk4 = false;
          kitty = false;
          pywalfox = false;
          qt5 = false;
          qt6 = false;
          vesktop = false;
        };
        network = {
          bluetoothEnabled = true;
          wifiEnabled = true;
        };
        nightLight = {
          autoSchedule = true;
          dayTemp = "6500";
          enabled = false;
          forced = false;
          manualSunrise = "06:30";
          manualSunset = "18:30";
          nightTemp = "4000";
        };
        notifications = {
          criticalUrgencyDuration = 15;
          doNotDisturb = false;
          lastSeenTs = 1757777327000;
          lowUrgencyDuration = 3;
          monitors = [ ];
          normalUrgencyDuration = 8;
        };
        screenRecorder = {
          audioCodec = "opus";
          audioSource = "default_output";
          colorRange = "limited";
          directory = "/home/ixxie/Videos";
          frameRate = 60;
          quality = "very_high";
          showCursor = true;
          videoCodec = "h264";
          videoSource = "portal";
        };
        settingsVersion = 2;
        ui = {
          fontBillboard = "MonaspiceNe Nerd Font";
          fontDefault = "MonaspiceNe Nerd Font";
          fontFixed = "MonaspiceNe Nerd Font";
          idleInhibitorEnabled = false;
          monitorsScaling = [ ];
        };
        wallpaper = {
          directory = directory;
          enableMultiMonitorDirectories = false;
          enabled = true;
          fillColor = "#000000";
          fillMode = "crop";
          monitors = [
            {
              directory = directory;
              name = "DP-2";
              wallpaper = wallpaper;
            }
            {
              directory = directory;
              name = "eDP-1";
              wallpaper = wallpaper;
            }
          ];
          randomEnabled = false;
          randomIntervalSec = 300;
          setWallpaperOnAllMonitors = true;
          transitionDuration = 1500;
          transitionEdgeSmoothness = 0.05;
          transitionType = "random";
        };
      };
    };
  };
}
