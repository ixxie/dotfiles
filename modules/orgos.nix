{config, ...}: {
  sops.secrets.zen-api-key = {
    owner = "ixxie";
  };

  config.home-manager.users.ixxie = {
    programs.fish.interactiveShellInit = ''
      # Zen API key
      if test -f ${config.sops.secrets.zen-api-key.path}
        set -gx ZEN_API_KEY (cat ${config.sops.secrets.zen-api-key.path})
      end
    '';

    xdg.configFile."org/agent.toml".text = ''
      default_model = "kimi-k2.5"

      [[providers]]
      provider = "openai"
      base_url = "https://opencode.ai/zen"
      api_key_env = "ZEN_API_KEY"
    '';
  };
}
