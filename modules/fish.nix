{
  pkgs,
  config,
  ...
}: let
  s = config.scheme;
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

    # base16 fish colors (source: https://github.com/tomyun/base16-fish)
    xdg.configFile."fish/conf.d/base16-colors.fish".text = ''
      set -g fish_color_autosuggestion ${s.base03}
      set -g fish_color_cancel -r
      set -g fish_color_command green
      set -g fish_color_comment ${s.base03}
      set -g fish_color_cwd green
      set -g fish_color_cwd_root red
      set -g fish_color_end brblack
      set -g fish_color_error red
      set -g fish_color_escape yellow
      set -g fish_color_history_current --bold
      set -g fish_color_host normal
      set -g fish_color_match --background=brblue
      set -g fish_color_normal normal
      set -g fish_color_operator blue
      set -g fish_color_param ${s.base04}
      set -g fish_color_quote yellow
      set -g fish_color_redirection cyan
      set -g fish_color_search_match bryellow --background=${s.base02}
      set -g fish_color_selection white --bold --background=${s.base02}
      set -g fish_color_status red
      set -g fish_color_user brgreen
      set -g fish_color_valid_path --underline
      set -g fish_pager_color_completion normal
      set -g fish_pager_color_description yellow --dim
      set -g fish_pager_color_prefix white --bold
      set -g fish_pager_color_progress brwhite --background=cyan
    '';
  };
}
