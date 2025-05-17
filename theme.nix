{ pkgs, inputs, ... }:

{
  imports = [
    inputs.stylix.nixosModules.stylix
  ];

  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/unikitty-dark.yaml";
    opacity.terminal = 0.8;
    image = ./static/jr-korpa-O-p6tKWPPig-unsplash.jpg;
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
        applications = 10;
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
