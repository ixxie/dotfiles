{
  description = "contingent - ixxie's Framework 13 Ryzen 7040 series";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    base16.url = "github:SenchoPens/base16.nix";
    tt-schemes = {
      url = "github:tinted-theming/schemes";
      flake = false;
    };
    base16-helix = {
      url = "github:tinted-theming/base16-helix";
      flake = false;
    };
    base16-fish = {
      url = "github:tomyun/base16-fish";
      flake = false;
    };
    base16-yazi = {
      url = "github:tinted-theming/tinted-yazi";
      flake = false;
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia-qs = {
      url = "github:noctalia-dev/noctalia-qs/v0.0.4";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.noctalia-qs.follows = "noctalia-qs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
    };
    bun2nix = {
      url = "github:nix-community/bun2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gifplx.url = "path:/home/ixxie/repos/apps/gifplx";
  };
  outputs = inputs @ {
    nixpkgs,
    bun2nix,
    ...
  }: let
    b2n = bun2nix.packages.x86_64-linux.default;
    org = b2n.mkDerivation {
      pname = "org";
      version = "0.1.0";
      src = ./cli;
      bunDeps = b2n.fetchBunDeps {
        bunNix = ./cli/bun.nix;
      };
      module = "src/index.ts";
    };
  in {
    packages.x86_64-linux.org = org;

    nixosConfigurations.contingent = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs org;};
      modules = [
        ./hardware.nix
        ./system.nix
        ./theme.nix
        ./user.nix
        # modules
        ./modules/browsers.nix
        ./modules/claude.nix
        ./modules/cli.nix
        ./modules/design.nix
        ./modules/development.nix
        ./modules/fish.nix
        ./modules/framework.nix
        ./modules/gifplx.nix
        ./modules/ghostty.nix
        #./modules/gnome.nix
        ./modules/helix.nix
        ./modules/media.nix
        ./modules/messaging.nix
        ./modules/torrent.nix
        ./modules/niri.nix
        ./modules/nix.nix
        ./modules/yazi.nix
        ./modules/noctalia.nix
        ./modules/opencode.nix
        ./modules/orgos.nix
        ./modules/secrets.nix
        ./modules/greeter.nix
      ];
    };

    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
  };
}
