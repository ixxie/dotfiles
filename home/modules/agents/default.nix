# corpus:article/architecture
# corpus:decision/26-05-21-one-agents-module-for-every-agent
{
  imports = [
    ./claude
    ./codex.nix
    ./opencode.nix
  ];

  secretEnv."openrouter-api-key" = "OPENROUTER_API_KEY";
}
