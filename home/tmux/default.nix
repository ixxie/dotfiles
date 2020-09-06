{ pkgs, ... }:

{
  home.file.".tmux.conf".source = ./tmux.conf;
}
