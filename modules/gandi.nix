{pkgs, ...}: {
  # Gandi from any shell, agents included. nixpkgs dropped gandi-cli
  # (unmaintained upstream, 2026-01), so the v5 REST API is driven with
  # curl + jq; the personal access token rides the same secretEnv path as
  # the other keys (sops → exported at shell init). Add the value with
  # `sops secrets.yaml` under `gandi-api-key` before switching — sops-nix
  # refuses a config naming a secret the file lacks.
  secretEnv."gandi-api-key" = "GANDI_TOKEN";

  home-manager.users.ixxie.home.packages = with pkgs; [
    jq
  ];
}
