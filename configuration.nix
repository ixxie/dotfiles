{ config, pkgs, ... }: 

{
  # Include the following configuration modules:
  imports =
  [
    ./system
    ./modules
  ]
  ++ (if
        (builtins.pathExists(./users/default.nix))
      then
        [./users ]
      else
        []
    );
}
