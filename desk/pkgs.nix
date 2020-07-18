{ config, pkgs, lib, ... }: 

let
  inter = pkgs.callPackage ../pkg/inter.nix {};
in
with lib;
{ 
  config = mkIf (config.desk != "none") {
    environment = {
      # add some desktop applications
      systemPackages = with pkgs; [
        evince
        firefox
        gparted
        gimp
        inkscape
        riot-web
        signal-desktop
        transmission_gtk
        vlc
        simple-scan
      ];
    };
    
    fonts.fonts = 
      with pkgs; [ 
        source-code-pro
        powerline-fonts
        font-awesome_5
        inter
    ];
  };
}
