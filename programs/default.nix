{ config, pkgs, ... }:

{
  imports = [
    ./cli.nix
    ./cloud.nix
    ./db.nix
    ./design.nix
    ./media.nix
    ./telecom.nix
    ./utilities.nix
    ./frontend.nix
    ./backend.nix
    ./lsp.nix
  ];
}
