{ config, pkgs, ... }:

{
  imports = [
    ./cli.nix
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
