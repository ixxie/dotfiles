# corpus:article/architecture
{
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (import ./claude/lib.nix {inherit lib pkgs;}) agentsMd allSkills;
in {
  config = {
    # Declared in the system layer rather than ~/.codex/config.toml: Codex
    # writes to the user file at runtime (project trust, /model), which a
    # read-only store symlink would break. The user layer still wins key by key.
    environment.etc."codex/config.toml".source = (pkgs.formats.toml {}).generate "codex-config" {
      check_for_update_on_startup = false;
      model_reasoning_effort = "high";
    };

    home-manager.users.ixxie.programs.codex = {
      enable = true;
      package = inputs.codex-cli.packages.x86_64-linux.default;
      context = agentsMd;
      # By name rather than as ./skills: home-manager only normalizes a flat
      # directory of *.md into <name>/SKILL.md for non-literal paths.
      skills = allSkills;
    };
  };
}
