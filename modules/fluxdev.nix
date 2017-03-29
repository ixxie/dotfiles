
{ pkgs, ... }: { 

	environment.systemPackages = 
		with pkgs; with eclipses; 
		[
			idea.idea-community
			jre
		    gitAndTools.gitFull
			graphviz
			nix-prefetch-git
			nixops
			rWrapper
		    sbt
		    vscode
		]; 
}
