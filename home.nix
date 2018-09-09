{ pkgs, ... }:
 
{
    
  home.file.".tmux.conf".source = ./tmux/tmux.conf;
 
  programs = {

    home-manager = {
      enable = true;
      path = "/home/ixxie/nixdev/home-manager";
    };

    zsh.enable = true;

    git = {

      enable = true;
	
      userName = "Matan Shenhav";
      userEmail = "matan@fluxcraft.net";

      extraConfig = ''
	[color "branch"]
	  current = green bold
	  local = green
	  remote = yellow

	[color "diff"]
	  frag = cyan bold
	  meta = yellow bold
	  new = green
	  old = red

	[diff "bin"]
	  textconv = hexdump -v -C
      '';
    };
  };
}
