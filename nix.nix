{
  pkgs,
  inputs,
  config,
  ...
}: let
  colmena = inputs.colmena.packages.x86_64-linux.colmena;
in {
  sops.secrets.nix-access-tokens = {
    mode = "0440";
    owner = "ixxie";
    group = "nixbld";
  };

  # Basic Package Suite
  environment.systemPackages = with pkgs; [
    nixVersions.latest
    nix-prefetch-git
    nixfmt
    glibcLocales # nix locale bug
    nixos-anywhere
    colmena
    sops
  ];

  # user-level nix config so flake commands (not just daemon) have the token
  sops.secrets.nix-access-tokens-user = {
    sopsFile = ./secrets.yaml;
    key = "nix-access-tokens";
    mode = "0400";
    owner = "ixxie";
    path = "/home/ixxie/.config/nix/nix.conf";
  };

  nix = {
    gc.automatic = true;
    extraOptions = ''
      !include ${config.sops.secrets.nix-access-tokens.path}
    '';
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = [
        "https://cache.nixos.org/"
        "https://niri.cachix.org"
        "https://nix-community.cachix.org"
        "https://microvm.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "microvm.cachix.org-1:oXnBc6hRE3eX5rSYdRyMYXnfzcCxC7yKPTbZXALsqys="
      ];
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
  };
}
