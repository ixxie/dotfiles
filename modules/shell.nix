{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # alacritty
    alacritty-theme
    # nushell
    starship
    nushellPlugins.query
    # completers
    carapace
    zoxide
    fish
  ];

  home-manager.users.ixxie.programs = {
    nushell = {
      enable = true;
      envFile.text = builtins.readFile ./shell.env.nu;
      configFile.text =
        builtins.readFile ./shell.config.nu
        + ''
          # PLUGINS

          plugin add ${pkgs.nushellPlugins.query}/bin/nu_plugin_query
        '';
    };
    alacritty = {
      enable = true;
      settings = {
        window = {
          padding = {
            x = 10;
            y = 10;
          };
          opacity = 0.9;
          blur = true;
          decorations = "None";
        };
        colors = {
          primary = {
            background = "#333c43";
            foreground = "#d3c6aa";
          };
          normal = {
            black = "#4d5960";
            red = "#e67e80";
            green = "#a7c080";
            yellow = "#dbbc7f";
            blue = "#7fbbb3";
            magenta = "#d699b6";
            cyan = "#83c092";
            white = "#d3c6aa";
          };
          bright = {
            black = "#4d5960";
            red = "#e67e80";
            green = "#a7c080";
            yellow = "#dbbc7f";
            blue = "#7fbbb3";
            magenta = "#d699b6";
            cyan = "#83c092";
            white = "#d3c6aa";
          };
        };
      };
    };
  };
}
