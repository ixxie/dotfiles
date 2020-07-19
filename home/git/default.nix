{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "Matan Shenhav";
    userEmail = "matan@fluxcraft.net";
    extraConfig = builtins.readFile ./gitconfig;
  };
}