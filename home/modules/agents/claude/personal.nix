# corpus:article/architecture
{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (import ./lib.nix {inherit lib pkgs;}) mkProfile mkPalette;
in {
  config.home-manager.users.ixxie = mkProfile {
    dir = ".claude";
    settings.theme = "custom:everforest";
    settings.tui = "fullscreen";
    themes.everforest = {
      name = "Everforest";
      base = "dark";
      overrides = mkPalette config.scheme;
    };
  };
}
