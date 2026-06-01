# vitro — laptop-side client config.
# Declares the host registry and client preferences. The vitro module
# materializes ~/.config/vitro/hosts.toml from this; the vitro CLI
# reads it. No `vitro host add` needed.
{ inputs, ... }: {
  imports = [ inputs.vitro.nixosModules.client ];

  vitro.client = {
    enable = true;
    user = "ixxie";
    hosts = {
      amoeba = "root@95.216.229.121";
    };
  };
}
