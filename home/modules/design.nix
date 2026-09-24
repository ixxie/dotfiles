# corpus:article/architecture
{pkgs, ...}:
with pkgs; {
  environment.systemPackages = [
    # krita  # broken: lager fails to find boost_system with Boost 1.89
    inkscape
    gimp  # gimp-with-plugins bundles GIMP 2-only plugins (farbfeld) that fail on 3.x
    ffmpeg
    pdftk
    gthumb
    imagemagick
  ];
  fonts.packages = with pkgs; [
    source-code-pro
    google-fonts
  ];
}
