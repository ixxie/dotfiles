{ pkgs, ... }:

{
  programs.fish = {
    enable = true;
    shellAliases = {
      shift = "make --directory=/home/ixxie/repos/shiftspace/";
      supabase = "/home/ixxie/repos/.utilities/supabase-cli/cli";
      gen = "sudo nixos-rebuild switch";
      gc = ''
        sudo nix-collect-garbage --delete-older-than 7d &&
        nix-store --optimise &&
        sudo nixos-rebuild switch;
      '';
    };
  };
}
