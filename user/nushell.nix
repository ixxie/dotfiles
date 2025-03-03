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

        # COMMANDS

        # NixOS helper commands        
        def nixos [] {
        }

        # Clean up the Nix store
        def "nixos gc" [] {
          sudo nix-collect-garbage --delete-older-than 7d
          nix-store --optimise
        }

        # Update the NixOS config's flake
        def "nixos update" [] {
          (cd ~/repos/dotfiles; sudo nix flake update)
        }

        # Rebuild the NixOS profile and switch to it
        def "nixos switch" [--update] {
          if $update {
            nixos update
          }
          sudo nixos-rebuild switch --flake .#contingent
        }

        # ALIASES

        # go to git root
        alias gr = cd (git rev-parse --show-toplevel)

        # PLUGINS

        plugin add ${pkgs.nushellPlugins.query}/bin/nu_plugin_query

        # COMPLETERS

        # main completer for most commands
        let carapace_completer = {|spans: list<string>|
            carapace $spans.0 nushell ...$spans
            | from json
            | if ($in | default [] | where value =~ '^-.*ERR$' | is-empty) { $in } else { null }
        }

        # used for some specific commands (e.g. git)
        let fish_completer = {|spans|
          fish --command $'complete "--do-complete=($spans | str join " ")"'
          | from tsv --flexible --noheaders --no-infer
          | rename value description
        }

        # learns from my input
        let zoxide_completer = {|spans|
          $spans | skip 1 | zoxide query -l ...$in | lines | where {|x| $x != $env.PWD}
        }

        # combining all completes
        let external_completer = {|spans|
            let expanded_alias = scope aliases
            | where name == $spans.0
            | get -i 0.expansion

            let spans = if $expanded_alias != null {
                $spans
                | skip 1
                | prepend ($expanded_alias | split row ' ' | take 1)
            } else {
                $spans
            }

            match $spans.0 {
                # carapace completions are incorrect for nu
                nu => $fish_completer
                # fish completes commits and branch names in a nicer way
                git => $fish_completer
                # carapace doesn't have completions for asdf
                asdf => $fish_completer
                # use zoxide completions for zoxide commands
                __zoxide_z | __zoxide_zi => $zoxide_completer
                _ => $carapace_completer
            } | do $in $spans
        }

        $env.config = {
            show_banner: false,
            completions: {
                external: {
                    enable: true
                    completer: $external_completer
                }
            }
        }
      '';
    };
  };
}
