{
  imports = [
    ./claude
    ./opencode.nix
    #./paseo.nix
  ];

  secretEnv."openrouter-api-key" = "OPENROUTER_API_KEY";
}
