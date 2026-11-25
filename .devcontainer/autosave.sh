#!/usr/bin/env bash
# Saves the student's work to GitHub every 5 minutes, so nothing is lost if the codespace stops.
# Quiet and safe: never fails, never asks anything. Writes its result to ~/.hackathon/save-status
# (the Claude status line shows it). HACKATHON_AUTOSAVE_ONCE=1 runs one round (for tests).
cd "${WORKSPACE_DIR:-$PWD}" 2>/dev/null || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
STATE="${HOME}/.hackathon"; mkdir -p "$STATE"
USER_NAME="${GITHUB_USER:-student}"
git config user.name  "$USER_NAME"
git config user.email "${USER_NAME}@users.noreply.github.com"   # never the student's real email
status() { printf '%s %s\n' "$(date +%s)" "$1" > "$STATE/save-status"; }
push() { if command -v timeout >/dev/null 2>&1; then timeout 60 git push -q origin HEAD >/dev/null 2>&1; else git push -q origin HEAD >/dev/null 2>&1; fi; }
while true; do
  # Files over 50 MB are never saved: GitHub refuses over 100 MB and one such file would block every later save.
  BIG=""
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    grep -qxF "/$f" .git/info/exclude 2>/dev/null || printf '/%s\n' "$f" >> .git/info/exclude
    git rm -q --cached -- "$f" >/dev/null 2>&1 || true
    BIG="$f"
  done < <(find . -type f -size +50M -not -path './.git/*' 2>/dev/null | sed 's|^\./||')
  if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    git add -A >/dev/null 2>&1
    git commit -qm "Autosave" >/dev/null 2>&1
    if push; then status "ok"; else status "failed"; fi
  elif [ ! -f "$STATE/save-status" ] || grep -q ' ok$' "$STATE/save-status"; then
    status "ok"
  fi
  [ -n "$BIG" ] && status "big:$BIG"
  [ -n "${HACKATHON_AUTOSAVE_ONCE:-}" ] && exit 0
  sleep "${HACKATHON_AUTOSAVE_SECONDS:-300}"
done
