{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.cella.nixosModules.default
  ];

  cella = {
    enable = true;
    nat.interface = "wlp1s0";

    vm = {
      mounts = {
        "/home/ixxie/.claude" = {mountPoint = "/home/ixxie/.claude";};
        "/home/ixxie/.ssh" = {
          mountPoint = "/home/ixxie/.ssh";
          readOnly = true;
        };
      };

      copyFiles = {
        "/home/ixxie/.claude.json" = "/home/ixxie/.claude.json";
      };

      config = {pkgs, ...}: {
        programs.fish.enable = true;
        programs.fish.shellAliases.claude = "claude --dangerously-skip-permissions";
        users.users.ixxie.shell = pkgs.fish;
        environment.variables.EDITOR = "hx";

        environment.systemPackages = [
          pkgs.helix
          inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];
        environment.etc."claude/CLAUDE.md".text = ''
          # Cella Sandboxed Environment

          You are running inside a cella VM — an isolated NixOS microVM with
          proxy-enforced network isolation.

          ## Workspace

          Your workspace is mounted at /cell. Work from there.

          ## Tools

          This is a minimal NixOS environment. Use `nix shell` to get any tool:

          ```fish
          nix shell nixpkgs#nodejs --command npm test
          nix shell nixpkgs#python3 --command python script.py
          nix shell nixpkgs#go --command go build .
          nix shell nixpkgs#jq --command jq '.data' file.json
          ```

          The nix store is shared from the host, so packages load instantly
          if the host already has them.

          Available without nix shell: git, helix (hx), curl, fish.

          ## Network

          Internet access works normally. Behind the scenes, a transparent
          proxy filters traffic: reads are open, writes are restricted to
          allowlisted domains. API credentials are injected automatically —
          you never see secrets directly.

          ## Git

          Standard git. Push to GitHub with `git push origin`.
          Git credentials are handled by the proxy automatically.

          A nucleus pre-commit hook reviews all commits for security.
          If the hook rejects your commit, fix the issues and retry.

          ## Restrictions

          - No sudo/root access
          - /cell is your workspace; /tmp is limited to 1GB
          - No direct internet — all traffic goes through the proxy
          - Secrets are not available as environment variables

          ## Shell

          Fish shell. NixOS. Helix is the default editor.
        '';
      };
    };

    egress = {
      writes.allowed = [
        "api.anthropic.com"
        "*.anthropic.com"
        "claude.com"
        "*.claude.com"
      ];

      credentials = [
        {
          host = "api.anthropic.com";
          header = "x-api-key";
          envVar = "ANTHROPIC_API_KEY";
        }
      ];
    };

    nucleus.enable = true;

    user = {
      name = "ixxie";
      authorizedKeys = [
        (builtins.readFile /home/ixxie/.ssh/id_ed25519.pub)
      ];
    };
  };

  environment.systemPackages = [
    inputs.cella.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
