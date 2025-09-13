{ pkgs, inputs, ... }:

{
  imports = [
    inputs.stylix.nixosModules.stylix
  ];

  stylix = {
    enable = true;
    autoEnable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/unikitty-dark.yaml";
    opacity.terminal = 0.8;
    cursor = {
      size = 8;
      name = "graphite-dark";
      package = pkgs.graphite-cursors;
    };
    image = ./static/casey-horner-wKjIeK4QSnk-unsplash.jpg;
    fonts = {
      serif = {
        package = pkgs.nerd-fonts.monaspace;
        name = "MonaspiceXe Nerd Font";
      };
      sansSerif = {
        package = pkgs.nerd-fonts.monaspace;
        name = "MonaspiceNe Nerd Font";
      };
      monospace = {
        package = pkgs.nerd-fonts.monaspace;
        name = "MonaspiceKr Nerd Font";
      };
      emoji = {
        package = pkgs.twemoji-color-font;
        name = "Twemoji Color";
      };
      sizes = {
        applications = 11;
        terminal = 11;
        popups = 11;
        desktop = 11;
      };
    };
  };
  home-manager.users.ixxie.stylix.iconTheme = {
    enable = true;
    package = pkgs.numix-icon-theme-circle;
    dark = "Numix-Circle";
    light = "Numix-Circle-Light";
  };
}
