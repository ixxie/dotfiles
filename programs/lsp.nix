{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    nodePackages.bash-language-server
    nodePackages.typescript-language-server
    texlab
    python312Packages.python-lsp-server
    nodePackages.svelte-language-server
  ];
}
