{pkgs, ...}: let
  user = "agent";
in {
  programs.fish.enable = true;
  users.users.${user}.shell = pkgs.fish;
  environment.variables.EDITOR = "nano";

  environment.systemPackages = [
    pkgs.nano
  ];

  environment.etc."claude-code/CLAUDE.md".text = ''
    # Cella Sandboxed Environment

    You are running inside a cella VM — an isolated NixOS microVM with
    proxy-enforced network isolation.

    ## Tools

    This is a minimal NixOS environment. Use `nix shell` to get any tool:

    ```bash
    nix shell nixpkgs#nodejs --command npm test
    nix shell nixpkgs#python3 --command python script.py
    nix shell nixpkgs#jq --command jq '.data' file.json
    ```

    The nix store is shared from the host, so packages load instantly
    if the host already has them.

    Per-project tools are declared in `.cella/flake.nix` and available
    system-wide in the VM.

    Available without nix shell: git, curl, nano, tmux.

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
    - /tmp is limited to 1GB
    - No direct internet — all traffic goes through the proxy
    - Secrets are not available as environment variables

    ## Autonomy

    You are running autonomously in a sandboxed environment. The user is
    not watching. Do not pause to ask for confirmation or clarification —
    make reasonable decisions and keep going. If something fails, debug it,
    try a different approach, or skip it and move on to the next task.

    Track your progress in a TASKS.md file at the project root. Mark tasks
    as done as you complete them. If you reach the end of your current work,
    check TASKS.md for remaining items and continue.

    Commit frequently with clear messages. Each commit should be a working
    state. Do not accumulate large uncommitted changes.

    If you hit a rate limit, your session will automatically resume — just
    pick up where you left off by reading TASKS.md.
  '';

}
