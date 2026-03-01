{config, ...}: {
  # system-wide orgos defaults — all enrolled users inherit these
  orgos.server.enable = true;
  orgos.cell.enable = true;

  orgos.agent = {
    enable = true;
    default_model = "kimi-k2.5";
    providers = [
      {
        provider = "openai";
        base_url = "https://opencode.ai/zen";
        api_key_env = "ZEN_API_KEY";
      }
    ];
  };

  # secrets
  sops.secrets.zen-api-key.owner = "ixxie";

  home-manager.users.ixxie.programs.fish.interactiveShellInit = ''
    if test -f ${config.sops.secrets.zen-api-key.path}
      set -gx ZEN_API_KEY (cat ${config.sops.secrets.zen-api-key.path})
    end
  '';
}
