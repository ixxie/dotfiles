{lib, ...}: let
  inherit (import ./lib.nix {inherit lib;}) mkProfile;
in {
  config.home-manager.users.ixxie = mkProfile {
    dir = ".claude-qualia";
  };
}
