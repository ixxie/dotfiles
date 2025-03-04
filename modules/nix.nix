{ pkgs, ... }:

{
  # Basic Package Suite
  environment.systemPackages = with pkgs; [
    nixVersions.git
    nix-prefetch-git
    nixfmt-rfc-style
    glibcLocales # nix locale bug
  ];

  nix = {
    gc.automatic = true;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  nixpkgs.config.allowBroken = true;
}
