{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    userSettings = {
      # theme
      "workbench.colorTheme" = "Atom Material Theme";
      "workbench.iconTheme" = "none";
      # editor
      "update.mode" = "none";
      "explorer.confirmDragAndDrop" = false;
      "explorer.sortOrder" = "type";
      "window.menuBarVisibility" = "toggle";
      # minimalize
      "editor.minimap.enabled" = false;
      "editor.renderWhitespace" = "none"; # removes whitespace chars
      "editor.renderIndentGuides" = false; # removes indent guides
      "editor.hideCursorInOverviewRuler" =
        true; # hides cursor mark in the overview ruler
      "editor.folding" = false; # removes the folding feature
      "editor.occurrencesHighlight" =
        false; # removes highlights occurrences (still works when you select a word)
      "explorer.openEditors.visible" =
        0; # removes the open editors section at the top of the sidebar, you can see the opened files with ⌘ + ⌥ + Tab
      "workbench.activityBar.visible" =
        false; # removes the activity bar (the 4 icons at the left of the screen), so now you will have to open the explorer, git, debugger and extension with shortcuts or through the Command Palette
      "workbench.editor.showIcons" =
        false; # removes icon from opened files in tabs
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
      "[svelte]" = {
        "editor.formatOnSave" = true;
        "editor.defaultFormatter" = "svelte.svelte-vscode";
        "editor.codeActionsOnSave" = { "source.organizeImports" = false; };
      };
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
      tobiasalthoff.atom-material-theme
      jdinhlife.gruvbox
    ];
  };
}
