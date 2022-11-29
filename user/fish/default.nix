{ pkgs, ... }:

{
  programs.fish = {
    enable = true;
    shellAliases = {
      shift = "make --directory=/home/ixxie/repos/shiftspace/";
      supabase = "cd /home/ixxie/repos/.utilities/supabase-cli && go run .";
      nixos = "sudo nixos-rebuild switch";
      gc = ''
        sudo nix-collect-garbage --delete-older-than 7d &&
        nix-store --optimise &&
        sudo nixos-rebuild switch;
      '';
    };
  };
}
