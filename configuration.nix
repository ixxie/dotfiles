{ config, pkgs, ... }:

{
  system.stateVersion = "22.11";

  # Include the following configuration modules:
  imports =
    [ <home-manager/nixos> ./machine ./user ./coding ./desktop ./programs ];

  # Enter hostname (network name for the machine configuration).
  networking.hostName = "meso";

  # Set your time zone.
  time.timeZone = "Europe/Paris";
}
