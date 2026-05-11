{inputs, ...}: {
  config.home-manager.users.ixxie = {
    home = {
      packages = [inputs.opencode.packages.x86_64-linux.default];

      file.".config/opencode/opencode.json".text = builtins.toJSON {
        tui.theme = "system";
        disabled_providers = ["opencode" "opencode-go"];
      };

      shellAliases = {
        code = "opencode";
      };
    };
  };
}
