# The user half: ixxie, the palette, and every module by concern. This is
# what becomes ~/config.
{
  imports = [
    ./theme.nix
    ./user.nix

    # shell
    ./modules/cli.nix
    ./modules/fish.nix
    ./modules/helix.nix
    ./modules/ghostty.nix
    ./modules/yazi.nix

    # desktop
    ./modules/niri.nix
    ./modules/cyberdeck.nix
    ./modules/greeter.nix
    ./modules/voyager/voyager.nix

    # apps
    ./modules/browsers.nix
    ./modules/messaging.nix
    ./modules/proton.nix
    ./modules/media.nix
    ./modules/design.nix
    ./modules/tailscale.nix
    ./modules/torrent.nix

    # dev
    ./modules/git.nix
    ./modules/agents
    #./modules/vitro.nix

    # ops
    ./modules/restic-backup.nix
    ./modules/hetzner.nix
    ./modules/gandi.nix
  ];
}
