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

  environment = {
    systemPackages = with pkgs; [
      gnome-tweaks
      nautilus
      gtk-engine-murrine
      gnomeExtensions.dash-to-dock
      gnomeExtensions.paperwm
      gnomeExtensions.vertical-workspaces
      gnomeExtensions.screen-rotate
      dconf
      dconf-editor
      canon-cups-ufr2
    ];
  };

  services.printing.enable = true;
}
