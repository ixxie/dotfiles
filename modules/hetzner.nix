{pkgs, ...}: {
  # Hetzner Cloud from any shell, agents included: the token rides the same
  # secretEnv path as the other keys (sops → exported at shell init). Add
  # the value with `sops secrets.yaml` under `hetzner-api-key` before
  # switching — sops-nix refuses a config naming a secret the file lacks.
  secretEnv."hetzner-api-key" = "HCLOUD_TOKEN";

  home-manager.users.ixxie.home.packages = with pkgs; [
    hcloud
    nixos-anywhere
  ];
}
