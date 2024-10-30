{ ... }:

{
  fonts.fontconfig = {
    enable = true;
    useEmbeddedBitmaps = true;
    defaultFonts = {
      emoji = [
        "Noto Color Emoji"
      ];
      sansSerif = [
        "Overpass"
      ];
      monospace = [
        "Overpass Mono"
      ];
    };
  };
}
