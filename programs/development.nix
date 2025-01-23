{ pkgs, ... }:

{
  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    # python
    python312
    python312Packages.python-lsp-server
    ruff
    uv
    # web
    nodejs_22
    vscode-langservers-extracted # html/css/json
    nodePackages.typescript-language-server
    nodePackages.svelte-language-server
    nodePackages."@vue/language-server"
    nodePackages.prettier
    prettierd
    eslint_d
    postman
    markdown-oxide
    bun
    # data
    duckdb
    sqlitebrowser
    # system
    nixd
    nodePackages.bash-language-server
  ];
}
