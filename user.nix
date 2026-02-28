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
      "libvirtd"
      "input"
    ];
    isNormalUser = true;
    shell = pkgs.fish;
  };
}
