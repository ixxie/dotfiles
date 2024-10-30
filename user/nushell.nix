{ pkgs, ... }:

{
  programs.nushell = {
    enable = true;
    envFile = {
      text = ''
        $env.STARSHIP_SHELL = "nu"

        def create_left_prompt [] {
            starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)'
        }

        $env.PROMPT_COMMAND = { || create_left_prompt }
        $env.PROMPT_COMMAND_RIGHT = ""

        $env.PROMPT_INDICATOR = ""
        $env.PROMPT_INDICATOR_VI_INSERT = ": "
        $env.PROMPT_INDICATOR_VI_NORMAL = "〉"
        $env.PROMPT_MULTILINE_INDICATOR = "::: "

        $env.MASCOPE_PATH = "/home/ixxie/repos/mascope"
      '';
    };
    configFile = {
      text = ''
        $env.config = {
          show_banner: false
        }
        alias gr = cd (git rev-parse --show-toplevel)
        def regen [] {
          echo "<< updating dotfiles nix flake >>
          "
          (cd ~/repos/dotfiles; sudo nix flake update)
          echo "<< rebuilding nixos system >>
          "
          sudo nixos-rebuild switch --flake .#contingent
        }
        def gc [] {
          sudo nix-collect-garbage --delete-older-than 7d
          nix-store --optimise
          sudo nixos-rebuild switch
        }

        # plugins

        plugin add ${pkgs.nushellPlugins.query}/bin/nu_plugin_query
      '';
    };
  };
}
