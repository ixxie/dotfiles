{
  description = "contingent - ixxie's Framework 13 Ryzen 7040 series";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      #url = "path:/home/ixxie/repos/foss/noctalia-shell";
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    retrobar = {
      url = "path:/home/ixxie/repos/retroshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
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
    cella = {
      url = "path:/home/ixxie/repos/cella";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.microvm.follows = "microvm";
      inputs.home-manager.follows = "home-manager";
    };
  };
  outputs = inputs @ {
    nixpkgs,
    bun2nix,
    cella,
    ...
  }: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    lib = nixpkgs.lib;
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
        ./modules/cella.nix
        ./modules/claude.nix
        ./modules/cli.nix
        ./modules/design.nix
        ./modules/development.nix
        ./modules/fish.nix
        ./modules/framework.nix
        ./modules/ghostty.nix
        ./modules/gnome.nix
        ./modules/helix.nix
        ./modules/media.nix
        ./modules/niri.nix
        ./modules/nix.nix
        ./modules/noctalia.nix
        #./modules/retrobar.nix
        ./modules/secrets.nix
        ./modules/xserver.nix
      ];
    };

    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
  };
}
