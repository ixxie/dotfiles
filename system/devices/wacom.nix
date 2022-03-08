{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ wacomtablet libwacom libinput ];
}
