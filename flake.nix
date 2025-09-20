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
    quickshell = {
      url = "github:outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "path:/home/ixxie/repos/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.quickshell.follows = "quickshell";
    };
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      ...
    }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.contingent = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./system.nix
          ./user.nix
          ./theme.nix
          # modules
          ./modules/claude.nix
          ./modules/cli.nix
          ./modules/design.nix
          ./modules/development.nix
          ./modules/framework.nix
          ./modules/ghostty
          ./modules/gnome.nix
          ./modules/hardware.nix
          ./modules/hyprland.nix
          ./modules/helix.nix
          ./modules/media.nix
          ./modules/niri.nix
          ./modules/nix.nix
          ./modules/noctalia
          ./modules/nushell
          ./modules/xserver.nix
        ];
      };
    };
}
