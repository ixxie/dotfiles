{ pkgs, inputs, ... }:

let
  colmena = inputs.colmena.packages.x86_64-linux.colmena;
in
{
  # Basic Package Suite
  environment.systemPackages = with pkgs; [
    nixVersions.latest
    nix-prefetch-git
    nixfmt-rfc-style
    glibcLocales # nix locale bug
    nixos-anywhere
    colmena
  ];

  nix = {
    gc.automatic = true;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = [
        "https://cache.nixos.org/"
        "https://niri.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
  };

  # home-manager.users.ixxie.programs = {
  #   direnv = {
  #     enable = true;
  #     enableNushellIntegration = true;
  #     enableBashIntegration = true;
  #     nix-direnv.enable = true;
  #   };
  # };
}
