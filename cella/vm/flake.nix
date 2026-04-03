{
  inputs = {
    claude-code.url = "github:anthropics/claude-code";
  };

  outputs = {claude-code, ...}: {
    nixosModule = {pkgs, ...}: {
      imports = [./config.nix];

      environment.systemPackages = [
        claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
  };
}
