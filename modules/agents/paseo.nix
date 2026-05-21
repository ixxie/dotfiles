{
  inputs,
  config,
  ...
}: let
  paseo = inputs.paseo.packages.x86_64-linux.default;
  paseo-desktop = inputs.paseo.packages.x86_64-linux.desktop;
in {
  imports = [inputs.paseo.nixosModules.paseo];

  services.paseo = {
    enable = true;
    user = "ixxie";
    package = paseo;

    # Demonstrating the new typed relay options from PR #923 (commit 4).
    # `mode = "hosted"` is the default and preserves current behaviour
    # (connect to relay.paseo.sh). Switch to `mode = "remote"` with host/port
    # set to point at a self-hosted relay.
    relay = {
      enable = true;
      mode = "hosted";
    };

    # Declarative ~/.paseo/config.json (PR #923, commit 3). Rendered to JSON
    # via pkgs.formats.json and installed on each service start. Schema is
    # PersistedConfigSchema in packages/server/src/server/persisted-config.ts.
    settings = {
      daemon.mcp = {
        enabled = true;
        injectIntoAgents = false;
      };
      log.file = {
        level = "info";
        path = "/home/ixxie/.paseo/daemon.log";
      };
    };
  };

  # Make PASEO_PASSWORD available to interactive shells (CLI).
  # secretEnv declares the sops secret with owner=ixxie; we reuse that
  # secret in the template below for the systemd unit.
  secretEnv."paseo-password" = "PASEO_PASSWORD";

  sops.templates."paseo.env" = {
    content = ''
      PASEO_PASSWORD=${config.sops.placeholder."paseo-password"}
      OPENROUTER_API_KEY=${config.sops.placeholder."openrouter-api-key"}
    '';
    owner = "ixxie";
  };

  systemd.services.paseo = {
    serviceConfig.EnvironmentFile = config.sops.templates."paseo.env".path;
    # sops re-renders the template when content changes, but doesn't bounce
    # consumers. This forces a restart on switch when the env file changes.
    restartTriggers = [config.sops.templates."paseo.env".content];
  };

  # paseo desktop app (PR #923, commit 5)
  environment.systemPackages = [paseo-desktop];
}
