{
  description = "contingent - ixxie's Framework 13 Ryzen 7040 series";

  outputs = inputs @ {nixpkgs, ...}: {
    nixosConfigurations.contingent = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        # host
        ./device.nix
        ./hardware.nix
        ./nix.nix
        ./system.nix
        ./theme.nix
        ./user.nix

        # lib
        ./lib/secret.nix

        # shell
        ./modules/cli.nix
        ./modules/fish.nix
        ./modules/helix.nix
        ./modules/ghostty.nix
        ./modules/yazi.nix
        ./cella/cella.nix

        # desktop
        ./modules/niri.nix
        ./modules/cyberdeck.nix
        ./modules/greeter.nix
        ./modules/gifplx.nix

        # apps
        ./modules/browsers.nix
        ./modules/messaging.nix
        ./modules/media.nix
        ./modules/design.nix
        ./modules/torrent.nix

        # dev
        ./modules/development.nix
        ./modules/claude
        ./modules/opencode.nix
      ];
    };

    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
  };

  inputs = {
    base16.url = "github:SenchoPens/base16.nix";
    cella = {
      url = "path:/home/ixxie/repos/org/cella";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cyberdeck = {
      url = "path:/home/ixxie/repos/org/cyberdeck";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gifplx.url = "path:/home/ixxie/repos/apps/gifplx";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
    };
  };
}
