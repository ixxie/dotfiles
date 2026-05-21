{lib, ...}: let
  inherit (import ./lib.nix {inherit lib;}) mkProfile;
in {
  config.home-manager.users.ixxie.home.file = mkProfile {
    dir = ".claude-qualia";
  };
}
