# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }: {

  # The NixOS release
	system.stateVersion = "16.09";

  # Enables all firmware shipped in linux-firmware. 
	hardware.enableAllFirmware = true;

  # Allow proprietary packages.
  nixpkgs.config.allowUnfree = true;

  imports =
    [
      ./hardware-configuration.nix
      ./fluxscript.nix
      ./fluxbase.nix
      ./fluxdev.nix
      ./efiboot.nix
      ./gnome.nix
      ./custom.nix
    ];

}
