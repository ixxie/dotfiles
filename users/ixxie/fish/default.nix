{ pkgs, ... }:

{
  programs.fish = {
    enable = true;
    shellAliases = {
      shift = "make --directory=/home/ixxie/repos/shiftspace/";
      supabase = "(cd /home/ixxie/repose/supabase-cli; go run . $@)";
    };
  };
}
