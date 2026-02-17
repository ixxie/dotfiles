{pkgs, config, inputs, ...}: {
  imports = [inputs.cella.nixosModules.default];
  cella = {
    enable = true;

    # External network interface for NAT
    nat.interface = "wlp1s0";

    # Credentials from sops-nix
    credentialsFile = config.sops.secrets.cella-credentials.path;

    # Share .claude directory for credential symlink
    guest.claudeDir = "/home/ixxie/.claude";

    # User configuration
    user = {
      name = "ixxie";
      uid = 1000;
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPcwKdkSvC2AP3kbQva2nhLOM9ha4VIuHVTne5RPIXLz ixxie@contingent"
      ];
    };

    # Default allowed domains (can extend if needed)
    allowedDomains = [
      # Anthropic
      "api.anthropic.com"
      "*.anthropic.com"
      # GitHub
      "github.com"
      "*.github.com"
      "*.githubusercontent.com"
      # NPM
      "registry.npmjs.org"
      "*.npmjs.org"
      # PyPI
      "pypi.org"
      "*.pypi.org"
      "files.pythonhosted.org"
      # Nix
      "cache.nixos.org"
      "*.cachix.org"
      # Crates.io
      "crates.io"
      "*.crates.io"
      "static.crates.io"
    ];
  };

  # Add cella CLI to system packages
  environment.systemPackages = [
    pkgs.cella
    pkgs.cella-server
  ];
}
