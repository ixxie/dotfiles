
{ pkgs, ... }: 

{ 
	environment.systemPackages = 
		with pkgs; 
		[
			docker
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
		    vscode
			aqemu
			kvm
		]; 

	programs.java.enable = true;

	services.postgresql.enable = true;

	virtualisation.libvirtd.enableKVM = true;
}
