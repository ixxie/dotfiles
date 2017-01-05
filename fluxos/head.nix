
{ config, pkgs, ... }: 

{

  # The NixOS release
	system.stateVersion = "16.09";

  # Enables all firmware shipped in linux-firmware. 
	hardware.enableAllFirmware = true;

  # Allow proprietary packages.
  nixpkgs.config.allowUnfree = true;

}