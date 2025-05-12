{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    helix-gpt
  ];
  home-manager.users.ixxie = {
    programs.helix = {
      enable = true;
      settings = {
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
          vls = {
            command = "vue-language-server";
            args = [ "--stdio" ];
          };
          llm = {
            command = "helix-gpt";
          };
        };
        language = [
          {
            name = "nix";
            auto-format = true;
            language-servers = [
              "nixd"
              "llm"
            ];
            file-types = [ "nix" ];
          }
          {
            name = "svelte";
            auto-format = true;
            file-types = [
              "svelte"
              "llm"
            ];
          }
          {
            name = "vue";
            file-types = [ "vue" ];
            language-servers = [
              "eslint"
              "vls"
              "llm"
            ];
            injection-regex = "vue";
            scope = "text.html.vue";
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
            file-types = [
              "js"
              "mjs"
            ];
            formatter = {
              command = "prettierd";
              args = [
                "--stdin-filepath"
                "x.js"
              ];
            };
            language-servers = [
              "typescript-language-server"
              "llm"
            ];
            auto-format = true;
          }
          {
            name = "typescript";
            file-types = [
              "ts"
            ];
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
            file-types = [
              "md"
              "mdx"
              "llm"
            ];
            auto-format = true;
            soft-wrap.enable = true;
          }
          {
            name = "python";
            auto-format = true;

            language-servers = [
              "ruff"
              "llm"
            ];
            file-types = [ "py" ];
          }
          {
            name = "bash";
            language-servers = [
              "bash-language-server"
              "llm"
            ];
            file-types = [ "sh" ];
          }
        ];
      };
    };
  };
}
