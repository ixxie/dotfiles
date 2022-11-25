{ config, pkgs, ... }:

{
  imports = [
    ./settings.nix
    ./options.nix
    ./cli.nix
    ./docker.nix
    ./nix.nix
    ./frontend.nix
  ];
}
