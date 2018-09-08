{ config, pkgs, ... }: 

{
  # Include the following configuration modules:
  imports =
  [
    ./modules/base.nix
    ./modules/gnome.nix
    ./modules/fluxcraft.nix
    ./modules/xps
    ./users
  ];

  # Enter hostname (network name for the machine configuration).
  networking.hostName = "meso"; 

  # Gnome desktop environment
  desktop = "gnome";
  
  # Set your time zone.
  time.timeZone = "Europe/Helsinki";

}
