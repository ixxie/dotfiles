{ config, ... }:
{
  config.home-manager.users.ixxie = {
    programs.opencode = {
      enable = true;
      settings.theme = "everforest";
    };
    programs.fish.interactiveShellInit = ''
      # OpenCode Zen API key
      if test -f ${config.sops.secrets.opencode-api-key.path}
        set -gx OPENCODE_API_KEY (cat ${config.sops.secrets.opencode-api-key.path})
      end
    '';
  };
}
