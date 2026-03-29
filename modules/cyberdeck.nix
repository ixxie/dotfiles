{
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
      layout = "pills";
      gap = 8;
      theme = {
        #color = "#${s.base00}";
        #opacity = 0;
      };
      monitors = {
        "DP-2" = {scale = 0.8;};
        "eDP-1" = {scale = 0.8;};
      };
    };
    mods = {
      calendar.enable = true;
      workspaces.enable = true;
      network.enable = true;
      session.enable = true;
      profiles.enable = true;
      outputs.enable = true;
      inputs.enable = true;
      bluetooth.enable = true;
      system.enable = true;
      brightness.enable = true;
      notifications.enable = true;
      weather = {
        enable = true;
        location = "Oraison";
      };
      recording.enable = true;
      screenshot.enable = true;
      storage.enable = true;

      window.enable = true;
      wallpaper = {
        enable = true;
        dir = "~/media/wallpapers";
      };
    };
  };
}
