{config, pkgs, ... }:

{
	environment.systemPackages = with pkgs; [
		nodePackages.bash-language-server
		nodePackages.typescript-language-server
		rnix-lsp
		texlab
		python310Packages.python-lsp-server
		nodePackages.svelte-language-server
	];
}
