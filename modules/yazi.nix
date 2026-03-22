{config, inputs, ...}: {
  home-manager.users.ixxie = {
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

    # base16 theme
    xdg.configFile."yazi/flavors/base16.yazi/flavor.toml".source =
      config.scheme {templateRepo = inputs.base16-yazi;};
  };
}
