{
  description = "contingent - ixxie's Framework 13 Ryzen 7040 series";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    stylix.url = "github:danth/stylix";
    hl.url = "github:pamburus/hl";
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      nixos-hardware,
      home-manager,
      stylix,
      ...
    }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.contingent = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = inputs;
        modules = [
          stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager
          nixos-hardware.nixosModules.framework-13-7040-amd
          ./system.nix
          ./user.nix
          ./theme.nix
          # modules
          ./modules/cli.nix
          ./modules/design.nix
          ./modules/desktop.nix
          ./modules/development.nix
          ./modules/editor.nix
          ./modules/framework.nix
          ./modules/hardware.nix
          ./modules/media.nix
          ./modules/nix.nix
          ./modules/shell.nix
        ];
      };
    };
}
