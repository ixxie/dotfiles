{ pkgs, ... }:

{
  services = {
    xserver = {
      enable = true;
      desktopManager.gnome.enable = true;
      displayManager.gdm.enable = true;
    };
    gnome.core-utilities.enable = false;
    illum.enable = true;
  };

  environment.systemPackages = with pkgs; [
    gnome-tweaks
    gtk-engine-murrine
    gnomeExtensions.dash-to-dock
    gnomeExtensions.paperwm
    gnomeExtensions.vertical-workspaces
    gnomeExtensions.screen-rotate
    dconf
    dconf-editor
    # file browser
    xarchiver
  ];

  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-media-tags-plugin
    ];
  };

  home-manager.users.ixxie = {
    gtk = {
      enable = true;

      iconTheme = {
        name = "Numix-Circle";
        package = pkgs.numix-icon-theme-circle;
      };

      gtk3.extraConfig = {
        Settings = ''
          gtk-application-prefer-dark-theme=1
        '';
      };

      gtk4.extraConfig = {
        Settings = ''
          gtk-application-prefer-dark-theme=1
        '';
      };
    };
    home.sessionVariables.GTK_THEME = "Numix";
  };

  services.printing.enable = true;
}
