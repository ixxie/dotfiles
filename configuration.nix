{ config, pkgs, ... }: 

with builtins;

{
  # Include the following configuration modules:
  imports =
  [
    ./modules
    ./users
    ./system
  ];
}
