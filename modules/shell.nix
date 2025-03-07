{ pkgs, lib, ... }:

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
          blur = true;
          decorations = "None";
        };
      };
    };
  };
}
