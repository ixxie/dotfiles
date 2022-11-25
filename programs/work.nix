{config, pkgs, ...}:

{
    environment.systemPackages = with pkgs; [
        python39Packages.flake8
        python39Packages.poetry
        go
        gopls
        gnumake
        duckdb
        slack
        ngrok
    ];
}