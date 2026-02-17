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
    };
  };
}
