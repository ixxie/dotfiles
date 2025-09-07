{ pkgs, ... }:

{
  services = {
    xserver.desktopManager.gnome.enable = true;
    gnome.core-utilities.enable = false;
  };

  environment.systemPackages = with pkgs; [
    gnome-tweaks
    gtk-engine-murrine
    gnomeExtensions.dash-to-dock
    gnomeExtensions.paperwm
    gnomeExtensions.vertical-workspaces
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.dash-to-panel
    dconf
    dconf-editor
  ];
}
