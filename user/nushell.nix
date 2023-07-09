{ pkgs, config, ... }:

{
  programs.nushell = {
    enable = true;
    envFile = {
      text = ''
        let-env STARSHIP_SHELL = "nu"

        def create_left_prompt [] {
            starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)'
        }

        let-env PROMPT_COMMAND = { || create_left_prompt }
        let-env PROMPT_COMMAND_RIGHT = ""

        let-env PROMPT_INDICATOR = ""
        let-env PROMPT_INDICATOR_VI_INSERT = ": "
        let-env PROMPT_INDICATOR_VI_NORMAL = "〉"
        let-env PROMPT_MULTILINE_INDICATOR = "::: "
      '';
    };
    configFile = {
      text = ''
        let-env config = {
          show_banner: false
        }
        let-env PATH = [
          /run/wrappers/bin
          /home/ixxie/.nix-profile/bin
          /etc/profiles/per-user/ixxie/bin
          /nix/var/nix/profiles/default/bin
          /run/current-system/sw/bin
        ]
        alias supabase = /home/ixxie/repos/.utilities/supabase-cli/cli
        alias vultr = vultr-cli
        alias gr = cd (git rev-parse --show-toplevel)
        def gen [] {
          echo "<< updating dotfiles nix flake >>
          "
          (cd ~/repos/dotfiles; sudo nix flake update)
          echo "<< rebuilding nixos system >>
          "
          sudo nixos-rebuild switch
        }
        def gc [] {
          sudo nix-collect-garbage --delete-older-than 7d
          nix-store --optimise
          sudo nixos-rebuild switch
        }
      '';
    };
  };
}

