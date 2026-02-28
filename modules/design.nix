{pkgs, ...}:
with pkgs; {
  environment.systemPackages = [
    # krita  # broken: lager fails to find boost_system with Boost 1.89
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
