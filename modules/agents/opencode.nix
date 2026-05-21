{inputs, ...}: let
  agentsMd = builtins.readFile ./AGENTS.md;
in {
  config.home-manager.users.ixxie = {
    home = {
      packages = [inputs.opencode.packages.x86_64-linux.default];

      file.".config/opencode/opencode.json".text = builtins.toJSON {
        tui.theme = "system";
        disabled_providers = ["opencode" "opencode-go"];
        autoupdate = false;
      };

      file.".config/opencode/AGENTS.md".text = agentsMd;

      shellAliases = {
        code = "opencode";
      };
    };
  };
}
