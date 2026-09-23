# claude-usage-record — statusLine command for both the operator's laptop
# (dotfiles) and the bacillus worker (this repo). Reads the statusLine
# hook's JSON off stdin; when `rate_limits` is present (Claude Code
# >=2.1.251, only after the session's first API response) records it
# atomically to $XDG_STATE_HOME/claude/usage.json for the budget guard
# (budget.sh) to read; always prints a one-line status for the status
# line itself. Uses only jq and coreutils. Never fails the status line —
# always exits 0, even if stdin is not JSON or the state dir can't be
# written.
#
# BYTE-IDENTICAL to cella's hosts/bacillus/flake/usage-record.sh (see
# the comment there). Edit one, copy the change to the other verbatim —
# two Nix packages (bacillus's system closure, the operator's home
# profile) wrap this same script text.

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/claude"
usage_file="$state_dir/usage.json"

input="$(cat 2>/dev/null)" || input=""

model="$(printf '%s' "$input" | jq -r '.model.display_name // .model.id // empty' 2>/dev/null)" || model=""
[ -n "$model" ] || model="claude"

rate_limits="$(printf '%s' "$input" | jq -c '.rate_limits // empty' 2>/dev/null)" || rate_limits=""

if [ -n "$rate_limits" ]; then
  mkdir -p "$state_dir" 2>/dev/null || true
  now="$(date +%s)" || now=""
  if [ -n "$now" ]; then
    record="$(jq -n --argjson recorded_at "$now" --argjson rate_limits "$rate_limits" \
      '{recorded_at: $recorded_at, rate_limits: $rate_limits}' 2>/dev/null)" || record=""
    if [ -n "$record" ]; then
      tmp="$(mktemp "$state_dir/usage.json.XXXXXX" 2>/dev/null)" || tmp=""
      if [ -n "$tmp" ]; then
        if printf '%s' "$record" > "$tmp" 2>/dev/null; then
          mv -f "$tmp" "$usage_file" 2>/dev/null || rm -f "$tmp" 2>/dev/null || true
        else
          rm -f "$tmp" 2>/dev/null || true
        fi
      fi
    fi
  fi
fi

five_h_raw="$(printf '%s' "$rate_limits" | jq -r '.five_hour.used_percentage // empty' 2>/dev/null)" || five_h_raw=""
seven_d_raw="$(printf '%s' "$rate_limits" | jq -r '.seven_day.used_percentage // empty' 2>/dev/null)" || seven_d_raw=""

five_h=""
seven_d=""
if [ -n "$five_h_raw" ]; then
  five_h="$(printf '%.0f' "$five_h_raw" 2>/dev/null)" || five_h=""
fi
if [ -n "$seven_d_raw" ]; then
  seven_d="$(printf '%.0f' "$seven_d_raw" 2>/dev/null)" || seven_d=""
fi

if [ -n "$five_h" ] && [ -n "$seven_d" ]; then
  printf '%s — 5h %s%% · 7d %s%%\n' "$model" "$five_h" "$seven_d"
else
  printf '%s\n' "$model"
fi

exit 0
