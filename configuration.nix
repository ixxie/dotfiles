# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }: 

{

  imports =
    [
      ./host.nix
      ./hardware-configuration.nix
      ./fluxscript.nix
      ./fluxbase.nix
      ./fluxdev.nix
      ./efiboot.nix
      ./gnome.nix
      ./custom.nix
    ];
}
