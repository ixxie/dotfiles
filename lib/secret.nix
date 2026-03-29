{config, lib, ...}: let
  cfg = config.secretEnv;
in {
  options.secretEnv = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = {};
    description = "Map of sops secret names to environment variable names.";
    example = {"hetzner-api-key" = "HCLOUD_TOKEN";};
  };

  config = lib.mkIf (cfg != {}) {
    sops.secrets = lib.mapAttrs (_: _: {owner = "ixxie";}) cfg;

    # fish
    home-manager.users.ixxie.programs.fish.interactiveShellInit =
      lib.concatStringsSep "\n" (lib.mapAttrsToList (secret: var: ''
        if test -f ${config.sops.secrets.${secret}.path}
          set -gx ${var} (cat ${config.sops.secrets.${secret}.path})
        end
      '') cfg);

    # bash / sh (POSIX shells via /etc/profile)
    environment.extraInit =
      lib.concatStringsSep "\n" (lib.mapAttrsToList (secret: var: ''
        if [ -f "${config.sops.secrets.${secret}.path}" ]; then
          export ${var}="$(cat "${config.sops.secrets.${secret}.path}")"
        fi
      '') cfg);
  };
}
