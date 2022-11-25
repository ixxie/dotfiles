{ config, pkgs, ... }:

{
  # Basic Package Suite
  environment = {
    systemPackages = with pkgs; [
      direnv
      home-manager
      morph
      nixUnstable
      nix-prefetch-git
      nix-index
      nixfmt
    ];
  };

  services.lorri.enable = true;

  nix.nixPath = [
    "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
    "nixos-config=/etc/nixos/configuration.nix"
    "/nix/var/nix/profiles/per-user/root/channels"
    "npmlock2nix=/home/ixxie/repos/npmlock2nix"
  ];
}
