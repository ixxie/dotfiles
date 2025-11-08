{pkgs, ...}:
with pkgs; {
  environment.systemPackages = [
    krita
    inkscape
    gimp-with-plugins
    ffmpeg
    pdftk
    gthumb
    imagemagick
    libreoffice
  ];
  fonts.packages = with pkgs; [
    source-code-pro
    google-fonts
  ];
}
