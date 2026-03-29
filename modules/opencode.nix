{ ... }: {
  secretEnv."opencode-api-key" = "OPENCODE_API_KEY";

  home-manager.users.ixxie.programs.opencode = {
    enable = true;
    settings.theme = "everforest";
  };
}
