{
  pkgs,
  config,
  inputs,
  ...
}: let
  hx-open = pkgs.writeShellScriptBin "hx-open" ''
    exec ghostty -e hx "$@"
  '';
in {
  programs.fish.enable = true;

  home-manager.users.ixxie = {
    home.packages = [hx-open pkgs.carapace];
    programs = {
      fish = {
        enable = true;
        interactiveShellInit = ''
          set fish_greeting
          starship init fish | source

          # Carapace completions
          carapace _carapace | source

          # Load secrets
          if test -f $DOTFILES/secrets/github_token.txt
            set -gx CR_PAT (cat $DOTFILES/secrets/github_token.txt)
          end

          # base16 theme
          source ${config.scheme {templateRepo = inputs.base16-fish;}}
        '';
        shellAbbrs = {
          "repo.root" = "cd (git rev-parse --show-toplevel)";
        };
        completions = {
          yo = ''
            complete -c yo -f
            complete -c yo -n "__fish_use_subcommand" -a "(yo completions)"
            complete -c yo -n "__fish_seen_subcommand_from cd" -a "(yo completions cd)"
            complete -c yo -n "__fish_seen_subcommand_from sys" -a "(yo completions sys)"
            complete -c yo -n "__fish_seen_subcommand_from cell" -a "(yo completions cell)"
            complete -c yo -n "__fish_seen_subcommand_from open" -a "(yo completions open)"
          '';
        };
        shellAliases = {
          ls = "eza --icons";
          ll = "eza -lh --icons";
          la = "eza -lah --icons";
          tree = "eza --tree --icons";
          cat = "bat";
          yo = "bun $DOTFILES/cli/src/index.ts";
        };
        shellInit = ''
          set -gx MASCOPE_PATH /home/ixxie/repos/apps/mascope
          set -gx DOTFILES /home/ixxie/repos/dotfiles
          set -gx QT_QPA_PLATFORM wayland
          set -gx LAUNCH_EDITOR hx-open
        '';
        functions = {
          mkcd = "mkdir -p $argv[1]; and cd $argv[1]";

          "showkeys" = {
            body = ''
              showmethekey-cli | while read -l line
                  notify-send -t 1000 "$line"
              end
            '';
            description = "Show keypresses as notifications";
          };

          repo = {
            body = "echo 'Repo helper - use: repo.diff, repo.root'";
          };
        };
      };

      starship = {
        enable = true;
        enableFishIntegration = true;
        settings = {
          nix_shell.disabled = true;
          gcloud.disabled = true;
          env_var.DEVSHELL_NAME = {
            format = "[$env_value]($style) ";
            style = "bold blue";
          };
          nodejs.format = "[$symbol$version]($style) ";
          python.format = "[$symbol$version]($style) ";
          rust.format = "[$symbol$version]($style) ";
          golang.format = "[$symbol$version]($style) ";
          java.format = "[$symbol$version]($style) ";
        };
      };

      eza.enable = true;
      bat.enable = true;
      zoxide = {
        enable = true;
        enableFishIntegration = true;
      };
    };
  };
}
