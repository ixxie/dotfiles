{ config, pkgs, ... }:

{
  imports = [ ./settings.nix ./options.nix ./cli.nix ];
}
