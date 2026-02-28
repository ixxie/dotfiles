{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.retrobar.nixosModules.default
  ];

  services.retrobar = {
    enable = true;
    extraConfig = {
      settings = {
        position = "top";
        font = "MonaspiceKr Nerd Font Mono";
        font-size = 11;
        background = {
          color = "#000000";
          opacity = 0.0;
        };
      };
      modules = {
        time.enable = true;
        workspaces.enable = true;
        network.enable = true;
        power.enable = true;
        system.enable = true;
        audio.enable = true;
        bluetooth.enable = true;
        display.enable = true;
        storage.enable = true;
        weather.enable = true;
        launcher.enable = true;
        media.enable = true;
        notifications.enable = true;
        window.enable = true;
      };
    };
  };
}
