{ config, pkgs, ... }: 

{
  # Include the following configuration modules:
  imports =
  [
    ./modules
  ]
  ++ (if
        (builtins.pathExists(./systems/default.nix))
      then
        [./systems ]
      else
        []
      )
  ++ (if
        (builtins.pathExists(./users/default.nix))
      then
        [./users ]
      else
        []
    );
}
