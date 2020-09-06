{ config, pkgs, ... }: 

{
  imports = [
    ./design.nix
    ./gaming.nix
    ./media.nix
    ./telecom.nix
    ./utilities.nix
  ];

}
