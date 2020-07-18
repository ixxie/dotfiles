{ config, pkgs, lib, ... }: 

  
with lib;
{ 
  config = mkIf (config.desk == "gnome") {

    services = {
      xserver = {
        displayManager.gdm = {
          enable = true;
          wayland = false;
        };
        desktopManager.gnome3.enable = true;  
      };
      illum.enable = true;
      redshift.brightness.night = 0.4;
    };
    
    environment = {
      # add some desktop applications
      systemPackages = with pkgs; [
        numix-gtk-theme
        numix-icon-theme-circle
        arc-icon-theme
        arc-theme
        gnomeExtensions.dash-to-dock
        gnome3.gnome-tweaks
      ];
  
      # GTK3 global theme (widget and icon theme)
      etc."xdg/gtk-3.0/settings.ini" = {
        text = ''
          [Settings]
          gtk-icon-theme-name=Arc
          gtk-theme-name=Arc-dark
          gtk-application-prefer-dark-theme = true
        '';
      };
    };
  };
}
