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
      url = "github:noctalia-dev/noctalia-qs/v0.0.8";
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
    # orgos = {
    #   url = "path:/home/ixxie/repos/org/orgos";
    #   inputs.nixpkgs.follows = "nixpkgs";
    #   inputs.home-manager.follows = "home-manager";
    #   inputs.microvm.follows = "microvm";
    # };
  };
  outputs = inputs @ {
    nixpkgs,
    ...
  }: {
    nixosConfigurations.contingent = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        # frameworks
        #inputs.orgos.nixosModules.default

        # host
        ./hardware.nix
        ./system.nix
        ./theme.nix
        ./user.nix

        # desktop
        ./modules/niri.nix
        ./modules/noctalia.nix
        ./modules/greeter.nix

        # tools
        ./modules/fish.nix
        ./modules/helix.nix
        ./modules/ghostty.nix
        ./modules/yazi.nix

        # apps
        ./modules/browsers.nix
        ./modules/messaging.nix
        ./modules/media.nix
        ./modules/design.nix
        ./modules/torrent.nix

        # dev
        ./modules/development.nix
        ./modules/claude.nix
        ./modules/opencode.nix
        #./modules/orgos.nix

        # system
        ./modules/nix.nix
        ./modules/cli.nix
        ./modules/framework.nix
        ./modules/gifplx.nix
      ];
    };

    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
  };
}
