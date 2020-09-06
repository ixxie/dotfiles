{ config, pkgs, lib, ... }: 

let
  inter = pkgs.callPackage ../packages/inter.nix {};
in
with lib;
{ 
  config = mkIf (config.desk != "none") {
    environment = {
      # add some desktop applications
      systemPackages = with pkgs; [
        krita
        gimp
        inkscape
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
