{ config, pkgs, ... }: 

{
  # Include the following configuration modules:
  imports = [
    ./machines/meso
    ./users
    ./core
    ./desktops
    ./devices
    ./programs
  ];

  # Enter hostname (network name for the machine configuration).
  networking.hostName = "meso"; 

  # Gnome desktop environment
  desk = "gnome";
  
  # Set your time zone.
  time.timeZone = "Europe/Helsinki";
}