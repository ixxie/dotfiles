{ pkgs, ... }:

{
  programs.fish = {
    enable = true;
    shellAliases = {
      shift = "make --directory=/home/ixxie/repos/shiftspace/";
      supabase = "cd /home/ixxie/repos/supabase-cli; go run . $argv;";
      nixos = "sudo nixos-rebuild switch";
    };
  };
}
