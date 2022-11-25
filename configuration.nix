{ config, pkgs, ... }:

{
  system.stateVersion = "22.11";

  # Include the following configuration modules:
  imports = [
    <home-manager/nixos>
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
  time.timeZone = "Europe/Paris";
}
