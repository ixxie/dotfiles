{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];
  home-manager = {
    backupFileExtension = "backup";
    users.ixxie = {
      nixpkgs.config.allowUnfree = true;
      home = {
        stateVersion = "24.05";
        username = "ixxie";
        sessionVariables = {
          EDITOR = "hx";
          BROWSER = "zen";
          TERMINAL = "ghostty";
        };
      };
      xdg = {
        enable = true;
        desktopEntries = {
          zen-beta = {
            name = "Zen";
            exec = "zen-beta --name zen-beta %U";
            icon = "zen-browser";
            genericName = "Web Browser";
            startupNotify = true;
            categories = [ "Network" "WebBrowser" ];
            mimeType = [
              "text/html" "text/xml" "application/xhtml+xml"
              "application/vnd.mozilla.xul+xml"
              "x-scheme-handler/http" "x-scheme-handler/https"
            ];
            settings.StartupWMClass = "zen-beta";
          };
          gimp = {
            name = "GIMP";
            exec = "gimp-3.0 %U";
            icon = "gimp";
            genericName = "Image Editor";
            categories = [ "Graphics" "2DGraphics" "RasterGraphics" ];
            mimeType = [
              "image/bmp" "image/gif" "image/jpeg" "image/png"
              "image/svg+xml" "image/tiff" "image/webp"
            ];
            settings.StartupWMClass = "gimp";
          };
        };
        mimeApps = {
          enable = true;
          defaultApplications = {
            "text/html" = "zen-beta.desktop";
            "x-scheme-handler/http" = "zen-beta.desktop";
            "x-scheme-handler/https" = "zen-beta.desktop";
            "x-scheme-handler/about" = "zen-beta.desktop";
            "x-scheme-handler/unknown" = "zen-beta.desktop";
            "video/mp4" = "io.github.celluloid_player.Celluloid.desktop";
            "video/x-matroska" = "io.github.celluloid_player.Celluloid.desktop";
            "video/webm" = "io.github.celluloid_player.Celluloid.desktop";
            "video/mpeg" = "io.github.celluloid_player.Celluloid.desktop";
            "video/quicktime" = "io.github.celluloid_player.Celluloid.desktop";
            "video/x-msvideo" = "io.github.celluloid_player.Celluloid.desktop";
            "image/png" = "viu.desktop";
            "image/jpeg" = "viu.desktop";
            "image/gif" = "viu.desktop";
            "image/webp" = "viu.desktop";
            "image/bmp" = "viu.desktop";
            "image/svg+xml" = "viu.desktop";
            "image/tiff" = "viu.desktop";
            "application/pdf" = "zen-beta.desktop";
          };
        };
      };
    };
  };

  users.users.ixxie = {
    home = "/home/ixxie";
    extraGroups = [
      "wheel"
      "networkmanager"
      "adbusers"
      "audio"
      "docker"
      "input"
    ];
    isNormalUser = true;
    shell = pkgs.fish;
  };
}
