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
      epson-escpr
    ];
  };

  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
