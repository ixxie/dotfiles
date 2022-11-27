{ config, pkgs, lib, ... }:

with lib; {

  services = {
    xserver.desktopManager.gnome.enable = true;
    illum.enable = true;
  };

  environment = {
    # add some desktop applications
    systemPackages = with pkgs; [
      numix-gtk-theme
      numix-icon-theme-circle
      arc-icon-theme
      arc-theme
      gnomeExtensions.workspace-matrix
      gnomeExtensions.dash-to-dock
      gnomeExtensions.sound-output-device-chooser
      gnome.gnome-tweaks
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
}
