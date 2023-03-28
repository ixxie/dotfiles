{ config, pkgs, ... }:

{
  # Basic Package Suite
  environment = {
    systemPackages = with pkgs; [
      nixUnstable
      nix-prefetch-git
      nixfmt
      glibcLocales # nix locale bug
    ];
  };

  nix = {
    gc.automatic = true;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };
}
