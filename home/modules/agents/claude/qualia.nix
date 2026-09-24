# corpus:article/architecture
{
  lib,
  pkgs,
  ...
}: let
  inherit (import ./lib.nix {inherit lib pkgs;}) mkProfile;
in {
  config.home-manager.users.ixxie = mkProfile {
    dir = ".claude-qualia";
    # The whole profile is work, so the shared qualia skills are simply on.
    # Declared rather than left to `q claude install`, which reaches the same
    # two keys imperatively: a fresh machine then knows where the marketplace
    # is and that the plugin is wanted before `q setup` has ever run.
    #
    # What stays imperative, deliberately: the plugin *payload* (a git clone
    # into plugins/cache, which `claude plugin install` owns and auto-update
    # refreshes) and the agent guard's deny rules (q-tool owns those and
    # revises them; a copy here would be a fork that drifts silently). Both
    # now survive a rebuild, since the settings seed merges.
    settings = {
      extraKnownMarketplaces.qualia = {
        source = {
          source = "git";
          url = "git@gitlab.com:qualia-studios/q-tool.git";
        };
        autoUpdate = true;
      };
      enabledPlugins."q@qualia" = true;
    };
  };
}
