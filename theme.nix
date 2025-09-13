{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.stylix.nixosModules.stylix
  ];

  stylix = {
    enable = true;
    autoEnable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/everforest-dark-hard.yaml";
    # base16Scheme = {
    #   base00 = "#2d353b"; # bg0,       palette1 dark
    #   base01 = "#343f44"; # bg1,       palette1 dark
    #   base02 = "#475258"; # bg3,       palette1 dark
    #   base03 = "#859289"; # grey1,     palette2 dark
    #   base04 = "#9da9a0"; # grey2,     palette2 dark
    #   base05 = "#d3c6aa"; # fg,        palette2 dark
    #   base06 = "#e6e2cc"; # bg3,       palette1 light
    #   base07 = "#fdf6e3"; # bg0,       palette1 light
    #   base08 = "#e67e80"; # red,       palette2 dark
    #   base09 = "#e69875"; # orange,    palette2 dark
    #   base0A = "#dbbc7f"; # yellow,    palette2 dark
    #   base0B = "#a7c080"; # green,     palette2 dark
    #   base0C = "#83c092"; # aqua,      palette2 dark
    #   base0D = "#7fbbb3"; # blue,      palette2 dark
    #   base0E = "#d699b6"; # purple,    palette2 dark
    #   base0F = "#9da9a0"; # grey2,     palette2 dark
    # };
    opacity.terminal = 0.8;
    cursor = {
      size = 8;
      name = "graphite-dark";
      package = pkgs.graphite-cursors;
    };
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
  home-manager.users.ixxie.stylix = {
    targets = {
      swaync.enable = false;
      waybar.enable = false;
    };
    iconTheme = {
      enable = true;
      package = pkgs.numix-icon-theme-circle;
      dark = "Numix-Circle";
      light = "Numix-Circle-Light";
    };
  };
}
