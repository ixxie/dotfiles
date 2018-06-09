{ config, pkgs, ... }: 

{
  # Include the following configuration modules:
  imports =
  [
    ./modules
    ./users
    ./system
#    ./modules/test.nix
  ];
}
