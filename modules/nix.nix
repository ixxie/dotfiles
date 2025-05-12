{ pkgs, inputs, ... }:

let
  colmena = inputs.colmena.packages.x86_64-linux.colmena;
in
{
  # Basic Package Suite
  environment.systemPackages = with pkgs; [
    nixVersions.latest
    nix-prefetch-git
    nixfmt-rfc-style
    glibcLocales # nix locale bug
    nixos-anywhere
    colmena
  ];

  nix = {
    gc.automatic = true;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  nixpkgs.config.allowBroken = true;

  # home-manager.users.ixxie.programs = {
  #   direnv = {
  #     enable = true;
  #     enableNushellIntegration = true;
  #     enableBashIntegration = true;
  #     nix-direnv.enable = true;
  #   };
  # };
}
