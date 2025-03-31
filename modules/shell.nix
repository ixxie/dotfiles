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
    ghostty = {
      enable = true;
      settings = {
        window-padding-x = 10;
        window-padding-y = 10;
        gtk-wide-tabs = false;
        gtk-custom-css = "/home/ixxie/repos/dotfiles/modules/shell.css";
      };
    };
    # redundency
    alacritty = {
      enable = true;
      settings = {
        window = {
          padding = {
            x = 10;
            y = 10;
          };
          blur = true;
          decorations = "None";
        };
      };
    };
  };
}
