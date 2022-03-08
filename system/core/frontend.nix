{ config, pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [
      # basic js dev tools
      yarn nodejs-14_x
    ];
  };
}