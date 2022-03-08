{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    userSettings = {
      "editor.minimap.enabled" = false;
      "update.mode" = "none";
      "explorer.confirmDragAndDrop" = false;
      "css.validate" = false;
      "scss.validate" = false;
      "less.validate" = false;
      "tailwindCSS.lint.cssConflict" = "ignore";
      "files.associations" = {
        "*.svelte" = "html";
      };
      "editor.codeActionsOnSave" = {
        "source.fixAll" = true;
      };
      "explorer.sortOrder" = "type";
      "javascript.updateImportsOnFileMove.enabled" = "never";
      "prettier.requireConfig" = true;
      "editor.formatOnSave" = true;
      
    };
    package = pkgs.vscodium;
        extensions =  with pkgs.vscode-extensions; [ 
        ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [ 
          {
            name = "nix-ide";
            publisher = "jnoortheen";
            version = "0.1.7";
            sha256 = "1bw4wyq9abimxbhl7q9g8grvj2ax9qqq6mmqbiqlbsi2arvk0wrm";
          }
          {
            name = "nix-env-selector";
            publisher = "arrterian";
            version = "0.1.2";
            sha256 = "1n5ilw1k29km9b0yzfd32m8gvwa2xhh6156d4dys6l8sbfpp2cv9";
          }
          {
            name = "svelte-vscode";
            publisher = "svelte";
            version = "104.0.0";
            sha256 = "17k58lrz0j13yin7gsrxa1wavfxb8xc5y9ggb27l8i9iys3g0lcb";
          }
          {
            name = "postcss";
            publisher = "csstools";
            version = "1.0.8";
            sha256 = "1kmp1nmmv4cac823fxx9jkryf376ha3wk8slkwl49d2nxzsiq1bg";
          }
          {
            name = "vscode-stylelint";
            publisher = "stylelint";
            version = "0.84.0";
            sha256 = "0n8shcx63ilhv9ncqm57nnn1fdm5bz53vhc0p6kffl3gs1axkx9x";
          }
          {
            name = "vim";
            publisher = "vscodevim";
            version = "1.18.5";
            sha256 = "0cbmmhkbr4f1afk443sgdihp2q5zkzchbr2yhp7bm5qnv7xdv5l4";
          }
          {
            name = "python";
            publisher = "ms-python";
            version = "2020.5.86806";
            sha256 = "0j3333gppvnn2igw77cbzpsgw6lbkb44l4w7rnpzn9z0q3piy6d4";
          }
    ];
  };
}
