{
  pkgs,
  inputs,
  config,
  ...
}: {
  imports = [inputs.base16.nixosModule];

  # base16 color scheme (everforest dark hard by Sainnhe Park)
  scheme = {
    slug = "everforest-dark-hard";
    scheme = "Everforest Dark Hard";
    author = "Sainnhe Park (https://github.com/sainnhe)";
    base00 = "272e33"; # bg0
    base01 = "2e383c"; # bg1
    base02 = "414b50"; # bg3
    base03 = "859289"; # grey1
    base04 = "9da9a0"; # grey2
    base05 = "d3c6aa"; # fg
    base06 = "edeada"; # bg3 light
    base07 = "fffbef"; # bg0 light
    base08 = "e67e80"; # red
    base09 = "e69875"; # orange
    base0A = "dbbc7f"; # yellow
    base0B = "a7c080"; # green
    base0C = "83c092"; # aqua
    base0D = "7fbbb3"; # blue
    base0E = "d699b6"; # purple
    base0F = "9da9a0"; # grey2
  };

  # fonts
  fonts.packages = [
    pkgs.nerd-fonts.monaspace
    pkgs.twemoji-color-font
  ];
  fonts.fontconfig.defaultFonts = {
    serif = ["MonaspiceXe Nerd Font"];
    sansSerif = ["MonaspiceNe Nerd Font"];
    monospace = ["MonaspiceKr Nerd Font"];
    emoji = ["Twemoji Color"];
  };

  home-manager.users.ixxie = {
    # cursor
    home.pointerCursor = {
      size = 6;
      name = "graphite-dark";
      package = pkgs.graphite-cursors;
      gtk.enable = true;
    };

    # icons
    gtk = {
      enable = true;
      font = {
        name = "MonaspiceNe Nerd Font";
        size = 11;
      };
      iconTheme = {
        name = "Numix-Circle";
        package = pkgs.numix-icon-theme-circle;
      };
    };

    fonts.fontconfig.enable = true;

    # dconf font settings (read by GTK/GNOME apps)
    dconf.settings."org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      font-name = "MonaspiceNe Nerd Font 11";
      document-font-name = "MonaspiceXe Nerd Font 11";
      monospace-font-name = "MonaspiceKr Nerd Font 11";
    };
  };
}
