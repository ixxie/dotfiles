# restic-backup — daily snapshot of contingent's $HOME to amoeba.
#
# Stop-gap design: single repo on amoeba's secondary SSD, accessed over
# SFTP as ixxie@amoeba. Password lives in sops; exclude list is
# hand-curated below. Forget policy keeps 7d/4w/6m.
#
# Restore: `restic -r sftp:ixxie@95.216.229.121:/var/backup/restic/contingent snapshots`
{
  config,
  pkgs,
  ...
}: let
  excludes = pkgs.writeText "restic-excludes" ''
    # caches and per-tool state regenerable on demand
    .cache
    .local/share/Trash
    .mozilla/firefox/*/storage
    .mozilla/firefox/*/cache2
    .mozilla/firefox/*/startupCache
    .config/google-chrome/*/Cache
    .config/google-chrome/*/Code Cache
    .config/zen/*/storage
    .config/zen/*/cache2
    .config/discord/Cache
    .config/discord/Code Cache
    .config/Signal/attachments.noindex
    .npm/_cacache
    .cargo/registry
    .cargo/git
    .rustup/toolchains
    go/pkg
    .pnpm-store
    .bun/install/cache

    # large opaque blobs the user can re-acquire
    temp
    media

    # build artifacts everywhere under repos/
    repos/*/target
    repos/*/result
    repos/*/result-*
    repos/*/node_modules
    repos/*/.direnv
    repos/*/dist
    repos/*/build
    repos/**/target
    repos/**/result
    repos/**/result-*
    repos/**/node_modules
    repos/**/.direnv
    repos/**/dist

    # foss/ is just upstream clones — re-cloneable, large
    repos/foss

    # cella's heavy artifacts
    repos/lab/cella/target

    # vitro env state lives on amoeba already
    repos/lab/cella/.vitro/state
    repos/lab/vitro/.vitro/state

    # nix-related noise
    .nix-profile
    .local/state/nix
  '';

  repo = "sftp:ixxie@95.216.229.121:/var/backup/restic/contingent";

  backupScript = pkgs.writeShellScript "restic-backup-amoeba" ''
    set -euo pipefail

    export RESTIC_PASSWORD_FILE=${config.sops.secrets.restic-password.path}
    export RESTIC_REPOSITORY=${repo}

    ${pkgs.restic}/bin/restic backup \
      --host contingent \
      --tag daily \
      --exclude-file=${excludes} \
      --exclude-caches \
      --one-file-system \
      /home/ixxie

    ${pkgs.restic}/bin/restic forget \
      --keep-daily 7 \
      --keep-weekly 4 \
      --keep-monthly 6 \
      --prune
  '';
in {
  sops.secrets.restic-password = {
    owner = "ixxie";
    mode = "0400";
  };

  systemd.services.restic-backup-amoeba = {
    description = "restic backup of /home/ixxie to amoeba";
    after = ["network-online.target"];
    wants = ["network-online.target"];

    serviceConfig = {
      Type = "oneshot";
      User = "ixxie";
      Group = "users";
      ExecStart = "${backupScript}";
      # don't wedge the laptop if backup runs hot
      Nice = 19;
      IOSchedulingClass = "idle";
      # don't hammer the disk if running on battery — soft check via
      # ConditionACPower (restic-backup.timer gates this too).
    };
  };

  systemd.timers.restic-backup-amoeba = {
    description = "daily restic backup to amoeba";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "03:00";
      Persistent = true;
      RandomizedDelaySec = "30m";
    };
  };
}
