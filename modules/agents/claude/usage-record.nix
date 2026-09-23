# corpus:decision/26-09-24-autonomous-usage-stays-under-80-of-the-session-limit
# The laptop's half of the budget guard: the statusLine command that
# records rate_limits so `services.claude-worker` on bacillus (cella's
# hosts/bacillus/flake/worker.nix) has fresh usage data, and so the
# operator's own interactive sessions can see "5h NN% · 7d MM%" too. See
# usage-record.sh for the script itself (byte-identical to bacillus's
# copy) and default.nix / lib.nix for where this is wired in.
{pkgs}:
pkgs.writeShellApplication {
  name = "claude-usage-record";
  runtimeInputs = with pkgs; [jq coreutils];
  text = builtins.readFile ./usage-record.sh;
}
