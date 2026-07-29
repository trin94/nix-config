#!/usr/bin/env bash
# Total +/- lines vs HEAD, for the claude-hud statusline (--extra-cmd).
# Prints nothing when outside a repo or when there is nothing to report.

git rev-parse --git-dir >/dev/null 2>&1 || exit 0

git --no-optional-locks diff --numstat HEAD 2>/dev/null | awk '
  $1 ~ /^[0-9]+$/ { add += $1; del += $2 }
  END {
    if (add == 0 && del == 0) exit 0
    if (add > 0) out = "+" add
    if (del > 0) out = (out == "" ? "" : out " ") "-" del
    print out
  }
'
