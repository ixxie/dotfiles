
{ pkgs, ... }: 

{ 
	environment.systemPackages = 
		with pkgs; 
		[
			docker
			file
			idea.idea-community
			jre
		    git
			graphviz
			gnumake
			gcc
			nix-prefetch-git
			nixops
			openjdk
			postgresql
		    sbt
		    unstable.vscode
			vim
		]; 

	programs.java.enable = true;

	services.postgresql.enable = true;
}
