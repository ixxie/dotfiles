{ config, pkgs, lib, ... }: 

with lib;
{ 
  config = mkIf (config.desk != "none") {
    services = {
      # enable the X11 windowing system
      xserver = {
        enable = true;
        xkbOptions = "eurosign:e";
        desktopManager.xterm.enable = false;
        displayManager = {
          defaultSession = "gnome";
          gdm.enable = true;
        };
      };
    };
  };
}
