{ config, pkgs, ... }: 

{
  # Include the following configuration modules:
  imports = [
    ./cfg/gear/meso
    ./cfg/user
    ./core
    ./desk
  ];

  # Enter hostname (network name for the machine configuration).
  networking.hostName = "meso"; 

  # Gnome desktop environment
  desk = "gnome";
  
  # Set your time zone.
  time.timeZone = "Europe/Helsinki";

}
