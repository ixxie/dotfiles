{config, ...}: {
  home-manager.users.ixxie = {
    programs.helix = {
      enable = true;
      settings = {
        theme = "base16-transparent";
        keys.normal.space.r = ":reload-all";
        keys.normal.space.o = [
          "extend_to_line_bounds"
          ":pipe-to url=$(grep -oP 'https?://[^\\s\\)\\]>]+' | head -1) && xdg-open \"$url\""
          "collapse_selection"
        ];
        editor = {
          shell = [
            "bash"
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
            language-servers = [
              "marksman"
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

    # base16 theme (source: https://github.com/tinted-theming/base16-helix)
    xdg.configFile."helix/themes/base16.toml".text = let s = config.scheme; in ''
      "attribute" = "base09"
      "comment" = { fg = "base03", modifiers = ["italic"] }
      "constant" = "base09"
      "constant.character.escape" = "base0C"
      "constant.numeric" = "base09"
      "constructor" = "base0D"
      "debug" = "base03"
      "diagnostic" = { modifiers = ["underlined"] }
      "diff.delta" = "base09"
      "diff.minus" = "base08"
      "diff.plus" = "base0B"
      "error" = "base08"
      "function" = "base0D"
      "hint" = "base03"
      "info" = "base0D"
      "keyword" = "base0E"
      "label" = "base0E"
      "namespace" = "base0E"
      "operator" = "base05"
      "special" = "base0D"
      "string" = "base0B"
      "tag" = "base08"
      "type" = "base0A"
      "variable" = "base08"
      "variable.other.member" = "base0D"
      "warning" = "base09"

      "markup.bold" = { fg = "base0A", modifiers = ["bold"] }
      "markup.heading.1" = { fg = "base0D", modifiers = ["bold"] }
      "markup.heading.2" = { fg = "base08", modifiers = ["bold"] }
      "markup.heading.3" = { fg = "base09", modifiers = ["bold"] }
      "markup.heading.4" = { fg = "base0A", modifiers = ["bold"] }
      "markup.heading.5" = { fg = "base0B", modifiers = ["bold"] }
      "markup.heading.6" = { fg = "base0C", modifiers = ["bold"] }
      "markup.italic" = { fg = "base0E", modifiers = ["italic"] }
      "markup.link.text" = "base08"
      "markup.link.url" = { fg = "base09", modifiers = ["underlined"] }
      "markup.list" = "base08"
      "markup.quote" = "base0C"
      "markup.raw" = "base0B"
      "markup.strikethrough" = { modifiers = ["crossed_out"] }

      "diagnostic.hint" = { underline = { style = "curl" } }
      "diagnostic.info" = { underline = { style = "curl" } }
      "diagnostic.warning" = { underline = { style = "curl" } }
      "diagnostic.error" = { underline = { style = "curl" } }

      "ui.background" = { bg = "base00" }
      "ui.bufferline.active" = { fg = "base00", bg = "base03", modifiers = ["bold"] }
      "ui.bufferline" = { fg = "base04", bg = "base00" }
      "ui.cursor" = { fg = "base06", modifiers = ["reversed"] }
      "ui.cursor.primary" = { fg = "base05", modifiers = ["reversed"] }
      "ui.cursorline.primary" = { fg = "base05", bg = "base01" }
      "ui.cursor.match" = { fg = "base05", bg = "base02", modifiers = ["bold"] }
      "ui.cursor.select" = { fg = "base05", modifiers = ["reversed"] }
      "ui.gutter" = { bg = "base00" }
      "ui.help" = { fg = "base06", bg = "base01" }
      "ui.linenr" = { fg = "base03", bg = "base00" }
      "ui.linenr.selected" = { fg = "base04", bg = "base01", modifiers = ["bold"] }
      "ui.menu" = { fg = "base05", bg = "base01" }
      "ui.menu.scroll" = { fg = "base03", bg = "base01" }
      "ui.menu.selected" = { fg = "base01", bg = "base04" }
      "ui.popup" = { bg = "base01" }
      "ui.selection" = { bg = "base02" }
      "ui.selection.primary" = { bg = "base02" }
      "ui.statusline" = { fg = "base04", bg = "base01" }
      "ui.statusline.inactive" = { bg = "base01", fg = "base03" }
      "ui.statusline.insert" = { fg = "base00", bg = "base0B" }
      "ui.statusline.normal" = { fg = "base00", bg = "base03" }
      "ui.statusline.select" = { fg = "base00", bg = "base0F" }
      "ui.text" = "base05"
      "ui.text.directory" = "base0D"
      "ui.text.focus" = "base05"
      "ui.virtual.indent-guide" = { fg = "base03" }
      "ui.virtual.inlay-hint" = { fg = "base03" }
      "ui.virtual.ruler" = { bg = "base01" }
      "ui.virtual.jump-label" = { fg = "base0A", modifiers = ["bold"] }
      "ui.virtual.whitespace" = { fg = "base03" }
      "ui.window" = { bg = "base01" }

      [palette]
      base00 = "#${s.base00}"
      base01 = "#${s.base01}"
      base02 = "#${s.base02}"
      base03 = "#${s.base03}"
      base04 = "#${s.base04}"
      base05 = "#${s.base05}"
      base06 = "#${s.base06}"
      base07 = "#${s.base07}"
      base08 = "#${s.base08}"
      base09 = "#${s.base09}"
      base0A = "#${s.base0A}"
      base0B = "#${s.base0B}"
      base0C = "#${s.base0C}"
      base0D = "#${s.base0D}"
      base0E = "#${s.base0E}"
      base0F = "#${s.base0F}"
    '';
    xdg.configFile."helix/themes/base16-transparent.toml".text = ''
      inherits = "base16"

      "ui.background" = {}
      "ui.gutter" = {}
      "ui.gutter.selected" = {}
      "ui.linenr" = {}
      "ui.linenr.selected" = {}
      "ui.statusline" = {}
      "ui.statusline.inactive" = {}
      "ui.popup" = {}
      "ui.menu" = {}
      "ui.menu.selected" = { modifiers = ["reversed"] }
      "ui.help" = {}
    '';
  };
}
