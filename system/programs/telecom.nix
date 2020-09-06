{ config, pkgs, lib, ... }: 

with lib;
{ 
  config = mkIf (config.desk != "none") {
    environment = {
      # add some desktop applications
      systemPackages = with pkgs; [
        firefox
        riot-web
        signal-desktop
        discord-canary
      ];
    };
  };
}