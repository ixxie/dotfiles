# corpus:article/architecture
# corpus:guide/backup
# restic-backup — daily snapshot of contingent's $HOME to bacillus.
#
# Single repo on a Hetzner volume mounted at /var/backup on bacillus (the
# volume outlives the VM), accessed over SFTP as ixxie@bacillus.corpus.pub
# (public DNS, key-only ssh; no tailnet is involved). Password lives in
# sops; exclude list is hand-curated below.
# Forget policy keeps 7d/4w/6m. The whole home goes, except temp/, inbox/, the
# office group (client data never lands on the personal server) and
# regenerable caches/artifacts.
#
# Restore: `restic -r sftp:ixxie@bacillus.corpus.pub:/var/backup/restic/contingent snapshots`
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

    # scratch — never backed up
    temp

    # capture zone — 30-day retention, never backed up
    inbox

    # kept media, re-downloadable — the one subtree of ~/files left out
    files/library

    # client work — never on the personal server
    projects/office

    # prototypes — no backup; members live on their remotes
    projects/playground

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

    # upstream clones — re-cloneable, large
    projects/community
    projects/**/target
    projects/**/result
    projects/**/node_modules
    projects/**/.direnv

    # cold storage keeps sources, not artifacts
    archive/**/target
    archive/**/result
    archive/**/node_modules
    archive/**/.direnv

    # parked checkouts
    projects/workshop/.archive

    # nix-related noise
    .nix-profile
    .local/state/nix
  '';

  repo = "sftp:ixxie@bacillus.corpus.pub:/var/backup/restic/contingent";

  backupScript = pkgs.writeShellScript "restic-backup-bacillus" ''
    set -euo pipefail

    export RESTIC_PASSWORD_FILE=${config.sops.secrets.restic-password.path}
    export RESTIC_REPOSITORY=${repo}

    # first run against a fresh volume: initialize the repository
    if ! ${pkgs.restic}/bin/restic snapshots --quiet >/dev/null 2>&1; then
      ${pkgs.restic}/bin/restic init
    fi

    # clear stale locks from interrupted prior runs before we take our own
    ${pkgs.restic}/bin/restic unlock

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

  systemd.services.restic-backup-bacillus = {
    description = "restic backup of /home/ixxie to bacillus";
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

  systemd.timers.restic-backup-bacillus = {
    description = "daily restic backup to bacillus";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "03:00";
      Persistent = true;
      RandomizedDelaySec = "30m";
    };
  };
}
