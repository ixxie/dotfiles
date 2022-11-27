{ config, pkgs, ... }:

{
  imports =
    [ ./cli.nix ./docker.nix ./nix.nix ./frontend.nix ./python.nix ./go.nix ];
}
