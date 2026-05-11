{
  description = "contingent - ixxie's Framework 13 Ryzen 7040 series";

  outputs = inputs @ {nixpkgs, ...}: let
    pkgs = import nixpkgs {
      overlays = [inputs.opencode.overlays.default];
    };
    # Upstream paseo's pinned npmDepsHash was computed against paseo's own
    # nixpkgs revision; our follow'd nixpkgs computes a different one for the
    # same package-lock.json. Override via .override (requires PR #923).
    paseo-pkg = inputs.paseo.packages.x86_64-linux.default.override {
      npmDepsHash = "sha256-FzJUt3N6JEd9S7GI6BB32AsSHLqqQsq8xXA85dissq4=";
    };
  in {
    nixosConfigurations.contingent = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs paseo-pkg;};
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

        # desktop
        ./modules/niri.nix
        ./modules/cyberdeck.nix
        ./modules/greeter.nix
        ./modules/voyager/voyager.nix

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
        ./modules/pi.nix
        ./modules/vitro.nix
        inputs.paseo.nixosModules.paseo
      ];
    };

    formatter.x86_64-linux = pkgs.alejandra;
  };

  inputs = {
    base16.url = "github:SenchoPens/base16.nix";
    zapp = {
      url = "path:/home/ixxie/repos/foss/zapp";
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
      url = "path:/home/ixxie/repos/lab/cyberdeck";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    janeway = {
      url = "path:/home/ixxie/repos/foss/janeway";
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
    opencode = {
      url = "github:dan-online/opencode-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    paseo = {
      url = "path:/home/ixxie/repos/foss/paseo";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pi-mono = {
      url = "github:lukasl-dev/pi-mono.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vitro = {
      url = "path:/home/ixxie/repos/lab/vitro";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
    };
  };
}
