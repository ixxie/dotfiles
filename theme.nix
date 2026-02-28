{
  pkgs,
  inputs,
  config,
  ...
}: {
  imports = [inputs.base16.nixosModule];

  # base16 color scheme
  scheme = "${inputs.tt-schemes}/base16/everforest-dark-hard.yaml";

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
