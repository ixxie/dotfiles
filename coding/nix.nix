{ config, pkgs, ... }:

{
  # Basic Package Suite
  environment = {
    systemPackages = with pkgs; [ nixUnstable nix-prefetch-git nixfmt ];
  };

  nix = {
    gc.automatic = true;
    nixPath = [
      "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
      "nixos-config=/etc/nixos/configuration.nix"
      "/nix/var/nix/profiles/per-user/root/channels"
      "npmlock2nix=/home/ixxie/repos/npmlock2nix"
    ];
  };
}
