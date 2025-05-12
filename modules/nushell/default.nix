{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
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
      envFile.text = builtins.readFile ./env.nu;
      configFile.text =
        builtins.readFile ./config.nu
        + ''
          # PLUGINS

          plugin add ${pkgs.nushellPlugins.query}/bin/nu_plugin_query
        '';
    };
  };
}
