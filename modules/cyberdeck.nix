{
  pkgs,
  config,
  inputs,
  ...
}: let
  s = config.scheme;
in {
  imports = [
    inputs.cyberdeck.nixosModules.default
  ];

  services.cyberdeck = {
    enable = true;
    settings = {
      position = "bottom";
      font = "MonaspiceKr Nerd Font";
      background = {
        color = "#${s.base00}";
        opacity = 0.8;
      };
      output-scales = {
        "DP-2" = 0.8;
        "eDP-1" = 0.8;
      };
    };
    mods = {
      calendar.enable = true;
      workspaces.enable = true;
      network.enable = true;
      session.enable = true;
      profiles.enable = true;
      audio.enable = true;
      bluetooth.enable = true;
      system.enable = true;
      brightness.enable = true;
      media.enable = true;
      notifications.enable = true;
      weather.enable = true;
      storage.enable = true;
      launcher.enable = true;
      window.enable = true;
      wallpaper = {
        enable = true;
        params.dir = "~/media/wallpapers";
      };
    };
  };
}
