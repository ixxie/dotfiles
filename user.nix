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
          BROWSER = "firefox";
          TERMINAL = "ghostty";
        };
      };
      programs.yazi = {
        enable = true;
        settings = {
          opener = {
            open = [
              {
                run = ''xdg-open "$@"'';
                orphan = true;
                desc = "Open with default application";
              }
            ];
          };
          open = {
            rules = [
              {
                mime = "*";
                use = "open";
              }
            ];
          };
        };
      };
      xdg = {
        enable = true;
        mimeApps = {
          enable = true;
          defaultApplications = {
            "video/mp4" = "io.github.celluloid_player.Celluloid.desktop";
            "video/x-matroska" = "io.github.celluloid_player.Celluloid.desktop";
            "video/webm" = "io.github.celluloid_player.Celluloid.desktop";
            "video/mpeg" = "io.github.celluloid_player.Celluloid.desktop";
            "video/quicktime" = "io.github.celluloid_player.Celluloid.desktop";
            "video/x-msvideo" = "io.github.celluloid_player.Celluloid.desktop";
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
    ];
    isNormalUser = true;
    shell = pkgs.nushell;
  };
}
