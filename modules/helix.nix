{pkgs, ...}: {
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
            args = ["server"];
          };
          eslint = {
            command = "vscode-eslint-language-server";
            args = ["--stdio"];
            config = {
              validate = "on";
            };
          };
          vls = {
            command = "vue-language-server";
            args = ["--stdio"];
          };
        };
        language = [
          {
            name = "nix";
            auto-format = true;
            language-servers = [
              "nixd"
            ];
            formatter = {
              command = "alejandra";
              args = ["-q"];
            };
            file-types = ["nix"];
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
            file-types = ["vue"];
            language-servers = [
              "eslint"
              "vls"
            ];
            injection-regex = "vue";
            scope = "text.html.vue";
            formatter = {
              command = "prettier";
              args = ["--parser" "vue"];
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
              command = "prettier";
              args = ["--parser" "typescript"];
            };
            language-servers = [
              "typescript-language-server"
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
              command = "prettier";
              args = ["--parser" "typescript"];
            };
          }
          {
            name = "html";
            formatter = {
              command = "prettier";
              args = ["--parser" "html"];
            };
            auto-format = true;
          }
          {
            name = "css";
            formatter = {
              command = "prettier";
              args = ["--parser" "css"];
            };
            auto-format = true;
          }
          {
            name = "markdown";
            file-types = [
              "md"
              "mdx"
            ];
            auto-format = true;
            soft-wrap.enable = true;
          }
          {
            name = "python";
            auto-format = true;

            language-servers = [
              "ruff"
            ];
            file-types = ["py"];
          }
          {
            name = "bash";
            language-servers = [
              "bash-language-server"
            ];
            file-types = ["sh"];
          }
        ];
      };
    };
  };
}
