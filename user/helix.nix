{ ... }:

{
  programs.helix = {
    enable = true;
    settings = {
      theme = "everforest_dark";
      editor = {
        shell = [
          "nu"
          "--stdin"
          "-c"
        ];
        true-color = true;
        file-picker.hidden = false;
        inline-diagnostics = {
          cursor-line = "hint";
          other-lines = "disable";
        };
        lsp.auto-signature-help = false;
      };
    };
    languages = {
      language-server = {
        nixd = {
          command = "nixd";
        };
        ruff = {
          command = "ruff";
          args = [ "server" ];
        };
        eslint = {
          command = "vscode-eslint-language-server";
          args = [ "--stdio" ];
          config = {
            validate = "on";
          };
        };
      };
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = "nixfmt";
          language-servers = [ "nixd" ];
          file-types = [ "nix" ];
        }
        {
          name = "svelte";
          auto-format = true;
          file-types = [
            "svelte"
          ];
        }
        {
          name = "vue";
          file-types = [ "vue" ];
          language-servers = [ "eslint" ];
          formatter = {
            command = "prettierd";
            args = [
              "--stdin-filepath"
              "x.vue"
            ];
          };
          auto-format = true;
        }
        {
          name = "javascript";
          file-types = [ "js" ];
          formatter = {
            command = "prettierd";
            args = [
              "--stdin-filepath"
              "x.js"
            ];
          };
          auto-format = true;
        }
        {
          name = "typescript";
          file-types = [ "ts" ];
          auto-format = true;
          formatter = {
            command = "prettierd";
            args = [
              "--stdin-filepath"
              "x.ts"
            ];
          };
        }
        {
          name = "markdown";
          file-types = [ "md" ];
          auto-format = true;
          soft-wrap.enable = true;
        }
        {
          name = "python";
          auto-format = true;
          language-servers = [ "ruff" ];
          file-types = [ "py" ];
        }
      ];
    };
  };
}
