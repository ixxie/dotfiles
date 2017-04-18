
{ pkgs, ... }: { 

	environment.systemPackages = 
		with pkgs;
		[
			idea.idea-community
			jre
		    gitAndTools.gitFull
			graphviz
			nix-prefetch-git
			nixops
		    sbt
		    vscode
		]; 
}
