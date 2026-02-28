{config, inputs, ...}: {
  home-manager.users.ixxie = {
    programs.yazi = {
      enable = true;
      shellWrapperName = "y";
      theme.flavor.use = "base16";
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

    # base16 theme
    xdg.configFile."yazi/flavors/base16.yazi/flavor.toml".source =
      config.scheme {templateRepo = inputs.base16-yazi;};
  };
}
