{
  imports = [
    ./claude
    ./opencode.nix
  ];

  secretEnv."openrouter-api-key" = "OPENROUTER_API_KEY";
}
