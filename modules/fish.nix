{pkgs, yo, ...}: let
  hx-open = pkgs.writeShellScriptBin "hx-open" ''
    exec ghostty -e hx "$@"
  '';
in {
  programs.fish.enable = true;

  home-manager.users.ixxie = {
    home.packages = [hx-open pkgs.carapace yo];
    programs = {
      fish = {
        enable = true;
        interactiveShellInit = ''
          set fish_greeting
          starship init fish | source

          # Carapace completions
          carapace _carapace | source

          # Load secrets
          if test -f $DOTFILES/secrets/anthropic_key.txt
            set -gx ANTHROPIC_API_KEY (cat $DOTFILES/secrets/anthropic_key.txt)
          end
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
          '';
        };
        shellAliases = {
          ls = "eza --icons";
          ll = "eza -lh --icons";
          la = "eza -lah --icons";
          tree = "eza --tree --icons";
          cat = "bat";
        };
        shellInit = ''
          set -gx MASCOPE_PATH /home/ixxie/repos/apps/mascope
          set -gx DOTFILES /home/ixxie/repos/dotfiles
          set -gx QT_QPA_PLATFORM wayland
          set -gx LAUNCH_EDITOR hx-open
        '';
        functions = {
          mkcd = "mkdir -p $argv[1]; and cd $argv[1]";

          nixos = {
            body = "echo 'NixOS helper - use: nixos.gc, nixos.update, nixos.switch'";
          };

          "nixos.gc" = {
            body = ''
              sudo nix-collect-garbage --delete-older-than 7d
              nix-store --optimise
            '';
            description = "Clean up the Nix store";
          };

          "nixos.update" = {
            body = "cd ~/repos/dotfiles; and sudo nix flake update";
            description = "Update the NixOS config's flake";
          };

          "nixos.switch" = {
            body = ''
              if contains -- --update $argv
                nixos.update
              end
              sudo nixos-rebuild switch --flake '/home/ixxie/repos/dotfiles#contingent'
            '';
            description = "Rebuild the NixOS profile and switch to it";
          };

          kit = {
            body = "echo 'Kit helper - use: kit.init, kit.up'";
          };

          "kit.init" = {
            body = ''
              set path (test -n "$argv[1]"; and echo $argv[1]; or echo ".")
              bunx sv create --template minimal --types ts --install bun $path
            '';
            description = "Initialize a SvelteKit project";
          };

          "kit.up" = {
            body = ''
              mkdir old
              mv * old 2>/dev/null
              kit.init
              cp -r old/src .
              cp -r old/static .
              mv old/.git .
              mv old/.gitignore .
              if contains -- --clean $argv
                rm -rf old
              end
            '';
            description = "Upgrade SvelteKit project";
          };

          "showkeys" = {
            body = ''
              showmethekey-cli | while read -l line
                  notify-send -t 1000 "$line"
              end
            '';
            description = "Show keypresses as notifications";
          };

          rip = {
            body = ''
              set pattern $argv[1]
              set replacement $argv[2]
              set expr "s/$pattern/$replacement/g"

              if contains -- --dry $argv
                rg --pretty $pattern | sed $expr
              else
                for file in (rg -l $pattern)
                  sed -i $expr $file
                end
              end
            '';
            description = "Find and replace with ripgrep";
          };

          repo = {
            body = "echo 'Repo helper - use: repo.diff, repo.root'";
          };

          "repo.diff" = {
            body = ''
              if test (count $argv) -eq 0
                set staged_diff (git diff --color)
                set untracked_files (git ls-files --others --exclude-standard)

                set untracked_diff ""
                for file in $untracked_files
                  set untracked_diff "$untracked_diff"(git diff --color -- /dev/null $file)
                end

                set combined "$staged_diff$untracked_diff"
                if test -n "$combined"
                  echo $combined | less --raw-control-chars
                end
              else
                git diff $argv
              end
            '';
            description = "Git diff with untracked files included";
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
