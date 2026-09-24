# corpus:article/architecture
# corpus:decision/26-05-21-one-agents-module-for-every-agent
{
  imports = [
    ./claude
    ./codex.nix
    ./opencode.nix
  ];

  secretEnv."openrouter-api-key" = "OPENROUTER_API_KEY";

  # The workstream dev servers (one per agent worktree, behind a front the
  # user runs) get bare names like http://sidebar.corpus.localhost only if an
  # unprivileged process may bind port 80. This is a developer's laptop.
  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 80;
}
