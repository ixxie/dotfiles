{ config, pkgs, lib, ... }:

with lib; {
  config = mkIf (config.desk != "none") {
    environment = {
      # add some desktop applications
      systemPackages = with pkgs; [ krita gimp inkscape simple-scan ffmpeg ];
    };

    fonts.fonts = with pkgs; [
      source-code-pro
      powerline-fonts
      font-awesome_5
      inter-ui
      google-fonts
    ];
  };
}
