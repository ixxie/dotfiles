# vitro — laptop-side client config.
# Declares the server registry and client preferences. The vitro module
# materializes ~/.config/vitro/servers.toml from this; the vitro CLI
# reads it. No `vitro server add` needed.
{ inputs, ... }: {
  imports = [ inputs.vitro.nixosModules.client ];

  vitro.client = {
    enable = true;
    user = "ixxie";
    servers = {
      grove = "root@95.216.229.121";
    };
  };
}
