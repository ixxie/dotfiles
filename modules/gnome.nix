{ pkgs, ... }:

{
  services = {
    desktopManager.gnome.enable = true;
    gnome.core-apps.enable = false;
  };

  environment.gnome.excludePackages = with pkgs; [
    orca
  ];

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
