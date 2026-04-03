{config, pkgs, ...}: let
  s = config.scheme;

  yaziWrapper = pkgs.writeShellScript "yazi-filechooser.sh" ''
    set -e

    multiple="$1"
    directory="$2"
    save="$3"
    path="$4"
    out="$5"

    termcmd="''${TERMCMD:-ghostty --title=filepicker -e}"

    if [ "$save" = "1" ]; then
      export YAZI_SAVE_MODE=1
      set -- --chooser-file="$out" --cwd-file="$out.cwd" "$(dirname "$path")"
    elif [ "$directory" = "1" ]; then
      export YAZI_SAVE_MODE=1
      set -- --chooser-file="$out" --cwd-file="$out.1" "$path"
    elif [ "$multiple" = "1" ]; then
      set -- --chooser-file="$out" "$path"
    else
      set -- --chooser-file="$out" "$path"
    fi

    command="$termcmd yazi"
    for arg in "$@"; do
      escaped=$(printf "%s" "$arg" | sed 's/"/\\"/g')
      command="$command \"$escaped\""
    done

    sh -c "$command"

    # save mode: if yazi returned a directory, append the original filename
    if [ "$save" = "1" ] && [ -f "$out" ]; then
      selected=$(cat "$out")
      if [ -d "$selected" ]; then
        echo "''${selected%/}/$(basename "$path")" > "$out"
      fi
    elif [ "$save" = "1" ] && [ -f "$out.cwd" ]; then
      cwd=$(cat "$out.cwd")
      echo "''${cwd%/}/$(basename "$path")" > "$out"
      rm -f "$out.cwd"
    fi

    # directory upload mode
    if [ "$directory" = "1" ]; then
      if [ ! -s "$out" ] && [ -s "$out.1" ]; then
        cat "$out.1" > "$out"
      fi
      rm -f "$out.1"
    fi

    rm -f "$out.cwd"
  '';
in {
  # portal: use yazi as file chooser
  xdg.portal = {
    extraPortals = [ pkgs.xdg-desktop-portal-termfilechooser ];
    config = {
      niri."org.freedesktop.impl.portal.FileChooser" = "termfilechooser";
      common."org.freedesktop.impl.portal.FileChooser" = "termfilechooser";
    };
  };

  home-manager.users.ixxie = {
    # termfilechooser: use yazi via ghostty as file picker
    xdg.configFile."xdg-desktop-portal-termfilechooser/config".text = ''
      [filechooser]
      cmd=${yaziWrapper}
      create_help_file=0
      default_dir=$HOME
      env=TERMCMD=ghostty --title=filepicker -e
    '';

    programs.yazi = {
      enable = true;
      shellWrapperName = "y";
      theme.flavor.use = "base16";
      keymap = {
        manager.prepend_keymap = [
          {
            on = ["<Enter>"];
            run = "plugin smart-enter";
            desc = "Open file or confirm directory in save mode";
          }
          {
            on = ["<Esc>"];
            run = "quit";
            desc = "Close yazi";
          }
        ];
      };
      settings = {
        opener = {
          open = [
            {
              run = ''xdg-open "$@"'';
              orphan = true;
              desc = "Open with default application";
            }
          ];
        };
        open = {
          rules = [
            {
              mime = "*";
              use = "open";
            }
          ];
        };
      };
    };

    # smart-enter plugin: in save/directory mode, Enter on a dir confirms and quits
    xdg.configFile."yazi/plugins/smart-enter.yazi/init.lua".text = ''
      return {
        entry = function()
          local h = cx.active.current.hovered
          if h and h.cha.is_dir and os.getenv("YAZI_SAVE_MODE") == "1" then
            ya.manager_emit("quit", {})
          else
            ya.manager_emit("open", {})
          end
        end,
      }
    '';

    # base16 theme (source: https://github.com/tinted-theming/tinted-yazi)
    xdg.configFile."yazi/flavors/base16.yazi/flavor.toml".text = ''
      [mgr]
      cwd = { fg = "#${s.base0C}" }

      find_keyword = { bold = true, fg = "#${s.base0A}" }
      find_position = { fg = "#${s.base0E}" }

      marker_copied = { fg = "#${s.base0B}", bg = "#${s.base0B}" }
      marker_cut = { fg = "#${s.base08}", bg = "#${s.base08}" }
      marker_selected = { fg = "#${s.base0A}", bg = "#${s.base0A}" }

      count_copied = { fg = "#${s.base00}", bg = "#${s.base0B}" }
      count_cut = { fg = "#${s.base00}", bg = "#${s.base08}" }
      count_selected = { fg = "#${s.base00}", bg = "#${s.base0A}" }

      border_style = { fg = "#${s.base0D}" }

      [tabs]
      active = { fg = "#${s.base00}", bg = "#${s.base0D}" }
      inactive = { fg = "#${s.base0D}", bg = "#${s.base01}" }

      [indicator]
      parent = { reversed = true }
      current = { reversed = true }
      preview = { underline = true }

      [mode]
      normal_main = { fg = "#${s.base00}", bg = "#${s.base0D}", bold = true }
      normal_alt = { fg = "#${s.base0D}", bg = "#${s.base02}" }

      select_alt = { fg = "#${s.base0E}", bg = "#${s.base02}" }
      select_main = { fg = "#${s.base00}", bg = "#${s.base0E}", bold = true }

      unset_main = { fg = "#${s.base00}", bg = "#${s.base08}", bold = true }
      unset_alt = { fg = "#${s.base08}", bg = "#${s.base02}" }

      [status]
      perm_exec = { fg = "#${s.base0B}" }
      perm_read = { fg = "#${s.base0A}" }
      perm_sep = { fg = "#${s.base0C}" }
      perm_type = { fg = "#${s.base0D}" }
      perm_write = { fg = "#${s.base08}" }

      progress_error = { fg = "#${s.base08}", bg = "#${s.base00}" }
      progress_label = { fg = "#${s.base05}", bg = "#${s.base00}" }
      progress_normal = { fg = "#${s.base05}", bg = "#${s.base00}" }

      [pick]
      active = { fg = "#${s.base0E}" }
      border = { fg = "#${s.base0D}" }
      inactive = { fg = "#${s.base05}" }

      [task]
      title = { fg = "#${s.base0D}" }
      border = { fg = "#${s.base0D}" }
      hovered = { fg = "#${s.base05}", bg = "#${s.base02}" }

      [input]
      border = { fg = "#${s.base0D}" }
      selected = { bg = "#${s.base02}" }

      [help]
      desc = { fg = "#${s.base05}" }
      on = { fg = "#${s.base0C}" }
      run = { fg = "#${s.base0E}" }
      hovered = { reversed = true, bold = true }
      footer = { fg = "#${s.base02}", bg = "#${s.base05}" }

      [which]
      mask = { bg = "#${s.base02}" }
      desc = { fg = "#${s.base05}" }
      cand = { fg = "#${s.base0C}" }
      rest = { fg = "#${s.base0F}" }

      separator_style = { fg = "#${s.base04}" }

      [notify]
      title_info = { fg = "#${s.base0C}" }
      title_warn = { fg = "#${s.base0A}" }
      title_error = { fg = "#${s.base08}" }

      [filetype]
      rules = [
        { mime = "image/*", fg = "#${s.base0C}" },
        { mime = "{audio, video}/*", fg = "#${s.base0A}" },
        { mime = "application/{pdf,doc,rtf}", fg = "#${s.base0B}" },
        { mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}", fg = "#${s.base0E}" },
        { url = "*/", fg = "#${s.base0D}" },
        { mime = "*", fg = "#${s.base05}" },
      ]
    '';
  };
}
