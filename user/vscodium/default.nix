{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    userSettings = {
      "update.mode" = "none";
      "explorer.confirmDragAndDrop" = false;
      "explorer.sortOrder" = "type";
      "editor.minimap.enabled" = false;
      # formatting
      "editor.formatOnSave" = true;
      "editor.codeActionsOnSave" = { "source.fixAll" = true; };
      # FRONTEND
      "prettier.requireConfig" = true;
      "[css][html][yaml][javascript][typescript]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
      "javascript.updateImportsOnFileMove.enabled" = "never";
      # css
      "css.validate" = false;
      "scss.validate" = false;
      "less.validate" = false;
      # svelte
      "[svelte]" = { "editor.defaultFormatter" = "svelte.svelte-vscode"; };
      "svelte.enable-ts-plugin" = true;
      # BACKEND
      # python
      "python.linting.flake8Enabled" = true;
      "python.linting.flake8Path" = "/run/current-system/sw/bin/flake8";
      "python.languageServer" = "pylance";
      # sql
      "inlineSQL.lintSQLFiles" = false;
    };
    package = pkgs.vscodium;
    extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      ms-python.python
      svelte.svelte-vscode
      vscodevim.vim
      esbenp.prettier-vscode
      golang.go
    ];
  };
}
